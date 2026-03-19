<?php

defined('BASEPATH') or exit('No direct script access allowed');

class League_model extends CI_Model
{
    public $toDateTime;

    public function __construct()
    {
        parent::__construct();
        date_default_timezone_set(get_system_timezone());
        $this->toDateTime = date('Y-m-d H:i:s');
    }

    public function get_data()
    {
        return $this->db->order_by('id', 'DESC')->get('tbl_league')->result();
    }

    public function add_league()
    {
        $data = [
            'name' => $this->input->post('name'),
            'language_id' => $this->input->post('language_id') ?? 0,
            'start_date' => $this->input->post('start_date'),
            'end_date' => $this->input->post('end_date'),
            'description' => $this->input->post('description'),
            'entry' => (int)$this->input->post('entry'),
            'created_by' => (int)$this->session->userdata('id'),
            'prize_status' => 0,
            'status' => 1,
            'date_created' => $this->toDateTime,
        ];

        $this->db->insert('tbl_league', $data);
        return $this->db->insert_id();
    }

    public function update_league()
    {
        $id = (int)$this->input->post('edit_id');

        $data = [
            'name' => $this->input->post('name'),
            'language_id' => $this->input->post('language_id') ?? 0,
            'start_date' => $this->input->post('start_date'),
            'end_date' => $this->input->post('end_date'),
            'description' => $this->input->post('description'),
            'entry' => (int)$this->input->post('entry'),
            'date_updated' => $this->toDateTime,
        ];

        $this->db->where('id', $id)->update('tbl_league', $data);
        return true;
    }

    public function delete_league($id)
    {
        $this->db->where('league_id', $id)->delete('tbl_league_prize');
        $this->db->where('league_id', $id)->delete('tbl_league_notification_log');
        $this->db->where('league_id', $id)->delete('tbl_league_submission');
        $this->db->where('league_id', $id)->delete('tbl_league_daily_quiz_questions');
        $this->db->where('league_id', $id)->delete('tbl_league_daily_quiz');
        $this->db->where('league_id', $id)->delete('tbl_league_leaderboard');
        $this->db->where('league_id', $id)->delete('tbl_league_user');
        $this->db->where('id', $id)->delete('tbl_league');
    }

    public function update_status()
    {
        $id = (int)$this->input->post('update_id');
        $status = (int)$this->input->post('status');
        $this->db->where('id', $id)->update('tbl_league', ['status' => $status]);
    }

    public function add_daily_quiz()
    {
        $league_id = (int)$this->input->post('league_id');
        $quiz_day = (int)$this->input->post('quiz_day');
        $quiz_date = $this->input->post('quiz_date');
        $question_ids = $this->input->post('question_ids');

        $daily = [
            'league_id' => $league_id,
            'quiz_day' => $quiz_day,
            'quiz_date' => $quiz_date,
            'question_count' => is_array($question_ids) ? count($question_ids) : 0,
            'date_assigned' => $this->toDateTime,
        ];

        $exists = $this->db->where('league_id', $league_id)->where('quiz_day', $quiz_day)->get('tbl_league_daily_quiz')->row_array();
        if (!empty($exists)) {
            $daily_id = (int)$exists['id'];
            $this->db->where('id', $daily_id)->update('tbl_league_daily_quiz', $daily);
            $this->db->where('daily_quiz_id', $daily_id)->delete('tbl_league_daily_quiz_questions');
        } else {
            $this->db->insert('tbl_league_daily_quiz', $daily);
            $daily_id = (int)$this->db->insert_id();
        }

        if (is_array($question_ids)) {
            $order = 1;
            foreach ($question_ids as $qid) {
                $this->db->insert('tbl_league_daily_quiz_questions', [
                    'daily_quiz_id' => $daily_id,
                    'question_id' => (int)$qid,
                    'question_order' => $order,
                ]);
                $order++;
            }
        }

        return $daily_id;
    }

    public function get_max_top_winner($id)
    {
        return $this->db
            ->select('top_winner as total')
            ->where('league_id', $id)
            ->order_by('top_winner', 'DESC')
            ->limit(1)
            ->get('tbl_league_prize')
            ->result();
    }

    public function add_league_prize()
    {
        $data = [
            'league_id' => (int)$this->input->post('league_id'),
            'top_winner' => (int)$this->input->post('winner'),
            'points' => (int)$this->input->post('points'),
        ];
        $this->db->insert('tbl_league_prize', $data);
    }

    public function update_league_prize()
    {
        $id = (int)$this->input->post('edit_id');
        $data = [
            'points' => (int)$this->input->post('points')
        ];
        $this->db->where('id', $id)->update('tbl_league_prize', $data);
    }

    public function delete_league_prize($id)
    {
        $this->db->where('id', (int)$id)->delete('tbl_league_prize');
    }
}
