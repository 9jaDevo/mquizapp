<?php

defined('BASEPATH') or exit('No direct script access allowed');


class AI_Questions extends CI_Controller
{
    public $toDateTime;
    public function __construct()
    {
        parent::__construct();
        if (!$this->session->userdata('isLoggedIn')) {
            redirect('/');
        }
        $this->load->config('quiz');
        date_default_timezone_set(get_system_timezone());
        $this->toDateTime = date('Y-m-d H:i:s');
        $this->result['language'] = $this->Language_model->get_data();
    }

    function getQuizType()
    {
        $quiz_type = [
            ['id' => 1, 'name' => lang('quiz_zone')],
            ['id' => 3, 'name' => lang('guess_the_word')],
            ['id' => 6, 'name' => lang('multi_match')],
            ['id' => 7, 'name' => lang('contests')],
            ['id' => 8, 'name' => lang('exam_module')]
        ];
        return json_encode($quiz_type);
    }

    public function index()
    {

        if (!has_permissions('read', 'ai_question_bank')) {
            redirect('/');
        } else {
            if ($this->input->post('btnadd')) {
                if (!has_permissions('create', 'ai_question_bank')) {
                    $this->session->set_flashdata('error', lang(PERMISSION_ERROR_MSG));
                } else {
                    $getData = $this->generateAIQuestion();
                    if (isset($getData['generatedQuestion'])) {
                        $data = $this->AI_Question_model->add_data($getData);
                        if ($data) {
                            $this->session->set_flashdata('success', lang('question_created_successfully'));
                        } else {
                            $this->session->set_flashdata('error', lang('something_wrong_please_try_again1'));
                        }
                    } else {
                        if (isset($getData['error']) && $getData['error']) {
                            $msg = $getData['msg'] ?? '';
                            $this->session->set_flashdata('error', $msg);
                        } else {
                            $this->session->set_flashdata('error', lang('something_wrong_please_try_again'));
                        }
                    }
                }
                redirect('create-ai-questions');
            } else if ($this->input->post('btnupdate')) {
                if (!has_permissions('update', 'ai_question_bank')) {
                    $this->session->set_flashdata('error', lang(PERMISSION_ERROR_MSG));
                } else {
                    $data = $this->AI_Question_model->update_data();
                    if ($data) {
                        $this->session->set_flashdata('success', lang('question_updated_successfully'));
                    } else {
                        $this->session->set_flashdata('error', lang('something_wrong_please_try_again'));
                    }
                }
                redirect('create-ai-questions');
            }
            $this->result['quiz_type'] = $this->getQuizType();
            $this->load->view('ai_questions_create', $this->result);
        }
    }

    public function manage_ai_questions()
    {
        if (!has_permissions('read', 'ai_question_bank')) {
            redirect('/');
        } else {
            $this->result['quiz_type'] = $this->getQuizType();
            $this->load->view('ai_questions_manage', $this->result);
        }
    }

    public function delete_ai_questions()
    {
        if (!has_permissions('delete', 'ai_question_bank')) {
            echo false;
        } else {
            $id = $this->input->post('id');
            $this->AI_Question_model->delete_data($id);
            echo TRUE;
        }
    }

    public function generateAIQuestion()
    {
        if (!has_permissions('create', 'ai_question_bank')) {
            $this->session->set_flashdata('error', PERMISSION_ERROR_MSG);
        } else {
            $this->load->library('AIService');
            $quiz_type = $this->input->post('quiz_type');
            $no_of_question = $this->input->post('no_of_question_generate');

            switch ($quiz_type) {
                case 1:
                    $level = $this->input->post('level');
                    $language_id = $this->input->post('language_id');
                    $language = $this->db->select('language')->where('id', $language_id)->limit(1)->get('tbl_languages')->row()->language;

                    $category = $this->input->post('category');
                    $category_name = $this->db->select('category_name')->where('id', $category)->limit(1)->get('tbl_category')->row()->category_name;

                    $subcategory = $this->input->post('subcategory') ? $this->input->post('subcategory') : 0;
                    $subcategory_name = $this->db->select('subcategory_name')->where('id', $subcategory)->limit(1)->get('tbl_subcategory')->row()->subcategory_name ?? '';

                    $question_type = $this->input->post('question_type');
                    $data = [
                        'quiz_type' => $quiz_type,
                        'language' => $language,
                        'category' => $category_name,
                        'subcategory' => $subcategory_name ? $subcategory_name : '',
                        'question_type' => $question_type,
                        'level' => $level,
                        'total_questions' => $no_of_question,
                    ];
                    break;
                case 3:
                    $language_id = $this->input->post('language_id');
                    $language = $this->db->select('language')->where('id', $language_id)->limit(1)->get('tbl_languages')->row()->language;

                    $category = $this->input->post('category');
                    $category_name = $this->db->select('category_name')->where('id', $category)->limit(1)->get('tbl_category')->row()->category_name;

                    $subcategory = $this->input->post('subcategory') ? $this->input->post('subcategory') : 0;
                    $subcategory_name = $this->db->select('subcategory_name')->where('id', $subcategory)->limit(1)->get('tbl_subcategory')->row()->subcategory_name ?? '';

                    $data = [
                        'quiz_type' => $quiz_type,
                        'language' => $language,
                        'category' => $category_name,
                        'subcategory' => $subcategory_name ? $subcategory_name : '',
                        'total_questions' => $no_of_question,
                    ];
                    break;
                case 6:
                    $level = $this->input->post('level');

                    $language_id = $this->input->post('language_id');
                    $language = $this->db->select('language')->where('id', $language_id)->limit(1)->get('tbl_languages')->row()->language;

                    $category = $this->input->post('category');
                    $category_name = $this->db->select('category_name')->where('id', $category)->limit(1)->get('tbl_category')->row()->category_name;

                    $subcategory = $this->input->post('subcategory') ? $this->input->post('subcategory') : 0;
                    $subcategory_name = $this->db->select('subcategory_name')->where('id', $subcategory)->limit(1)->get('tbl_subcategory')->row()->subcategory_name ?? '';

                    $question_type = $this->input->post('question_type');
                    $answer_type = $this->input->post('answer_type');
                    $data = [
                        'quiz_type' => $quiz_type,
                        'language' => $language,
                        'category' => $category_name,
                        'subcategory' => $subcategory_name ? $subcategory_name : '',
                        'question_type' => $question_type,
                        'answer_type' => $answer_type,
                        'level' => $level,
                        'total_questions' => $no_of_question,
                    ];
                    break;
                case 7:
                    $language_id = $this->input->post('language_id');
                    $language = $this->db->select('language')->where('id', $language_id)->limit(1)->get('tbl_languages')->row()->language;

                    $contest_id = $this->input->post('contest_id');
                    $contest_name = $this->db->select('name')->where('id', $contest_id)->limit(1)->get('tbl_contest')->row()->name;

                    $question_type = $this->input->post('question_type');
                    $contest_detail = $this->input->post('contest_detail');
                    $data = [
                        'quiz_type' => $quiz_type,
                        'language' => $language,
                        'contest' => $contest_name ? $contest_name : '',
                        'question_type' => $question_type,
                        'detail' => $contest_detail,
                        'total_questions' => $no_of_question,
                    ];
                    break;
                case 8:
                    $language_id = $this->input->post('language_id');
                    $language = $this->db->select('language')->where('id', $language_id)->limit(1)->get('tbl_languages')->row()->language;

                    $exam_id = $this->input->post('exam_id');
                    $exam_name = $this->db->select('title')->where('id', $exam_id)->limit(1)->get('tbl_exam_module')->row()->title;

                    $question_type = $this->input->post('question_type');
                    $exam_detail = $this->input->post('exam_detail');
                    $marks = $this->input->post('marks') ? $this->input->post('marks') : 0;
                    $data = [
                        'quiz_type' => $quiz_type,
                        'language' => $language,
                        'exam' => $exam_name ? $exam_name : '',
                        'question_type' => $question_type,
                        'detail' => $exam_detail,
                        'marks' => $marks,
                        'total_questions' => $no_of_question,
                    ];
                    break;
                default:
                    break;
            }

            if ($data) {
                $generateQuestion = $this->aiservice->generate($data);
                $metadata =  [
                    'language_id' => $language_id ?? 0,
                    'quiz_type' => $quiz_type ?? 0,
                    'contest_id' => $contest_id ?? 0,
                    'exam_id' => $exam_id ?? 0,
                    'category' => $category ?? 0,
                    'subcategory' => $subcategory ?? 0,
                    'level' => $level ?? 0,
                    'question_type' => $question_type ?? 0,
                    'answer_type' => $answer_type ?? 0,
                    'marks' => $marks ?? 0,
                    'status' => 0,
                    'date_time' => $this->toDateTime,
                ];
                if ($generateQuestion) {
                    if (!isset($generateQuestion['error'])) {
                        return ['generatedQuestion' => $generateQuestion, 'metadata' => $metadata];
                    } else {
                        return $generateQuestion;
                    }
                } else {
                    return false;
                }
            }
            return false;
        }
    }

    public function moveQuestion()
    {
        if (!has_permissions('create', 'ai_question_bank')) {
            echo false;
        } else {
            $data = $this->AI_Question_model->moveQuestion();
            if ($data) {
                echo true;
            } else {
                echo false;
            }
        }
    }
}
