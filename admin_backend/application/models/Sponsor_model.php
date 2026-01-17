<?php

defined('BASEPATH') or exit('No direct script access allowed');

/**
 * Sponsor_model
 * 
 * Manages rotating sponsor banners with impression tracking
 */
class Sponsor_model extends CI_Model
{
    public function __construct()
    {
        parent::__construct();
        $this->load->helper('settings');
        
        // Ensure directory exists using absolute path
        $full_path = FCPATH . SPONSOR_BANNER_IMG_PATH;
        error_log('Checking sponsor banner path: ' . $full_path);
        
        if (!is_dir($full_path)) {
            error_log('Creating directory: ' . $full_path);
            $result = mkdir($full_path, 0755, true);
            error_log('Directory creation result: ' . ($result ? 'SUCCESS' : 'FAILED'));
            
            if (!$result) {
                error_log('Failed to create directory. FCPATH: ' . FCPATH);
            }
        } else {
            error_log('Directory already exists');
        }
    }

    /**
     * Get all sponsor banners
     * 
     * @param int $limit
     * @return array
     */
    public function get_all_banners($limit = 50)
    {
        $result = $this->db->select('sb.*, 
                COUNT(CASE WHEN bi.action = "showed" THEN 1 END) as total_impressions,
                COUNT(CASE WHEN bi.action = "clicked" THEN 1 END) as total_clicks,
                COUNT(CASE WHEN bi.action = "showed" AND DATE(bi.recorded_at) = CURDATE() THEN 1 END) as today_impressions')
                       ->from('tbl_sponsor_banners sb')
                       ->join('tbl_banner_impressions bi', 'sb.id = bi.banner_id', 'left')
                       ->group_by('sb.id')
                       ->order_by('sb.is_active', 'DESC')
                       ->order_by('sb.priority', 'DESC')
                       ->order_by('sb.start_date', 'DESC')
                       ->limit($limit)
                       ->get()
                       ->result();
        
        return $result;
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
        error_log('Starting add_banner...');
        error_log('FILES: ' . print_r($_FILES, true));
        
        // Handle image upload
        $image_url = $this->handle_image_upload('banner_image');
        
        if (!$image_url) {
            error_log('Image upload failed!');
            error_log('Upload errors: ' . $this->upload->display_errors());
            return false;
        }
        
        error_log('Image uploaded successfully: ' . $image_url);

        $data = [
            'sponsor_name' => $this->input->post('sponsor_name'),
            'title' => $this->input->post('title'),
            'image_url' => $image_url,
            'image_path' => SPONSOR_BANNER_IMG_PATH . basename($image_url),
            'redirect_url' => $this->input->post('redirect_url') ?: null,
            'redirect_type' => $this->input->post('redirect_type') ?? 'url',
            'impression_limit' => $this->input->post('impression_limit') ?? 0,
            'impression_period' => $this->input->post('impression_period') ?? 'daily',
            'impression_reset_date' => date('Y-m-d'),
            'current_impressions' => 0,
            'is_active' => $this->input->post('is_active') ?? 1,
            'priority' => $this->input->post('priority') ?? 0,
            'start_date' => $this->input->post('start_date'),
            'end_date' => $this->input->post('end_date'),
            'created_by' => $this->session->userdata('authId'),
            'created_at' => date('Y-m-d H:i:s')
        ];

        error_log('Inserting banner data: ' . print_r($data, true));
        
        if ($this->db->insert('tbl_sponsor_banners', $data)) {
            $insert_id = $this->db->insert_id();
            error_log('Banner inserted successfully with ID: ' . $insert_id);
            return $insert_id;
        }
        
        error_log('Database insert failed: ' . $this->db->error()['message']);
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

        // Bail out early if banner not found to avoid null access
        if (!$banner) {
            log_message('error', '[SPONSOR_MODEL] update_banner: Banner not found for ID ' . $id);
            return false;
        }

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
            'redirect_url' => $this->input->post('redirect_url') ?: null,
            'redirect_type' => $this->input->post('redirect_type') ?: 'url',
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

        if (!$banner) {
            log_message('error', '[SPONSOR_MODEL] delete_banner: Banner not found for ID ' . $id);
            return false;
        }

        if ($banner['image_path'] && file_exists($banner['image_path'])) {
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
     * Get multiple active banners for rotation (client-side carousel)
     * Respects impression limits and date ranges, ordered by priority
     *
     * @param int $limit
     * @return array
     */
    public function get_active_banners($limit = 10)
    {
        $result = [];

        $is_enabled = is_settings('sponsor_banner_enable');
        log_message('debug', '[SPONSOR_MODEL] sponsor_banner_enable: ' . ($is_enabled ? 'true' : 'false'));
        
        if (!$is_enabled) {
            log_message('debug', '[SPONSOR_MODEL] Sponsor banners disabled, returning empty array');
            return $result;
        }

        $now = date('Y-m-d H:i:s');
        $today = date('Y-m-d');
        
        log_message('debug', '[SPONSOR_MODEL] Querying banners. Now: ' . $now . ', Today: ' . $today);

        $banners = $this->db->select('*')
                            ->where('is_active', 1)
                            ->where('start_date <=', $now)
                            ->where('end_date >=', $now)
                            ->order_by('priority', 'DESC')
                            ->order_by('RAND()')
                            ->get('tbl_sponsor_banners')
                            ->result_array();

        log_message('debug', '[SPONSOR_MODEL] Found ' . count($banners) . ' banners from DB');

        foreach ($banners as $banner) {
            log_message('debug', '[SPONSOR_MODEL] Checking banner: ' . $banner['sponsor_name'] . ' (ID: ' . $banner['id'] . ')');
            
            // Reset daily counters when date changes
            if ($banner['impression_limit'] > 0 && $banner['impression_period'] === 'daily') {
                if ($banner['impression_reset_date'] < $today) {
                    $this->db->where('id', $banner['id'])
                             ->update('tbl_sponsor_banners', [
                                 'current_impressions' => 0,
                                 'impression_reset_date' => $today,
                             ]);
                    $banner['current_impressions'] = 0;
                    log_message('debug', '[SPONSOR_MODEL] Reset daily counter for banner ' . $banner['id']);
                }
            }

            // Include if unlimited or within limit
            if ($banner['impression_limit'] == 0 || $banner['current_impressions'] < $banner['impression_limit']) {
                $result[] = $banner;
                log_message('debug', '[SPONSOR_MODEL] Added banner ' . $banner['id'] . ' to result');
            } else {
                log_message('debug', '[SPONSOR_MODEL] Skipped banner ' . $banner['id'] . ' - impression limit reached');
            }

            if (count($result) >= $limit) {
                break;
            }
        }

        log_message('debug', '[SPONSOR_MODEL] Returning ' . count($result) . ' banners');
        return $result;
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
            $this->db->set('current_impressions', 'current_impressions + 1', FALSE)
                     ->where('id', $banner_id)
                     ->update('tbl_sponsor_banners');
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
                (array)$banner,
                $this->get_banner_analytics($banner->id)
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
        $config = [
            'upload_path' => FCPATH . SPONSOR_BANNER_IMG_PATH,
            'allowed_types' => 'gif|jpg|jpeg|png|webp',
            'max_size' => 5000,  // 5MB
            'file_name' => 'sponsor_' . time(),
            'overwrite' => false
        ];

        $this->upload->initialize($config);

        if ($this->upload->do_upload($input_name)) {
            $upload_data = $this->upload->data();
            return base_url(SPONSOR_BANNER_IMG_PATH . $upload_data['file_name']);
        }

        return false;
    }
}
