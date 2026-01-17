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
        if (!$this->session->userdata('isLoggedIn')) {
            redirect('/');
        }

        if ($this->input->post('btnupdate')) {
            if (!ALLOW_MODIFICATION) {
                $this->session->set_flashdata('error', lang('Modification_in_demo_version_is_not_allowed'));
                redirect('daily-streak-settings');
            }

            $this->update_settings();
            $this->session->set_flashdata('success', 'Daily Streak settings updated successfully');
            redirect('daily-streak-settings');
        }

        $data['daily_streak_coin_reward'] = $this->db->where('type', 'daily_streak_coin_reward')->get('tbl_settings')->row_array();
        $data['daily_streak_multiplier_enable'] = $this->db->where('type', 'daily_streak_multiplier_enable')->get('tbl_settings')->row_array();
        $data['daily_streak_bonus_threshold'] = $this->db->where('type', 'daily_streak_bonus_threshold')->get('tbl_settings')->row_array();
        $data['daily_streak_bonus_coin'] = $this->db->where('type', 'daily_streak_bonus_coin')->get('tbl_settings')->row_array();

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

        foreach ($settings as $name => $value) {
            $this->db->where('type', $name)
                     ->update('tbl_settings', ['message' => $value]);
        }
    }
}
