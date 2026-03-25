<?php

defined('BASEPATH') or exit('No direct script access allowed');

class League_model extends CI_Model
{
    public $toDateTime;
    private $last_error = '';

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
        $this->last_error = '';
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

        if ($this->league_image_column_exists()) {
            $data['image'] = '';
        }

        if ($this->league_image_column_exists() && !empty($_FILES['file']['name'])) {
            $upload = $this->upload_league_image('file');
            if (empty($upload['success'])) {
                $this->last_error = $upload['message'];
                return false;
            }
            $data['image'] = $upload['file_name'];
        }

        $this->db->insert('tbl_league', $data);
        return $this->db->insert_id();
    }

    public function update_league()
    {
        $this->last_error = '';
        $id = (int)$this->input->post('edit_id');
        $oldImage = $this->input->post('old_image') ?? '';

        $data = [
            'name' => $this->input->post('name'),
            'language_id' => $this->input->post('language_id') ?? 0,
            'start_date' => $this->input->post('start_date'),
            'end_date' => $this->input->post('end_date'),
            'description' => $this->input->post('description'),
            'entry' => (int)$this->input->post('entry'),
            'date_updated' => $this->toDateTime,
        ];

        if ($this->league_image_column_exists() && !empty($_FILES['update_file']['name'])) {
            $upload = $this->upload_league_image('update_file', $oldImage);
            if (empty($upload['success'])) {
                $this->last_error = $upload['message'];
                return false;
            }
            $data['image'] = $upload['file_name'];
        }

        $this->db->where('id', $id)->update('tbl_league', $data);
        return true;
    }

    public function get_last_error()
    {
        return !empty($this->last_error) ? $this->last_error : IMAGE_ALLOW_MSG;
    }

    public function delete_league($id)
    {
        if ($this->league_image_column_exists()) {
            $row = $this->db->select('image')->where('id', (int)$id)->get('tbl_league')->row();
            if (!empty($row) && !empty($row->image) && file_exists(LEAGUE_IMG_PATH . $row->image)) {
                unlink(LEAGUE_IMG_PATH . $row->image);
            }
        }

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

        return $this->upsert_daily_quiz_assignment($league_id, $quiz_day, $quiz_date, $question_ids);
    }

    public function add_daily_quiz_auto($payload)
    {
        $league_id = (int)($payload['league_id'] ?? 0);
        $quiz_day = (int)($payload['quiz_day'] ?? 0);
        $quiz_date = $payload['quiz_date'] ?? '';
        $question_count = (int)($payload['question_count'] ?? 20);
        $category_id = (int)($payload['category_id'] ?? 0);
        $subcategory_id = (int)($payload['subcategory_id'] ?? 0);

        $easy_percent = max(0, (int)($payload['easy_percent'] ?? 30));
        $medium_percent = max(0, (int)($payload['medium_percent'] ?? 50));
        $hard_percent = max(0, (int)($payload['hard_percent'] ?? 20));

        if ($league_id <= 0 || $quiz_day <= 0 || empty($quiz_date) || $category_id <= 0 || $question_count <= 0) {
            return [
                'success' => false,
                'message' => 'Invalid automation inputs.',
                'assigned_count' => 0,
                'used_fallback' => false,
            ];
        }

        $total_percent = $easy_percent + $medium_percent + $hard_percent;
        if ($total_percent <= 0) {
            $easy_percent = 30;
            $medium_percent = 50;
            $hard_percent = 20;
            $total_percent = 100;
        }

        $league = $this->db->where('id', $league_id)->get('tbl_league')->row_array();
        if (empty($league)) {
            return [
                'success' => false,
                'message' => 'League not found.',
                'assigned_count' => 0,
                'used_fallback' => false,
            ];
        }

        $language_id = (int)($league['language_id'] ?? 0);

        $targetEasy = (int)round(($question_count * $easy_percent) / $total_percent);
        $targetMedium = (int)round(($question_count * $medium_percent) / $total_percent);
        $targetHard = $question_count - ($targetEasy + $targetMedium);

        $selectedQuestionIds = [];
        $usedFallback = false;

        $levelTargets = [
            1 => max(0, $targetEasy),
            2 => max(0, $targetMedium),
            3 => max(0, $targetHard),
        ];

        foreach ($levelTargets as $level => $targetCount) {
            if ($targetCount <= 0) {
                continue;
            }

            $rows = $this->fetch_question_pool([
                'category_id' => $category_id,
                'subcategory_id' => $subcategory_id,
                'language_id' => $language_id,
                'level' => $level,
                'limit' => $targetCount,
                'exclude_ids' => $selectedQuestionIds,
            ]);

            foreach ($rows as $row) {
                $selectedQuestionIds[] = (int)$row['id'];
            }

            if (count($rows) < $targetCount && $subcategory_id > 0) {
                $usedFallback = true;
                $remaining = $targetCount - count($rows);
                $fallbackRows = $this->fetch_question_pool([
                    'category_id' => $category_id,
                    'subcategory_id' => 0,
                    'language_id' => $language_id,
                    'level' => $level,
                    'limit' => $remaining,
                    'exclude_ids' => $selectedQuestionIds,
                ]);
                foreach ($fallbackRows as $row) {
                    $selectedQuestionIds[] = (int)$row['id'];
                }
            }
        }

        if (count($selectedQuestionIds) < $question_count) {
            $usedFallback = true;
            $remaining = $question_count - count($selectedQuestionIds);
            $fillRows = $this->fetch_question_pool([
                'category_id' => $category_id,
                'subcategory_id' => 0,
                'language_id' => $language_id,
                'level' => null,
                'limit' => $remaining,
                'exclude_ids' => $selectedQuestionIds,
            ]);
            foreach ($fillRows as $row) {
                $selectedQuestionIds[] = (int)$row['id'];
            }
        }

        if (count($selectedQuestionIds) < $question_count && $language_id > 0) {
            $usedFallback = true;
            $remaining = $question_count - count($selectedQuestionIds);
            $languageRelaxRows = $this->fetch_question_pool([
                'category_id' => $category_id,
                'subcategory_id' => 0,
                'language_id' => 0,
                'level' => null,
                'limit' => $remaining,
                'exclude_ids' => $selectedQuestionIds,
            ]);
            foreach ($languageRelaxRows as $row) {
                $selectedQuestionIds[] = (int)$row['id'];
            }
        }

        if (empty($selectedQuestionIds)) {
            return [
                'success' => false,
                'message' => 'No questions found for selected automation rules.',
                'assigned_count' => 0,
                'used_fallback' => $usedFallback,
            ];
        }

        shuffle($selectedQuestionIds);
        $selectedQuestionIds = array_slice($selectedQuestionIds, 0, $question_count);

        $contestQuestionIds = [];
        foreach ($selectedQuestionIds as $sourceQuestionId) {
            $contestQuestionId = $this->materialize_to_contest_question((int)$sourceQuestionId);
            if ($contestQuestionId > 0) {
                $contestQuestionIds[] = $contestQuestionId;
            }
        }

        if (empty($contestQuestionIds)) {
            return [
                'success' => false,
                'message' => 'Failed to prepare contest question set for league assignment.',
                'assigned_count' => 0,
                'used_fallback' => $usedFallback,
            ];
        }

        $this->upsert_daily_quiz_assignment($league_id, $quiz_day, $quiz_date, $contestQuestionIds);

        return [
            'success' => true,
            'message' => 'Auto assignment completed.',
            'assigned_count' => count($contestQuestionIds),
            'used_fallback' => $usedFallback,
        ];
    }

    public function get_auto_assignment_categories()
    {
        $rows = $this->db->select('id, category_name, type, row_order')
            ->where('type', 'quiz-zone')
            ->order_by('row_order', 'ASC')
            ->get('tbl_category')
            ->result();

        if (!empty($rows)) {
            return $rows;
        }

        return $this->db->select('id, category_name, type, row_order')
            ->order_by('row_order', 'ASC')
            ->get('tbl_category')
            ->result();
    }

    public function get_auto_assignment_subcategories()
    {
        return $this->db->select('id, maincat_id, subcategory_name')
            ->order_by('id', 'ASC')
            ->get('tbl_subcategory')
            ->result();
    }

    public function get_daily_quiz_assignments()
    {
        return $this->db->select('dq.id, dq.league_id, dq.quiz_day, dq.quiz_date, dq.question_count, dq.date_assigned, l.name as league_name')
            ->from('tbl_league_daily_quiz dq')
            ->join('tbl_league l', 'l.id = dq.league_id', 'left')
            ->order_by('dq.quiz_date', 'DESC')
            ->order_by('dq.quiz_day', 'ASC')
            ->get()
            ->result();
    }

    public function update_daily_quiz_meta()
    {
        $id = (int)$this->input->post('edit_id');
        $league_id = (int)$this->input->post('league_id');
        $quiz_day = (int)$this->input->post('quiz_day');
        $quiz_date = $this->input->post('quiz_date');

        if ($id <= 0 || $league_id <= 0 || $quiz_day <= 0 || empty($quiz_date)) {
            return false;
        }

        $duplicate = $this->db->where('league_id', $league_id)
            ->where('quiz_day', $quiz_day)
            ->where('id !=', $id)
            ->get('tbl_league_daily_quiz')
            ->row_array();

        if (!empty($duplicate)) {
            return false;
        }

        $data = [
            'league_id' => $league_id,
            'quiz_day' => $quiz_day,
            'quiz_date' => $quiz_date,
            'date_assigned' => $this->toDateTime,
        ];

        $this->db->where('id', $id)->update('tbl_league_daily_quiz', $data);
        return $this->db->affected_rows() >= 0;
    }

    public function delete_daily_quiz($id)
    {
        $id = (int)$id;
        if ($id <= 0) {
            return;
        }

        $this->db->where('daily_quiz_id', $id)->delete('tbl_league_daily_quiz_questions');
        $this->db->where('id', $id)->delete('tbl_league_daily_quiz');
    }

    private function upsert_daily_quiz_assignment($league_id, $quiz_day, $quiz_date, $question_ids)
    {
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

    private function fetch_question_pool($options)
    {
        $category_id = (int)($options['category_id'] ?? 0);
        $subcategory_id = (int)($options['subcategory_id'] ?? 0);
        $language_id = (int)($options['language_id'] ?? 0);
        $level = isset($options['level']) ? $options['level'] : null;
        $limit = (int)($options['limit'] ?? 0);
        $exclude_ids = $options['exclude_ids'] ?? [];

        $this->db->select('id')
            ->from('tbl_question')
            ->where('category', $category_id);

        if ($subcategory_id > 0) {
            $this->db->where('subcategory', $subcategory_id);
        }

        if ($language_id > 0) {
            $this->db->where('language_id', $language_id);
        }

        if ($level !== null) {
            $this->db->where('level', (int)$level);
        }

        if (!empty($exclude_ids)) {
            $exclude_ids = array_map('intval', $exclude_ids);
            $this->db->where_not_in('id', $exclude_ids);
        }

        $this->db->order_by('RAND()');

        if ($limit > 0) {
            $this->db->limit($limit);
        }

        return $this->db->get()->result_array();
    }

    private function materialize_to_contest_question($sourceQuestionId)
    {
        $source = $this->db->where('id', (int)$sourceQuestionId)->get('tbl_question')->row_array();
        if (empty($source)) {
            return 0;
        }

        $insertData = [
            'contest_id' => 0,
            'question' => $source['question'] ?? '',
            'question_type' => $source['question_type'] ?? 1,
            'optiona' => $source['optiona'] ?? '',
            'optionb' => $source['optionb'] ?? '',
            'optionc' => $source['optionc'] ?? '',
            'optiond' => $source['optiond'] ?? '',
            'optione' => $source['optione'] ?? '',
            'answer' => $source['answer'] ?? '',
            'note' => $source['note'] ?? '',
            'image' => $source['image'] ?? '',
        ];

        $this->db->insert('tbl_contest_question', $insertData);
        return (int)$this->db->insert_id();
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

    private function league_image_column_exists()
    {
        static $exists = null;
        if ($exists === null) {
            $exists = $this->db->field_exists('image', 'tbl_league');
        }

        return $exists;
    }

    private function upload_league_image($fileField, $oldImage = '')
    {
        if (!is_dir(LEAGUE_IMG_PATH)) {
            mkdir(LEAGUE_IMG_PATH, 0777, true);
        }

        $config['upload_path'] = LEAGUE_IMG_PATH;
        $config['allowed_types'] = IMG_ALLOWED_TYPES;
        $config['file_name'] = time() . '_' . mt_rand(1000, 9999);

        $this->load->library('upload', $config);
        $this->upload->initialize($config);

        if (!$this->upload->do_upload($fileField)) {
            return [
                'success' => false,
                'message' => $this->upload->display_errors('', ''),
            ];
        }

        $uploaded = $this->upload->data();
        if (!empty($oldImage) && file_exists(LEAGUE_IMG_PATH . $oldImage)) {
            unlink(LEAGUE_IMG_PATH . $oldImage);
        }

        return [
            'success' => true,
            'file_name' => $uploaded['file_name'],
        ];
    }
}
