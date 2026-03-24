<?php

defined('BASEPATH') or exit('No direct script access allowed');

class League extends CI_Controller
{
    public function __construct()
    {
        parent::__construct();
        if (!$this->session->userdata('isLoggedIn')) {
            redirect('login');
        }
        $this->load->model('League_model');
        $this->load->model('Language_model');
    }

    public function index()
    {
        if (!has_permissions('read', 'manage_contest')) {
            redirect('dashboard');
            return;
        }

        if ($this->input->post('btnadd')) {
            if (!has_permissions('create', 'manage_contest')) {
                $this->session->set_flashdata('error', lang(PERMISSION_ERROR_MSG));
            } else {
                $this->League_model->add_league();
                $this->session->set_flashdata('success', 'League created successfully');
            }
            redirect('league');
            return;
        }

        if ($this->input->post('btnupdate')) {
            if (!has_permissions('update', 'manage_contest')) {
                $this->session->set_flashdata('error', lang(PERMISSION_ERROR_MSG));
            } else {
                $this->League_model->update_league();
                $this->session->set_flashdata('success', 'League updated successfully');
            }
            redirect('league');
            return;
        }

        $this->result['league'] = $this->League_model->get_data();
        $this->result['language'] = $this->Language_model->get_data();
        $this->load->view('league', $this->result);
    }

    public function delete_league()
    {
        if (!has_permissions('delete', 'manage_contest')) {
            echo false;
            return;
        }

        $id = (int)$this->input->post('id');
        $this->League_model->delete_league($id);
        echo true;
    }

    public function update_league_status()
    {
        if (!has_permissions('update', 'manage_contest')) {
            echo false;
            return;
        }
        $this->League_model->update_status();
        echo true;
    }

    public function daily_quiz()
    {
        if (!has_permissions('update', 'manage_contest')) {
            redirect('dashboard');
            return;
        }

        if ($this->input->post('btnadd')) {
            $this->League_model->add_daily_quiz();
            $this->session->set_flashdata('success', 'Daily quiz assigned successfully');
            redirect('league-daily-quiz');
            return;
        }

        $this->result['league'] = $this->League_model->get_data();
        $this->result['questions'] = $this->db->select('id,question')->order_by('id', 'DESC')->get('tbl_contest_question')->result();
        $this->load->view('league_daily_quiz', $this->result);
    }

    public function league_prize($id)
    {
        if (!has_permissions('read', 'manage_contest')) {
            redirect('dashboard');
            return;
        }

        if ($this->input->post('btnadd')) {
            if (!has_permissions('create', 'manage_contest')) {
                $this->session->set_flashdata('error', lang(PERMISSION_ERROR_MSG));
            } else {
                $this->League_model->add_league_prize();
                $this->session->set_flashdata('success', 'League prize created successfully');
            }
            redirect('league-prize/' . $id);
            return;
        }

        if ($this->input->post('btnupdate')) {
            if (!has_permissions('update', 'manage_contest')) {
                $this->session->set_flashdata('error', lang(PERMISSION_ERROR_MSG));
            } else {
                $this->League_model->update_league_prize();
                $this->session->set_flashdata('success', 'League prize updated successfully');
            }
            redirect('league-prize/' . $id);
            return;
        }

        $this->result['max'] = $this->League_model->get_max_top_winner($id);
        $this->result['league_id'] = (int)$id;
        $this->result['prizes'] = $this->db->where('league_id', (int)$id)->order_by('top_winner', 'ASC')->get('tbl_league_prize')->result();
        $this->load->view('league_prize', $this->result);
    }

    public function delete_league_prize()
    {
        if (!has_permissions('delete', 'manage_contest')) {
            echo false;
            return;
        }
        $id = (int)$this->input->post('id');
        $this->League_model->delete_league_prize($id);
        echo true;
    }

    public function league_prize_distribute($id)
    {
        if (!has_permissions('read', 'manage_contest')) {
            redirect('dashboard');
            return;
        }

        $league = $this->db->where('id', (int)$id)->limit(1)->get('tbl_league')->row();
        if (empty($league)) {
            $this->session->set_flashdata('error', 'League not found.');
            redirect('league');
            return;
        }

        if ((int)$league->prize_status === 1) {
            $this->session->set_flashdata('error', 'Prize already distributed for this league.');
            redirect('league');
            return;
        }

        if (strtotime($league->end_date) > time()) {
            $this->session->set_flashdata('error', 'Prize distribution is not available before league end date.');
            redirect('league');
            return;
        }

        $prizes = $this->db->where('league_id', (int)$id)->order_by('top_winner', 'ASC')->get('tbl_league_prize')->result();
        if (empty($prizes)) {
            $this->session->set_flashdata('error', 'No prize tiers configured for this league.');
            redirect('league-prize/' . (int)$id);
            return;
        }

        $this->db->trans_start();

        foreach ($prizes as $tier) {
            $winnerRank = (int)$tier->top_winner;
            $winnerPoints = (int)$tier->points;

            $query = $this->db->query("SELECT r.*, u.firebase_id, u.coins
                FROM (
                    SELECT s.*, @user_rank := @user_rank + 1 user_rank
                    FROM (
                        SELECT user_id, cumulative_best_score AS score
                        FROM tbl_league_leaderboard
                        WHERE league_id='" . (int)$id . "'
                        ORDER BY cumulative_best_score DESC, last_updated ASC
                    ) s, (SELECT @user_rank := 0) init
                ) r
                INNER JOIN tbl_users u ON u.id = r.user_id
                WHERE r.user_rank='" . $winnerRank . "'
                ORDER BY r.user_rank ASC");
            $winners = $query->result();

            foreach ($winners as $winner) {
                $this->db->insert('tbl_tracker', [
                    'user_id' => $winner->user_id,
                    'uid' => $winner->firebase_id,
                    'points' => $winnerPoints,
                    'type' => 'wonLeague',
                    'status' => 0,
                    'date' => date('Y-m-d'),
                ]);

                $coins = (int)$winner->coins + $winnerPoints;
                $this->db->where('id', $winner->user_id)->update('tbl_users', ['coins' => $coins]);
            }
        }

        $this->db->where('id', (int)$id)->update('tbl_league', ['prize_status' => 1]);

        $this->db->trans_complete();
        if ($this->db->trans_status() === false) {
            $this->session->set_flashdata('error', 'Prize distribution failed due to a transaction error.');
            redirect('league');
            return;
        }

        $this->session->set_flashdata('success', 'Prize distributed successfully for league: ' . $league->name);
        redirect('league');
    }
}
