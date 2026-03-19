<?php

defined('BASEPATH') or exit('No direct script access allowed');

use Kreait\Firebase\Factory;
use Kreait\Firebase\Messaging\CloudMessage;

require FCPATH . 'vendor/autoload.php';

class League_Cron_Job extends CI_Controller
{
    public function __construct()
    {
        parent::__construct();
        date_default_timezone_set(get_system_timezone());
    }

    public function index()
    {
        $pre = $this->run_pre_start_notifications();
        $start = $this->run_start_day_notifications();

        $response = [
            'error' => false,
            'message' => 'League cron jobs executed',
            'data' => [
                'pre_start' => $pre,
                'start_day' => $start,
            ],
        ];

        header('Content-Type: application/json');
        echo json_encode($response);
    }

    public function pre_start()
    {
        $result = $this->run_pre_start_notifications();
        $response = ['error' => false, 'message' => 'Pre-start notifications processed', 'data' => $result];
        header('Content-Type: application/json');
        echo json_encode($response);
    }

    public function start_day()
    {
        $result = $this->run_start_day_notifications();
        $response = ['error' => false, 'message' => 'Start-day notifications processed', 'data' => $result];
        header('Content-Type: application/json');
        echo json_encode($response);
    }

    private function run_pre_start_notifications()
    {
        $now = date('Y-m-d H:i:s');
        $next24 = date('Y-m-d H:i:s', strtotime('+24 hours'));

        $leagues = $this->db->where('status', 1)
            ->where('start_date >=', $now)
            ->where('start_date <=', $next24)
            ->get('tbl_league')
            ->result_array();

        $summary = [
            'processed_leagues' => count($leagues),
            'users_sent' => 0,
            'users_failed' => 0,
            'users_skipped' => 0,
        ];

        foreach ($leagues as $league) {
            $stats = $this->process_league_notifications(
                (int)$league['id'],
                'pre-league',
                'League starts in less than 24 hours',
                'Your league "' . $league['name'] . '" is starting soon. Join and play daily to climb the leaderboard.'
            );

            $summary['users_sent'] += $stats['sent'];
            $summary['users_failed'] += $stats['failed'];
            $summary['users_skipped'] += $stats['skipped'];
        }

        return $summary;
    }

    private function run_start_day_notifications()
    {
        $today = date('Y-m-d');
        $now = date('Y-m-d H:i:s');

        $leagues = $this->db->where('status', 1)
            ->where('DATE(start_date) =', $today)
            ->where('start_date <=', $now)
            ->where('end_date >=', $now)
            ->get('tbl_league')
            ->result_array();

        $summary = [
            'processed_leagues' => count($leagues),
            'users_sent' => 0,
            'users_failed' => 0,
            'users_skipped' => 0,
        ];

        foreach ($leagues as $league) {
            $stats = $this->process_league_notifications(
                (int)$league['id'],
                'start-day',
                'League is live now',
                'Your league "' . $league['name'] . '" has started. Play your daily quiz and secure today\'s best score.'
            );

            $summary['users_sent'] += $stats['sent'];
            $summary['users_failed'] += $stats['failed'];
            $summary['users_skipped'] += $stats['skipped'];
        }

        return $summary;
    }

    private function process_league_notifications($league_id, $notification_type, $title, $body)
    {
        $stats = ['sent' => 0, 'failed' => 0, 'skipped' => 0];

        $users = $this->db->select('lu.user_id, lu.device_token, lu.notifications_enabled, u.fcm_id, u.web_fcm_id')
            ->from('tbl_league_user lu')
            ->join('tbl_users u', 'u.id = lu.user_id', 'inner')
            ->where('lu.league_id', $league_id)
            ->where_in('lu.status', ['opt-in', 'active'])
            ->get()
            ->result_array();

        foreach ($users as $user) {
            $user_id = (int)$user['user_id'];

            if ((int)$user['notifications_enabled'] !== 1) {
                $this->insert_log_if_absent($league_id, $user_id, $notification_type, 'skipped', null, null, 'notifications_disabled');
                $stats['skipped']++;
                continue;
            }

            if ($this->is_already_sent($league_id, $user_id, $notification_type)) {
                $stats['skipped']++;
                continue;
            }

            $tokens = $this->collect_tokens($user);
            if (empty($tokens)) {
                $this->insert_log_if_absent($league_id, $user_id, $notification_type, 'failed', null, null, 'no_device_token');
                $stats['failed']++;
                continue;
            }

            try {
                $payload = [
                    'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
                    'type' => 'league',
                    'notification_type' => $notification_type,
                    'league_id' => (string)$league_id,
                    'title' => $title,
                    'body' => $body,
                ];

                $factory = (new Factory)->withServiceAccount('assets/firebase_config.json');
                $messaging = $factory->createMessaging();
                $tokenChunks = array_chunk($tokens, 500);

                foreach ($tokenChunks as $chunk) {
                    $message = CloudMessage::new();
                    $message = $message->withNotification($payload)->withData($payload);
                    $messaging->sendMulticast($message, $chunk);
                }

                $this->log_notification($league_id, $user_id, $notification_type, 'sent', date('Y-m-d H:i:s'), implode(',', $tokens), null);
                $stats['sent']++;
            } catch (Exception $e) {
                $this->log_notification($league_id, $user_id, $notification_type, 'failed', null, implode(',', $tokens), $e->getMessage());
                $stats['failed']++;
            }
        }

        return $stats;
    }

    private function collect_tokens($user)
    {
        $all = [];

        $candidates = [
            isset($user['device_token']) ? $user['device_token'] : '',
            isset($user['fcm_id']) ? $user['fcm_id'] : '',
            isset($user['web_fcm_id']) ? $user['web_fcm_id'] : '',
        ];

        foreach ($candidates as $raw) {
            if (empty($raw) || $raw === 'empty') {
                continue;
            }
            $parts = explode(',', $raw);
            foreach ($parts as $part) {
                $token = trim($part);
                if (!empty($token) && strtolower($token) !== 'empty') {
                    $all[] = $token;
                }
            }
        }

        return array_values(array_unique($all));
    }

    private function is_already_sent($league_id, $user_id, $notification_type)
    {
        $sent = $this->db->where('league_id', $league_id)
            ->where('user_id', $user_id)
            ->where('notification_type', $notification_type)
            ->where('status', 'sent')
            ->limit(1)
            ->get('tbl_league_notification_log')
            ->row_array();

        return !empty($sent);
    }

    private function insert_log_if_absent($league_id, $user_id, $notification_type, $status, $sent_at, $device_token, $error_message)
    {
        $exists = $this->db->where('league_id', $league_id)
            ->where('user_id', $user_id)
            ->where('notification_type', $notification_type)
            ->where('status', $status)
            ->where('DATE(date_created) =', date('Y-m-d'))
            ->limit(1)
            ->get('tbl_league_notification_log')
            ->row_array();

        if (empty($exists)) {
            $this->log_notification($league_id, $user_id, $notification_type, $status, $sent_at, $device_token, $error_message);
        }
    }

    private function log_notification($league_id, $user_id, $notification_type, $status, $sent_at, $device_token, $error_message)
    {
        $data = [
            'league_id' => (int)$league_id,
            'user_id' => (int)$user_id,
            'notification_type' => $notification_type,
            'status' => $status,
            'sent_at' => $sent_at,
            'device_token' => $device_token,
            'error_message' => $error_message,
            'date_created' => date('Y-m-d H:i:s'),
        ];

        $this->db->insert('tbl_league_notification_log', $data);
     }
 }
