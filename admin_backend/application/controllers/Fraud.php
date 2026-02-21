<?php

defined('BASEPATH') or exit('No direct script access allowed');

/**
 * Fraud Controller
 * 
 * Manages fraud detection and suspicious activity review
 */
class Fraud extends CI_Controller
{
    public function __construct()
    {
        parent::__construct();
        $this->load->model('Fraud_model');
    }

    /**
     * Fraud Detection Dashboard
     */
    public function index()
    {
        if (!has_permissions('read', 'fraud_detection')) {
            redirect('/');
        }

        // Get unresolved detections
        $limit = 20;
        $page = $this->input->get('page') ?? 0;
        $offset = $page * $limit;

        $detections = $this->Fraud_model->get_detections_for_review('review', $limit, $offset);
        $stats = $this->Fraud_model->get_fraud_statistics();

        $data['detections'] = $detections['data'];
        $data['total'] = $detections['total'];
        $data['limit'] = $limit;
        $data['current_page'] = $page;
        $data['total_pages'] = ceil($detections['total'] / $limit);
        $data['stats'] = $stats;

        // Thresholds for reference
        $data['daily_ad_limit'] = is_settings('fraud_daily_ad_limit');
        $data['accuracy_threshold'] = is_settings('fraud_quiz_accuracy_threshold');
        $data['speed_threshold'] = is_settings('fraud_quiz_speed_seconds');
        $data['withdrawal_wait_days'] = is_settings('fraud_new_account_withdrawal_days');

        $this->load->view('fraud_detection_dashboard', $data);
    }

    /**
     * Get detections for AJAX
     */
    public function get_detections()
    {
        if (!has_permissions('read', 'fraud_detection')) {
            echo json_encode(['success' => false, 'message' => 'No permission']);
            return;
        }

        $status = $this->input->post('status') ?? 'review';
        $limit = $this->input->post('limit') ?? 20;
        $offset = $this->input->post('offset') ?? 0;

        $detections = $this->Fraud_model->get_detections_for_review($status, $limit, $offset);

        echo json_encode([
            'success' => true,
            'data' => $detections['data'],
            'total' => $detections['total']
        ]);
    }

    /**
     * Resolve fraud detection
     */
    public function resolve_detection()
    {
        if (!has_permissions('update', 'fraud_detection')) {
            echo json_encode(['success' => false, 'message' => 'No permission']);
            return;
        }

        $detection_id = $this->input->post('detection_id');
        $action = $this->input->post('action');  // 'none', 'warning', 'suspend'
        $notes = $this->input->post('notes') ?? '';

        $result = $this->Fraud_model->resolve_detection($detection_id, $action, $notes);

        if ($result && $action == 'suspend') {
            // Get user_id and auth provider from detection
            $detection = $this->db->select('fd.user_id, tu.type as auth_provider')
                ->from('tbl_fraud_detection fd')
                ->join('tbl_users tu', 'fd.user_id = tu.id', 'left')
                ->where('fd.id', $detection_id)
                ->get()
                ->row();

            if ($detection) {
                // OAuth accounts (Google, Apple) must not be suspended automatically.
                // Firebase verifies the identity of these users; a fraud flag may be
                // a false positive from the quiz-speed check. Force a warning instead
                // and inform the admin — they can deactivate from the Users table
                // if they have absolute certainty of fraud.
                $oauth_types = ['gmail', 'apple'];
                if (in_array($detection->auth_provider, $oauth_types)) {
                    // Downgrade to warning and tell the admin
                    $this->Fraud_model->resolve_detection($detection_id, 'warning', 'OAuth account — auto-downgraded from suspend. Verify manually before deactivating.');
                    echo json_encode([
                        'success' => false,
                        'message' => 'Cannot auto-suspend OAuth-verified account (' . strtoupper($detection->auth_provider) . '). Action downgraded to Warning. Deactivate from the Users table only after manual review.',
                        'downgraded' => true,
                        'auth_provider' => $detection->auth_provider
                    ]);
                    return;
                }

                $this->db->where('id', $detection->user_id)
                    ->update('tbl_users', ['status' => 'suspended']);
            }
        }

        echo json_encode([
            'success' => $result,
            'message' => $result ? 'Detection resolved' : 'Failed to resolve'
        ]);
    }

    /**
     * View detection details
     */
    public function view_detection()
    {
        if (!has_permissions('read', 'fraud_detection')) {
            show_404();
        }

        $detection_id = $this->input->get('id');
        $detection = $this->db->select('fd.*, tu.name, tu.email, tu.coins, tu.created')
            ->from('tbl_fraud_detection fd')
            ->join('tbl_users tu', 'fd.user_id = tu.id')
            ->where('fd.id', $detection_id)
            ->get()
            ->row_array();

        if (!$detection) {
            show_404();
        }

        // Get user's activity
        $data['detection'] = $detection;
        $data['user_activity'] = $this->db->select('*')
            ->where('user_id', $detection['user_id'])
            ->order_by('date', 'DESC')
            ->limit(20)
            ->get('tbl_tracker')
            ->result_array();

        $this->load->view('fraud_detection_detail', $data);
    }

    /**
     * Update fraud detection settings (thresholds)
     */
    public function update_settings()
    {
        if (!has_permissions('update', 'fraud_detection')) {
            echo json_encode(['success' => false, 'message' => 'No permission']);
            return;
        }

        $settings = [
            'fraud_daily_ad_limit' => $this->input->post('fraud_daily_ad_limit'),
            'fraud_quiz_accuracy_threshold' => $this->input->post('fraud_quiz_accuracy_threshold'),
            'fraud_quiz_speed_seconds' => $this->input->post('fraud_quiz_speed_seconds'),
            'fraud_new_account_withdrawal_days' => $this->input->post('fraud_new_account_withdrawal_days'),
            'fraud_auto_review_threshold' => $this->input->post('fraud_auto_review_threshold')
        ];

        foreach ($settings as $name => $value) {
            $this->db->where('setting_name', $name)
                ->update('tbl_settings', ['setting_value' => $value]);
        }

        echo json_encode(['success' => true, 'message' => 'Thresholds updated']);
    }

    /**
     * Get fraud statistics
     */
    public function get_statistics()
    {
        if (!has_permissions('read', 'fraud_detection')) {
            echo json_encode(['success' => false]);
            return;
        }

        $stats = $this->Fraud_model->get_fraud_statistics();

        echo json_encode([
            'success' => true,
            'data' => $stats
        ]);
    }
}
