<?php

defined('BASEPATH') or exit('No direct script access allowed');

/**
 * Device Controller
 * 
 * Manages device tracking and multi-account prevention
 */
class Device extends CI_Controller
{
    public function __construct()
    {
        parent::__construct();
        $this->load->model('Device_model');
    }

    /**
     * Admin panel - Device Management Dashboard
     */
    public function index()
    {
        if (!has_permissions('read', 'device_management')) {
            redirect('/');
        }

        // Get devices with multiple accounts
        $data['multi_account_devices'] = $this->Device_model->get_devices_with_multiple_accounts();

        // Get recent device registrations
        $data['recent_devices'] = $this->db->select('dm.*, tu.name, tu.email')
                                           ->from('tbl_device_mapping dm')
                                           ->join('tbl_users tu', 'dm.user_id = tu.id')
                                           ->order_by('dm.last_login', 'DESC')
                                           ->limit(50)
                                           ->get()
                                           ->result_array();

        // Settings
        $data['device_enforcement_enabled'] = is_settings('device_one_account_enforcement');
        $data['suspension_action'] = is_settings('device_suspension_action');

        $this->load->view('device_management', $data);
    }

    /**
     * Update device enforcement settings
     */
    public function update_settings()
    {
        if (!has_permissions('update', 'device_management')) {
            echo json_encode(['success' => false, 'message' => 'No permission']);
            return;
        }

        $enforcement = $this->input->post('device_one_account_enforcement') ? 1 : 0;
        $action = $this->input->post('device_suspension_action');

        $this->db->where('setting_name', 'device_one_account_enforcement')
                 ->update('tbl_settings', ['setting_value' => $enforcement]);

        $this->db->where('setting_name', 'device_suspension_action')
                 ->update('tbl_settings', ['setting_value' => $action]);

        echo json_encode(['success' => true, 'message' => 'Settings updated']);
    }

    /**
     * Suspend device
     */
    public function suspend_device()
    {
        if (!has_permissions('update', 'device_management')) {
            echo json_encode(['success' => false, 'message' => 'No permission']);
            return;
        }

        $device_id = $this->input->post('device_id');
        $reason = $this->input->post('reason');

        $this->Device_model->suspend_device($device_id, $reason);

        echo json_encode(['success' => true, 'message' => 'Device suspended']);
    }

    /**
     * Get user's devices
     */
    public function get_user_devices()
    {
        $user_id = $this->input->post('user_id');
        $devices = $this->Device_model->get_user_devices($user_id);

        echo json_encode([
            'success' => true,
            'devices' => $devices,
            'count' => count($devices)
        ]);
    }
}
