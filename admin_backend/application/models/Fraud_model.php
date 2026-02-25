<?php

defined('BASEPATH') or exit('No direct script access allowed');

/**
 * Fraud_model
 * 
 * Detects suspicious activities and manages fraud prevention
 */
class Fraud_model extends CI_Model
{
    public function __construct()
    {
        parent::__construct();
        $this->load->helper('settings');
    }

    /**
     * Evaluate user activity for fraud indicators
     * Applies multiple detection rules
     * 
     * @param int $user_id
     * @param string $action_type 'ad_watch', 'quiz_complete', 'payout_request'
     * @param array $metadata Additional context
     * @return array Detection results with severity
     */
    public function evaluate_user_activity($user_id, $action_type, $metadata = [])
    {
        $detections = [];

        // Rule 1: AD SPAM (exceeds daily limit)
        if ($action_type == 'ad_watch' || $action_type == 'quiz_complete') {
            $ad_check = $this->check_ad_spam($user_id);
            if ($ad_check['is_suspicious']) {
                $detections[] = $ad_check;
            }
        }

        // Rule 2: QUIZ CHEATING (perfect accuracy + unrealistic speed)
        if ($action_type == 'quiz_complete' && !empty($metadata)) {
            $quiz_check = $this->check_quiz_cheating($user_id, $metadata);
            if ($quiz_check['is_suspicious']) {
                $detections[] = $quiz_check;
            }
        }

        // Rule 3: NEW ACCOUNT INSTANT WITHDRAWAL
        if ($action_type == 'payout_request') {
            $withdrawal_check = $this->check_instant_withdrawal($user_id);
            if ($withdrawal_check['is_suspicious']) {
                $detections[] = $withdrawal_check;
            }
        }

        // Record all detections
        foreach ($detections as $detection) {
            $this->log_fraud_detection($user_id, $detection);
        }

        return [
            'is_suspicious' => count($detections) > 0,
            'detections' => $detections,
            'total_detections' => count($detections),
            'action' => count($detections) > 0 ? 'review' : 'allow',
            'highest_severity' => count($detections) > 0
                ? $this->get_highest_severity($detections)
                : 'none'
        ];
    }

    /**
     * Check for ad spam (excessive ad watching)
     * 
     * @param int $user_id
     * @return array
     */
    private function check_ad_spam($user_id)
    {
        $daily_ad_limit = (int)is_settings('fraud_daily_ad_limit');
        $today = date('Y-m-d');

        // Count ads watched today
        $ads_today = $this->db->select('COUNT(*) as count')
            ->where('user_id', $user_id)
            ->where("DATE(date) = '$today'")
            ->where("type = 'watchedAds'")
            ->get('tbl_tracker')
            ->row()
            ->count;

        if ($ads_today >= $daily_ad_limit) {
            return [
                'is_suspicious' => true,
                'type' => 'ad_spam',
                'severity' => 'high',
                'reason' => "Exceeded daily ad limit: $ads_today/$daily_ad_limit",
                'metadata' => ['ad_count' => $ads_today, 'limit' => $daily_ad_limit]
            ];
        }

        return ['is_suspicious' => false];
    }

    /**
     * Check for quiz cheating (suspicious accuracy/speed pattern)
     * 
     * @param int $user_id
     * @param array $metadata Quiz stats
     * @return array
     */
    private function check_quiz_cheating($user_id, $metadata)
    {
        $accuracy = (int)($metadata['accuracy'] ?? 0);
        $avg_time = (int)($metadata['avg_answer_time'] ?? 0);

        $accuracy_threshold = (int)is_settings('fraud_quiz_accuracy_threshold');
        $speed_threshold = (int)is_settings('fraud_quiz_speed_seconds');

        if ($accuracy >= $accuracy_threshold && $avg_time <= $speed_threshold) {
            return [
                'is_suspicious' => true,
                'type' => 'quiz_speed',
                'severity' => 'high',
                'reason' => "Perfect accuracy ($accuracy%) with impossible speed ($avg_time sec)",
                'metadata' => [
                    'accuracy' => $accuracy,
                    'avg_answer_time' => $avg_time,
                    'accuracy_threshold' => $accuracy_threshold,
                    'speed_threshold' => $speed_threshold
                ]
            ];
        }

        return ['is_suspicious' => false];
    }

    /**
     * Check for new account instant withdrawal
     * 
     * @param int $user_id
     * @return array
     */
    private function check_instant_withdrawal($user_id)
    {
        $min_days = (int)is_settings('fraud_new_account_withdrawal_days');

        // Get user creation date
        $user = $this->db->select('created')->where('id', $user_id)->get('tbl_users')->row();

        if (!$user) {
            return ['is_suspicious' => false];
        }

        $created_date = strtotime($user->created);
        $today = strtotime(date('Y-m-d'));
        $age_days = ceil(($today - $created_date) / 86400);

        if ($age_days < $min_days) {
            return [
                'is_suspicious' => true,
                'type' => 'instant_withdraw',
                'severity' => 'medium',
                'reason' => "Payout request within $age_days days of account creation (min: $min_days)",
                'metadata' => ['account_age_days' => $age_days, 'min_days' => $min_days]
            ];
        }

        return ['is_suspicious' => false];
    }

    /**
     * Log fraud detection to database
     * 
     * @param int $user_id
     * @param array $detection
     */
    private function log_fraud_detection($user_id, $detection)
    {
        $user = $this->db->select('uid, type')->where('id', $user_id)->get('tbl_users')->row();

        // Embed auth provider so admin can identify OAuth accounts at a glance
        $meta = $detection['metadata'] ?? [];
        $meta['auth_provider'] = $user->type ?? 'unknown';

        $data = [
            'user_id' => $user_id,
            'uid' => $user->uid ?? '',
            'detection_type' => $detection['type'],
            'reason' => $detection['reason'],
            'severity' => $detection['severity'],
            'action_taken' => 'review',
            'metadata' => json_encode($meta),
            'created_at' => date('Y-m-d H:i:s')
        ];

        $this->db->insert('tbl_fraud_detection', $data);
    }

    /**
     * Get highest severity level
     * 
     * @param array $detections
     * @return string
     */
    private function get_highest_severity($detections)
    {
        $severity_order = ['critical' => 4, 'high' => 3, 'medium' => 2, 'low' => 1];
        $highest = 'low';
        $highest_score = 0;

        foreach ($detections as $detection) {
            $score = $severity_order[$detection['severity']] ?? 0;
            if ($score > $highest_score) {
                $highest_score = $score;
                $highest = $detection['severity'];
            }
        }

        return $highest;
    }

    /**
     * Get fraud detections for admin review
     * 
     * @param string $status 'review', 'warning', 'suspend', 'resolved'
     * @param int $limit
     * @param int $offset
     * @return array
     */
    public function get_detections_for_review($status = 'review', $limit = 20, $offset = 0)
    {
        $query = $this->db->select('fd.*, tu.name, tu.email, tu.coins, tu.type as auth_provider')
            ->from('tbl_fraud_detection fd')
            ->join('tbl_users tu', 'fd.user_id = tu.id', 'left')
            ->where('fd.action_taken', $status)
            ->where('fd.resolved', 0);

        $total = $query->count_all_results(false);

        $results = $query->order_by('fd.severity', 'DESC')
            ->order_by('fd.created_at', 'DESC')
            ->limit($limit, $offset)
            ->get()
            ->result_array();

        return [
            'data' => $results,
            'total' => $total,
            'limit' => $limit,
            'offset' => $offset
        ];
    }

    /**
     * Update fraud record status and take action
     * 
     * @param int $detection_id
     * @param string $action 'none', 'warning', 'suspend'
     * @param string $notes
     * @return bool
     */
    public function resolve_detection($detection_id, $action = 'none', $notes = '')
    {
        $data = [
            'action_taken' => $action,
            'action_date' => date('Y-m-d H:i:s'),
            'resolved' => 1,
            'resolved_at' => date('Y-m-d H:i:s'),
            'resolution_notes' => $notes
        ];

        return $this->db->where('id', $detection_id)
            ->update('tbl_fraud_detection', $data);
    }

    /**
     * Get detection statistics
     * 
     * @return array
     */
    public function get_fraud_statistics()
    {
        $stats = [
            'total_detections' => $this->db->count_all('tbl_fraud_detection'),
            'unresolved' => $this->db->where('resolved', 0)
                ->count_all_results('tbl_fraud_detection'),
            'by_type' => $this->db->select('detection_type, COUNT(*) as count')
                ->group_by('detection_type')
                ->get('tbl_fraud_detection')
                ->result_array(),
            'by_severity' => $this->db->select('severity, COUNT(*) as count')
                ->group_by('severity')
                ->get('tbl_fraud_detection')
                ->result_array(),
            'resolved_count' => $this->db->where('resolved', 1)
                ->count_all_results('tbl_fraud_detection')
        ];

        return $stats;
    }

    /**
     * Check signup fraud signals for a new user registration.
     *
     * Runs lightweight checks that are possible at signup time:
     *   1. IP flood: too many signups from this IP today (via tbl_referrals records)
     *   2. Referral daily abuse: referrer has exceeded max-per-day threshold
     *   3. Referral IP abuse: same IP used too many times on this referral code
     *
     * POLICY: All detections are logged for admin review. This method NEVER disables
     * an account — that decision belongs to a human admin.
     *
     * @param int    $user_id       Newly created user id
     * @param string $signup_ip     IP address detected at signup
     * @param string $referrer_id   Referrer user_id if a friends_code was used (0/'')
     * @return array ['flagged' => bool, 'rules_triggered' => string[]]
     */
    public function check_signup_fraud($user_id, $signup_ip, $referrer_id = 0)
    {
        $rules_triggered = [];

        // ── Rule 1: IP flood check ────────────────────────────────────────────
        // Count signups from this IP recorded in tbl_referrals today
        $check_ip = $this->db->where('type', 'referral_block_same_ip')->get('tbl_settings')->row();
        if ($check_ip && $check_ip->message == '1' && !empty($signup_ip)) {
            $max_row = $this->db->where('type', 'referral_same_ip_max_count')->get('tbl_settings')->row();
            $max_ip  = $max_row ? (int)$max_row->message : 2;

            $ip_count = $this->db->where('signup_ip', $signup_ip)
                                  ->where('DATE(signup_date)', date('Y-m-d'))
                                  ->count_all_results('tbl_referrals');

            error_log('[SIGNUP-FRAUD] IP ' . $signup_ip . ': ' . $ip_count . ' referral signups today (max ' . $max_ip . ')');

            if ($ip_count >= $max_ip) {
                $rules_triggered[] = 'ip_flood';
                $this->log_fraud_detection($user_id, [
                    'type'     => 'signup_ip_flood',
                    'reason'   => 'IP ' . $signup_ip . ' has ' . ($ip_count + 1) . ' signups today (max ' . $max_ip . ')',
                    'severity' => 'medium',
                    'metadata' => ['signup_ip' => $signup_ip, 'count' => $ip_count + 1, 'max' => $max_ip]
                ]);
            }
        }

        // ── Rule 2 & 3: Referral-specific checks (only when a code was used) ──
        if (!empty($referrer_id) && $referrer_id > 0) {
            // Rule 2: Referrer daily cap
            $daily_row = $this->db->where('type', 'referral_max_per_day')->get('tbl_settings')->row();
            $max_day   = $daily_row ? (int)$daily_row->message : 5;

            $today_referrals = $this->db->where('referrer_id', $referrer_id)
                                         ->where('DATE(signup_date)', date('Y-m-d'))
                                         ->count_all_results('tbl_referrals');

            error_log('[SIGNUP-FRAUD] Referrer ' . $referrer_id . ': ' . $today_referrals . ' referrals today (max ' . $max_day . ')');

            if ($today_referrals >= $max_day) {
                $rules_triggered[] = 'referral_daily_cap';
                $this->log_fraud_detection($user_id, [
                    'type'     => 'referral_daily_cap_exceeded',
                    'reason'   => 'Referrer ' . $referrer_id . ' has ' . ($today_referrals + 1) . ' referrals today (max ' . $max_day . ')',
                    'severity' => 'medium',
                    'metadata' => ['referrer_id' => $referrer_id, 'today_count' => $today_referrals + 1, 'max' => $max_day]
                ]);
            }

            // Rule 3: Same IP on same referral code
            if (!empty($signup_ip)) {
                $ip_ref_count = $this->db->where('referrer_id', $referrer_id)
                                          ->where('signup_ip', $signup_ip)
                                          ->count_all_results('tbl_referrals');

                $max_ip_ref_row = $this->db->where('type', 'referral_same_ip_max_count')->get('tbl_settings')->row();
                $max_ip_ref    = $max_ip_ref_row ? (int)$max_ip_ref_row->message : 2;

                error_log('[SIGNUP-FRAUD] Referrer ' . $referrer_id . ' + IP ' . $signup_ip . ': ' . $ip_ref_count . ' sign-ups (max ' . $max_ip_ref . ')');

                if ($ip_ref_count >= $max_ip_ref) {
                    $rules_triggered[] = 'referral_ip_duplicate';
                    $this->log_fraud_detection($user_id, [
                        'type'     => 'referral_ip_duplicate',
                        'reason'   => 'IP ' . $signup_ip . ' used ' . ($ip_ref_count + 1) . 'x with referrer ' . $referrer_id . ' (max ' . $max_ip_ref . ')',
                        'severity' => 'high',
                        'metadata' => ['referrer_id' => $referrer_id, 'signup_ip' => $signup_ip, 'count' => $ip_ref_count + 1, 'max' => $max_ip_ref]
                    ]);
                }
            }
        }

        $flagged = !empty($rules_triggered);
        if ($flagged) {
            error_log('[SIGNUP-FRAUD] ⚠️  User ' . $user_id . ' flagged at signup. Rules: ' . implode(', ', $rules_triggered) . '. Logged for admin review — account NOT disabled.');
        } else {
            error_log('[SIGNUP-FRAUD] ✅ User ' . $user_id . ' passed all signup fraud checks.');
        }

        return [
            'flagged'         => $flagged,
            'rules_triggered' => $rules_triggered
        ];
    }
}
