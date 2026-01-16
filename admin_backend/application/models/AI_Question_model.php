<?php

defined('BASEPATH') or exit('No direct script access allowed');

class AI_Question_model extends CI_Model
{
    public function add_data($data)
    {
        $generatedQuestion = $data['generatedQuestion'] ?? [];
        $metadata = $data['metadata'] ?? [];
        if (is_string($generatedQuestion)) {
            $decoded = json_decode($generatedQuestion, true);
            if (json_last_error() === JSON_ERROR_NONE) {
                $generatedQuestion = $decoded;
            } else {
                $generatedQuestion = [];
            }
        }
        if (!isset($generatedQuestion[0]['question'])) {
            return;
        }

        $chunkSize = 10;

        $questionChunks = array_chunk($generatedQuestion, $chunkSize);

        foreach ($questionChunks as $chunkIndex =>  $chunk) {
            $insertBatch = [];

            foreach ($chunk as $q) {
                $insertBatch[] = array_merge($metadata, [
                    'question' => $q['question'] ?? '',
                    'note' => $q['note'] ?? '',
                    'options' => json_encode($q['options'] ?? []),
                    'correct_answer' => is_array($q['correctAnswer'] ?? $q['correct_answer'] ?? '')
                        ? json_encode($q['correctAnswer'] ?? $q['correct_answer'] ?? [])
                        : ($q['correctAnswer'] ?? $q['correct_answer'] ?? ''),
                ]);
            }

            if (!empty($insertBatch)) {
                $this->db->insert_batch('tbl_ai_questions', $insertBatch);
            } else {
                log_message('error', "Empty or invalid chunk $chunkIndex, skipping insert.");
            }
        }
        return TRUE;
    }

    public function update_data()
    {
        $id = $this->input->post('edit_id');
        $getData = $this->db->where('id', $id)->get('tbl_ai_questions')->row_array();
        $quiz_type = $getData['quiz_type'];
        $correct_answer = '';

        $question = $this->input->post('question');
        $question_type = $this->input->post('edit_question_type') ?? 0;
        $a = $this->input->post('a');
        $b = $this->input->post('b');
        $c = ($question_type == 1) ? $this->input->post('c') : "";
        $d = ($question_type == 1) ? $this->input->post('d') : "";
        $e = ($this->input->post('e')) ? $this->input->post('e') : "";

        $optionData = [
            'a' => $a,
            'b' => $b,
        ];
        if ($question_type == 1) {
            $optionData['c'] = $c;
            $optionData['d'] = $d;
            $optionData['e'] = $e;
        }

        $options = json_encode($optionData);

        $answer_type = $this->input->post('edit_answer_type') ?? 1;
        $level = $this->input->post('level') ?? 0;
        $note = $this->input->post('note');
        $marks = $this->input->post('marks') ?? 0;

        switch ($quiz_type) {
            case 1:
                $correct_answer = $this->input->post('quiz_answer') ?? '';
                $insertData = [
                    'question'  => $question,
                    'question_type'  => $question_type,
                    'options'  => $options,
                    'correct_answer'  => $correct_answer,
                    'level'  => $level,
                    'note'  => $note,
                ];
                break;
            case 3:
                $correct_answer = $this->input->post('textAnswer') ?? '';
                $insertData = [
                    'question'  => $question,
                    'correct_answer'  => $correct_answer,
                    'note'  => $note,
                ];
                break;
            case 6:
                if ($answer_type == 2) {
                    $correct_answer = ($this->input->post('text_answer')) ? $this->input->post('text_answer') : '';
                } else {
                    $correct_answer = ($this->input->post('answer')) ? implode(',', $this->input->post('answer')) : '';
                }
                $insertData = [
                    'question'  => $question,
                    'question_type'  => $question_type,
                    'options'  => $options,
                    'answer_type'  => $answer_type,
                    'correct_answer'  => $correct_answer,
                    'level'  => $level,
                    'note'  => $note,
                ];
                break;
            case 7:
                $correct_answer = $this->input->post('quiz_answer') ?? '';
                $insertData = [
                    'question'  => $question,
                    'question_type'  => $question_type,
                    'options'  => $options,
                    'correct_answer'  => $correct_answer,
                    'note'  => $note,
                ];
                break;
            case 8:
                $correct_answer = $this->input->post('quiz_answer') ?? '';
                $insertData = [
                    'marks'  => $marks,
                    'question'  => $question,
                    'question_type'  => $question_type,
                    'options'  => $options,
                    'correct_answer'  => $correct_answer,
                ];
                break;
            default:
                break;
        }
        $data = $this->db->where('id', $id)->update('tbl_ai_questions', $insertData);
        return $data;
    }

    public function delete_data($id)
    {
        $this->db->where('id', $id)->delete('tbl_ai_questions');
    }

    public function moveQuestion()
    {
        $is_multiple = $this->input->post('is_multiple');
        if ($is_multiple) {
            $ids = $this->input->post('ids');
            $getAllData = $this->db->where_in('id', explode(',', $ids))->get('tbl_ai_questions')->result_array();
        } else {
            $id = $this->input->post('id');
            $getAllData = $this->db->where('id', $id)->get('tbl_ai_questions')->result_array();
        }

        if (empty($getAllData)) {
            return false;
        }

        $batches = array_chunk($getAllData, 25);
        if (empty($batches)) {
            return false;
        }
        foreach ($batches as $getbatch) {
            if (empty($getbatch)) {
                return false;
            }
            foreach ($getbatch as $getData) {
                $id = $getData['id'];
                $language_id = $getData['language_id'];
                $quiz_type = $getData['quiz_type'];
                $contest_id = $getData['contest_id'];
                $exam_id = $getData['exam_id'];
                $category = $getData['category'];
                $subcategory = $getData['subcategory'];
                $level = $getData['level'];
                $question_type = $getData['question_type'];
                $answer_type = $getData['answer_type'];
                $question = $getData['question'];
                $get_options = $getData['options'];
                $options = json_decode($get_options, true);
                $optiona = $options['a'] ?? "";
                $optionb = $options['b'] ?? "";
                $optionc = $options['c'] ?? "";
                $optiond = $options['d'] ?? "";
                $optione = $options['e'] ?? "";
                $correct_answer = $getData['correct_answer'];
                $marks = $getData['marks'] ?? 0;
                $note = $getData['note'] ?? '';
                $table = '';

                switch ($quiz_type) {
                    case 1:
                        $table = 'tbl_question';
                        $insertData = [
                            'category'  => $category,
                            'subcategory'  => $subcategory,
                            'language_id'  => $language_id,
                            'image'  => '',
                            'question'  => $question,
                            'question_type'  => $question_type,
                            'optiona'  => $optiona,
                            'optionb'  => $optionb,
                            'optionc'  => $optionc,
                            'optiond'  => $optiond,
                            'optione'  => $optione,
                            'answer'  => $correct_answer,
                            'level'  => $level,
                            'note'  => $note,
                        ];
                        break;
                    case 3:
                        $table = 'tbl_guess_the_word';
                        $insertData = [
                            'category'  => $category,
                            'subcategory'  => $subcategory,
                            'language_id'  => $language_id,
                            'image'  => '',
                            'question'  => $question,
                            'answer'  => $correct_answer,
                        ];
                        break;
                    case 6:
                        $table = 'tbl_multi_match';
                        $insertData = [
                            'category'  => $category,
                            'subcategory'  => $subcategory,
                            'language_id'  => $language_id,
                            'image'  => '',
                            'question'  => $question,
                            'question_type'  => $question_type,
                            'optiona'  => $optiona,
                            'optionb'  => $optionb,
                            'optionc'  => $optionc,
                            'optiond'  => $optiond,
                            'optione'  => $optione,
                            'answer_type'  => $answer_type,
                            'answer'  => $correct_answer,
                            'level'  => $level,
                            'note'  => $note,
                        ];
                        break;
                    case 7:
                        $table = 'tbl_contest_question';
                        $insertData = [
                            'contest_id'  => $contest_id,
                            'langauge_id'  => $language_id,
                            'image'  => '',
                            'question'  => $question,
                            'question_type'  => $question_type,
                            'optiona'  => $optiona,
                            'optionb'  => $optionb,
                            'optionc'  => $optionc,
                            'optiond'  => $optiond,
                            'optione'  => $optione,
                            'answer'  => $correct_answer,
                            'note'  => $note,
                        ];
                        break;
                    case 8:
                        $table = 'tbl_exam_module_question';
                        $insertData = [
                            'exam_module_id'  => $exam_id,
                            'image'  => '',
                            'marks'  => $marks,
                            'question'  => $question,
                            'question_type'  => $question_type,
                            'optiona'  => $optiona,
                            'optionb'  => $optionb,
                            'optionc'  => $optionc,
                            'optiond'  => $optiond,
                            'optione'  => $optione,
                            'answer'  => $correct_answer,
                        ];
                        break;
                    default:
                        break;
                }

                if ($table) {
                    $this->db->insert($table, $insertData);
                    $this->db->where('id', $id)->update('tbl_ai_questions', ['status' => 1]);
                }
            }
        }
        return true;
    }
}
