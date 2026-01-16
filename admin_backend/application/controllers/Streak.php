<?php

defined('BASEPATH') or exit('No direct script access allowed');

/**
 * Streak Controller
 * 
 * Manages daily login streaks via Admin Panel
 * API endpoints in Api.php will call these methods
 */
class Streak extends CI_Controller
{
    public function __construct()
    {
        parent::__construct();
        $this->load->model('Streak_model');
    }

    /**
     * Admin panel page for streak settings
     */
    public function index()
    {
        if (!has_permissions('read', 'daily_streak_settings')) {
            redirect('/');
        }

        if ($this->input->post('btnupdate')) {
            if (!has_permissions('update', 'daily_streak_settings')) {
                $this->session->set_flashdata('error', lang('permission_denied'));
                redirect('daily-streak-settings');
            }

            $this->update_settings();
            $this->session->set_flashdata('success', lang('data_updated_successfully'));
            redirect('daily-streak-settings');
        }

        $data['streak_coin_reward'] = is_settings('daily_streak_coin_reward');
        $data['streak_multiplier_enable'] = is_settings('daily_streak_multiplier_enable');
        $data['streak_bonus_threshold'] = is_settings('daily_streak_bonus_threshold');
        $data['streak_bonus_coin'] = is_settings('daily_streak_bonus_coin');

        // Get statistics
        $data['total_active_streaks'] = $this->db->where('streak_count >', 0)
                                                 ->count_all_results('tbl_daily_streak');
        $data['avg_streak'] = $this->db->select_avg('streak_count')
                                       ->get('tbl_daily_streak')
                                       ->row()
                                       ->streak_count;

        $this->load->view('daily_streak_settings', $data);
    }

    /**
     * Get top streaks for leaderboard
     */
    public function get_top_streaks()
    {
        $limit = $this->input->post('limit') ?? 10;
        $streaks = $this->Streak_model->get_top_streaks($limit);

        echo json_encode([
            'success' => true,
            'data' => $streaks
        ]);
    }

    /**
     * Update streak settings
     */
    private function update_settings()
    {
        $settings = [
            'daily_streak_coin_reward' => $this->input->post('daily_streak_coin_reward'),
            'daily_streak_multiplier_enable' => $this->input->post('daily_streak_multiplier_enable'),
            'daily_streak_bonus_threshold' => $this->input->post('daily_streak_bonus_threshold'),
            'daily_streak_bonus_coin' => $this->input->post('daily_streak_bonus_coin')
        ];

        $this->db->set('setting_value', 'CASE setting_name', false);
        foreach ($settings as $name => $value) {
            $this->db->set("WHEN '$name' THEN '$value'", null, false);
        }
        $this->db->set('setting_value', 'setting_value', false);
        $this->db->where_in('setting_name', array_keys($settings));
        $this->db->update('tbl_settings');
    }
}
