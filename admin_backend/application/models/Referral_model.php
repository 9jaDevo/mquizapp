<?php
defined('BASEPATH') or exit('No direct script access allowed');

/**
 * Referral_model
 * 
 * Manages referral system with anti-farming protection
 * 
 * Features:
 * - Referral code generation and validation
 * - Activity tracking for referred users
 * - Fraud detection (duplicate IP, device, rapid signups)
 * - Reward distribution after qualification
 * - Admin dashboard statistics
 * 
 * @package    Models
 * @author     Your Name
 * @since      2026-01-16
 */
class Referral_model extends CI_Model
{
    /**
     * Generate unique referral code for user
     */
    public function generate_referral_code($user_id, $uid)
    {
        // Check if user already has a code
        $existing = $this->db->where('user_id', $user_id)->get('tbl_referral_codes')->row();
        
        if ($existing) {
            return [
                'error' => false,
                'referral_code' => $existing->referral_code,
                'message' => 'Existing code returned'
            ];
        }
        
        // Generate unique code (6 characters: e.g., "ABC123")
        $code = $this->generate_unique_code();
        
        $data = [
            'user_id' => $user_id,
            'uid' => $uid,
            'referral_code' => $code,
            'created_at' => date('Y-m-d H:i:s')
        ];
        
        $insert = $this->db->insert('tbl_referral_codes', $data);
        
        if ($insert) {
            return [
                'error' => false,
                'referral_code' => $code,
                'message' => 'Referral code generated'
            ];
        }
        
        return [
            'error' => true,
            'message' => 'Failed to generate code'
        ];
    }
    
    /**
     * Generate unique 6-character code
     */
    private function generate_unique_code()
    {
        $characters = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // Exclude similar characters
        $max_attempts = 10;
        
        for ($i = 0; $i < $max_attempts; $i++) {
            $code = '';
            for ($j = 0; $j < 6; $j++) {
                $code .= $characters[rand(0, strlen($characters) - 1)];
            }
            
            // Check if code exists
            $exists = $this->db->where('referral_code', $code)->get('tbl_referral_codes')->row();
            if (!$exists) {
                return $code;
            }
        }
        
        // Fallback: use timestamp-based code
        return strtoupper(substr(md5(time() . rand()), 0, 6));
    }
    
    /**
     * Apply referral code during signup
     */
    public function apply_referral_code($referral_code, $referee_id, $referee_uid, $signup_ip, $device_id)
    {
        // Validate referral code
        $code_data = $this->db->where('referral_code', $referral_code)
                               ->where('is_active', 1)
                               ->get('tbl_referral_codes')
                               ->row();
        
        if (!$code_data) {
            return ['error' => true, 'message' => 'Invalid referral code'];
        }
        
        // Check if referee already used a referral
        $existing = $this->db->where('referee_id', $referee_id)->get('tbl_referrals')->row();
        if ($existing) {
            return ['error' => true, 'message' => 'You have already used a referral code'];
        }
        
        // Check if user is trying to refer themselves
        if ($code_data->user_id == $referee_id) {
            return ['error' => true, 'message' => 'Cannot use your own referral code'];
        }
        
        // Check fraud before creating referral
        $fraud_checks = $this->check_referral_fraud($signup_ip, $device_id, $code_data->user_id);
        
        // Create referral record
        $referral_data = [
            'referrer_id' => $code_data->user_id,
            'referrer_uid' => $code_data->uid,
            'referee_id' => $referee_id,
            'referee_uid' => $referee_uid,
            'referral_code' => $referral_code,
            'signup_date' => date('Y-m-d H:i:s'),
            'signup_ip' => $signup_ip,
            'signup_device_id' => $device_id,
            'status' => $fraud_checks['suspicious'] ? 'pending' : 'pending'
        ];
        
        $insert = $this->db->insert('tbl_referrals', $referral_data);
        
        if ($insert) {
            $referral_id = $this->db->insert_id();
            
            // Update referral code stats
            $this->db->where('user_id', $code_data->user_id)
                     ->set('total_referrals', 'total_referrals + 1', FALSE)
                     ->update('tbl_referral_codes');
            
            // Log fraud checks if any
            if ($fraud_checks['suspicious']) {
                foreach ($fraud_checks['issues'] as $issue) {
                    $this->log_fraud_check($referral_id, $issue['type'], $issue['severity'], $issue['details']);
                }
            }
            
            return [
                'error' => false,
                'referral_id' => $referral_id,
                'message' => 'Referral applied successfully',
                'fraud_detected' => $fraud_checks['suspicious']
            ];
        }
        
        return ['error' => true, 'message' => 'Failed to apply referral'];
    }
    
    /**
     * Check for referral fraud patterns
     */
    private function check_referral_fraud($ip, $device_id, $referrer_id)
    {
        $issues = [];
        $suspicious = false;
        
        // Check 1: Duplicate IP
        $block_same_ip = $this->db->where('type', 'referral_block_same_ip')->get('tbl_settings')->row();
        if ($block_same_ip && $block_same_ip->message == '1') {
            $ip_count = $this->db->where('signup_ip', $ip)->get('tbl_referrals')->num_rows();
            $max_same_ip = $this->db->where('type', 'referral_same_ip_max_count')->get('tbl_settings')->row();
            
            if ($ip_count >= (int)$max_same_ip->message) {
                $issues[] = [
                    'type' => 'duplicate_ip',
                    'severity' => 'high',
                    'details' => json_encode(['ip' => $ip, 'count' => $ip_count + 1])
                ];
                $suspicious = true;
            }
        }
        
        // Check 2: Duplicate Device
        $verify_device = $this->db->where('type', 'referral_verify_device_unique')->get('tbl_settings')->row();
        if ($verify_device && $verify_device->message == '1') {
            $device_count = $this->db->where('signup_device_id', $device_id)->get('tbl_referrals')->num_rows();
            $max_per_device = $this->db->where('type', 'referral_max_per_device')->get('tbl_settings')->row();
            
            if ($device_count >= (int)$max_per_device->message) {
                $issues[] = [
                    'type' => 'same_device_multiple_accounts',
                    'severity' => 'critical',
                    'details' => json_encode(['device_id' => $device_id, 'count' => $device_count + 1])
                ];
                $suspicious = true;
            }
        }
        
        // Check 3: Rapid signups from same referrer
        $max_per_day = $this->db->where('type', 'referral_max_per_day')->get('tbl_settings')->row();
        $today_referrals = $this->db->where('referrer_id', $referrer_id)
                                     ->where('DATE(signup_date)', date('Y-m-d'))
                                     ->get('tbl_referrals')
                                     ->num_rows();
        
        if ($today_referrals >= (int)$max_per_day->message) {
            $issues[] = [
                'type' => 'rapid_signups',
                'severity' => 'medium',
                'details' => json_encode(['referrer_id' => $referrer_id, 'today_count' => $today_referrals + 1])
            ];
            $suspicious = true;
        }
        
        return [
            'suspicious' => $suspicious,
            'issues' => $issues
        ];
    }
    
    /**
     * Log fraud check
     */
    private function log_fraud_check($referral_id, $type, $severity, $details)
    {
        $data = [
            'referral_id' => $referral_id,
            'check_type' => $type,
            'severity' => $severity,
            'details' => $details,
            'detected_at' => date('Y-m-d H:i:s')
        ];
        
        $this->db->insert('tbl_referral_fraud_checks', $data);
    }
    
    /**
     * Update referee activity (called after quiz completion)
     */
    public function update_referee_activity($user_id, $coins_earned = 0, $quiz_played = 0)
    {
        // Check if user is a referee
        $referral = $this->db->where('referee_id', $user_id)
                             ->where_in('status', ['pending', 'qualified'])
                             ->get('tbl_referrals')
                             ->row();
        
        if (!$referral) {
            return; // Not a referee or already rewarded
        }
        
        $today = date('Y-m-d');
        
        // Update or insert daily activity
        $activity = $this->db->where('referral_id', $referral->id)
                             ->where('activity_date', $today)
                             ->get('tbl_referral_activity')
                             ->row();
        
        if ($activity) {
            // Update existing activity
            $this->db->where('id', $activity->id)
                     ->set('quizzes_played', 'quizzes_played + ' . $quiz_played, FALSE)
                     ->set('coins_earned', 'coins_earned + ' . $coins_earned, FALSE)
                     ->set('is_active_day', 1)
                     ->update('tbl_referral_activity');
        } else {
            // Insert new activity
            $this->db->insert('tbl_referral_activity', [
                'referral_id' => $referral->id,
                'referee_id' => $user_id,
                'activity_date' => $today,
                'quizzes_played' => $quiz_played,
                'coins_earned' => $coins_earned,
                'is_active_day' => 1
            ]);
        }
        
        // Update referral totals
        $active_days = $this->db->where('referral_id', $referral->id)
                                ->where('is_active_day', 1)
                                ->get('tbl_referral_activity')
                                ->num_rows();
        
        $total_quizzes = $this->db->select_sum('quizzes_played')
                                   ->where('referral_id', $referral->id)
                                   ->get('tbl_referral_activity')
                                   ->row()
                                   ->quizzes_played ?? 0;
        
        $total_coins = $this->db->select_sum('coins_earned')
                                ->where('referral_id', $referral->id)
                                ->get('tbl_referral_activity')
                                ->row()
                                ->coins_earned ?? 0;
        
        $this->db->where('id', $referral->id)
                 ->update('tbl_referrals', [
                     'referee_active_days' => $active_days,
                     'referee_quizzes_played' => $total_quizzes,
                     'referee_coins_earned' => $total_coins
                 ]);
        
        // Check if now eligible
        $this->check_and_reward_if_eligible($referral->id);
    }
    
    /**
     * Check if referral is eligible and reward
     */
    private function check_and_reward_if_eligible($referral_id)
    {
        $referral = $this->db->where('id', $referral_id)->get('tbl_referrals')->row();
        
        if ($referral->status != 'pending') {
            return; // Already processed
        }
        
        // Get requirements
        $min_days = (int)$this->db->where('type', 'referral_reward_min_active_days')->get('tbl_settings')->row()->message;
        $min_quizzes = (int)$this->db->where('type', 'referral_reward_min_quizzes')->get('tbl_settings')->row()->message;
        
        // Check fraud flags
        $fraud_count = $this->db->where('referral_id', $referral_id)
                                ->where_in('severity', ['high', 'critical'])
                                ->where('resolved', 0)
                                ->get('tbl_referral_fraud_checks')
                                ->num_rows();
        
        if ($fraud_count > 0) {
            // Reject due to fraud
            $this->db->where('id', $referral_id)
                     ->update('tbl_referrals', [
                         'status' => 'rejected',
                         'rejection_reason' => 'Fraud detected'
                     ]);
            return;
        }
        
        // Check if meets requirements
        if ($referral->referee_active_days >= $min_days && $referral->referee_quizzes_played >= $min_quizzes) {
            // Mark as qualified
            $this->db->where('id', $referral_id)
                     ->update('tbl_referrals', [
                         'status' => 'qualified',
                         'qualified_date' => date('Y-m-d H:i:s')
                     ]);
            
            // Automatically reward
            $this->reward_referral($referral_id);
        }
    }
    
    /**
     * Reward both referrer and referee
     */
    public function reward_referral($referral_id)
    {
        $referral = $this->db->where('id', $referral_id)->get('tbl_referrals')->row();
        
        if (!$referral || $referral->status == 'rewarded') {
            return ['error' => true, 'message' => 'Already rewarded or not found'];
        }
        
        // Get bonus reward amounts (not total, just bonus on top of instant rewards)
        $referrer_coins = (int)$this->db->where('type', 'referral_bonus_referrer_coins')->get('tbl_settings')->row()->message;
        $referee_coins = (int)$this->db->where('type', 'referral_bonus_referee_coins')->get('tbl_settings')->row()->message;
        
        $this->db->trans_start();
        
        // Update referrer coins
        $this->db->where('id', $referral->referrer_id)
                 ->set('coins', 'coins + ' . $referrer_coins, FALSE)
                 ->update('tbl_users');
        
        // Update referee coins
        $this->db->where('id', $referral->referee_id)
                 ->set('coins', 'coins + ' . $referee_coins, FALSE)
                 ->update('tbl_users');
        
        // Update referral record
        $this->db->where('id', $referral_id)
                 ->update('tbl_referrals', [
                     'status' => 'rewarded',
                     'reward_date' => date('Y-m-d H:i:s'),
                     'referrer_coins_rewarded' => $referrer_coins,
                     'referee_coins_rewarded' => $referee_coins
                 ]);
        
        // Update referral code stats
        $this->db->where('user_id', $referral->referrer_id)
                 ->set('successful_referrals', 'successful_referrals + 1', FALSE)
                 ->set('total_coins_earned', 'total_coins_earned + ' . $referrer_coins, FALSE)
                 ->update('tbl_referral_codes');
        
        $this->db->trans_complete();
        
        if ($this->db->trans_status() === FALSE) {
            return ['error' => true, 'message' => 'Failed to distribute rewards'];
        }
        
        return [
            'error' => false,
            'message' => 'Rewards distributed successfully',
            'referrer_coins' => $referrer_coins,
            'referee_coins' => $referee_coins
        ];
    }
    
    /**
     * Get user's referral statistics
     */
    public function get_user_referral_stats($user_id)
    {
        $code = $this->db->where('user_id', $user_id)->get('tbl_referral_codes')->row();
        
        if (!$code) {
            return [
                'has_code' => false,
                'referral_code' => null,
                'total_referrals' => 0,
                'successful_referrals' => 0,
                'pending_referrals' => 0,
                'total_coins_earned' => 0
            ];
        }
        
        $stats = $this->db->select('
                COUNT(*) as total,
                SUM(CASE WHEN status = "rewarded" THEN 1 ELSE 0 END) as successful,
                SUM(CASE WHEN status = "pending" OR status = "qualified" THEN 1 ELSE 0 END) as pending
            ')
            ->where('referrer_id', $user_id)
            ->get('tbl_referrals')
            ->row();
        
        return [
            'has_code' => true,
            'referral_code' => $code->referral_code,
            'total_referrals' => $stats->total ?? 0,
            'successful_referrals' => $stats->successful ?? 0,
            'pending_referrals' => $stats->pending ?? 0,
            'total_coins_earned' => $code->total_coins_earned
        ];
    }
    
    /**
     * Admin: Get all referrals with pagination
     */
    public function get_all_referrals($limit = 20, $offset = 0, $status = null)
    {
        $this->db->select('
                r.*,
                u1.name as referrer_name,
                u1.email as referrer_email,
                u2.name as referee_name,
                u2.email as referee_email
            ')
            ->from('tbl_referrals r')
            ->join('tbl_users u1', 'r.referrer_id = u1.id', 'left')
            ->join('tbl_users u2', 'r.referee_id = u2.id', 'left');
        
        if ($status) {
            $this->db->where('r.status', $status);
        }
        
        $this->db->order_by('r.signup_date', 'DESC')
                 ->limit($limit, $offset);
        
        return $this->db->get()->result();
    }
    
    /**
     * Admin: Get suspicious referrals
     */
    public function get_suspicious_referrals()
    {
        return $this->db->query("
            SELECT * FROM vw_suspicious_referrals
            ORDER BY max_severity DESC, fraud_flags DESC
        ")->result();
    }
}
