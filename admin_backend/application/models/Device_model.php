<?php

defined('BASEPATH') or exit('No direct script access allowed');

/**
 * Device_model
 * 
 * Manages device tracking to prevent multi-accounting
 * One account per device enforcement
 */
class Device_model extends CI_Model
{
    public function __construct()
    {
        parent::__construct();
        $this->load->helper('settings');
    }

    /**
     * Register or update device mapping for a user
     * Enforces one account per device if enabled
     * 
     * @param int $user_id
     * @param string $device_id Firebase Device ID
     * @param string $device_type 'android' or 'ios'
     * @param string $device_name Optional device name
     * @return array Status, message, and any conflicts
     */
    public function register_or_update_device($user_id, $device_id, $device_type, $device_name = '')
    {
        $enforcement_enabled = (int)is_settings('device_one_account_enforcement');

        // Check if device already registered
        $existing_device = $this->db->select('*')
                                    ->where('device_id', $device_id)
                                    ->get('tbl_device_mapping')
                                    ->row();

        // If device exists and belongs to different user
        if ($existing_device && $existing_device->user_id != $user_id) {
            if (!$enforcement_enabled) {
                // Just update last login
                $this->update_device_login($device_id);
                return [
                    'status' => 'allowed',
                    'message' => 'Device registered',
                    'enforcement_enabled' => false
                ];
            }

            // Enforcement is enabled - check status
            if ($existing_device->status == 'suspended') {
                return [
                    'status' => 'conflict',
                    'message' => 'This device is suspended',
                    'suspended_user_id' => $existing_device->user_id
                ];
            }

            // Get other accounts on this device
            $other_accounts = $this->db->select('user_id, id')
                                       ->where('device_id', $device_id)
                                       ->where('user_id !=', $user_id)
                                       ->where('status', 'active')
                                       ->get('tbl_device_mapping')
                                       ->result_array();

            if (count($other_accounts) > 0) {
                // Multiple accounts detected
                $action = is_settings('device_suspension_action');

                if ($action == 'suspend') {
                    // Suspend current user
                    $this->db->where('id', $user_id)
                             ->update('tbl_users', ['status' => 'suspended']);

                    // Create fraud record
                    $this->create_fraud_record(
                        $user_id,
                        'multi_account',
                        'Device linked to multiple accounts: ' . json_encode($other_accounts),
                        'critical',
                        'suspend'
                    );

                    // Suspend device mapping for current user attempt
                    $this->create_device_mapping($user_id, $device_id, $device_type, $device_name, 'suspended', 'Multi-account detected');

                    return [
                        'status' => 'suspended',
                        'message' => 'Your account has been suspended due to multi-account activity',
                        'other_accounts' => $other_accounts,
                        'conflict_count' => count($other_accounts)
                    ];
                }
            }
        }

        // Device is clean - register or update
        if ($existing_device) {
            $this->update_device_login($device_id);
        } else {
            $this->create_device_mapping($user_id, $device_id, $device_type, $device_name, 'active');
        }

        return [
            'status' => 'allowed',
            'message' => 'Device registered successfully',
            'device_id' => $device_id
        ];
    }

    /**
     * Create new device mapping
     * 
     * @param int $user_id
     * @param string $device_id
     * @param string $device_type
     * @param string $device_name
     * @param string $status
     * @param string $reason Optional suspension reason
     */
    private function create_device_mapping($user_id, $device_id, $device_type, $device_name = '', $status = 'active', $reason = '')
    {
        $data = [
            'user_id' => $user_id,
            'device_id' => $device_id,
            'device_type' => $device_type,
            'device_name' => $device_name ?: 'Unknown Device',
            'first_login' => date('Y-m-d H:i:s'),
            'last_login' => date('Y-m-d H:i:s'),
            'status' => $status,
            'suspension_reason' => $reason
        ];

        return $this->db->insert('tbl_device_mapping', $data);
    }

    /**
     * Update device last login time
     * 
     * @param string $device_id
     */
    private function update_device_login($device_id)
    {
        $this->db->where('device_id', $device_id)
                 ->update('tbl_device_mapping', [
                     'last_login' => date('Y-m-d H:i:s')
                 ]);
    }

    /**
     * Get all devices for a user
     * 
     * @param int $user_id
     * @return array
     */
    public function get_user_devices($user_id)
    {
        return $this->db->select('*')
                       ->where('user_id', $user_id)
                       ->order_by('last_login', 'DESC')
                       ->get('tbl_device_mapping')
                       ->result_array();
    }

    /**
     * Suspend device
     * 
     * @param int $device_id
     * @param string $reason
     */
    public function suspend_device($device_id, $reason)
    {
        $this->db->where('id', $device_id)
                 ->update('tbl_device_mapping', [
                     'status' => 'suspended',
                     'suspension_reason' => $reason
                 ]);
    }

    /**
     * Get devices with multiple accounts (potential fraud)
     * 
     * @return array
     */
    public function get_devices_with_multiple_accounts()
    {
        return $this->db->select('device_id, COUNT(DISTINCT user_id) as account_count')
                       ->where('status', 'active')
                       ->group_by('device_id')
                       ->having('account_count >', 1)
                       ->get('tbl_device_mapping')
                       ->result_array();
    }

    /**
     * Create fraud record
     * 
     * @param int $user_id
     * @param string $type
     * @param string $reason
     * @param string $severity
     * @param string $action
     */
    private function create_fraud_record($user_id, $type, $reason, $severity, $action)
    {
        $user = $this->db->select('uid')->where('id', $user_id)->get('tbl_users')->row();
        
        $data = [
            'user_id' => $user_id,
            'uid' => $user->uid ?? '',
            'detection_type' => $type,
            'reason' => $reason,
            'severity' => $severity,
            'action_taken' => $action,
            'action_date' => date('Y-m-d H:i:s'),
            'created_at' => date('Y-m-d H:i:s')
        ];

        $this->db->insert('tbl_fraud_detection', $data);
    }
}
