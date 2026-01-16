<?php

defined('BASEPATH') or exit('No direct script access allowed');

/**
 * Streak_model
 * 
 * Handles daily login streak tracking and coin rewards
 */
class Streak_model extends CI_Model
{
    public function __construct()
    {
        parent::__construct();
        $this->load->model('User_model');
        $this->load->helper('settings');
    }

    /**
     * Handle daily login - increment streak or reset
     * 
     * @param int $user_id
     * @param string $firebase_id
     * @return array Streak info with coins earned
     */
    public function handle_daily_login($user_id, $firebase_id)
    {
        $today = date('Y-m-d');
        
        // Get existing streak record
        $existing = $this->db->select('last_login_date, streak_count, max_streak')
                             ->where('user_id', $user_id)
                             ->get('tbl_daily_streak')
                             ->row();

        // Check if already logged in today
        if ($existing && $existing->last_login_date == $today) {
            return [
                'streak_count' => $existing->streak_count,
                'coins_earned' => 0,
                'max_streak' => $existing->max_streak,
                'bonus_unlocked' => false,
                'bonus_coin' => 0,
                'message' => 'Already logged in today'
            ];
        }

        // Check if streak continues (logged in yesterday)
        $yesterday = date('Y-m-d', strtotime('-1 day'));
        $streak_continued = $existing && $existing->last_login_date == $yesterday;

        // Calculate new streak
        $new_streak = $streak_continued ? ($existing->streak_count + 1) : 1;
        $current_max = $existing ? $existing->max_streak : 0;
        $new_max = max($new_streak, $current_max);

        // Get configurable coin rewards
        $daily_coin_reward = (int)is_settings('daily_streak_coin_reward');
        $bonus_threshold = (int)is_settings('daily_streak_bonus_threshold');
        $bonus_coin = (int)is_settings('daily_streak_bonus_coin');

        // Calculate total coins for today
        $coins_earned = $daily_coin_reward;
        $bonus_unlocked = false;
        $bonus_earned = 0;

        // Check if milestone reached
        if ($bonus_threshold > 0 && $new_streak % $bonus_threshold == 0) {
            $bonus_unlocked = true;
            $bonus_earned = $bonus_coin;
            $coins_earned += $bonus_coin;
        }

        // Update or create streak record
        $update_data = [
            'user_id' => $user_id,
            'uid' => $firebase_id,
            'last_login_date' => $today,
            'streak_count' => $new_streak,
            'max_streak' => $new_max,
            'coin_earned_today' => $coins_earned,
            'updated_at' => date('Y-m-d H:i:s')
        ];

        if ($existing) {
            $this->db->where('user_id', $user_id)
                     ->update('tbl_daily_streak', $update_data);
        } else {
            $this->db->insert('tbl_daily_streak', $update_data);
        }

        // Award coins to user
        $this->add_coins($user_id, $coins_earned, 'daily_streak');

        // Log to tracker
        $this->set_tracker_data(
            $user_id,
            $firebase_id,
            $coins_earned,
            'daily_streak',
            1
        );

        return [
            'streak_count' => $new_streak,
            'coins_earned' => $coins_earned,
            'daily_coin' => $daily_coin_reward,
            'bonus_coin' => $bonus_earned,
            'max_streak' => $new_max,
            'bonus_unlocked' => $bonus_unlocked,
            'next_bonus_at' => ($bonus_threshold > 0) ? $bonus_threshold - ($new_streak % $bonus_threshold) : 0,
            'message' => $bonus_unlocked 
                ? "Great! You reached day $new_streak and earned $coins_earned coins!"
                : "Day $new_streak: +$coins_earned coins"
        ];
    }

    /**
     * Get user's current streak info
     * 
     * @param int $user_id
     * @return array|null
     */
    public function get_streak($user_id)
    {
        return $this->db->select('*')
                       ->where('user_id', $user_id)
                       ->get('tbl_daily_streak')
                       ->row_array();
    }

    /**
     * Reset streak (called when user misses a day)
     * 
     * @param int $user_id
     */
    public function reset_streak_if_missed($user_id)
    {
        $streak = $this->get_streak($user_id);
        
        if (!$streak) return; // No streak record yet

        $today = date('Y-m-d');
        $tomorrow = date('Y-m-d', strtotime('+1 day'));
        $last_login = $streak['last_login_date'];

        // If last login is not today or yesterday, reset streak
        if ($last_login != $today && $last_login != date('Y-m-d', strtotime('-1 day'))) {
            $this->db->where('user_id', $user_id)
                     ->update('tbl_daily_streak', ['streak_count' => 0]);
        }
    }

    /**
     * Get top users by streak (for leaderboard)
     * 
     * @param int $limit
     * @return array
     */
    public function get_top_streaks($limit = 10)
    {
        return $this->db->select('ts.*, tu.name, tu.profile')
                       ->from('tbl_daily_streak ts')
                       ->join('tbl_users tu', 'ts.user_id = tu.id')
                       ->order_by('ts.streak_count', 'DESC')
                       ->limit($limit)
                       ->get()
                       ->result_array();
    }

    /**
     * Add coins to user (reuse Api.php logic)
     * 
     * @param int $user_id
     * @param int $coins
     * @param string $type
     */
    private function add_coins($user_id, $coins, $type = 'daily_streak')
    {
        $current_coins = $this->db->select('coins')
                                  ->where('id', $user_id)
                                  ->get('tbl_users')
                                  ->row()
                                  ->coins;

        $new_coins = (int)$current_coins + $coins;

        $this->db->where('id', $user_id)
                 ->update('tbl_users', ['coins' => $new_coins]);
    }

    /**
     * Log transaction to tracker
     * 
     * @param int $user_id
     * @param string $firebase_id
     * @param int $coins
     * @param string $type
     * @param int $status
     */
    private function set_tracker_data($user_id, $firebase_id, $coins, $type, $status)
    {
        $tracker_data = [
            'user_id' => $user_id,
            'uid' => $firebase_id,
            'points' => $coins,
            'type' => $type,
            'status' => $status,
            'date' => date('Y-m-d H:i:s'),
            'date_created' => date('Y-m-d H:i:s')
        ];

        $this->db->insert('tbl_tracker', $tracker_data);
    }
}
