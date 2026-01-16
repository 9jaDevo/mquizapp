<?php

defined('BASEPATH') or exit('No direct script access allowed');

/**
 * Sponsor_model
 * 
 * Manages rotating sponsor banners with impression tracking
 */
class Sponsor_model extends CI_Model
{
    private $upload_path = 'admin_backend/images/sponsor_banners/';

    public function __construct()
    {
        parent::__construct();
        $this->load->helper('settings');
    }

    /**
     * Get all sponsor banners
     * 
     * @param int $limit
     * @return array
     */
    public function get_all_banners($limit = 50)
    {
        return $this->db->select('*')
                       ->order_by('is_active', 'DESC')
                       ->order_by('priority', 'DESC')
                       ->order_by('start_date', 'DESC')
                       ->limit($limit)
                       ->get('tbl_sponsor_banners')
                       ->result_array();
    }

    /**
     * Get single banner by ID
     * 
     * @param int $id
     * @return array|null
     */
    public function get_banner($id)
    {
        return $this->db->select('*')
                       ->where('id', $id)
                       ->get('tbl_sponsor_banners')
                       ->row_array();
    }

    /**
     * Add new sponsor banner
     * 
     * @return bool|int Banner ID
     */
    public function add_banner()
    {
        // Handle image upload
        $image_url = $this->handle_image_upload('banner_image');

        $data = [
            'sponsor_name' => $this->input->post('sponsor_name'),
            'title' => $this->input->post('title'),
            'image_url' => $image_url,
            'image_path' => $this->upload_path . basename($image_url),
            'redirect_url' => $this->input->post('redirect_url'),
            'redirect_type' => $this->input->post('redirect_type') ?? 'url',
            'impression_limit' => $this->input->post('impression_limit') ?? 0,
            'impression_period' => $this->input->post('impression_period') ?? 'daily',
            'impression_reset_date' => date('Y-m-d'),
            'current_impressions' => 0,
            'is_active' => $this->input->post('is_active') ?? 1,
            'priority' => $this->input->post('priority') ?? 0,
            'start_date' => $this->input->post('start_date'),
            'end_date' => $this->input->post('end_date'),
            'created_by' => $this->session->userdata('auth_id'),
            'created_at' => date('Y-m-d H:i:s')
        ];

        if ($this->db->insert('tbl_sponsor_banners', $data)) {
            return $this->db->insert_id();
        }

        return false;
    }

    /**
     * Update sponsor banner
     * 
     * @return bool
     */
    public function update_banner()
    {
        $id = $this->input->post('id');
        $banner = $this->get_banner($id);

        // Handle image upload if provided
        $image_url = $banner['image_url'];
        if (!empty($_FILES['banner_image']['name'])) {
            $old_image = $banner['image_path'];
            if ($old_image && file_exists($old_image)) {
                unlink($old_image);
            }
            $image_url = $this->handle_image_upload('banner_image');
        }

        $data = [
            'sponsor_name' => $this->input->post('sponsor_name'),
            'title' => $this->input->post('title'),
            'image_url' => $image_url,
            'redirect_url' => $this->input->post('redirect_url'),
            'redirect_type' => $this->input->post('redirect_type'),
            'impression_limit' => $this->input->post('impression_limit') ?? 0,
            'impression_period' => $this->input->post('impression_period'),
            'is_active' => $this->input->post('is_active') ?? 0,
            'priority' => $this->input->post('priority') ?? 0,
            'start_date' => $this->input->post('start_date'),
            'end_date' => $this->input->post('end_date'),
            'updated_at' => date('Y-m-d H:i:s')
        ];

        return $this->db->where('id', $id)
                       ->update('tbl_sponsor_banners', $data);
    }

    /**
     * Delete sponsor banner
     * 
     * @param int $id
     * @return bool
     */
    public function delete_banner($id)
    {
        $banner = $this->get_banner($id);
        
        if ($banner && $banner['image_path'] && file_exists($banner['image_path'])) {
            unlink($banner['image_path']);
        }

        return $this->db->where('id', $id)
                       ->delete('tbl_sponsor_banners');
    }

    /**
     * Get active banner for display (for rotation)
     * Respects impression limits and date ranges
     * 
     * @return array|null
     */
    public function get_active_banner_for_rotation()
    {
        if (!is_settings('sponsor_banner_enable')) {
            return null;
        }

        $now = date('Y-m-d H:i:s');
        $today = date('Y-m-d');

        // Get active banners within date range, ordered by priority
        $banners = $this->db->select('*')
                           ->where('is_active', 1)
                           ->where('start_date <=', $now)
                           ->where('end_date >=', $now)
                           ->order_by('priority', 'DESC')
                           ->order_by('RAND()')
                           ->get('tbl_sponsor_banners')
                           ->result_array();

        // Find first banner that hasn't hit impression limit
        foreach ($banners as $banner) {
            if ($banner['impression_limit'] == 0) {
                // Unlimited impressions
                return $banner;
            }

            // Check impression limit
            if ($banner['impression_period'] == 'daily') {
                // Reset if date changed
                if ($banner['impression_reset_date'] < $today) {
                    $this->db->where('id', $banner['id'])
                             ->update('tbl_sponsor_banners', [
                                 'current_impressions' => 0,
                                 'impression_reset_date' => $today
                             ]);
                    $banner['current_impressions'] = 0;
                }
            }

            if ($banner['current_impressions'] < $banner['impression_limit']) {
                return $banner;
            }
        }

        return null;
    }

    /**
     * Record banner impression
     * 
     * @param int $banner_id
     * @param int|null $user_id
     * @param string $action 'showed' or 'clicked'
     * @return bool
     */
    public function record_impression($banner_id, $user_id = null, $action = 'showed')
    {
        $data = [
            'banner_id' => $banner_id,
            'user_id' => $user_id,
            'action' => $action,
            'recorded_at' => date('Y-m-d H:i:s')
        ];

        $inserted = $this->db->insert('tbl_banner_impressions', $data);

        if ($inserted && $action == 'showed') {
            // Increment impression counter
            $this->db->where('id', $banner_id)
                     ->update('tbl_sponsor_banners', [
                         'current_impressions' => $this->db->raw('current_impressions + 1')
                     ]);
        }

        return $inserted;
    }

    /**
     * Get banner analytics
     * 
     * @param int $banner_id
     * @return array
     */
    public function get_banner_analytics($banner_id)
    {
        $impressions = $this->db->select('COUNT(*) as total')
                               ->where('banner_id', $banner_id)
                               ->where('action', 'showed')
                               ->get('tbl_banner_impressions')
                               ->row()
                               ->total;

        $clicks = $this->db->select('COUNT(*) as total')
                          ->where('banner_id', $banner_id)
                          ->where('action', 'clicked')
                          ->get('tbl_banner_impressions')
                          ->row()
                          ->total;

        $ctr = $impressions > 0 ? round(($clicks / $impressions) * 100, 2) : 0;

        // Unique users
        $unique_users = $this->db->select('COUNT(DISTINCT user_id) as count')
                                ->where('banner_id', $banner_id)
                                ->where('user_id IS NOT NULL')
                                ->get('tbl_banner_impressions')
                                ->row()
                                ->count;

        return [
            'banner_id' => $banner_id,
            'total_impressions' => $impressions,
            'total_clicks' => $clicks,
            'click_through_rate' => $ctr . '%',
            'unique_users' => $unique_users,
            'efficiency' => $impressions > 0 ? round($clicks / $impressions, 4) : 0
        ];
    }

    /**
     * Get analytics for all banners
     * 
     * @return array
     */
    public function get_all_analytics()
    {
        $banners = $this->get_all_banners();
        $analytics = [];

        foreach ($banners as $banner) {
            $analytics[] = array_merge(
                $banner,
                $this->get_banner_analytics($banner['id'])
            );
        }

        return $analytics;
    }

    /**
     * Handle banner image upload
     * 
     * @param string $input_name
     * @return string|false Image URL
     */
    private function handle_image_upload($input_name)
    {
        // Ensure upload directory exists
        if (!is_dir($this->upload_path)) {
            mkdir($this->upload_path, 0755, true);
        }

        $config = [
            'upload_path' => $this->upload_path,
            'allowed_types' => 'gif|jpg|jpeg|png|webp',
            'max_size' => 5000,  // 5MB
            'file_name' => 'sponsor_' . time(),
            'overwrite' => false
        ];

        $this->load->library('upload', $config);

        if ($this->upload->do_upload($input_name)) {
            return base_url($this->upload_path . $this->upload->data('file_name'));
        }

        return false;
    }
}
