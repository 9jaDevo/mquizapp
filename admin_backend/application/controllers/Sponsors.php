<?php

defined('BASEPATH') or exit('No direct script access allowed');

/**
 * Sponsors Controller
 * 
 * Manages rotating sponsor banners with impression tracking
 */
class Sponsors extends CI_Controller
{
    public function __construct()
    {
        parent::__construct();
        $this->load->model('Sponsor_model');
    }

    /**
     * List all sponsor banners
     */
    public function index()
    {
        if (!has_permissions('read', 'sponsor_banners')) {
            redirect('/');
        }

        if ($this->input->post('btnadd')) {
            if (!has_permissions('create', 'sponsor_banners')) {
                $this->session->set_flashdata('error', lang('permission_denied'));
            } else {
                $banner_id = $this->Sponsor_model->add_banner();
                if ($banner_id) {
                    $this->session->set_flashdata('success', 'Sponsor banner created successfully');
                } else {
                    $this->session->set_flashdata('error', 'Failed to create sponsor banner');
                }
            }
            redirect('sponsor-banners');
        }

        if ($this->input->post('btnupdate')) {
            if (!has_permissions('update', 'sponsor_banners')) {
                $this->session->set_flashdata('error', lang('permission_denied'));
            } else {
                $result = $this->Sponsor_model->update_banner();
                $this->session->set_flashdata(
                    $result ? 'success' : 'error',
                    $result ? 'Banner updated' : 'Update failed'
                );
            }
            redirect('sponsor-banners');
        }

        $data['banners'] = $this->Sponsor_model->get_all_banners();
        $data['analytics'] = $this->Sponsor_model->get_all_analytics();
        $data['banner_enabled'] = is_settings('sponsor_banner_enable');

        $this->load->view('sponsor_banners', $data);
    }

    /**
     * View single banner details & analytics
     */
    public function view()
    {
        if (!has_permissions('read', 'sponsor_banners')) {
            show_404();
        }

        $id = $this->input->get('id');
        $banner = $this->Sponsor_model->get_banner($id);

        if (!$banner) {
            show_404();
        }

        $data['banner'] = $banner;
        $data['analytics'] = $this->Sponsor_model->get_banner_analytics($id);

        // Daily impressions chart data
        $data['daily_data'] = $this->db->select('DATE(recorded_at) as date, COUNT(*) as count')
                                       ->where('banner_id', $id)
                                       ->where('action', 'showed')
                                       ->group_by('DATE(recorded_at)')
                                       ->order_by('date', 'ASC')
                                       ->limit(30)
                                       ->get('tbl_banner_impressions')
                                       ->result_array();

        $this->load->view('sponsor_banner_detail', $data);
    }

    /**
     * Delete sponsor banner
     */
    public function delete()
    {
        if (!has_permissions('delete', 'sponsor_banners')) {
            echo json_encode(['success' => false, 'message' => 'No permission']);
            return;
        }

        $id = $this->input->post('id');
        $result = $this->Sponsor_model->delete_banner($id);

        echo json_encode([
            'success' => $result,
            'message' => $result ? 'Banner deleted' : 'Delete failed'
        ]);
    }

    /**
     * Toggle banner active/inactive
     */
    public function toggle_active()
    {
        if (!has_permissions('update', 'sponsor_banners')) {
            echo json_encode(['success' => false, 'message' => 'No permission']);
            return;
        }

        $id = $this->input->post('id');
        $status = $this->input->post('status');

        $result = $this->db->where('id', $id)
                          ->update('tbl_sponsor_banners', ['is_active' => $status]);

        echo json_encode(['success' => $result]);
    }

    /**
     * Update sponsor banner settings
     */
    public function update_settings()
    {
        if (!has_permissions('update', 'sponsor_banners')) {
            echo json_encode(['success' => false, 'message' => 'No permission']);
            return;
        }

        $settings = [
            'sponsor_banner_enable' => $this->input->post('sponsor_banner_enable') ? 1 : 0,
            'sponsor_banner_rotation_seconds' => $this->input->post('sponsor_banner_rotation_seconds'),
            'sponsor_banner_analytics_track_user' => $this->input->post('sponsor_banner_analytics_track_user') ? 1 : 0
        ];

        foreach ($settings as $name => $value) {
            $this->db->where('setting_name', $name)
                     ->update('tbl_settings', ['setting_value' => $value]);
        }

        echo json_encode(['success' => true, 'message' => 'Settings updated']);
    }

    /**
     * Get overall sponsor banner analytics
     */
    public function get_analytics()
    {
        if (!has_permissions('read', 'sponsor_banners')) {
            echo json_encode(['success' => false]);
            return;
        }

        $analytics = $this->Sponsor_model->get_all_analytics();

        echo json_encode([
            'success' => true,
            'data' => $analytics
        ]);
    }
}
