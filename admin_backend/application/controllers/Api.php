<?php

defined('BASEPATH') or exit('No direct script access allowed');

require APPPATH . '/libraries/REST_Controller.php';
require FCPATH . 'vendor/autoload.php';

use Kreait\Firebase\Factory;
use Kreait\Firebase\Messaging\CloudMessage;
use ReceiptValidator\iTunes\Validator as iTunesValidator;

class Api extends REST_Controller
{
    public function __construct()
    {
        parent::__construct();
        $this->load->database();
        // Default image
        $this->NO_IMAGE = base_url() . LOGO_IMG_PATH . is_settings('half_logo');

        date_default_timezone_set(get_system_timezone());

        $this->toDate = date('Y-m-d');
        $this->twoDayOldDate = date('Y-m-d', strtotime('-2 days'));
        $this->toDateTime = date('Y-m-d H:i:s');
        $this->twoDayOldDateTime = date('Y-m-d H:i:s', strtotime('-2 days'));
        $this->toContestDateTime = date('Y-m-d H:i:00');
        $this->load->library('JWT');
        $jwtKey = $this->db->where('type', 'jwt_key')->get('tbl_settings')->row_array();
        $jwtKey = $jwtKey['message'];
        $this->JWT_SECRET_KEY = "$jwtKey";

        $this->systemTimezoneGMT = is_settings('system_timezone_gmt') ? is_settings('system_timezone_gmt') : 'Asia/Kolkata';
        $this->systemTimezone = is_settings('system_timezone') ? is_settings('system_timezone') : '+05:30';

        $questionShuffleMode = $this->db->where('type', 'question_shuffle_mode')->get('tbl_settings')->row_array();
        $questionShuffleMode = $questionShuffleMode['message'];
        if ($questionShuffleMode) {
            $this->Order_By = 'rand()';
        } else {
            $this->Order_By = 'id';
        }

        $optionShuffleMode = $this->db->where('type', 'option_shuffle_mode')->get('tbl_settings')->row_array();
        $optionShuffleMode = $optionShuffleMode['message'];
        $this->OPTION_SHUFFLE_MODE = "$optionShuffleMode";

        $this->DASHING_DEBUT = 'dashing_debut';
        $this->COMBAT_WINNER = 'combat_winner';
        $this->CLASH_WINNER = 'clash_winner';
        $this->ULTIMATE_PLAYER = 'ultimate_player';
        $this->QUIZ_WARRIOR = 'quiz_warrior';
        $this->SUPER_SONIC = 'super_sonic';
        $this->FLASHBACK = 'flashback';
        $this->BRAINIAC = 'brainiac';
        $this->BIG_THING = 'big_thing';
        $this->ELITE = 'elite';
        $this->THIRSTY = 'thirsty';
        $this->POWER_ELITE = 'power_elite';
        $this->SHARING_CARING = 'sharing_caring';
        $this->STREAK = 'streak';
        $this->refer_coin_msg = 'usedReferCode';
        $this->earn_coin_msg = 'referCodeToFriend';
        $this->opening_msg = 'welcomeBonus';
        $this->watched_ads = 'watchedAds';
        $this->minimumQuestionsForBadge = 5;
    }

    /**
     * Default GET handler to avoid REST_Controller callback errors when hitting /Api without a specific method.
     */
    public function index_get()
    {
        $response['error'] = true;
        $response['message'] = 'Invalid endpoint';
        return $this->response($response, REST_Controller::HTTP_BAD_REQUEST);
    }

    public function user_signup_post()
    {

        error_log('[BACKEND user_signup_post] Received POST data - firebase_id: ' . $this->post('firebase_id') . ', email: ' . $this->post('email') . ', name: ' . $this->post('name'));

        if ($this->post('firebase_id') && $this->post('type') && ($this->post('firebase_id') != 'null') && ($this->post('firebase_id') != 'NULL')) {
            $firebase_id = $this->post('firebase_id');
            error_log('[BACKEND user_signup_post] Processing firebase_id: ' . $firebase_id);

            // ------- Should be Enabled for server  ----------
            $is_verify = $this->verify_user($firebase_id);
            // ---------------------------------------------------
            // ------- Should be Disable for server  ----------
            // $is_verify=true;
            // ---------------------------------------------------
            if ($is_verify) {
                $type = $this->post('type');
                $email = ($this->post('email')) ? $this->post('email') : '';
                $name = ($this->post('name')) ? $this->post('name') : '';
                $mobile = ($this->post('mobile')) ? $this->post('mobile') : '';
                $profile = ($this->post('profile')) ? $this->post('profile') : '';
                $fcm_id = ($this->post('fcm_id')) ? $this->post('fcm_id') : '';
                $web_fcm_id = ($this->post('web_fcm_id')) ? $this->post('web_fcm_id') : '';
                $friends_code = ($this->post('friends_code')) ? $this->post('friends_code') : '';
                // Status is always set by the backend — never trust the client
                $status = '1';
                $refer_coin = is_settings('refer_coin');
                $earn_coin = is_settings('earn_coin');

                error_log('[BACKEND] user_signup_post - firebase_id: ' . $firebase_id . ', email: ' . $email);

                if (!empty($friends_code)) {
                    $code = valid_friends_refer_code($friends_code);
                    if (!$code['is_valid']) {
                        $friends_code = '';
                    }
                }
                $res = $this->db->where('firebase_id', $firebase_id)->get('tbl_users')->row_array();
                error_log('[BACKEND] Existing user check - found: ' . (!empty($res) ? 'YES (id=' . $res['id'] . ')' : 'NO'));
                if (!empty($res)) {
                    // login
                    if ($res['status'] == 1) {
                        $user_id = $res['id'];
                        $refer_code = $this->random_string(4) . $res['refer_code'];

                        $friends_code_is_used = check_friends_code_is_used_by_user($user_id);
                        if (!$friends_code_is_used['is_used'] && $friends_code != '') {
                            $data = array('friends_code' => $friends_code);
                            $this->db->where('id', $user_id)->update('tbl_users', $data);
                            //update coins
                            $this->set_coins($user_id, $refer_coin);
                            // set tracker data
                            $this->set_tracker_data($user_id, $refer_coin, $this->refer_coin_msg, 0);

                            $credited = credit_coins_to_friends_code($friends_code);
                            if ($credited['credited']) {
                                $this->set_coins($credited['user_id'], $credited['coins'], false);
                                // set tracker data
                                $this->set_tracker_data($credited['user_id'], $earn_coin, $this->earn_coin_msg, 0);
                                // for sharing is caring badge
                                $friends = $this->db->where('friends_code', $friends_code)->get('tbl_users')->result_array();
                                $friends_counter = count($friends);
                                $this->set_coins($credited['user_id'], $friends_counter, false, $type = 'sharing_caring');

                                // LINK TO NEW REFERRAL SYSTEM: Track for bonus rewards after activity
                                if (is_settings('referral_bonus_system_enable') == '1') {
                                    $this->link_to_bonus_referral_system($credited['user_id'], $user_id, $friends_code, $this->input->ip_address(), $device_id ?? '');
                                }
                            }
                        }
                        if (!empty($fcm_id)) {
                            $data = array('fcm_id' => $fcm_id);
                            $this->db->where('id', $user_id)->update('tbl_users', $data);
                        }
                        if (!empty($web_fcm_id)) {
                            $data = array('web_fcm_id' => $web_fcm_id);
                            $this->db->where('id', $user_id)->update('tbl_users', $data);
                        }
                        if (!is_refer_code_set($user_id) && !empty($refer_code)) {
                            $data = array('refer_code' => $refer_code);
                            $this->db->where('id', $user_id)->update('tbl_users', $data);
                        }
                        if (!empty($name)) {
                            $data = array('name' => $name);
                            $this->db->where('id', $user_id)->update('tbl_users', $data);
                        }

                        //generate token
                        $api_token = $this->generate_token($user_id, $firebase_id);
                        $this->db->where('id', $user_id)->update('tbl_users', ['api_token' => $api_token]);

                        $res1 = $this->db->where('firebase_id', $firebase_id)->get('tbl_users')->row_array();

                        if (filter_var($res['profile'], FILTER_VALIDATE_URL) === false) {
                            $res1['profile'] = ($res1['profile']) ? base_url() . USER_IMG_PATH . $res1['profile'] : '';
                        }
                        $response['error'] = false;
                        $response['message'] = "105";
                        $response['data'] = $res1;
                    } else {
                        $response['error'] = true;
                        $response['message'] = "126";
                    }
                } else {
                    // register
                    if ($this->post('app_language') && !empty($this->post('app_language'))) {
                        $default_app_language = $this->post('app_language');
                    } else {
                        $get_app_default_language = $this->db->select('id,name,app_default')->where('app_default', 1)->get('tbl_upload_languages')->row_array();
                        $default_app_language = $get_app_default_language['name'];
                    }

                    if ($this->post('web_language') && !empty($this->post('web_language'))) {
                        $default_web_language = $this->post('web_language');
                    } else {
                        $get_web_default_language = $this->db->select('id,name,web_default')->where('web_default', 1)->get('tbl_upload_languages')->row_array();
                        $default_web_language = $get_web_default_language['name'];
                    }

                    // Detect user's location from IP address
                    $this->load->library('Geolocation');
                    $user_ip = $this->geolocation->getUserIP();
                    $location = $this->geolocation->detectCountryFromIP($user_ip);

                    $data = array(
                        'firebase_id' => $firebase_id,
                        'name' => $name,
                        'email' => $email,
                        'mobile' => $mobile,
                        'type' => $type,
                        'profile' => $profile,
                        'fcm_id' => $fcm_id,
                        'web_fcm_id' => $web_fcm_id,
                        'friends_code' => $friends_code,
                        'coins' => '0',
                        'status' => $status,
                        'date_registered' => $this->toDateTime,
                        'app_language' => $default_app_language ?? 'english',
                        'web_language' => $default_web_language ?? 'english',
                        'country_code' => $location['country_code'] ?? null,
                        'country_name' => $location['country_name'] ?? null,
                        'continent' => $location['continent'] ?? null,
                        'region_auto_detected' => 1
                    );
                    $this->db->insert('tbl_users', $data);
                    $insert_id = $this->db->insert_id();
                    error_log('[BACKEND] Created new user - insert_id: ' . $insert_id . ', firebase_id: ' . $firebase_id);

                    // get the welcome bonus result from settings 
                    $welcome_bonus_query = $this->db->select('message')->where('type', 'welcome_bonus_coin')->get('tbl_settings')->row_array();

                    // get the welcome bonus data if not found then default will be 5
                    $welcome_bonus_coins = (int)$welcome_bonus_query['message'] ?? 5;

                    //set the welcome bonus entry in table :- tracker
                    $this->set_tracker_data($insert_id, $welcome_bonus_coins, $this->opening_msg, 0);

                    //add coins to users
                    $this->db->where('id', $insert_id)->update('tbl_users', ['coins' => $welcome_bonus_coins]);

                    //generate token
                    $api_token = $this->generate_token($insert_id, $firebase_id);
                    error_log('[BACKEND] Generated token for user_id: ' . $insert_id . ', firebase_id: ' . $firebase_id);
                    $this->db->where('id', $insert_id)->update('tbl_users', ['api_token' => $api_token]);

                    $counter = 0;
                    $badges = [
                        'user_id' => $insert_id,
                        'dashing_debut' => $counter,
                        'dashing_debut_counter' => $counter,
                        'combat_winner' => $counter,
                        'combat_winner_counter' => $counter,
                        'clash_winner' => $counter,
                        'clash_winner_counter' => $counter,
                        'most_wanted_winner' => $counter,
                        'most_wanted_winner_counter' => $counter,
                        'ultimate_player' => $counter,
                        'quiz_warrior' => $counter,
                        'quiz_warrior_counter' => $counter,
                        'super_sonic' => $counter,
                        'flashback' => $counter,
                        'brainiac' => $counter,
                        'big_thing' => $counter,
                        'elite' => $counter,
                        'thirsty' => $counter,
                        'thirsty_date' => '0000-00-00',
                        'thirsty_counter' => $counter,
                        'power_elite' => $counter,
                        'power_elite_counter' => $counter,
                        'sharing_caring' => $counter,
                        'streak' => $counter,
                        'streak_date' => '0000-00-00',
                        'streak_counter' => $counter,
                    ];
                    $this->db->insert('tbl_users_badges', $badges);

                    $refer_code = $this->random_string(4) . $insert_id;
                    $dataR = array('refer_code' => $refer_code);
                    $this->db->where('id', $insert_id)->update('tbl_users', $dataR);

                    if ($friends_code != '') {
                        $data = array('coins' => $refer_coin);
                        $this->db->where('id', $insert_id)->update('tbl_users', $data);
                        $this->set_tracker_data($insert_id, $refer_coin, $this->refer_coin_msg, 0);
                        $credited = credit_coins_to_friends_code($friends_code);
                        if ($credited['credited']) {
                            $this->set_coins($credited['user_id'], $credited['coins'], false);
                            $this->set_tracker_data($credited['user_id'], $earn_coin, $this->earn_coin_msg, 0);
                            // for sharing is caring badge
                            $friends = $this->db->where('friends_code', $friends_code)->get('tbl_users')->result_array();
                            $friends_counter = count($friends);
                            $this->set_coins($credited['user_id'], $friends_counter, false, $type = 'sharing_caring');

                            // LINK TO NEW REFERRAL SYSTEM: Track for bonus rewards after activity
                            if (is_settings('referral_bonus_system_enable') == '1') {
                                $this->link_to_bonus_referral_system($credited['user_id'], $insert_id, $friends_code, $this->input->ip_address(), $device_id ?? '');
                            }
                        }
                    }

                    $res1 = $this->db->where('id', $insert_id)->get('tbl_users')->row_array();
                    error_log('[BACKEND] Fetched user data - id: ' . $res1['id'] . ', firebase_id: ' . $res1['firebase_id'] . ', api_token firebase_id: ' . (isset($res1['api_token']) ? substr($res1['api_token'], 0, 50) : 'none'));

                    // ── Backend signup fraud check ────────────────────────────
                    // Runs AFTER insert so the new user_id is available for logging.
                    // Findings are flagged for admin review; the account is never
                    // auto-disabled here — that is a manual admin decision.
                    $this->load->model('Fraud_model');
                    $referrer_id_for_fraud = 0;
                    if (!empty($friends_code)) {
                        $credited_user_row = $this->db->select('id')->where('friends_code', $friends_code)->get('tbl_users')->row();
                        $referrer_id_for_fraud = $credited_user_row ? (int)$credited_user_row->id : 0;
                    }
                    $this->Fraud_model->check_signup_fraud($insert_id, $user_ip, $referrer_id_for_fraud);
                    // ─────────────────────────────────────────────────────────

                    if (filter_var($res1['profile'], FILTER_VALIDATE_URL) === false) {
                        $res1['profile'] = ($res1['profile']) ? base_url() . USER_IMG_PATH . $res1['profile'] : '';
                    }
                    $response['error'] = false;
                    $response['message'] = "104";
                    $response['data'] = $res1;
                }
            } else {
                $response['error'] = true;
                $response['message'] = "129";
            }
        } else {
            $response['error'] = true;
            $response['message'] = "103";
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_random_questions_post()
    {
        $is_user = $this->verify_token();
        if (!$is_user['error']) {
            $user_id = $is_user['user_id'];
            $firebase_id = $is_user['firebase_id'];
        } else {
            $this->response($is_user, REST_Controller::HTTP_OK);
            return false;
        }

        if ($this->post('match_id')) {
            $match_id = $this->post('match_id');
            if ($this->post('destroy_match') && $this->post('destroy_match') == 1) {
                $this->db->where('match_id', $match_id)->delete('tbl_battle_questions');
                $response['error'] = false;
                $response['message'] = "108";
            } else {
                $this->db->where('date_created <', $this->toDate)->delete('tbl_battle_questions');

                $language_id = ($this->post('language_id')) ? $this->post('language_id') : 0;
                if ($this->post('category')) {
                    $category = $this->post('category');
                } else {
                    $category = '0';
                }

                if (!$this->checkBattleExists($match_id)) {
                    $is_random = $this->post('random') ?? 0;
                    $fix_question = is_settings('battle_mode_one_fix_question');
                    $limit = is_settings('battle_mode_one_total_question');
                    if ($is_random != 0) {
                        $fix_question = is_settings('battle_mode_random_fix_question');
                        $limit = is_settings('battle_mode_random_total_question');
                    }
                    /* if match does not exist read and store the questions */
                    $this->db->select('tbl_question.*,c.id as cat_id, sc.id as subcat_id'); // Select all columns from tbl_question

                    if (!empty($language_id)) {
                        $this->db->where('tbl_question.language_id', $language_id);
                    }
                    if (!empty($category)) {
                        $this->db->where('tbl_question.category', $category);
                    }
                    $this->db->join('tbl_category c', 'tbl_question.category = c.id')->where('c.is_premium = 0');
                    $this->db->join('tbl_subcategory sc', 'tbl_question.subcategory = sc.id', 'left');
                    $this->db->order_by('rand()');
                    if ($fix_question == 1) {
                        $this->db->limit($limit, 0);
                    }
                    $res = $this->db->get('tbl_question')->result_array();

                    if (empty($res)) {
                        $response['error'] = true;
                        $response['message'] = "102";
                    } else {
                        $questions = json_encode($res);

                        $entry_coin = $this->post('entry_coin') ? $this->post('entry_coin') : 0;
                        $frm_data = array(
                            'match_id' => $match_id,
                            'entry_coin' => $entry_coin,
                            'questions' => $questions,
                            'set_user1' => 0,
                            'set_user2' => 0,
                            'date_created' => $this->toDateTime,
                        );
                        $this->db->insert('tbl_battle_questions', $frm_data);
                        foreach ($res as $row) {
                            $row['image'] = (!empty($row['image'])) ? base_url() . QUESTION_IMG_PATH . $row['image'] : '';
                            $row['answer'] = $this->encrypt_data($firebase_id, trim($row['answer']));

                            unset($row['session_answer']);
                            $temp[] = $row;
                        }
                        $res = $temp;

                        $response['error'] = false;
                        $response['data'] = $res;
                    }
                } else {
                    /* read the questions and send it. */
                    $res = $this->db->where('match_id', $match_id)->get('tbl_battle_questions')->row_array();

                    $res = json_decode($res['questions'], 1);
                    foreach ($res as $rowData) {
                        $rowData['image'] = (!empty($rowData['image'])) ? base_url() . QUESTION_IMG_PATH . $rowData['image'] : '';
                        $rowData['answer'] = $this->encrypt_data($firebase_id, trim($rowData['answer']));
                        unset($rowData['session_answer']);
                        $temp[] = $rowData;
                    }
                    $res['questions'] = json_encode($temp);
                    $response['error'] = false;
                    $response['data'] = json_decode($res['questions']);
                }
            }
        } else {
            $response['error'] = true;
            $response['message'] = "103";
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_question_by_room_id_post()
    {
        $is_user = $this->verify_token();
        if (!$is_user['error']) {
            $user_id = $is_user['user_id'];
            $firebase_id = $is_user['firebase_id'];
        } else {
            $this->response($is_user, REST_Controller::HTTP_OK);
            return false;
        }

        if ($this->post('room_id')) {
            $room_id = $this->post('room_id');

            $res = $this->db->where('room_id', $room_id)->get('tbl_rooms')->row_array();
            if (empty($res)) {
                $response['error'] = true;
                $response['message'] = "102";
            } else {
                $res = json_decode($res['questions'], true);
                $fix_question = is_settings('battle_mode_group_fix_question');
                $limit = is_settings('battle_mode_group_total_question'); // Get the limit
                if ($fix_question == 1) {
                    $res = array_slice($res, 0, $limit); // Limit the number of questions
                }
                foreach ($res as $row) {
                    $row['image'] = (!empty($row['image'])) ? base_url() . QUESTION_IMG_PATH . $row['image'] : '';
                    $row['answer'] = $this->encrypt_data($firebase_id, trim($row['answer']));
                    $temp[] = $row;
                }
                $res[0]['questions'] = json_encode($temp);
                $response['error'] = false;
                $response['data'] = json_decode($res[0]['questions']);
            }
        } else {
            $response['error'] = true;
            $response['message'] = "103";
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function create_room_post()
    {
        $is_user = $this->verify_token();
        if (!$is_user['error']) {
            $user_id = $is_user['user_id'];
            $firebase_id = $is_user['firebase_id'];
        } else {
            $this->response($is_user, REST_Controller::HTTP_OK);
            return false;
        }

        if ($user_id && $this->post('room_id') && $this->post('room_type')) {
            $room_id = $this->post('room_id');
            $room_type = $this->post('room_type');
            $no_of_que = is_settings('battle_mode_group_fix_question') ? (is_settings('battle_mode_group_total_question') ?? 10) : 10;

            $language_id = ($this->post('language_id')) ? $this->post('language_id') : 0;
            $entry_coin = ($this->post('entry_coin')) ? $this->post('entry_coin') : 0;

            $category = $this->post('category') ? $this->post('category') : '';

            $res1 = $this->db->where('room_id', $room_id)->get('tbl_rooms')->row_array();
            if (empty($res1)) {
                if (!empty($language_id)) {
                    $this->db->where('language_id', $language_id);
                }
                if (!empty($category)) {
                    $this->db->where('category', $category);
                }
                $this->db->order_by($this->Order_By)->limit($no_of_que);
                $res = $this->db->get('tbl_question')->result_array();

                if (empty($res)) {
                    $response['error'] = true;
                    $response['message'] = "102";
                } else {
                    $total_questions = count($res);
                    $questions = json_encode($res);

                    $frm_data = array(
                        'room_id' => $room_id,
                        'entry_coin' => $entry_coin,
                        'user_id' => $user_id,
                        'room_type' => $room_type,
                        'category_id' => $category,
                        'no_of_que' => $total_questions ?? $no_of_que,
                        'questions' => $questions,
                        'set_user1' => 0,
                        'set_user2' => 0,
                        'set_user3' => 0,
                        'set_user4' => 0,
                        'date_created' => $this->toDateTime,
                    );
                    $this->db->insert('tbl_rooms', $frm_data);

                    $response['error'] = false;
                    $response['message'] = "120";
                }
            } else {
                $response['error'] = true;
                $response['message'] = "119";
            }
        } else {
            $response['error'] = true;
            $response['message'] = "103";
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_bookmark_post()
    {
        $is_user = $this->verify_token();
        if (!$is_user['error']) {
            $user_id = $is_user['user_id'];
            $firebase_id = $is_user['firebase_id'];
        } else {
            $this->response($is_user, REST_Controller::HTTP_OK);
            return false;
        }

        if ($user_id && $this->post('type')) {
            $type = $this->post('type');

            if ($type == 3 || $type == '3') {
                $this->db->select('b.*, q.language_id, q.category, q.subcategory, q.image, q.question, q.answer');
                $this->db->join('tbl_guess_the_word q', 'q.id=b.question_id');
            } else if ($type == 4 || $type == '4') {
                $this->db->select('b.*, q.category, q.subcategory, q.language_id, q.audio_type, q.audio, q.question, q.question_type, q.optiona, q.optionb, q.optionc, q.optiond, q.optione, q.answer, q.note');
                $this->db->join('tbl_audio_question q', 'q.id=b.question_id');
            } else if ($type == 5 || $type == '5') {
                $this->db->select('b.*, q.category, q.subcategory, q.language_id, q.image, q.question, q.question_type, q.optiona, q.optionb, q.optionc, q.optiond, q.optione, q.answer, q.note');
                $this->db->join('tbl_maths_question q', 'q.id=b.question_id');
            } else if ($type == 6 || $type == '6') {
                $this->db->select('b.*, q.category, q.subcategory, q.language_id, q.image, q.question, q.question_type,q.answer_type, q.optiona, q.optionb, q.optionc, q.optiond, q.optione, q.answer, q.note');
                $this->db->join('tbl_multi_match q', 'q.id=b.question_id');
            } else {
                $this->db->select('b.*, q.category, q.subcategory, q.language_id, q.image, q.question, q.question_type, q.optiona, q.optionb, q.optionc, q.optiond, q.optione, q.answer, q.level, q.note');
                $this->db->join('tbl_question q', 'q.id=b.question_id');
            }
            $this->db->where('b.type', $type);
            $this->db->where('b.user_id', $user_id)->order_by('b.id', 'DESC');
            $data = $this->db->get('tbl_bookmark b')->result_array();
            if (!empty($data)) {
                for ($i = 0; $i < count($data); $i++) {
                    if ($type == 3 || $type == '3') {
                        $data[$i]['image'] = ($data[$i]['image']) ? base_url() . GUESS_WORD_IMG_PATH . $data[$i]['image'] : '';
                    } else if ($type == 4 || $type == '4') {
                        $data[$i]['audio'] = ($data[$i]['audio']) ? (($data[$i]['audio_type'] != '1') ? base_url() . QUESTION_AUDIO_PATH : '') . $data[$i]['audio'] : '';
                        $data[$i] = $this->suffleOptions($data[$i], $firebase_id);
                        unset($data[$i]['session_answer']);
                    } else if ($type == 5 || $type == '5') {
                        $data[$i]['image'] = ($data[$i]['image']) ? base_url() . MATHS_QUESTION_IMG_PATH . $data[$i]['image'] : '';
                        $data[$i] = $this->suffleOptions($data[$i], $firebase_id);
                        unset($data[$i]['session_answer']);
                    } else if ($type == 6 || $type == '6') {
                        $seedSource = 'bookmark_multi_match|' . $user_id . '|' . ($data[$i]['id'] ?? '') . '|' . ($data[$i]['question_id'] ?? '');
                        $data[$i] = $this->remapMultiMatchSequenceQuestion($data[$i], $seedSource);
                        $data[$i]['image'] = ($data[$i]['image']) ? base_url() . MULTIMATCH_QUESTION_IMG_PATH . $data[$i]['image'] : '';
                        $answers = explode(',', trim($data[$i]['answer']));
                        $data[$i]['answer'] = array_map(function ($answer) use ($firebase_id) {
                            return $this->encrypt_data($firebase_id, $answer);
                        }, $answers);
                    } else {
                        $data[$i]['image'] = ($data[$i]['image']) ? base_url() . QUESTION_IMG_PATH . $data[$i]['image'] : '';
                        $data[$i] = $this->suffleOptions($data[$i], $firebase_id);
                        unset($data[$i]['session_answer']);
                    }
                }
                $response['error'] = false;
                $response['data'] = $data;
            } else {
                $response['error'] = false;
                $response['data'] = $data;
            }
        } else {
            $response['error'] = true;
            $response['message'] = "103";
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function set_bookmark_post()
    {
        $is_user = $this->verify_token();
        if (!$is_user['error']) {
            $user_id = $is_user['user_id'];
            $firebase_id = $is_user['firebase_id'];
        } else {
            $this->response($is_user, REST_Controller::HTTP_OK);
            return false;
        }

        if ($user_id && $this->post('question_id') && $this->post('status') != '' && $this->post('type')) {
            $question_id = $this->post('question_id');
            $status = $this->post('status');
            $type = $this->post('type');

            if ($status == '1' || $status == 1) {
                $frm_data = array(
                    'user_id' => $user_id,
                    'question_id' => $question_id,
                    'status' => $status,
                    'type' => $type,
                );
                $this->db->insert('tbl_bookmark', $frm_data);
            } else {
                $this->db->where('user_id', $user_id)->where('question_id', $question_id)->delete('tbl_bookmark');
            }
            $response['error'] = false;
            $response['message'] = "111";
        } else {
            $response['error'] = true;
            $response['message'] = "103";
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_notifications_post()
    {
        $is_user = $this->verify_token();
        if (!$is_user['error']) {
            $user_id = $is_user['user_id'];
            $firebase_id = $is_user['firebase_id'];
        } else {
            $this->response($is_user, REST_Controller::HTTP_OK);
            return false;
        }

        $get_user_data = $this->db->select('date_registered')->where('id', $user_id)->get('tbl_users')->row_array();
        $register_date = date('Y-m-d', strtotime($get_user_data['date_registered']));

        $limit = ($this->post('limit') && is_numeric($this->post('limit'))) ? $this->post('limit') : 10;
        $offset = ($this->post('offset') && is_numeric($this->post('offset'))) ? $this->post('offset') : 0;

        $sort = ($this->post('sort')) ? $this->post('sort') : 'id';
        $order = ($this->post('order')) ? $this->post('order') : 'DESC';

        $this->db->select('id,title,message,users,type,type_id,image,date_sent')
            ->from('tbl_notifications n')
            ->where('DATE(n.date_sent) >=', $register_date)
            ->group_start()
            ->where('n.users', 'all')
            ->or_where('FIND_IN_SET(' . $user_id . ', n.user_id) >', 0)
            ->group_end()
            ->order_by($sort, $order)
            ->limit($limit, $offset);
        $result = $this->db->get()->result_array();

        $this->db->select('COUNT(*) as total')
            ->from('tbl_notifications n')
            ->where('DATE(n.date_sent) >=', $register_date)
            ->group_start()
            ->where('n.users', 'all')
            ->or_where('FIND_IN_SET(' . $user_id . ', n.user_id) >', 0)
            ->group_end();
        $total = $this->db->get()->row()->total;

        if (!empty($result)) {
            for ($i = 0; $i < count($result); $i++) {
                if (filter_var($result[$i]['image'], FILTER_VALIDATE_URL) === false) {
                    /* Not a valid URL. Its a image only or empty */
                    $result[$i]['image'] = (!empty($result[$i]['image'])) ? base_url() . NOTIFICATION_IMG_PATH . $result[$i]['image'] : '';
                }
            }
            $response['error'] = false;
            $response['total'] = "$total";
            $response['data'] = $result;
        } else {
            $response['error'] = true;
            $response['message'] = "102";
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_user_by_id_post()
    {
        try {
            // ------- Should be Enabled for server  ----------
            $is_user = $this->verify_token();
            if (!$is_user['error']) {
                $user_id = $is_user['user_id'];
                $firebase_id = $is_user['firebase_id'];
                $user_status = $is_user['status'];
            } else {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }
            // ---------------------------------------------------

            // ------- Should be Disable for server  ----------
            // $user_id = $this->post('user_id');
            // $firebase_id = $this->post('firebase_id');
            // ------------------------------------------------


            if ($user_status == 1) {
                if ($firebase_id) {
                    // /* Check User Daily Ads Counter */
                    $dailyAdsCoinQuery = $this->db->select('message')->where('type', 'daily_ads_coins')->get('tbl_settings')->row_array();
                    $dailyAdsCoin = $dailyAdsCoinQuery['message'];

                    // Get Daily Ads Counter from Settings
                    $dailyAdsCounterQuery = $this->db->select('message')->where('type', 'daily_ads_counter')->get('tbl_settings')->row_array();
                    $dailyAdsCounter = $dailyAdsCounterQuery['message'];

                    // Get User Daily Ads Counter And Date            
                    $res = $this->db->where('id', $user_id)->get('tbl_users')->row_array();
                    $userCounter = $res['daily_ads_counter'];
                    $userDailyAdsDate = $res['daily_ads_date'];

                    // Convert Date to string time 
                    $dailyAdsDate = strtotime($userDailyAdsDate);
                    $currentDate = strtotime(date('Y-m-d'));

                    if ($currentDate != $dailyAdsDate) {
                        // If Date Doen't match with today's date
                        // Then Update Counter to 0 and date to today's
                        $data = array(
                            'daily_ads_counter' => 0,
                            'daily_ads_date' => date('Y-m-d'),
                        );

                        // Update data and allow the user to watch ads
                        $this->db->where('id', $user_id)->where('firebase_id', $firebase_id)->update('tbl_users', $data);
                        $dailyAdsAvailable = 1;
                    } else {
                        if ($dailyAdsCounter == $userCounter) {
                            // If Daily Ads Counter is less than or equal to user's counter then not allow to watch ads
                            $dailyAdsAvailable = 0;
                        } else {
                            // If Daily Ads Counter is greater than or equal to user's counter then allow to watch ads
                            $dailyAdsAvailable = 1;
                        }
                    }
                    $res = $this->db->select('id, firebase_id, name, email, mobile, type, profile, fcm_id,web_fcm_id, coins, refer_code, friends_code, status, date_registered,remove_ads,app_language,web_language')->where('firebase_id', $firebase_id)->get('tbl_users')->row_array();
                    if ($res) {
                        $res1 = $this->db->where('user_id', $user_id)->get('tbl_users_badges')->row_array();
                        if (empty($res1)) {
                            $counter = 0;
                            $badges = [
                                'user_id' => $user_id,
                                'dashing_debut' => $counter,
                                'dashing_debut_counter' => $counter,
                                'combat_winner' => $counter,
                                'combat_winner_counter' => $counter,
                                'clash_winner' => $counter,
                                'clash_winner_counter' => $counter,
                                'most_wanted_winner' => $counter,
                                'most_wanted_winner_counter' => $counter,
                                'ultimate_player' => $counter,
                                'quiz_warrior' => $counter,
                                'quiz_warrior_counter' => $counter,
                                'super_sonic' => $counter,
                                'flashback' => $counter,
                                'brainiac' => $counter,
                                'big_thing' => $counter,
                                'elite' => $counter,
                                'thirsty' => $counter,
                                'thirsty_date' => '0000-00-00',
                                'thirsty_counter' => $counter,
                                'power_elite' => $counter,
                                'power_elite_counter' => $counter,
                                'sharing_caring' => $counter,
                                'streak' => $counter,
                                'streak_date' => '0000-00-00',
                                'streak_counter' => $counter,
                            ];
                            $this->db->insert('tbl_users_badges', $badges);
                        }

                        if (filter_var($res['profile'], FILTER_VALIDATE_URL) === false) {
                            // Not a valid URL. Its a image only or empty
                            $res['profile'] = ($res['profile']) ? base_url() . USER_IMG_PATH . $res['profile'] : '';
                        }
                        $my_rank_sql = "SELECT m.total_score AS score, ( SELECT COUNT(*) + 1 FROM ( SELECT user_id, SUM(score) AS total_score FROM tbl_leaderboard_monthly GROUP BY user_id ) AS sub WHERE sub.total_score > m.total_score ) AS user_rank FROM ( SELECT user_id, SUM(score) AS total_score FROM tbl_leaderboard_monthly GROUP BY user_id ) AS m WHERE m.user_id=?";
                        $my_rank = $this->db->query($my_rank_sql, [$res['id']])->row_array();
                        $res['all_time_score'] = ($my_rank) ? $my_rank['score'] : '0';
                        $res['all_time_rank'] = ($my_rank) ? $my_rank['user_rank'] : '0';
                        $res['daily_ads_available'] = $dailyAdsAvailable ?? 0;

                        $getStreakData = $this->db->select('id,streak,streak_date')->where('user_id', $user_id)->get('tbl_users_badges')->row_array();
                        if ($getStreakData['streak'] == 0 && $getStreakData['streak_date'] != $this->toDate) {
                            $this->set_badge_counter($user_id, $this->STREAK, 0);
                        }

                        $response['error'] = false;
                        $response['data'] = $res;
                    } else {
                        $response['error'] = true;
                        $response['message'] = "131";
                    }
                } else {
                    $response['error'] = true;
                    $response['message'] = "103";
                }
            } else {
                $response['error'] = true;
                $response['message'] = "126";
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
            $response['error'] = $e;
        }
        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function check_user_exists_post()
    {
        try {
            if ($this->post('firebase_id')) {
                $firebase_id = $this->post('firebase_id');
                error_log('[BACKEND] check_user_exists - firebase_id: ' . $firebase_id);
                $res = $this->db->where('firebase_id', $firebase_id)->get('tbl_users')->row_array();
                error_log('[BACKEND] check_user_exists - found: ' . ($res ? 'YES (id=' . $res['id'] . ')' : 'NO'));
                if ($res) {
                    $response['error'] = false;
                    $response['message'] = "130";
                } else {
                    $response['error'] = false;
                    $response['message'] = "131";
                }
            } else {
                $response['error'] = true;
                $response['message'] = "103";
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
            $response['error'] = $e;
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function upload_profile_image_post()
    {
        try {
            $is_user = $this->verify_token();
            if (!$is_user['error']) {
                $user_id = $is_user['user_id'];
                $firebase_id = $is_user['firebase_id'];
            } else {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            if ($user_id && $_FILES['image']['name'] != '') {
                // create folder
                if (!is_dir(USER_IMG_PATH)) {
                    mkdir(USER_IMG_PATH, 0777, true);
                }
                $config['upload_path'] = USER_IMG_PATH;
                $config['allowed_types'] = IMG_ALLOWED_WITH_SVG_TYPES;
                $config['file_name'] = time();
                $this->load->library('upload', $config);
                $this->upload->initialize($config);

                if (!$this->upload->do_upload('image')) {
                    $response['error'] = true;
                    $response['message'] = "107";
                } else {
                    $sql1 = $this->db->select('profile')->where('id', $user_id)->get('tbl_users')->row_array();
                    if ($sql1['profile'] != "") {
                        $full_url = USER_IMG_PATH . $sql1['profile'];
                        if (file_exists($full_url)) {
                            unlink($full_url);
                        }
                    }

                    $data = $this->upload->data();
                    $img = $data['file_name'];

                    if ($_FILES['image']['type'] != 'application/octet-stream' && $_FILES['image']['type'] != 'image/svg+xml') {

                        //image compress
                        $this->load->library('Compress'); // load the codeginiter library

                        $compress = new Compress();
                        $compress->file_url = base_url() . USER_IMG_PATH . $img;
                        $compress->new_name_image = $img;
                        $compress->quality = 80;
                        $compress->destination = base_url() . USER_IMG_PATH;
                        $compress->compress_image();
                    }

                    $insert_data = array(
                        'profile' => $img,
                    );
                    $this->db->where('id', $user_id)->update('tbl_users', $insert_data);

                    $res = $this->db->select('profile')->where('id', $user_id)->get('tbl_users')->row_array();
                    if (filter_var($res['profile'], FILTER_VALIDATE_URL) === false) {
                        // Not a valid URL. Its a image only or empty
                        $res['profile'] = ($res['profile']) ? base_url() . USER_IMG_PATH . $res['profile'] : '';
                    }
                    $response['error'] = false;
                    $response['message'] = '106';
                    $response['data'] = $res;
                }
            } else {
                $response['error'] = true;
                $response['message'] = "103";
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
            $response['error'] = $e;
        }
        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function set_user_coin_score_post()
    {
        try {
            $is_user = $this->verify_token();
            if (!$is_user['error']) {
                $user_id = $is_user['user_id'];
                $firebase_id = $is_user['firebase_id'];
            } else {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            if ($user_id) {
                if ($this->post('coins') && $this->post('title')) {
                    $coins = $this->post('coins');
                    $title = $this->post('title');
                    $status = $this->post('type') ? 0 : 1;
                    if ($this->post('type')) {
                        $type = $this->post('type');
                        if ($type != 'watchedRewardAd') {
                            $this->set_badges_reward($user_id, $type);
                        }
                    }
                    $this->set_coins($user_id, $coins);
                    $this->set_tracker_data($user_id, $coins, $title, $status);
                } else if ($this->post('score')) {
                    $score = $this->post('score');
                    $this->set_monthly_leaderboard($user_id, $score);
                }

                $result = $this->db->select('coins')->where('id', $user_id)->get('tbl_users')->row_array();

                if (!empty($result)) {
                    $my_rank = $this->myGlobalRank($user_id);

                    $result['score'] = ($my_rank) ? $my_rank['score'] : '0';

                    $response['error'] = false;
                    $response['message'] = "111";
                    $response['data'] = $result;
                } else {
                    $response['error'] = true;
                    $response['message'] = "102";
                }
            } else {
                $response['error'] = true;
                $response['message'] = "103";
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
            $response['error'] = $e;
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function update_profile_post()
    {
        try {
            $is_user = $this->verify_token();
            if (!$is_user['error']) {
                $user_id = $is_user['user_id'];
                $firebase_id = $is_user['firebase_id'];
            } else {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            if ($user_id) {
                $data = array();
                if ($this->post('name')) {
                    $data['name'] = $this->post('name');
                }

                if ($this->post('email')) {
                    $data['email'] = $this->post('email');
                }
                if ($this->post('mobile')) {
                    $data['mobile'] = $this->post('mobile');
                }
                if ($this->post('app_language')) {
                    $data['app_language'] = $this->post('app_language');
                }
                if ($this->post('web_language')) {
                    $data['web_language'] = $this->post('web_language');
                }
                if ($this->post('remove_ads')) {
                    if ($this->post('remove_ads') <= 1 && $this->post('remove_ads') > -1) {
                        $data['remove_ads'] = $this->post('remove_ads');
                    } else {
                        $response['error'] = false;
                        $response['message'] = "122";
                        $this->response($response, REST_Controller::HTTP_OK);
                        return false;
                    }
                }
                $this->db->where('id', $user_id)->update('tbl_users', $data);

                $response['error'] = false;
                $response['message'] = "106";
            } else {
                $response['error'] = true;
                $response['message'] = "103";
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
            $response['error'] = $e;
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_categories_post()
    {
        try {
            $is_user = $this->verify_token();
            if (!$is_user['error']) {
                $user_id = $is_user['user_id'];
                $firebase_id = $is_user['firebase_id'];
            } else {
                $user_id = 0;
            }
            if ($this->post('type')) {
                $type = $this->post('type');
                $subType = $this->post('sub_type') ?? 0;
                $no_of_que_Condition = '';
                $no_of_Condition = '';
                $join = '';
                if ($type == 1 || $type == '1') {
                    $tbl = 'tbl_question';
                    if ($subType) {
                        if ($subType == 1) {
                            $join .= 'LEFT JOIN tbl_user_category uc ON q.category = uc.category_id';
                            $no_of_que_Condition .= 'AND (c.is_premium = 0 OR (c.is_premium = 1 AND uc.user_id = ' . $user_id . '))';
                        } else {
                            $no_of_que_Condition .= 'AND c.is_premium = 0';
                        }
                        $no_of_Condition .= 'AND c.is_premium = 0';
                    }
                } else if ($type == 2 || $type == '2') {
                    $tbl = 'tbl_fun_n_learn';
                } else if ($type == 3 || $type == '3') {
                    $tbl = 'tbl_guess_the_word';
                } else if ($type == 4 || $type == '4') {
                    $tbl = 'tbl_audio_question';
                } else if ($type == 5 || $type == '5') {
                    $tbl = 'tbl_maths_question';
                } else if ($type == 6 || $type == '6') {
                    $tbl = 'tbl_multi_match';
                } else {
                    $tbl = 'tbl_question'; // Default to tbl_question if type doesn't match
                }

                $no_of =  '(SELECT COUNT(s.id) FROM tbl_subcategory s WHERE s.maincat_id = c.id ' . $no_of_Condition . ' AND s.status = 1 AND s.id IN (SELECT DISTINCT subcategory FROM ' . $tbl . ' WHERE subcategory != 0)) as no_of';
                $no_of_que = ',(select count(q.id) from ' . $tbl . ' q ' . $join . ' where q.category=c.id ' . $no_of_que_Condition . ') as no_of_que';

                $maxlevel = '';
                if ($type == 1 || $type == 6) {
                    $maxlevel = ',(CASE WHEN (SELECT COUNT(s.id) FROM tbl_subcategory s WHERE s.maincat_id = c.id AND s.status = 1 AND s.id IN (SELECT DISTINCT subcategory FROM ' . $tbl . ' WHERE subcategory != 0 )) = 0 THEN (SELECT MAX(CAST(level AS UNSIGNED)) FROM ' . $tbl . ' q WHERE q.category = c.id) ELSE 0 END) AS maxlevel';
                }

                $has_unlocked = '';
                if ($user_id) {
                    $has_unlocked = ',(SELECT COUNT(*) FROM tbl_user_category uc WHERE uc.category_id = c.id AND uc.user_id = ' . $user_id . ') AS has_unlocked';
                }
                $selectField = 'c.*,' . $no_of . $no_of_que . $maxlevel . $has_unlocked;
                $this->db->select($selectField);
                $this->db->from('tbl_category c');
                $this->db->where('type', $type);
                if ($this->post('id')) {
                    $id = $this->post('id');
                    $this->db->where('id', $id);
                }
                if ($this->post('language_id')) {
                    $language_id = $this->post('language_id');
                    $this->db->where('language_id', $language_id);
                }
                $this->db->having('no_of_que >', 0); // check that no of questions should be more than 0
                $this->db->order_by('row_order', 'ASC');
                $data = $this->db->get()->result_array();
                if (!empty($data)) {
                    for ($i = 0; $i < count($data); $i++) {
                        $data[$i]['image'] = $data[$i]['image'] ? base_url() . CATEGORY_IMG_PATH . $data[$i]['image'] : '';
                        $data[$i]['maxlevel'] = (array_key_exists('maxlevel', $data[$i]) && !empty($data[$i]['maxlevel'])) ? $data[$i]['maxlevel'] : '0';
                        if ($user_id) {
                            //check if category played or not
                            $res = $this->db->where('category', $data[$i]['id'])->where('type', $type)->where('user_id', $user_id)->get('tbl_quiz_categories')->row_array();
                            $data[$i]['is_play'] = !empty($res) ? '1' : '0';
                            $data[$i]['has_unlocked'] = $data[$i]['has_unlocked'] ? '1' : '0';
                        }
                    }
                    $response['error'] = false;
                    $response['subType'] = $subType;
                    $response['data'] = $data;
                } else {
                    $response['error'] = true;
                    $response['message'] = '102';
                }
            } else {
                $response['error'] = true;
                $response['message'] = '103';
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }
        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_subcategory_by_maincategory_post()
    {
        try {
            $is_user = $this->verify_token();
            if (!$is_user['error']) {
                $user_id = $is_user['user_id'];
                $firebase_id = $is_user['firebase_id'];
            } else {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            if ($user_id && ($this->post('category') || $this->post('category_slug'))) {
                $category = $this->post('category') ?? 0;
                $categorySlug = !empty($this->post('category_slug')) ? $this->post('category_slug') : null;
                $res = $this->getCategoryData($category, $categorySlug);

                if ($res) {
                    $type = (!empty($res)) ? $res['type'] : 1;

                    if ($type == 1 || $type == '1') {
                        $no_of_que = ' (select count(id) from tbl_question q where q.subcategory=s.id ) as no_of_que,';
                    } else if ($type == 2 || $type == '2') {
                        $no_of_que = ' (select count(id) from tbl_fun_n_learn q where q.subcategory=s.id AND q.status=1) as no_of_que,';
                    } else if ($type == 3 || $type == '3') {
                        $no_of_que = ' (select count(id) from tbl_guess_the_word q where q.subcategory=s.id ) as no_of_que,';
                    } else if ($type == 4 || $type == '4') {
                        $no_of_que = ' (select count(id) from tbl_audio_question q where q.subcategory=s.id ) as no_of_que,';
                    } else if ($type == 5 || $type == '5') {
                        $no_of_que = ' (select count(id) from tbl_maths_question q where q.subcategory=s.id ) as no_of_que,';
                    } else if ($type == 6 || $type == '6') {
                        $no_of_que = ' (select count(id) from tbl_multi_match q where q.subcategory=s.id ) as no_of_que,';
                    }

                    if ($type == 6) {
                        $this->db->select('s.*,`c.category_name as category_name, ' . $no_of_que . ' (select max(`level` + 0) from tbl_multi_match q where q.subcategory=s.id ) as maxlevel');
                    } else {
                        $this->db->select('s.*,`c.category_name as category_name, ' . $no_of_que . ' (select max(`level` + 0) from tbl_question q where q.subcategory=s.id ) as maxlevel');
                    }
                    $this->db->join('tbl_category c', 'c.id = s.maincat_id');
                    $this->db->where('maincat_id', $res['id']);
                    $this->db->where('status', 1);
                    $this->db->having('no_of_que >', 0); // check that no of questions should be more than 0
                    $this->db->order_by('row_order', 'ASC');
                    $data = $this->db->get('tbl_subcategory s')->result_array();
                    if (!empty($data)) {
                        for ($i = 0; $i < count($data); $i++) {
                            $data[$i]['image'] = ($data[$i]['image']) ? base_url() . SUBCATEGORY_IMG_PATH . $data[$i]['image'] : '';
                            $data[$i]['maxlevel'] = ($data[$i]['maxlevel'] == '' || $data[$i]['maxlevel'] == null) ? '0' : $data[$i]['maxlevel'];

                            //check if category played or not
                            $res = $this->db->where('subcategory', $data[$i]['id'])->where('category', $data[$i]['maincat_id'])->where('user_id', $user_id)->get('tbl_quiz_categories')->row_array();
                            $data[$i]['is_play'] = (!empty($res)) ? '1' : '0';
                        }
                        $response['error'] = false;
                        $response['data'] = $data;
                    } else {
                        $response['error'] = true;
                        $response['message'] = "102";
                    }
                } else {
                    $response['error'] = true;
                    $response['message'] = "102";
                }
            } else {
                $response['error'] = true;
                $response['message'] = "103";
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }
        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_questions_by_level_post()
    {
        try {
            $is_user = $this->verify_token();
            if (!$is_user['error']) {

                $user_id = $is_user['user_id'];
                $firebase_id = $is_user['firebase_id'];
            } else {

                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }
            if ($this->post('level') && ($this->post('category') || $this->post('subcategory'))) {
                $level = $this->post('level');
                $language_id = ($this->post('language_id')) ? $this->post('language_id') : 0;
                $category_id = $this->post('category');
                $subcategory_id = $this->post('subcategory');
                $fix_question = is_settings('quiz_zone_fix_level_question');
                $limit = is_settings('quiz_zone_total_level_question');

                $this->db->select('tbl_question.*,cat.slug as category_slug,subcat.slug as subcategory_slug');
                $this->db->where('level', $level);
                $this->db->join('tbl_category cat', 'cat.id=tbl_question.category', 'left');
                $this->db->join('tbl_subcategory subcat', 'subcat.id=tbl_question.subcategory', 'left');
                if ($this->post('subcategory')) {
                    $this->db->where('tbl_question.subcategory', $subcategory_id);
                } else {
                    $this->db->where('tbl_question.category', $category_id);
                }
                if (!empty($language_id)) {
                    $this->db->where('tbl_question.language_id', $language_id);
                }
                $this->db->order_by($this->Order_By);
                if ($fix_question == 1) {
                    $this->db->limit($limit, 0);
                }
                $data = $this->db->get('tbl_question')->result_array();
                $questionData = [];
                if (!empty($data)) {
                    for ($i = 0; $i < count($data); $i++) {
                        $data[$i]['image'] = ($data[$i]['image']) ? base_url() . QUESTION_IMG_PATH . $data[$i]['image'] : '';
                        $optionData = $this->suffleOptions($data[$i], $firebase_id);
                        $data[$i] = $optionData;
                        $questionData[] = [
                            'id' => $data[$i]['id'],
                            'answer' => $data[$i]['session_answer'],
                            'level' => $data[$i]['level']
                        ];
                        unset($data[$i]['session_answer']);
                    }
                    if ($questionData) {
                        $this->set_user_session($user_id, $questionData, 'tbl_user_quiz_zone_session');
                    }
                    $response['error'] = false;
                    $response['data'] = $data;
                } else {
                    $response['error'] = true;
                    $response['message'] = "102";
                }
            } else {
                $response['error'] = true;
                $response['message'] = "103";
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }
        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_daily_quiz_post()
    {
        try {
            $is_user = $this->verify_token();
            if (!$is_user['error']) {
                $user_id = $is_user['user_id'];
                $firebase_id = $is_user['firebase_id'];
            } else {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            if ($user_id) {
                $timezone = $this->post('timezone') ? $this->post('timezone') : $this->systemTimezone;
                $today = new DateTime('now', new DateTimeZone($timezone));
                $today_date = $today->format('Y-m-d');
                $gmt_format = $this->post('gmt_format') ? $this->post('gmt_format') : $this->systemTimezoneGMT;

                $res1 = $this->db->where("DATE(CONVERT_TZ(date, '+00:00', '" . $gmt_format . "')) =", $today_date)->where('user_id', $user_id)->get('tbl_daily_quiz_user')->row_array();
                if (empty($res1)) {
                    $questions = $response = array();
                    $language_id = ($this->post('language_id') && is_numeric($this->post('language_id'))) ? $this->post('language_id') : '0';
                    $res = $this->db->where("DATE(CONVERT_TZ(date_published, '+00:00', '" . $gmt_format . "')) =", $today_date)->where('language_id', $language_id)->get('tbl_daily_quiz')->row_array();
                    if (!empty($res)) {
                        $res2 = $this->db->where('user_id', $user_id)->get('tbl_daily_quiz_user')->row_array();
                        if (!empty($res2)) {
                            $frm_data = array(
                                'date' => $today_date,
                            );
                            $this->db->where('user_id', $user_id)->update('tbl_daily_quiz_user', $frm_data);
                        } else {
                            $frm_data = array(
                                'user_id' => $user_id,
                                'date' => $today_date,
                            );
                            $this->db->insert('tbl_daily_quiz_user', $frm_data);
                        }

                        $questions = $res['questions_id'];
                        $questionData = [];
                        $result = $this->db->query("SELECT * FROM tbl_question WHERE id IN (" . $questions . ") ORDER BY FIELD(id," . $questions . ")")->result_array();
                        if (!empty($result)) {
                            for ($i = 0; $i < count($result); $i++) {
                                $result[$i]['image'] = ($result[$i]['image']) ? base_url() . QUESTION_IMG_PATH . $result[$i]['image'] : '';
                                $optionData = $this->suffleOptions($result[$i], $firebase_id);
                                $result[$i] = $optionData;
                                $questionData[] = [
                                    'id' => $result[$i]['id'],
                                    'answer' => $result[$i]['session_answer']
                                ];
                                unset($result[$i]['session_answer']);
                            }
                            if ($questionData) {
                                $this->set_user_session($user_id, $questionData, 'tbl_user_daily_quiz_session');
                            }
                            $response['error'] = false;
                            $response['data'] = $result;
                        } else {
                            $response['error'] = true;
                            $response['message'] = "102";
                        }
                    } else {
                        $response['error'] = true;
                        $response['message'] = "102";
                    }
                } else {
                    $response['error'] = true;
                    $response['message'] = "112";
                }
            } else {
                $response['error'] = true;
                $response['message'] = "103";
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }
        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_level_data_post()
    {
        try {
            $is_user = $this->verify_token();
            if (!$is_user['error']) {
                $user_id = $is_user['user_id'];
                $firebase_id = $is_user['firebase_id'];
            } else {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            if ($user_id && ($this->post('category') || $this->post('category_slug'))) {
                $category = $this->post('category') ?? 0;
                $categorySlug = !empty($this->post('category_slug')) ? $this->post('category_slug') : null;
                $subcategory = ($this->post('subcategory')) ? $this->post('subcategory') : 0;
                $subcategorySlug = !empty($this->post('subcategory_slug')) ? $this->post('subcategory_slug') : null;

                if ($subcategory) {
                    $subcategoryData = $this->db->select("id,maincat_id,subcategory_name,slug")->where('id', $subcategory)->get('tbl_subcategory')->row_array();
                    if ($subcategoryData) {
                        $categoryData = $this->getCategoryData($category, $categorySlug);
                        $questionData = $this->getQuestionData($subcategoryData, $categoryData);
                    }
                } elseif ($subcategorySlug) {
                    $subcategoryData = $this->db->select("id,maincat_id,subcategory_name,slug")->where('slug', $subcategorySlug)->get('tbl_subcategory')->row_array();
                    if ($subcategoryData) {
                        $categoryData = $this->getCategoryData($category, $categorySlug);
                        $questionData = $this->getQuestionData($subcategoryData, $categoryData);
                    }
                } else {
                    $categoryData = $this->getCategoryData($category, $categorySlug);
                    $subcategoryData = ['id' => 0];
                    $questionData = $this->getQuestionData($subcategoryData, $categoryData);
                }

                if ((isset($categoryData) && !empty($categoryData)) && (isset($subcategoryData) && !empty($subcategoryData))) {
                    // Get Level Data with its Particular Question Count
                    $max_level = $questionData['max_level'];
                    $counter = range(1, $max_level);
                    $levelData = [];

                    foreach ($counter as $key => $level) {
                        $query = $this->db->query('select count(id) as no_of_que from tbl_question where level = ' . $level . ' and category = ' . $categoryData["id"] . ' and subcategory = ' . $subcategoryData["id"])->row_array();
                        $levelData[$key]['level'] = $level;
                        $levelData[$key]['no_of_ques'] = $query['no_of_que'];
                    }

                    // Get Data 
                    $res = $this->db->select('level')->where('user_id', $user_id)->where('category', $categoryData['id'])->where('subcategory', $subcategoryData['id'])->get('tbl_level')->row_array();
                    $data = array(
                        'level' => $res['level'] ?? "1",
                        'no_of_ques' => $questionData['no_of_que'],
                        'max_level' => $questionData['max_level'],
                        'category' => $categoryData ?? [],
                        'subcategory' => $subcategoryData ?? [],
                        'level_data' => $levelData ?? []
                    );
                    $response['error'] = false;
                    $response['data'] = $data;
                } else {
                    $response['error'] = true;
                    $response['message'] = "102";
                }
            } else {
                $response['error'] = true;
                $response['message'] = "103";
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_questions_for_self_challenge_post()
    {
        try {
            $is_user = $this->verify_token();
            if (!$is_user['error']) {
                $user_id = $is_user['user_id'];
                $firebase_id = $is_user['firebase_id'];
            } else {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            if ($this->post('limit') && ($this->post('category') || $this->post('subcategory') || $this->post('category_slug') || $this->post('subcategory_slug'))) {
                $language_id = ($this->post('language_id')) ? $this->post('language_id') : 0;
                $limit = $this->post('limit');

                // Get Category and subcategory data from params
                $category = $this->post('category') ?? 0;
                $categorySlug = !empty($this->post('category_slug')) ? $this->post('category_slug') : '';
                $subcategory = ($this->post('subcategory')) ? $this->post('subcategory') : 0;
                $subcategorySlug = !empty($this->post('subcategory_slug')) ? $this->post('subcategory_slug') : '';

                if ($subcategory || $subcategorySlug) {
                    // if Subcategory is there 
                    $subcategory = $this->getSubCategoryData($subcategory, $subcategorySlug);
                    $this->db->where('subcategory', $subcategory['id']);
                } else {
                    // Else show category data
                    $categoryData = $this->getCategoryData($category, $categorySlug);
                    $this->db->where('category', $categoryData['id']);
                }

                if (!empty($language_id)) {
                    $this->db->where('language_id', $language_id);
                }
                $this->db->order_by($this->Order_By)->limit($limit, 0);
                $data = $this->db->get('tbl_question')->result_array();
                if (!empty($data)) {
                    for ($i = 0; $i < count($data); $i++) {
                        $data[$i]['image'] = ($data[$i]['image']) ? base_url() . QUESTION_IMG_PATH . $data[$i]['image'] : '';
                        $data[$i] = $this->suffleOptions($data[$i], $firebase_id);
                        unset($data[$i]['session_answer']);
                    }
                    $response['error'] = false;
                    $response['data'] = $data;
                } else {
                    $response['error'] = true;
                    $response['message'] = "102";
                }
            } else {
                $response['error'] = true;
                $response['message'] = "103";
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_monthly_leaderboard_post()
    {
        try {
            $is_user = $this->verify_token();
            if (!$is_user['error']) {
                $user_id = $is_user['user_id'];
                $firebase_id = $is_user['firebase_id'];
            } else {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            $offset = ($this->post('offset')) ? $this->post('offset') : 0;
            $limit = ($this->post('limit')) ? $this->post('limit') : 25;
            $scope = ($this->post('scope')) ? $this->post('scope') : 'world';
            $filter_value = ($this->post('filter_value')) ? $this->post('filter_value') : '';

            $month = date('m', strtotime($this->toDate));
            $year = date('Y', strtotime($this->toDate));

            // Build scope filter
            $scope_where = "";
            if ($scope === 'country' && !empty($filter_value)) {
                $scope_where = "AND u.country_code = '" . $this->db->escape_str($filter_value) . "'";
            } elseif ($scope === 'region' && !empty($filter_value)) {
                $scope_where = "AND u.continent = '" . $this->db->escape_str($filter_value) . "'";
            }

            $sort = 'r.user_rank';
            $order = 'ASC';

            $sub_query = "SELECT s.*, @user_rank := @user_rank + 1 user_rank FROM ( SELECT m.id, user_id,u.email, u.name,u.profile, u.country_code, SUM(score) as score,date_created, MAX(last_updated) as last_updated FROM tbl_leaderboard_monthly m join tbl_users u on u.id = m.user_id WHERE u.status=1 AND YEAR(last_updated)=$year AND MONTH(last_updated)=$month {$scope_where} GROUP BY user_id) s, (SELECT @user_rank := 0) init ORDER BY score DESC, last_updated ASC";

            $this->db->reset_query();
            $this->db->from("($sub_query) r");

            $total = $this->db->count_all_results('', false);

            $this->db->select('r.*');
            $this->db->order_by($sort, $order);

            if ($limit) {
                $this->db->limit($limit, $offset);
            }

            $other_user_rank_sql = $this->db->get();
            $data = $other_user_rank_sql->result_array();

            if ($user_id) {
                if (!empty($data)) {
                    for ($i = 0; $i < count($data); $i++) {
                        if (filter_var($data[$i]['profile'], FILTER_VALIDATE_URL) === false) {
                            // Not a valid URL. Its a image only or empty
                            $data[$i]['profile'] = ($data[$i]['profile']) ? base_url() . USER_IMG_PATH . $data[$i]['profile'] : '';
                        }
                    }

                    $this->db->reset_query();
                    $this->db->from("($sub_query) r");
                    $this->db->select('r.*');
                    $this->db->order_by($sort, $order);
                    $this->db->limit(3);
                    $topThree_sql = $this->db->get();
                    $topThreeUsersData = $topThree_sql->result_array();

                    for ($i = 0; $i < count($topThreeUsersData); $i++) {
                        if (filter_var($topThreeUsersData[$i]['profile'], FILTER_VALIDATE_URL) === false) {
                            // Not a valid URL. Its a image only or empty
                            $topThreeUsersData[$i]['profile'] = ($topThreeUsersData[$i]['profile']) ? base_url() . USER_IMG_PATH . $topThreeUsersData[$i]['profile'] : '';
                        }
                    }

                    $this->db->reset_query();
                    $this->db->from("($sub_query) r");
                    $this->db->select('r.*');
                    $this->db->where('r.user_id', $user_id);
                    $this->db->limit(1);
                    $user_rank_sql = $this->db->get();
                    $my_rank = $user_rank_sql->row_array();

                    if (!empty($my_rank)) {
                        if (filter_var($my_rank['profile'], FILTER_VALIDATE_URL) === false) {
                            // Not a valid URL. Its a image only or empty
                            $my_rank['profile'] = (!empty($my_rank['profile'])) ? base_url() . USER_IMG_PATH . $my_rank['profile'] : '';
                        }
                        $user_rank = $my_rank;
                    } else {
                        $my_rank = array(
                            'user_id' => $user_id,
                            'score' => '0',
                            'user_rank' => '0',
                            'email' => '',
                            'name' => '',
                            'profile' => '',
                            'country_code' => '',
                        );
                        $user_rank = $my_rank;
                    }
                }
                $response['error'] = false;
                $response['total'] = "$total";
                // making user's rank and other user's rank in seperate indexes
                $response['data'] = array(
                    'my_rank' => $user_rank ?? array(
                        'user_id' => $user_id,
                        'score' => '0',
                        'user_rank' => '0',
                        'email' => '',
                        'name' => '',
                        'profile' => '',
                        'country_code' => '',
                    ),
                    'other_users_rank' => $data,
                    'top_three_ranks' => $topThreeUsersData ?? array()
                );
            } else {
                $response['error'] = true;
                $response['message'] = "102";
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_daily_leaderboard_post()
    {
        try {
            $is_user = $this->verify_token();
            if (!$is_user['error']) {
                $user_id = $is_user['user_id'];
                $firebase_id = $is_user['firebase_id'];
            } else {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            $offset = ($this->post('offset')) ? $this->post('offset') : 0;
            $limit = ($this->post('limit')) ? $this->post('limit') : 25;

            $sort = 'r.user_rank';
            $order = 'ASC';

            $this->db->select('d.id, user_id, u.email, u.name, u.profile,score, date_created, @user_rank := @user_rank + 1 AS user_rank', false);
            $this->db->from("(SELECT @user_rank := 0) init, tbl_leaderboard_daily d");
            $this->db->join('tbl_users u', 'u.id = d.user_id');
            $this->db->where('u.status', 1);
            $this->db->where('DATE(date_created)', $this->toDate);
            $this->db->order_by('score', 'DESC');
            $this->db->order_by('date_created', 'ASC');
            $subQuery = $this->db->get_compiled_select();

            $this->db->reset_query();
            $this->db->from("($subQuery) r");

            $total = $this->db->count_all_results('', false);

            $this->db->select('r.*');
            $this->db->order_by($sort, $order);
            if ($limit) {
                $this->db->limit($limit, $offset);
            }
            $query = $this->db->get();
            $data = $query->result_array();
            if ($user_id) {
                if (!empty($data)) {
                    for ($i = 0; $i < count($data); $i++) {
                        if (filter_var($data[$i]['profile'], FILTER_VALIDATE_URL) === false) {
                            // Not a valid URL. Its a image only or empty
                            $data[$i]['profile'] = ($data[$i]['profile']) ? base_url() . USER_IMG_PATH . $data[$i]['profile'] : '';
                        }
                    }


                    $this->db->reset_query();
                    $this->db->from("($subQuery) r");
                    $this->db->select('r.*');
                    $this->db->order_by($sort, $order);
                    $this->db->limit(3);
                    $topThree_sql = $this->db->get();
                    $topThreeUsersData = $topThree_sql->result_array();
                    for ($i = 0; $i < count($topThreeUsersData); $i++) {
                        if (filter_var($topThreeUsersData[$i]['profile'], FILTER_VALIDATE_URL) === false) {
                            // Not a valid URL. Its a image only or empty
                            $topThreeUsersData[$i]['profile'] = ($topThreeUsersData[$i]['profile']) ? base_url() . USER_IMG_PATH . $topThreeUsersData[$i]['profile'] : '';
                        }
                    }


                    $this->db->reset_query();
                    $this->db->from("($subQuery) r");
                    $this->db->where('r.user_id', $user_id);
                    $this->db->select('r.*');
                    $this->db->limit(1);
                    $my_rank_sql = $this->db->get();
                    $my_rank = $my_rank_sql->row_array();

                    if (!empty($my_rank)) {
                        if (filter_var($my_rank['profile'], FILTER_VALIDATE_URL) === false) {
                            // Not a valid URL. Its a image only or empty
                            $my_rank['profile'] = (!empty($my_rank['profile'])) ? base_url() . USER_IMG_PATH . $my_rank['profile'] : '';
                        }
                        $user_rank = $my_rank;
                    } else {
                        $my_rank = array(
                            'user_id' => $user_id,
                            'score' => '0',
                            'user_rank' => '0',
                            'email' => '',
                            'name' => '',
                            'profile' => '',
                        );
                        $user_rank = $my_rank;
                    }
                }
                $response['error'] = false;
                $response['total'] = "$total";
                $response['data'] = array(
                    'my_rank' => $user_rank ?? array(
                        'user_id' => $user_id,
                        'score' => '0',
                        'user_rank' => '0',
                        'email' => '',
                        'name' => '',
                        'profile' => '',
                    ),
                    'other_users_rank' => $data,
                    'top_three_ranks' => $topThreeUsersData ?? array()
                );
            } else {
                $response['error'] = true;
                $response['message'] = "102";
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_globle_leaderboard_post()
    {
        try {
            $is_user = $this->verify_token();
            if (!$is_user['error']) {
                $user_id = $is_user['user_id'];
                $firebase_id = $is_user['firebase_id'];
            } else {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            $offset = ($this->post('offset')) ? $this->post('offset') : 0;
            $limit = ($this->post('limit')) ? $this->post('limit') : 25;
            $scope = ($this->post('scope')) ? $this->post('scope') : 'world';
            $filter_value = ($this->post('filter_value')) ? $this->post('filter_value') : '';

            // Build scope filter
            $scope_where = "";
            if ($scope === 'country' && !empty($filter_value)) {
                $scope_where = "AND u.country_code = '" . $this->db->escape_str($filter_value) . "'";
            } elseif ($scope === 'region' && !empty($filter_value)) {
                $scope_where = "AND u.continent = '" . $this->db->escape_str($filter_value) . "'";
            }

            $sort = 'r.user_rank';
            $order = 'ASC';

            $sub_query = "(SELECT s.*, @user_rank := @user_rank + 1 AS user_rank FROM (SELECT m.id, m.user_id,u.email, u.name,u.profile,u.country_code, SUM(m.score) AS score,MAX(m.last_updated) as last_updated FROM tbl_leaderboard_monthly m JOIN tbl_users u ON u.id = m.user_id WHERE u.status = 1 {$scope_where} GROUP BY m.user_id) s, (SELECT @user_rank := 0) init ORDER BY s.score DESC, s.last_updated ASC)";
            $this->db->select('r.*');
            $this->db->from("$sub_query r", false);

            $total = $this->db->count_all_results('', false);
            $this->db->order_by($sort, $order);
            if ($limit) {
                $this->db->limit($limit, $offset);
            }

            $other_user_rank_sql = $this->db->get();
            $data = $other_user_rank_sql->result_array();
            if ($user_id) {

                if (!empty($data)) {
                    for ($i = 0; $i < count($data); $i++) {
                        if (filter_var($data[$i]['profile'], FILTER_VALIDATE_URL) === false) {
                            // Not a valid URL. Its a image only or empty
                            $data[$i]['profile'] = ($data[$i]['profile']) ? base_url() . USER_IMG_PATH . $data[$i]['profile'] : '';
                        }
                    }

                    $this->db->reset_query();
                    $this->db->from("($sub_query) r");
                    $this->db->select('r.*');
                    $this->db->order_by($sort, $order);
                    $this->db->limit(3);
                    $top_three_user_rank_sql = $this->db->get();
                    $topThreeUsersData = $top_three_user_rank_sql->result_array();

                    for ($i = 0; $i < count($topThreeUsersData); $i++) {
                        if (filter_var($topThreeUsersData[$i]['profile'], FILTER_VALIDATE_URL) === false) {
                            // Not a valid URL. Its a image only or empty
                            $topThreeUsersData[$i]['profile'] = ($topThreeUsersData[$i]['profile']) ? base_url() . USER_IMG_PATH . $topThreeUsersData[$i]['profile'] : '';
                        }
                    }

                    $my_rank = $this->myGlobalRank($user_id, $scope, $filter_value);

                    if (!empty($my_rank)) {
                        if (filter_var($my_rank['profile'], FILTER_VALIDATE_URL) === false) {
                            // Not a valid URL. Its a image only or empty
                            $my_rank['profile'] = (!empty($my_rank['profile'])) ? base_url() . USER_IMG_PATH . $my_rank['profile'] : '';
                        }
                        $user_rank = $my_rank;
                    } else {
                        $my_rank = array(
                            'user_id' => $user_id,
                            'score' => '0',
                            'user_rank' => '0',
                            'email' => '',
                            'name' => '',
                            'profile' => '',
                            'country_code' => '',
                        );
                        $user_rank = $my_rank;
                    }
                }
                $response['error'] = false;
                $response['total'] = "$total";
                $response['data'] = array(
                    'my_rank' => $user_rank ?? array(
                        'user_id' => $user_id,
                        'score' => '0',
                        'user_rank' => '0',
                        'email' => '',
                        'name' => '',
                        'profile' => '',
                        'country_code' => '',
                    ),
                    'other_users_rank' => $data,
                    'top_three_ranks' => $topThreeUsersData ?? array()
                );
            } else {
                $response['error'] = true;
                $response['message'] = "102";
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }


        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_questions_by_type_post()
    {
        try {
            $is_user = $this->verify_token();
            if (!$is_user['error']) {
                $user_id = $is_user['user_id'];
                $firebase_id = $is_user['firebase_id'];
            } else {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            if ($this->post('type')) {
                $type = $this->post('type');
                $language_id = ($this->post('language_id')) ? $this->post('language_id') : "0";
                $fix_question = is_settings('true_false_quiz_fix_question');
                $limit = is_settings('true_false_quiz_total_question');

                $this->db->select('tbl_question.*,c.id as cat_id, sc.id as subcat_id'); // Select all columns from tbl_question

                $this->db->where('tbl_question.question_type', $type);
                if (!empty($language_id)) {
                    $this->db->where('tbl_question.language_id', $language_id);
                }
                $this->db->join('tbl_category c', 'tbl_question.category = c.id')->where('c.is_premium', '0');
                $this->db->join('tbl_subcategory sc', 'tbl_question.subcategory = sc.id', 'left');
                $this->db->order_by($this->Order_By);

                if ($fix_question == 1 && $limit) {
                    $this->db->limit($limit, 0);
                }

                $data = $this->db->get('tbl_question')->result_array();

                $questionData = [];
                if (!empty($data)) {
                    for ($i = 0; $i < count($data); $i++) {
                        $data[$i]['image'] = ($data[$i]['image']) ? base_url() . QUESTION_IMG_PATH . $data[$i]['image'] : '';
                        $optionData = $this->suffleOptions($data[$i], $firebase_id);
                        $data[$i] = $optionData;
                        $questionData[] = [
                            'id' => $data[$i]['id'],
                            'answer' => $data[$i]['session_answer'],
                            'level' => $data[$i]['level']
                        ];
                        unset($data[$i]['session_answer']);
                    }
                    if ($questionData) {
                        $this->set_user_session($user_id, $questionData, 'tbl_user_true_false_session');
                    }

                    $response['error'] = false;
                    $response['data'] = $data;
                } else {
                    $response['error'] = true;
                    $response['message'] = "102";
                }
            } else {
                $response['error'] = true;
                $response['message'] = "103";
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }
        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_contest_post()
    {
        try {
            $is_user = $this->verify_token();
            if (!$is_user['error']) {
                $user_id = $is_user['user_id'];
                $firebase_id = $is_user['firebase_id'];
            } else {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            if ($user_id) {
                $timezone = $this->post('timezone') ? $this->post('timezone') : $this->systemTimezone;
                $today = new DateTime('now', new DateTimeZone($timezone));
                $today_date = $today->format('Y-m-d H:i:00');
                $gmt_format = $this->post('gmt_format') ? $this->post('gmt_format') : $this->systemTimezoneGMT;

                $toDateTime = (new DateTime("now", new DateTimeZone($timezone)))->format("Y-m-d H:i:00");

                $language_id = ($this->post('language_id') && is_numeric($this->post('language_id'))) ? $this->post('language_id') : '0';

                /* selecting live quiz ids */
                if ($language_id) {
                    $result = $this->db->query("SELECT id FROM tbl_contest WHERE status=1 AND language_id = $language_id AND (CONVERT_TZ('" . $toDateTime . "', '+00:00', '" . $gmt_format . "') BETWEEN CONVERT_TZ(start_date, '+00:00', '" . $gmt_format . "') AND CONVERT_TZ(end_date, '+00:00', '" . $gmt_format . "'))")->result_array();
                } else {
                    $result = $this->db->query("SELECT id FROM tbl_contest WHERE status=1 AND (CONVERT_TZ('" . $toDateTime . "', '+00:00', '" . $gmt_format . "') BETWEEN CONVERT_TZ(start_date, '+00:00', '" . $gmt_format . "') AND CONVERT_TZ(end_date, '+00:00', '" . $gmt_format . "'))")->result_array();
                }


                $live_type_ids = $past_type_ids = '';
                if (!empty($result)) {
                    foreach ($result as $type_id) {
                        $live_type_ids .= $type_id['id'] . ', ';
                    }
                    $live_type_ids = rtrim($live_type_ids, ', ');

                    /* getting past quiz ids & its data which user has played */
                    $result = $this->db->query("SELECT contest_id FROM tbl_contest_leaderboard WHERE contest_id in ($live_type_ids) and user_id = $user_id ORDER BY id DESC")->result_array();
                    if (!empty($result)) {
                        foreach ($result as $type_id) {
                            $past_type_ids .= $type_id['contest_id'] . ', ';
                        }
                        $past_type_ids = rtrim($past_type_ids, ', ');

                        $past_result = $this->db->query("SELECT *, (select SUM(points) FROM tbl_contest_prize tcp WHERE tcp.contest_id=c.id) as points, (select count(contest_id) FROM tbl_contest_prize tcp WHERE tcp.contest_id=c.id) as top_users,(SELECT COUNT(*) from tbl_contest_leaderboard tcl where tcl.contest_id = c.id ) as participants FROM tbl_contest c WHERE c.id in ($past_type_ids) ORDER BY c.id DESC")->result_array();
                        unset($result);
                        foreach ($past_result as $quiz) {
                            $quiz['image'] = (!empty($quiz['image'])) ? base_url() . CONTEST_IMG_PATH . $quiz['image'] : '';
                            $quiz['start_date'] = date("d-M", strtotime($quiz['start_date']));
                            $quiz['end_date'] = date("d-M", strtotime($quiz['end_date']));

                            $points = $this->db->query("SELECT top_winner, points FROM tbl_contest_prize WHERE contest_id=" . $quiz['id'])->result_array();
                            $quiz['points'] = $points;
                            $result[] = $quiz;
                        }
                        $past_result = $result;
                        $response['past_contest']['error'] = false;
                        $response['past_contest']['message'] = "117";
                        $response['past_contest']['data'] = (!empty($past_result)) ? $past_result : '';
                    } else {
                        if ($language_id) {
                            $past_result = $this->db->query("SELECT c.*, (select SUM(points) FROM tbl_contest_prize tcp WHERE tcp.contest_id=c.id) as points, (select count(contest_id) FROM tbl_contest_prize tcp WHERE tcp.contest_id=c.id) as top_users,(SELECT COUNT(*) from tbl_contest_leaderboard tcl where tcl.contest_id=c.id ) as participants FROM tbl_contest_leaderboard as l, tbl_contest as c WHERE l.user_id = '$user_id' and l.contest_id = c.id and c.language_id = $language_id ORDER BY c.id DESC")->result_array();
                        } else {
                            $past_result = $this->db->query("SELECT c.*, (select SUM(points) FROM tbl_contest_prize tcp WHERE tcp.contest_id=c.id) as points, (select count(contest_id) FROM tbl_contest_prize tcp WHERE tcp.contest_id=c.id) as top_users,(SELECT COUNT(*) from tbl_contest_leaderboard tcl where tcl.contest_id=c.id ) as participants FROM tbl_contest_leaderboard as l, tbl_contest as c WHERE l.user_id = '$user_id' and l.contest_id = c.id ORDER BY c.id DESC")->result_array();
                        }
                        if (!empty($past_result)) {
                            foreach ($past_result as $quiz) {
                                $quiz['image'] = (!empty($quiz['image'])) ? base_url() . CONTEST_IMG_PATH . $quiz['image'] : '';
                                $quiz['start_date'] = date("d-M", strtotime($quiz['start_date']));
                                $quiz['end_date'] = date("d-M", strtotime($quiz['end_date']));
                                $points = $this->db->query("SELECT top_winner, points FROM tbl_contest_prize WHERE contest_id=" . $quiz['id'])->result_array();
                                $quiz['points'] = $points;
                                $result[] = $quiz;
                            }
                            $past_result = $result;
                            $response['past_contest']['error'] = false;
                            $response['past_contest']['message'] = "117";
                            $response['past_contest']['data'] = (!empty($past_result)) ? $past_result : '';
                        } else {
                            $response['past_contest']['error'] = true;
                            $response['past_contest']['message'] = "116";
                        }
                    }

                    /* getting all quiz details by ids retrieved */
                    $sql = (empty($past_type_ids)) ?
                        "SELECT c.*, (select SUM(points) FROM tbl_contest_prize tcp WHERE tcp.contest_id=c.id) as points, (select count(contest_id) FROM tbl_contest_prize tcp WHERE tcp.contest_id=c.id) as top_users,(SELECT COUNT(*) from tbl_contest_leaderboard tcl WHERE tcl.contest_id=c.id ) as participants FROM tbl_contest c WHERE id IN ($live_type_ids) AND status='1' ORDER BY `id` DESC" :
                        "SELECT c.*, (select SUM(points) FROM tbl_contest_prize tcp WHERE tcp.contest_id=c.id) as points, (select count(contest_id) FROM tbl_contest_prize tcp WHERE tcp.contest_id=c.id) as top_users,(SELECT COUNT(*) from tbl_contest_leaderboard tcl WHERE tcl.contest_id=c.id ) as participants FROM tbl_contest c WHERE id IN ($live_type_ids) and id NOT IN ($past_type_ids) AND status='1' ORDER BY `id` DESC";
                    $live_result = $this->db->query($sql)->result_array();

                    $result = array();

                    if (!empty($live_result)) {
                        foreach ($live_result as $quiz) {
                            $quiz['image'] = (!empty($quiz['image'])) ? base_url() . CONTEST_IMG_PATH . $quiz['image'] : '';
                            $quiz['start_date'] = date("d-M", strtotime($quiz['start_date']));
                            $quiz['end_date'] = date("d-M", strtotime($quiz['end_date']));

                            $points = $this->db->query("SELECT top_winner, points FROM tbl_contest_prize WHERE contest_id=" . $quiz['id'])->result_array();
                            $quiz['points'] = $points;
                            $result[] = $quiz;
                        }
                        $live_result = $result;
                        $response['live_contest']['error'] = false;
                        $response['live_contest']['message'] = "118";
                        $response['live_contest']['data'] = (!empty($live_result)) ? $live_result : '';
                    } else {
                        $response['live_contest']['error'] = true;
                        $response['live_contest']['message'] = "115";
                    }
                } else {
                    if ($language_id) {
                        $past_result = $this->db->query("SELECT c.*, (select SUM(points) FROM tbl_contest_prize tcp WHERE tcp.contest_id=c.id) as points, (select count(contest_id) FROM tbl_contest_prize tcp WHERE tcp.contest_id=c.id) as top_users,(SELECT COUNT(*) from tbl_contest_leaderboard tcl where tcl.contest_id=c.id ) as participants FROM tbl_contest_leaderboard as l, tbl_contest as c WHERE l.user_id='$user_id' and l.contest_id=c.id and c.language_id = $language_id ORDER BY c.id DESC")->result_array();
                    } else {
                        $past_result = $this->db->query("SELECT c.*, (select SUM(points) FROM tbl_contest_prize tcp WHERE tcp.contest_id=c.id) as points, (select count(contest_id) FROM tbl_contest_prize tcp WHERE tcp.contest_id=c.id) as top_users,(SELECT COUNT(*) from tbl_contest_leaderboard tcl where tcl.contest_id=c.id ) as participants FROM tbl_contest_leaderboard as l, tbl_contest as c WHERE l.user_id='$user_id' and l.contest_id=c.id ORDER BY c.id DESC")->result_array();
                    }
                    if (!empty($past_result)) {
                        foreach ($past_result as $quiz) {
                            $quiz['image'] = (!empty($quiz['image'])) ? base_url() . CONTEST_IMG_PATH . $quiz['image'] : '';
                            $quiz['start_date'] = date("d-M", strtotime($quiz['start_date']));
                            $quiz['end_date'] = date("d-M", strtotime($quiz['end_date']));

                            $points = $this->db->query("SELECT top_winner, points FROM tbl_contest_prize WHERE contest_id=" . $quiz['id'])->result_array();
                            $quiz['points'] = $points;
                            $result[] = $quiz;
                        }
                        $past_result = $result;
                        $response['past_contest']['error'] = false;
                        $response['past_contest']['message'] = "117";
                        $response['past_contest']['data'] = (!empty($past_result)) ? $past_result : '';
                    } else {
                        $response['past_contest']['error'] = true;
                        $response['past_contest']['message'] = "116";
                    }
                    $response['live_contest']['error'] = true;
                    $response['live_contest']['message'] = "115";
                }

                /* selecting upcoming quiz ids */
                if ($language_id) {
                    $result = $this->db->query("SELECT id FROM tbl_contest where language_id = $language_id and ((start_date) > '$this->toContestDateTime')")->result_array();
                } else {
                    $result = $this->db->query("SELECT id FROM tbl_contest where (CAST(start_date AS DATE) > '$this->toDate')")->result_array();
                }
                $upcoming_type_ids = '';
                if (!empty($result)) {

                    foreach ($result as $type_id) {
                        $upcoming_type_ids .= $type_id['id'] . ', ';
                    }
                    $upcoming_type_ids = rtrim($upcoming_type_ids, ', ');

                    /* getting all quiz details by ids retrieved */
                    $upcoming_result = $this->db->query("SELECT c.*, (select SUM(points) FROM tbl_contest_prize tcp WHERE tcp.contest_id=c.id) as points, (select count(contest_id) FROM tbl_contest_prize tcp WHERE tcp.contest_id=c.id) as top_users FROM tbl_contest c WHERE id IN ($upcoming_type_ids) ORDER BY id DESC")->result_array();
                    $result = array();
                    if (!empty($upcoming_result)) {
                        foreach ($upcoming_result as $quiz) {
                            $quiz['image'] = (!empty($quiz['image'])) ? base_url() . CONTEST_IMG_PATH . $quiz['image'] : '';
                            $quiz['start_date'] = date("d-M", strtotime($quiz['start_date']));
                            $quiz['end_date'] = date("d-M", strtotime($quiz['end_date']));

                            $points = $this->db->query("SELECT top_winner, points FROM tbl_contest_prize WHERE contest_id=" . $quiz['id'])->result_array();
                            $quiz['points'] = $points;
                            $quiz['participants'] = "";
                            $result[] = $quiz;
                        }
                        $upcoming_result = $result;
                    }
                    $response['upcoming_contest']['error'] = false;
                    $response['upcoming_contest']['message'] = "118";
                    $response['upcoming_contest']['data'] = (!empty($upcoming_result)) ? $upcoming_result : '';
                } else {
                    $response['upcoming_contest']['error'] = true;
                    $response['upcoming_contest']['message'] = "114";
                }
            } else {
                $response['error'] = true;
                $response['message'] = "103";
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }
        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_questions_by_contest_post()
    {
        try {
            $is_user = $this->verify_token();
            if (!$is_user['error']) {
                $user_id = $is_user['user_id'];
                $firebase_id = $is_user['firebase_id'];
            } else {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            if ($this->post('contest_id')) {
                $contest_id = $this->post('contest_id');
                $data = $this->db->where('contest_id', $contest_id)->order_by($this->Order_By)->get('tbl_contest_question')->result_array();
                if (!empty($data)) {
                    $questionData = [];
                    for ($i = 0; $i < count($data); $i++) {
                        $data[$i]['image'] = ($data[$i]['image']) ? base_url() . CONTEST_QUESTION_IMG_PATH . $data[$i]['image'] : '';
                        $optionData = $this->suffleOptions($data[$i], $firebase_id);
                        $data[$i] = $optionData;
                        $questionData[] = [
                            'id' => $data[$i]['id'],
                            'answer' => $data[$i]['session_answer'],
                        ];
                        unset($data[$i]['session_answer']);
                    }
                    if ($questionData) {
                        $questionData[0]['contest_id'] = $contest_id;
                        $this->set_user_session($user_id, $questionData, 'tbl_user_contest_session');
                    }
                    $response['error'] = false;
                    $response['data'] = $data;
                } else {
                    $response['error'] = true;
                    $response['message'] = "102";
                }
            } else {
                $response['error'] = true;
                $response['message'] = "103";
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }


        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_contest_leaderboard_post()
    {
        try {
            $is_user = $this->verify_token();
            if (!$is_user['error']) {
                $user_id = $is_user['user_id'];
                $firebase_id = $is_user['firebase_id'];
            } else {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            if ($this->post('contest_id')) {
                $contest_id = $this->post('contest_id');
                $offset = ($this->post('offset') && is_numeric($this->post('offset'))) ? $this->post('offset') : 0;
                $limit = ($this->post('limit') && is_numeric($this->post('limit'))) ? $this->post('limit') : 25;

                $sort = 'r.user_rank';
                $order = 'ASC';

                $sub_query = "SELECT s.*, @user_rank := @user_rank + 1 user_rank FROM ( SELECT c.*,u.name,u.profile FROM tbl_contest_leaderboard c join tbl_users u on u.id = c.user_id where u.status=1 AND contest_id='" . $contest_id . "') s, (SELECT @user_rank := 0) init ORDER BY score DESC,last_updated ASC";

                $this->db->select('r.*');
                $this->db->from("($sub_query) r");
                $this->db->where('contest_id', $contest_id);

                $total = $this->db->count_all_results('', false);
                $this->db->order_by($sort, $order);
                if ($limit) {
                    $this->db->limit($limit, $offset);
                }
                $other_user_rank_sql = $this->db->get();
                $res = $other_user_rank_sql->result_array();

                $response['total'] = $total;
                for ($i = 0; $i < count($res); $i++) {
                    if (filter_var($res[$i]['profile'], FILTER_VALIDATE_URL) === false) {
                        // Not a valid URL. Its a image only or empty
                        $res[$i]['profile'] = (!empty($res[$i]['profile'])) ? base_url() . USER_IMG_PATH . $res[$i]['profile'] : '';
                    }
                }
                if ($user_id) {
                    $this->db->reset_query();
                    $this->db->from("($sub_query) r");
                    $this->db->where('contest_id', $contest_id);
                    $this->db->where('r.user_id', $user_id);
                    $this->db->select('r.*');
                    $this->db->limit(1);
                    $my_rank_sql = $this->db->get();
                    $my_rank = $my_rank_sql->row_array();

                    if (!empty($my_rank)) {
                        if (filter_var($my_rank['profile'], FILTER_VALIDATE_URL) === false) {
                            // Not a valid URL. Its a image only or empty
                            $my_rank['profile'] = (!empty($my_rank['profile'])) ? base_url() . USER_IMG_PATH . $my_rank['profile'] : '';
                        }
                        $response['my_rank'] = $my_rank;
                    }
                }
                if (empty($res)) {
                    $response['error'] = true;
                    $response['message'] = "102";
                } else {
                    $response['error'] = false;
                    $response['data'] = $res;

                    $this->db->reset_query();
                    $this->db->from("($sub_query) r");
                    $this->db->where('contest_id', $contest_id);
                    $this->db->select('r.*');
                    $this->db->order_by($sort, $order);
                    $this->db->limit(3);
                    $topThree_rank_sql = $this->db->get();
                    $topThreeUsersdata = $topThree_rank_sql->result_array();

                    for ($i = 0; $i < count($topThreeUsersdata); $i++) {
                        if (filter_var($topThreeUsersdata[$i]['profile'], FILTER_VALIDATE_URL) === false) {
                            // Not a valid URL. Its a image only or empty
                            $topThreeUsersdata[$i]['profile'] = (!empty($topThreeUsersdata[$i]['profile'])) ? base_url() . USER_IMG_PATH . $topThreeUsersdata[$i]['profile'] : '';
                        }
                    }
                    $response['top_three_ranks'] = $topThreeUsersdata;
                }
            } else {
                $response['error'] = true;
                $response['message'] = "103";
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }


        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_fun_n_learn_post()
    {
        try {
            $is_user = $this->verify_token();
            if (!$is_user['error']) {
                $user_id = $is_user['user_id'];
                $firebase_id = $is_user['firebase_id'];
            } else {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }
            if ($this->post('type') && $this->post('type_id') && $user_id) {
                $type = $this->post('type');
                $type_id = $this->post('type_id');
                $this->db->select('c.*,cat.category_name as category_name,subcat.subcategory_name as subcategory_name, (select count(id) from tbl_fun_n_learn_question q where q.fun_n_learn_id=c.id ) as no_of_que');
                if ($this->post('id')) {
                    $id = $this->post('id');
                    $this->db->where('id', $id);
                }
                if ($this->post('language_id')) {
                    $language_id = $this->post('language_id');
                    $this->db->where('c.language_id', $language_id);
                }
                $this->db->join('tbl_category cat', 'cat.id=c.category', 'left');
                $this->db->join('tbl_subcategory subcat', 'subcat.id=c.subcategory', 'left');
                $this->db->where($type, $type_id);
                $this->db->where('c.status', 1);
                $this->db->order_by('id', 'DESC');
                $data = $this->db->get('tbl_fun_n_learn c')->result_array();
                if (!empty($data)) {
                    for ($i = 0; $i < count($data); $i++) {
                        //check if category played or not
                        if ($data[$i]['content_data'] != '' && $data[$i]['content_type'] == 2) {
                            $data[$i]['content_data'] = base_url(FUN_LEARN_IMG_PATH . $data[$i]['content_data']);
                        } else if ($data[$i]['content_type'] == 0) {
                            $data[$i]['content_data'] = '';
                        }
                        $res = $this->db->where('type_id', $data[$i]['id'])->where('subcategory', $data[$i]['subcategory'])->where('category', $data[$i]['category'])->where('user_id', $user_id)->get('tbl_quiz_categories')->row_array();
                        $data[$i]['is_play'] = (!empty($res)) ? '1' : '0';
                    }
                    $response['error'] = false;
                    $response['data'] = $data;
                } else {
                    $response['error'] = true;
                    $response['message'] = "102";
                }
            } else {
                $response['error'] = true;
                $response['message'] = "103";
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_fun_n_learn_questions_post()
    {
        try {
            $is_user = $this->verify_token();
            if (!$is_user['error']) {
                $user_id = $is_user['user_id'];
                $firebase_id = $is_user['firebase_id'];
            } else {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            if ($this->post('fun_n_learn_id')) {
                $optionEMode = is_option_e_mode_enabled();
                $fun_n_learn_id = $this->post('fun_n_learn_id');
                $fix_question = is_settings('fun_n_learn_quiz_fix_question');
                $limit = is_settings('fun_n_learn_quiz_total_question');

                $this->db->select('q.*, tf.category, tf.subcategory');
                $this->db->join('tbl_fun_n_learn tf', 'tf.id=q.fun_n_learn_id');
                if (!$optionEMode) {
                    $this->db->where('answer !=', 'e');
                }
                $this->db->where('fun_n_learn_id', $fun_n_learn_id);
                $this->db->order_by($this->Order_By);

                if ($fix_question == 1 && $limit) {
                    $this->db->limit($limit, 0);
                }

                $data = $this->db->get('tbl_fun_n_learn_question q')->result_array();
                $questionData = [];
                if (!empty($data)) {

                    for ($i = 0; $i < count($data); $i++) {
                        $data[$i]['image'] = ($data[$i]['image']) ? base_url() . FUN_LEARN_QUESTION_IMG_PATH . $data[$i]['image'] : '';
                        $optionData = $this->suffleOptions($data[$i], $firebase_id);
                        $data[$i] = $optionData;
                        $questionData[] = [
                            'id' => $data[$i]['id'],
                            'answer' => $data[$i]['session_answer'],
                        ];
                        unset($data[$i]['session_answer']);
                    }
                    if ($questionData) {
                        $questionData[0]['fun_n_learn_id'] = $fun_n_learn_id;
                        $this->set_user_session($user_id, $questionData, 'tbl_user_fun_n_learn_session');
                    }
                    $response['error'] = false;
                    $response['data'] = $data;
                } else {
                    $response['error'] = true;
                    $response['message'] = "102";
                }
            } else {
                $response['error'] = true;
                $response['message'] = "103";
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_users_statistics_post()
    {
        try {
            $is_user = $this->verify_token();
            if (!$is_user['error']) {
                $user_id = $is_user['user_id'];
                $firebase_id = $is_user['firebase_id'];
            } else {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            if ($user_id) {
                $result = $this->db->query("SELECT us.*,u.name,u.profile,(SELECT category_name FROM tbl_category c WHERE c.id=us.strong_category) as strong_category, (SELECT category_name FROM tbl_category c WHERE c.id=us.weak_category) as weak_category FROM tbl_users_statistics us LEFT JOIN tbl_users u on u.id = us.user_id WHERE user_id=$user_id")->result_array();

                if (!empty($result)) {
                    if ($result[0]['strong_category'] == null) {
                        $result[0]['strong_category'] = "0";
                    }
                    if ($result[0]['weak_category'] == null) {
                        $result[0]['weak_category'] = "0";
                    }
                    if ($result[0]['questions_answered'] == null) {
                        $result[0]['questions_answered'] = "0";
                    }
                    if ($result[0]['correct_answers'] == null) {
                        $result[0]['correct_answers'] = "0";
                    }
                    if ($result[0]['strong_category'] == null) {
                        $result[0]['strong_category'] = "0";
                    }
                    if ($result[0]['best_position'] == null) {
                        $result[0]['best_position'] = "0";
                    }
                    if (filter_var($result[0]['profile'], FILTER_VALIDATE_URL) === false) {
                        // Not a valid URL. Its a image only or empty
                        $result[0]['profile'] = (!empty($result[0]['profile'])) ? base_url() . USER_IMG_PATH . $result[0]['profile'] : '';
                    }
                    $response['error'] = false;
                    $response['data'] = $result[0];
                } else {
                    $response['error'] = true;
                    $response['message'] = "102";
                }
            } else {
                $response['error'] = true;
                $response['message'] = "103";
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }
        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_system_configurations_post()
    {
        try {
            $setting = [
                'system_timezone',
                'system_timezone_gmt',
                'app_link',
                'ios_app_link',
                'refer_coin',
                'earn_coin',
                'reward_coin',
                'app_version',
                'app_version_ios',
                'shareapp_text',
                'language_mode',
                'force_update',
                'daily_quiz_mode',
                'in_app_purchase_mode',
                'in_app_ads_mode',
                'ads_type',
                'android_banner_id',
                'android_interstitial_id',
                'android_rewarded_id',
                'ios_banner_id',
                'ios_interstitial_id',
                'ios_rewarded_id',
                'android_game_id',
                'ios_game_id',
                'app_open_id_android',
                'app_open_id_ios',
                'rewarded_interstitial_id_android',
                'rewarded_interstitial_id_ios',
                'app_key_android_iron_source',
                'app_key_ios_iron_source',
                'rewarded_id_android_iron_source',
                'rewarded_id_ios_iron_source',
                'interstitial_id_android_iron_source',
                'interstitial_id_ios_iron_source',
                'banner_id_android_iron_source',
                'banner_id_ios_iron_source',
                'payment_mode',
                'per_coin',
                'coin_amount',
                'currency_symbol',
                'coin_limit',
                'app_maintenance',
                'bot_image',
                'daily_ads_visibility',
                'daily_ads_coins',
                'daily_ads_counter',
                'ad_rollout_utility_interstitials',
                'ad_rollout_wallet_banner_placement',
                'ad_rollout_coin_store_banner_placement',
                'ad_rollout_rewarded_fallback',
                'ad_compliance_upload_enabled',
                'ad_compliance_upload_batch_size',
                // 'maximum_winning_coins',
                // 'minimum_coins_winning_percentage',
                'quiz_winning_percentage',
                'score',
                'answer_mode',
                'review_answers_deduct_coin',
                'quiz_zone_mode',
                'quiz_zone_duration',
                'quiz_zone_lifeline_deduct_coin',
                // 'quiz_zone_wrong_answer_deduct_score',
                // 'quiz_zone_correct_answer_credit_score',
                'guess_the_word_question',
                'guess_the_word_seconds',
                'guess_the_word_max_hints',
                // 'guess_the_word_max_winning_coin',
                // 'guess_the_word_wrong_answer_deduct_score',
                // 'guess_the_word_correct_answer_credit_score',
                'guess_the_word_hint_deduct_coin',
                'audio_mode_question',
                'audio_quiz_seconds',
                // 'audio_quiz_wrong_answer_deduct_score',
                // 'audio_quiz_correct_answer_credit_score',
                'maths_quiz_mode',
                'maths_quiz_seconds',
                // 'maths_quiz_wrong_answer_deduct_score',
                // 'maths_quiz_correct_answer_credit_score',
                'fun_n_learn_question',
                'fun_and_learn_time_in_seconds',
                // 'fun_n_learn_quiz_wrong_answer_deduct_score',
                // 'fun_n_learn_quiz_correct_answer_credit_score',
                'true_false_mode',
                'true_false_quiz_in_seconds',
                // 'true_false_quiz_wrong_answer_deduct_score',
                // 'true_false_quiz_correct_answer_credit_score',
                'battle_mode_one',
                'battle_mode_one_category',
                'battle_mode_one_in_seconds',
                // 'battle_mode_one_correct_answer_credit_score',
                // 'battle_mode_one_quickest_correct_answer_extra_score',
                // 'battle_mode_one_second_quickest_correct_answer_extra_score',
                'battle_mode_one_code_char',
                'battle_mode_one_entry_coin',
                'battle_mode_group',
                'battle_mode_group_category',
                'battle_mode_group_in_seconds',
                'battle_mode_group_wrong_answer_deduct_score',
                'battle_mode_group_correct_answer_credit_score',
                'battle_mode_group_quickest_correct_answer_extra_score',
                'battle_mode_group_second_quickest_correct_answer_extra_score',
                'battle_mode_group_code_char',
                'battle_mode_group_entry_coin',
                'battle_mode_random',
                'battle_mode_random_category',
                'battle_mode_random_in_seconds',
                // 'battle_mode_random_correct_answer_credit_score',
                // 'battle_mode_random_quickest_correct_answer_extra_score',
                // 'battle_mode_random_second_quickest_correct_answer_extra_score',
                'battle_mode_random_search_duration',
                'battle_mode_random_entry_coin',
                'self_challenge_mode',
                'self_challenge_max_minutes',
                'self_challenge_max_questions',
                'exam_module',
                'exam_module_resume_exam_timeout',
                'contest_mode',
                // 'contest_mode_wrong_deduct_score',
                // 'contest_mode_correct_credit_score',
                'multi_match_mode',
                'multi_match_fix_level_question',
                'multi_match_total_level_question',
                'multi_match_duration',
                // 'multi_match_wrong_answer_deduct_score',
                // 'multi_match_correct_answer_credit_score',
                'latex_mode',
                'exam_latex_mode',
                'gmail_login',
                'email_login',
                'phone_login',
                'apple_login'
            ];
            foreach ($setting as $row) {
                $data = $this->db->where('type', $row)->get('tbl_settings')->row_array();
                if ($row == 'bot_image') {
                    $res[$row] = ($data) ? base_url() . LOGO_IMG_PATH . $data['message'] : base_url() . LOGO_IMG_PATH . 'bot-stock.png';
                } else {
                    $res[$row] = ($data) ? $data['message'] : '';
                }
            }
            if (!empty($res)) {
                $response['error'] = false;
                $response['data'] = $res;
            } else {
                $response['error'] = true;
                $response['message'] = "102";
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }
        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_coin_store_data_post()
    {
        try {
            $data = $this->db->where('status', 1)->order_by('id', 'asc')->get('tbl_coin_store')->result_array();
            for ($i = 0; $i < count($data); $i++) {
                $data[$i]['image'] = ($data[$i]['image']) ? base_url() . COIN_STORE_IMG_PATH . $data[$i]['image'] :  $this->NO_IMAGE;
            }
            if (!empty($data)) {
                $response['error'] = false;
                $response['data'] = $data;
            } else {
                $response['error'] = true;
                $response['message'] = "102";
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_languages_post()
    {
        try {
            if ($this->post('id')) {
                $id = $this->post('id');
                $this->db->where('id', $id);
            }
            $data = $this->db->select('id, language, code, default_active')->where('status', 1)->where('type', 1)->order_by('id', 'ASC')->get('tbl_languages')->result_array();
            if (!empty($data)) {
                $response['error'] = false;
                $response['data'] = $data;
            } else {
                $response['error'] = true;
                $response['message'] = "102";
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_guess_the_word_post()
    {
        try {
            $is_user = $this->verify_token();
            if (!$is_user['error']) {
                $user_id = $is_user['user_id'];
                $firebase_id = $is_user['firebase_id'];
            } else {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }
            if ($this->post('type') && $this->post('type_id')) {
                $fix_question = is_settings('guess_the_word_fix_question');
                $limit = is_settings('guess_the_word_total_question');

                $type = $this->post('type');
                $type_id = $this->post('type_id');

                if ($this->post('language_id')) {
                    $language_id = $this->post('language_id');
                    $this->db->where('language_id', $language_id);
                }
                $this->db->where($type, $type_id);
                $this->db->order_by($this->Order_By);

                if ($fix_question == 1) {
                    $this->db->limit($limit, 0);
                }
                $data = $this->db->get('tbl_guess_the_word c')->result_array();
                $questionData = [];
                if (!empty($data)) {
                    for ($i = 0; $i < count($data); $i++) {
                        $data[$i]['image'] = ($data[$i]['image']) ? base_url() . GUESS_WORD_IMG_PATH . $data[$i]['image'] : '';
                        $questionData[] = [
                            'id' => $data[$i]['id'],
                            'answer' => trim($data[$i]['answer']),
                        ];
                        $data[$i]['answer'] = $this->encrypt_data($firebase_id, trim($data[$i]['answer']));
                    }
                    if ($questionData) {
                        $this->set_user_session($user_id, $questionData, 'tbl_user_guess_the_word_session');
                    }
                    $response['error'] = false;
                    $response['data'] = $data;
                } else {
                    $response['error'] = true;
                    $response['message'] = "102";
                }
            } else {
                $response['error'] = true;
                $response['message'] = "103";
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }
        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_settings_post()
    {
        try {
            if ($this->post('type')) {
                $type = $this->post('type');
                $res = $this->db->where('type', $type)->get('tbl_settings')->row_array();
                if (!empty($res)) {
                    $response['error'] = false;
                    $response['data'] = $res['message'];
                } else {
                    $response['error'] = true;
                    $response['message'] = "102";
                }
            } else {
                $setting_data = [
                    'about_us',
                    'privacy_policy',
                    'terms_conditions',
                    'contact_us',
                    'instructions',
                    'app_name'
                ];
                $res = $this->db->where('type!=', 'shared_secrets')->where_in('type', $setting_data)->get('tbl_settings')->result_array();
                if (!empty($res)) {
                    $response['error'] = false;
                    $response['data'] = $res;
                } else {
                    $response['error'] = true;
                    $response['message'] = "102";
                }
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function report_question_post()
    {
        try {
            $is_user = $this->verify_token();
            if (!$is_user['error']) {
                $user_id = $is_user['user_id'];
                $firebase_id = $is_user['firebase_id'];
            } else {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            if ($this->post('question_id') && $user_id && $this->post('message')) {
                $frm_data = array(
                    'question_id' => $this->post('question_id'),
                    'user_id' => $user_id,
                    'message' => $this->post('message'),
                    'date' => $this->toDateTime,
                );
                $this->db->insert('tbl_question_reports', $frm_data);
                $response['error'] = false;
                $response['message'] = "109";
            } else {
                $response['error'] = true;
                $response['message'] = "103";
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_questions_post()
    {
        try {
            $is_user = $this->verify_token();
            if (!$is_user['error']) {
                $user_id = $is_user['user_id'];
                $firebase_id = $is_user['firebase_id'];
            } else {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            if ($this->post('type') && $this->post('id')) {
                $type = $this->post('type');
                $id = $this->post('id');

                $this->db->where($type, $id);
                $this->db->order_by($this->Order_By);
                $data = $this->db->get('tbl_question')->result_array();
                if (!empty($data)) {
                    for ($i = 0; $i < count($data); $i++) {
                        $data[$i]['image'] = ($data[$i]['image']) ? base_url() . QUESTION_IMG_PATH . $data[$i]['image'] : '';
                        $data[$i] = $this->suffleOptions($data[$i], $firebase_id);
                        unset($data[$i]['session_answer']);
                    }
                    $response['error'] = false;
                    $response['data'] = $data;
                } else {
                    $response['error'] = true;
                    $response['message'] = "102";
                }
            } else {
                $response['error'] = true;
                $response['message'] = "103";
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function update_fcm_id_post()
    {
        try {
            $is_user = $this->verify_token();
            if (!$is_user['error']) {
                $user_id = $is_user['user_id'];
                $firebase_id = $is_user['firebase_id'];
            } else {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            if ($firebase_id) {
                $data = [];
                $fcm_id = $this->post('fcm_id');
                if ($fcm_id) {
                    $data['fcm_id'] = $fcm_id;
                }
                $web_fcm_id = $this->post('web_fcm_id');
                if ($web_fcm_id) {
                    $data['web_fcm_id'] = $web_fcm_id;
                }
                if ($data) {
                    $this->db->where('firebase_id', $firebase_id)->update('tbl_users', $data);
                }
                $response['error'] = false;
                $response['message'] = "111";
            } else {
                $response['error'] = true;
                $response['message'] = "103";
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_audio_questions_post()
    {
        try {
            $is_user = $this->verify_token();
            if (!$is_user['error']) {
                $user_id = $is_user['user_id'];
                $firebase_id = $is_user['firebase_id'];
            } else {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }
            if ($this->post('type') && $this->post('type_id')) {
                $type = $this->post('type');
                $id = $this->post('type_id');
                $fix_question = is_settings('audio_quiz_fix_question');
                $limit = is_settings('audio_quiz_total_question');

                $this->db->where($type, $id);
                $this->db->order_by($this->Order_By);

                if ($fix_question == 1) {
                    $this->db->limit($limit, 0);
                }

                $data = $this->db->get('tbl_audio_question')->result_array();
                if (!empty($data)) {
                    $questionData = [];
                    for ($i = 0; $i < count($data); $i++) {
                        if ($data[$i]['audio_type'] != '1') {
                            $path = base_url() . QUESTION_AUDIO_PATH;
                        } else {
                            $path = "";
                        }
                        $data[$i]['audio'] = ($data[$i]['audio']) ? $path . $data[$i]['audio'] : '';
                        $optionData = $this->suffleOptions($data[$i], $firebase_id);
                        $data[$i] = $optionData;
                        $questionData[] = [
                            'id' => $data[$i]['id'],
                            'answer' => $data[$i]['session_answer'],
                        ];
                        unset($data[$i]['session_answer']);
                    }
                    if ($questionData) {
                        $this->set_user_session($user_id, $questionData, 'tbl_user_audio_quiz_session');
                    }
                    $response['error'] = false;
                    $response['data'] = $data;
                } else {
                    $response['error'] = true;
                    $response['message'] = "102";
                }
            } else {
                $response['error'] = true;
                $response['message'] = "103";
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }
        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_user_badges_post()
    {
        try {
            $is_user = $this->verify_token();
            if (!$is_user['error']) {
                $user_id = $is_user['user_id'];
                $firebase_id = $is_user['firebase_id'];
            } else {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }
            if ($user_id) {
                $res1 = $this->db->select('id')->where('user_id', $user_id)->get('tbl_users_badges')->row_array();
                if ($res1) {
                    $badges = [
                        'dashing_debut',
                        'combat_winner',
                        'clash_winner',
                        'most_wanted_winner',
                        'ultimate_player',
                        'quiz_warrior',
                        'super_sonic',
                        'flashback',
                        'brainiac',
                        'big_thing',
                        'elite',
                        'thirsty',
                        'power_elite',
                        'sharing_caring',
                        'streak',
                    ];
                    // Get the language_id from the post data or default to 14
                    $language_id = $this->post('language_id') ? $this->post('language_id') : 14;
                    foreach ($badges as $key => $row) {
                        $res[$key] = $this->db->where('type', $row)->where('language_id', $language_id)->get('tbl_badges')->row_array();
                        if (empty($res[$key])) {
                            $res[$key] = $this->db->where('type', $row)->where('language_id', 14)->get('tbl_badges')->row_array();
                        }
                        $get_user_language = $this->db->select('id,app_language,web_language')->where('id', $user_id)->get('tbl_users')->row_array();
                        $user_app_language = $get_user_language['app_language'];
                        $user_web_language = $get_user_language['web_language'];

                        $get_app_default_language = $this->db->select('id,name,app_default')->where('app_default', 1)->get('tbl_upload_languages')->row_array();
                        $get_web_default_language = $this->db->select('id,name,web_default')->where('web_default', 1)->get('tbl_upload_languages')->row_array();
                        $default_app_language = $get_app_default_language['name'] ?? '';
                        $default_web_language = $get_web_default_language['name'] ?? '';

                        $app_data = $this->getBadgeNotificationData($user_app_language, $row, APP_LANGUAGE_FILE_PATH, 'app_sample_file.json', $default_app_language);
                        $web_data = $this->getBadgeNotificationData($user_web_language, $row, WEB_LANGUAGE_FILE_PATH, 'web_sample_file.json', $default_web_language);

                        $res[$key]['badge_label'] = $web_data['notification_title'] ?? 'Congratulations!';
                        $res[$key]['badge_note'] = $web_data['notification_body'] ?? 'You have unlocked new badge.';

                        $res[$key]['app_badge_label'] = $app_data['notification_title'] ?? 'Congratulations!';
                        $res[$key]['app_badge_note'] = $app_data['notification_body'] ?? 'You have unlocked new badge.';
                        $res[$key]['badge_icon'] = (isset($res[$key]['badge_icon']) && !empty($res[$key]['badge_icon'])) ? base_url() . BADGE_IMG_PATH . $res[$key]['badge_icon'] : "";
                        $res1 = $this->db->select($row)->where('user_id', $user_id)->get('tbl_users_badges')->row_array();
                        $res[$key]['status'] = $res1[$row];
                    }
                    $response['error'] = false;
                    $response['data'] = $res;
                } else {
                    $response['error'] = true;
                    $response['message'] = "102";
                }
            } else {
                $response['error'] = true;
                $response['message'] = "103";
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }
        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_battle_statistics_post()
    {
        try {
            $is_user = $this->verify_token();
            if (!$is_user['error']) {
                $user_id = $is_user['user_id'];
                $firebase_id = $is_user['firebase_id'];
            } else {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            if ($user_id) {
                $offset = ($this->post('offset') && is_numeric($this->post('offset'))) ? $this->post('offset') : 0;
                $limit = ($this->post('limit') && is_numeric($this->post('limit'))) ? $this->post('limit') : 5;

                $sort = ($this->post('sort')) ? $this->post('sort') : 'id';
                $order = ($this->post('order')) ? $this->post('order') : 'DESC';

                $result = $this->db->query("SELECT (SELECT COUNT(*) FROM (SELECT DISTINCT date_created from tbl_battle_statistics WHERE winner_id = $user_id)as w ) AS Victories, (SELECT COUNT(*) FROM (SELECT DISTINCT `date_created` from tbl_battle_statistics WHERE (user_id1= $user_id || user_id2= $user_id)AND is_drawn=1)as d) AS Drawn, (SELECT COUNT(*) FROM (SELECT DISTINCT `date_created` from tbl_battle_statistics WHERE (user_id1= $user_id || user_id2= $user_id) AND winner_id != $user_id and is_drawn = 0)as l )AS Loose")->result_array();
                $response['myreport'] = $result;

                $matches = $temp = array();

                $result = $this->db->query("SELECT *, (select name from tbl_users u WHERE u.id = m.user_id1 ) as user_1, (select name from tbl_users u WHERE u.id = m.user_id2 ) as user_2, (select profile from tbl_users u WHERE u.id = m.user_id1 ) as user_profile1, (select profile from tbl_users u WHERE u.id = m.user_id2 ) as user_profile2 FROM tbl_battle_statistics m where user_id1 = $user_id or user_id2 = $user_id GROUP BY DATE(date_created) ORDER BY $sort $order limit $offset,$limit")->result_array();
                if (!empty($result)) {
                    foreach ($result as $row) {
                        $temp['opponent_id'] = ($row['user_id1'] == $user_id) ? $row['user_id2'] : $row['user_id1'];
                        $temp['opponent_name'] = ($row['user_id1'] == $user_id) ? $row['user_2'] : $row['user_1'];
                        $temp['opponent_profile'] = ($row['user_id1'] == $user_id) ? $row['user_profile2'] : $row['user_profile1'];
                        if (!empty($temp['opponent_profile']) || $temp['opponent_profile'] != null) {
                            if (filter_var($temp['opponent_profile'], FILTER_VALIDATE_URL) === false) {
                                // Not a valid URL. Its a image only or empty
                                $temp['opponent_profile'] = (!empty($temp['opponent_profile'])) ? base_url() . USER_IMG_PATH . $temp['opponent_profile'] : '';
                            }
                        }

                        if ($row['is_drawn'] == 1) {
                            $temp['mystatus'] = "Draw";
                        } else {
                            $temp['mystatus'] = ($row['winner_id'] == $user_id) ? "Won" : "Lost";
                        }
                        $temp['date_created'] = $row['date_created'];
                        $matches[] = $temp;
                    }
                    $response['error'] = false;
                    $response['data'] = $matches;
                } else {
                    $response['error'] = false;
                    $response['message'] = "113";
                }
            } else {
                $response['error'] = true;
                $response['message'] = "103";
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_exam_module_post()
    {
        try {
            $is_user = $this->verify_token();
            if (!$is_user['error']) {
                $user_id = $is_user['user_id'];
                $firebase_id = $is_user['firebase_id'];
            } else {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            if ($user_id && $this->post('type')) {
                $type = $this->post('type');
                $timezone = $this->post('timezone') ? $this->post('timezone') : $this->systemTimezone;
                $today = new DateTime('now', new DateTimeZone($timezone));
                $today_date = $today->format('Y-m-d');
                $gmt_format = $this->post('gmt_format') ? $this->post('gmt_format') : $this->systemTimezoneGMT;

                if ($type == 1 || $type == '1') {
                    $this->db->select('te.*,DATE_FORMAT(CONVERT_TZ(te.date, "+00:00", "' . $gmt_format . '"), "%Y-%m-%d") AS converted_date, (select count(id) from tbl_exam_module_question q where q.exam_module_id=te.id ) as no_of_que, (select SUM(marks) from tbl_exam_module_question q where q.exam_module_id=te.id ) as total_marks');
                    if ($this->post('id')) {
                        $id = $this->post('id');
                        $this->db->where('id', $id);
                    }
                    if ($this->post('language_id')) {
                        $language_id = $this->post('language_id');
                        $this->db->where('language_id', $language_id);
                    }
                    $this->db->where('status', 1);
                    $this->db->where("DATE(CONVERT_TZ(date, '+00:00', '" . $gmt_format . "')) =", $today_date);

                    $this->db->order_by('id', 'DESC');
                    $data = $this->db->get('tbl_exam_module te')->result_array();
                    if (!empty($data)) {
                        for ($i = 0; $i < count($data); $i++) {
                            $res = $this->db->where('user_id', $user_id)->where('exam_module_id', $data[$i]['id'])->get('tbl_exam_module_result')->result_array();
                            $data[$i]['exam_status'] = (empty($res)) ? '1' : $res[0]['status'];
                        }
                        $response['error'] = false;
                        $response['data'] = $data;
                    } else {
                        $response['error'] = true;
                        $response['message'] = "102";
                    }
                } else if ($type == 2 || $type == '2') {
                    $offset = ($this->post('offset') && is_numeric($this->post('offset'))) ? $this->post('offset') : 0;
                    $limit = ($this->post('limit') && is_numeric($this->post('limit'))) ? $this->post('limit') : 10;
                    $this->db->select('te.*, ter.obtained_marks, ter.total_duration, ter.statistics, (select SUM(marks) from tbl_exam_module_question q where q.exam_module_id=te.id ) as total_marks');
                    $this->db->join('tbl_exam_module_result ter', 'ter.exam_module_id=te.id');
                    if ($this->post('language_id')) {
                        $language_id = $this->post('language_id');
                        $this->db->where('language_id', $language_id);
                    }
                    $this->db->where('te.status', 1)->where('ter.user_id', $user_id);
                    $this->db->order_by('id', 'DESC');
                    $this->db->limit($limit, $offset);
                    $data = $this->db->get('tbl_exam_module te')->result_array();
                    if (!empty($data)) {
                        $this->db->select('te.*, ter.obtained_marks, ter.total_duration, ter.statistics, (select SUM(marks) from tbl_exam_module_question q where q.exam_module_id=te.id ) as total_marks');
                        $this->db->join('tbl_exam_module_result ter', 'ter.exam_module_id=te.id');
                        if ($this->post('language_id')) {
                            $language_id = $this->post('language_id');
                            $this->db->where('language_id', $language_id);
                        }
                        $this->db->where('te.status', 1)->where('ter.user_id', $user_id);
                        $data1 = $this->db->get('tbl_exam_module te')->result_array();
                        $total = count($data1);
                        for ($i = 0; $i < count($data); $i++) {
                            $data[$i]['statistics'] = json_decode($data[$i]['statistics'], true);
                        }
                        $response['error'] = false;
                        $response['total'] = "$total";
                        $response['data'] = $data;
                    } else {
                        $response['error'] = true;
                        $response['message'] = "102";
                    }
                } else {
                    $response['error'] = true;
                    $response['message'] = "102";
                }
            } else {
                $response['error'] = true;
                $response['message'] = "103";
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }
        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_exam_module_questions_post()
    {
        try {
            $is_user = $this->verify_token();
            if (!$is_user['error']) {
                $user_id = $is_user['user_id'];
                $firebase_id = $is_user['firebase_id'];
            } else {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }
            if ($this->post('exam_module_id')) {
                $exam_module_id = $this->post('exam_module_id');
                $this->db->where('exam_module_id', $exam_module_id);
                $this->db->order_by($this->Order_By);
                $data = $this->db->get('tbl_exam_module_question')->result_array();
                if (!empty($data)) {
                    for ($i = 0; $i < count($data); $i++) {
                        $data[$i]['image'] = ($data[$i]['image']) ? base_url() . EXAM_QUESTION_IMG_PATH . $data[$i]['image'] : '';
                        $data[$i] = $this->suffleOptions($data[$i], $firebase_id);
                        unset($data[$i]['session_answer']);
                    }
                    $response['error'] = false;
                    $response['data'] = $data;
                } else {
                    $response['error'] = true;
                    $response['message'] = "102";
                }
            } else {
                $response['error'] = true;
                $response['message'] = "103";
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }
        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function set_exam_module_result_post()
    {
        try {
            $is_user = $this->verify_token();
            if (!$is_user['error']) {
                $user_id = $is_user['user_id'];
                $firebase_id = $is_user['firebase_id'];
            } else {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }
            if ($this->post('exam_module_id') && $user_id) {
                $exam_module_id = $this->post('exam_module_id');

                $res = $this->db->where('exam_module_id', $exam_module_id)->where('user_id', $user_id)->get('tbl_exam_module_result')->result_array();
                if (empty($res)) {
                    $data = array(
                        'exam_module_id' => $this->post('exam_module_id'),
                        'user_id' => $user_id,
                        'rules_violated' => 0,
                        'status' => 2,
                    );
                    $this->db->insert('tbl_exam_module_result', $data);
                    $response['error'] = false;
                    $response['message'] = "110";
                } else {
                    if ($this->post('total_duration') != '' && $this->post('statistics') && $this->post('obtained_marks') != '') {
                        $data = array(
                            'obtained_marks' => $this->post('obtained_marks'),
                            'total_duration' => $this->post('total_duration'),
                            'statistics' => $this->post('statistics'),
                            'status' => 3,
                            'rules_violated' => ($this->post('rules_violated')) ? $this->post('rules_violated') : 0,
                            'captured_question_ids' => ($this->post('captured_question_ids')) ? $this->post('captured_question_ids') : '',
                        );
                        $this->db->where('exam_module_id', $exam_module_id)->where('user_id', $user_id)->update('tbl_exam_module_result', $data);
                        $response['error'] = false;
                        $response['message'] = "110";
                    } else {
                        $response['error'] = true;
                        $response['message'] = "103";
                    }
                }
            } else {
                $response['error'] = true;
                $response['message'] = "103";
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }
        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function delete_user_account_post()
    {
        try {
            // ------- Should be Enabled for server  -----------------
            $is_user = $this->verify_token();
            if (!$is_user['error']) {
                $user_id = $is_user['user_id'];
                $firebase_id = $is_user['firebase_id'];
            } else {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }
            // --------------------------------------------------------

            // ------- Should be Enabled for local  ------------------
            // $user_id = $this->post('user_id');
            // $firebase_id = $this->post('firebase_id');
            // --------------------------------------------------------

            if ($user_id) {
                $tables = [
                    'tbl_bookmark',
                    'tbl_contest_leaderboard',
                    'tbl_daily_quiz_user',
                    'tbl_exam_module_result',
                    'tbl_leaderboard_daily',
                    'tbl_leaderboard_monthly',
                    'tbl_level',
                    'tbl_multi_match_level',
                    'tbl_multi_match_question_reports',
                    'tbl_payment_request',
                    'tbl_question_reports',
                    'tbl_quiz_categories',
                    'tbl_rooms',
                    'tbl_tracker',
                    'tbl_users_badges',
                    'tbl_users_statistics',
                    'tbl_user_category',
                    'tbl_user_subcategory',
                    'tbl_user_quiz_zone_session',
                    'tbl_user_daily_quiz_session',
                    'tbl_user_true_false_session',
                    'tbl_user_fun_n_learn_session',
                    'tbl_user_guess_the_word_session',
                    'tbl_user_audio_quiz_session',
                    'tbl_user_maths_quiz_session',
                    'tbl_user_multi_match_session',
                    'tbl_user_contest_session'
                ];

                foreach ($tables as $type) {
                    if ($this->db->table_exists($type)) {
                        $this->db->where('user_id', $user_id)->delete($type);
                    }
                }

                $this->db->where('user_id1', $user_id)->delete('tbl_battle_statistics');
                $this->db->where('user_id2', $user_id)->delete('tbl_battle_statistics');
                $this->db->query("UPDATE tbl_notifications SET user_id = TRIM(BOTH ',' FROM REPLACE(CONCAT(',', user_id, ','), '," . $user_id . ",', ',')) WHERE type = 'selected' AND FIND_IN_SET('$user_id', user_id) > 0");
                $this->db->where('id', $user_id)->delete('tbl_users');

                $response['error'] = false;
                $response['message'] = "111";
            } else {
                $response['error'] = true;
                $response['message'] = "103";
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }
        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function set_tracker_data_post()
    {
        try {
            $is_user = $this->verify_token();
            if (!$is_user['error']) {
                $user_id = $is_user['user_id'];
                $firebase_id = $is_user['firebase_id'];
            } else {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }
            if ($user_id && $this->post('coins') && $this->post('title') && $this->post('status') != "") {
                $coins = $this->post('coins');
                $title = $this->post('title');
                $status = $this->post('status');

                $this->set_tracker_data($user_id, $coins, $title, $status);

                $response['error'] = false;
                $response['message'] = "111";
            } else {
                $response['error'] = true;
                $response['message'] = "103";
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_tracker_data_post()
    {
        try {
            $is_user = $this->verify_token();
            if (!$is_user['error']) {
                $user_id = $is_user['user_id'];
                $firebase_id = $is_user['firebase_id'];
            } else {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }
            if ($user_id) {
                $offset = ($this->post('offset') && is_numeric($this->post('offset'))) ? $this->post('offset') : 0;
                $limit = ($this->post('limit') && is_numeric($this->post('limit'))) ? $this->post('limit') : 10;
                $type = ($this->post('type') && is_numeric($this->post('type'))) ? $this->post('type') : 0;
                if ($type == 1) {
                    $this->db->where('status', 0);
                } else if ($type == 2) {
                    $this->db->where('status', 1);
                }

                $this->db->where('user_id', $user_id);
                $this->db->order_by('id', 'DESC');
                $this->db->limit($limit, $offset);
                $data = $this->db->get('tbl_tracker')->result_array();
                if (!empty($data)) {
                    if ($type == 1) {
                        $data1 = $this->db->where('user_id', $user_id)->where('status', 0)->order_by('id', 'DESC')->get('tbl_tracker')->result_array();
                    } else if ($type == 2) {
                        $data1 = $this->db->where('user_id', $user_id)->where('status', 1)->order_by('id', 'DESC')->get('tbl_tracker')->result_array();
                    } else {
                        $data1 = $this->db->where('user_id', $user_id)->order_by('id', 'DESC')->get('tbl_tracker')->result_array();
                    }

                    $total = count($data1);

                    $response['error'] = false;
                    $response['total'] = "$total";
                    $response['data'] = $data;
                } else {
                    $response['error'] = true;
                    $response['message'] = "102";
                }
            } else {
                $response['error'] = true;
                $response['message'] = "103";
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function set_payment_request_post()
    {
        try {
            $is_user = $this->verify_token();
            if (!$is_user['error']) {
                $user_id = $is_user['user_id'];
                $firebase_id = $is_user['firebase_id'];
            } else {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }
            if ($user_id && $this->post('payment_type') && $this->post('payment_address') && $this->post('payment_amount') && $this->post('coin_used') && $this->post('details')) {
                $payment_type = $this->post('payment_type');
                $payment_address = $this->post('payment_address');
                $payment_amount = $this->post('payment_amount');
                $coin_used = $this->post('coin_used');
                $details = $this->post('details');
                $status = 0; // 0-pending & 1-completed

                $res = $this->db->where('type', 'payment_mode')->get('tbl_settings')->row_array();
                $res_msg = $this->db->where('type', 'payment_message')->get('tbl_settings')->row_array();
                if (!empty($res) && !empty($res_msg)) {
                    if ($res['message'] == 1 || $res['message'] == '1') {
                        $user_res = $this->db->where('id', $user_id)->get('tbl_users')->row_array();
                        if (!empty($user_res)) {

                            $firebase_id = $user_res['firebase_id'];
                            if ($user_res['status'] == 1 || $user_res['status'] == '1') {

                                /* check if user already made request before 24 hours */
                                $payment_res = $this->db->where('user_id', $user_id)->order_by('id', 'DESC')->get('tbl_payment_request')->row_array();

                                if (!empty($payment_res)) {
                                    $current_time = $this->toDateTime;
                                    $old_date = $payment_res['date'];
                                    $hourdiff = round((strtotime($current_time) - strtotime($old_date)) / 3600, 1);
                                    $hours_res = $this->db->where('type', 'difference_hours')->get('tbl_settings')->row_array();
                                    $hours_diff = (!empty($hours_res)) ? $hours_res['message'] : 48;
                                    if ($hourdiff < $hours_diff) {
                                        $response['error'] = true;
                                        $response['message'] = "127";
                                        $this->response($response, REST_Controller::HTTP_OK);
                                        return false;
                                    }
                                }

                                $frm_data = array(
                                    'user_id' => $user_id,
                                    'uid' => $firebase_id,
                                    'payment_type' => $payment_type,
                                    'payment_address' => $payment_address,
                                    'payment_amount' => $payment_amount,
                                    'coin_used' => $coin_used,
                                    'details' => $details,
                                    'status' => $status,
                                    'date' => $this->toDateTime,
                                    'status_date' => $this->toDateTime,
                                );
                                $this->db->insert('tbl_payment_request', $frm_data);

                                //set tracker data
                                $coins = -$coin_used;
                                $title = "redeemRequest";
                                $this->set_tracker_data($user_id, $coins, $title, 1);

                                //deduct cion from user table
                                $old_coin = $user_res['coins'];
                                $new_coin = $old_coin - $coin_used;
                                $data = array(
                                    'coins' => $new_coin,
                                );
                                $this->db->where('id', $user_id)->where('firebase_id', $firebase_id)->update('tbl_users', $data);
                                $response['error'] = false;
                                $response['message'] = "111";
                            } else {
                                $response['error'] = true;
                                $response['message'] = "126";
                            }
                        } else {
                            $response['error'] = true;
                            $response['message'] = "102";
                        }
                    } else {
                        $response['error'] = true;
                        $response['message'] = $res_msg['message'];
                    }
                } else {
                    $response['error'] = true;
                    $response['message'] = "102";
                }
            } else {
                $response['error'] = true;
                $response['message'] = "103";
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }
        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_payment_request_post()
    {
        try {
            $is_user = $this->verify_token();
            if (!$is_user['error']) {
                $user_id = $is_user['user_id'];
                $firebase_id = $is_user['firebase_id'];
            } else {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }
            if ($user_id) {
                $offset = ($this->post('offset') && is_numeric($this->post('offset'))) ? $this->post('offset') : 0;
                $limit = ($this->post('limit') && is_numeric($this->post('limit'))) ? $this->post('limit') : 10;
                $this->db->where('user_id', $user_id);
                $this->db->order_by('id', 'DESC');
                $this->db->limit($limit, $offset);
                $data = $this->db->get('tbl_payment_request')->result_array();
                if (!empty($data)) {
                    $data1 = $this->db->where('user_id', $user_id)->order_by('id', 'DESC')->get('tbl_payment_request')->result_array();
                    $total = count($data1);

                    $response['error'] = false;
                    $response['total'] = "$total";
                    $response['data'] = $data;
                } else {
                    $response['error'] = true;
                    $response['message'] = "102";
                }
            } else {
                $response['error'] = true;
                $response['message'] = "103";
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_maths_questions_post()
    {
        try {
            $is_user = $this->verify_token();
            if (!$is_user['error']) {
                $user_id = $is_user['user_id'];
                $firebase_id = $is_user['firebase_id'];
            } else {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }
            if ($this->post('type') && $this->post('type_id')) {
                $type = $this->post('type');
                $id = $this->post('type_id');
                $fix_question = is_settings('maths_quiz_fix_question');
                $limit = is_settings('maths_quiz_total_question');

                $this->db->where($type, $id);
                $this->db->order_by($this->Order_By);

                if ($fix_question == 1) {
                    $this->db->limit($limit, 0);
                }
                $data = $this->db->get('tbl_maths_question')->result_array();
                if (!empty($data)) {
                    $questionData = [];
                    for ($i = 0; $i < count($data); $i++) {
                        $data[$i]['image'] = ($data[$i]['image']) ? base_url() . MATHS_QUESTION_IMG_PATH . $data[$i]['image'] : '';
                        $optionData = $this->suffleOptions($data[$i], $firebase_id);
                        $data[$i] = $optionData;
                        $questionData[] = [
                            'id' => $data[$i]['id'],
                            'answer' => $data[$i]['session_answer'],
                        ];
                        unset($data[$i]['session_answer']);
                    }
                    if ($questionData) {
                        $this->set_user_session($user_id, $questionData, 'tbl_user_maths_quiz_session');
                    }
                    $response['error'] = false;
                    $response['data'] = $data;
                } else {
                    $response['error'] = true;
                    $response['message'] = "102";
                }
            } else {
                $response['error'] = true;
                $response['message'] = "103";
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function delete_pending_payment_request_post()
    {
        try {
            $is_user = $this->verify_token();
            if (!$is_user['error']) {
                $user_id = $is_user['user_id'];
            } else {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }
            if ($user_id && $this->post('payment_id')) {
                $user_res = $this->db->where('id', $user_id)->get('tbl_users')->row_array();
                $paymentId = $this->post('payment_id');
                $paymentData = $this->db->where('id', $paymentId)->get('tbl_payment_request')->row_array();
                if ($paymentData) {
                    $newCoins = 0;
                    if ($paymentData['status'] == 0) {

                        // Add Tracker of Cancelled Payment Request
                        $title = "cancelPaymentRequest";
                        $this->set_tracker_data($user_id, $paymentData['coin_used'], $title, 0);

                        // Delete Payment Request
                        $this->db->where('id', $paymentId)->delete('tbl_payment_request');


                        // Calculate new coins
                        $newCoins = $user_res['coins'] + $paymentData['coin_used'];
                        $data = array(
                            'coins' => $newCoins,
                        );
                        // Update Coins in users table
                        $this->db->where('id', $user_id)->update('tbl_users', $data);

                        $response['error'] = false;
                        $response['message'] = "111";
                    } else {
                        $response['error'] = true;
                        $response['message'] = "135";
                    }
                } else {
                    $response['error'] = true;
                    $response['message'] = "102";
                }
            } else {
                $response['error'] = true;
                $response['message'] = "103";
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }
        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function unlock_premium_category_post()
    {
        try {
            $is_user = $this->verify_token();
            if (!$is_user['error']) {
                $user_id = $is_user['user_id'];
                $firebase_id = $is_user['firebase_id'];
            } else {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            if ($this->post('category')) {
                $category_id = $this->post('category');
                $data = $this->db->where(['user_id' => $user_id, 'category_id' => $category_id])->order_by('id', 'asc')->get('tbl_user_category')->result_array();
                if ($data) {
                    $response['error'] = true;
                    $response['message'] = "132";
                } else {
                    $frm_data = array(
                        'user_id' => $user_id,
                        'category_id' => $category_id,
                    );
                    $this->db->insert('tbl_user_category', $frm_data);
                    $response['error'] = false;
                    $response['message'] = "110";
                }
            } else {
                $response['error'] = true;
                $response['message'] = "103";
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }


        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function check_daily_ads_status_post()
    {
        try {
            $is_user = $this->verify_token();
            if (!$is_user['error']) {
                $user_id = $is_user['user_id'];
                $firebase_id = $is_user['firebase_id'];
            } else {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            // Get Daily Ads Coin from Settings
            $dailyAdsCoinQuery = $this->db->select('message')->where('type', 'daily_ads_coins')->get('tbl_settings')->row_array();
            $dailyAdsCoin = $dailyAdsCoinQuery['message'];

            // Get Daily Ads Counter from Settings
            $dailyAdsCounterQuery = $this->db->select('message')->where('type', 'daily_ads_counter')->get('tbl_settings')->row_array();
            $dailyAdsCounter = $dailyAdsCounterQuery['message'];

            // Get User Daily Ads Counter And Date            
            $res = $this->db->where('id', $user_id)->get('tbl_users')->row_array();
            $userCounter = $res['daily_ads_counter'];
            $userDailyAdsDate = $res['daily_ads_date'];

            // Convert Date to string time 
            $dailyAdsDate = strtotime($userDailyAdsDate);
            $currentDate = strtotime(date('Y-m-d'));

            if ($currentDate != $dailyAdsDate) {
                // If Date Doen't match with today's date
                // Then Update Counter to 0 and date to today's
                $data = array(
                    'daily_ads_counter' => 0,
                    'daily_ads_date' => date('Y-m-d'),
                );

                // Update data and allow the user to watch ads
                $this->db->where('id', $user_id)->where('firebase_id', $firebase_id)->update('tbl_users', $data);
                $response['error'] = false;
                $response['message'] = "134";
            } else {
                if ($dailyAdsCounter == $userCounter) {
                    // If Daily Ads Counter is less than or equal to user's counter then not allow to watch ads
                    $response['error'] = true;
                    $response['message'] = "133";
                } else {
                    // If Daily Ads Counter is greater than or equal to user's counter then allow to watch ads
                    $response['error'] = false;
                    $response['message'] = "134";
                }
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function update_daily_ads_counter_post()
    {

        try {
            $is_user = $this->verify_token();
            if (!$is_user['error']) {
                $user_id = $is_user['user_id'];
                $firebase_id = $is_user['firebase_id'];
            } else {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            // Get Daily Ads Coin from Settings
            $dailyAdsCoinQuery = $this->db->select('message')->where('type', 'daily_ads_coins')->get('tbl_settings')->row_array();
            $dailyAdsCoin = $dailyAdsCoinQuery ? $dailyAdsCoinQuery['message'] : 5;

            // Get Daily Ads Counter from Settings
            $dailyAdsCounterQuery = $this->db->select('message')->where('type', 'daily_ads_counter')->get('tbl_settings')->row_array();
            $dailyAdsCounter = $dailyAdsCounterQuery ? $dailyAdsCounterQuery['message'] : 1;

            // Get User Daily Ads Counter, Date And Coins
            $res = $this->db->where('id', $user_id)->get('tbl_users')->row_array();
            $userCounter = $res['daily_ads_counter'];
            $userDailyAdsDate = $res['daily_ads_date'];
            $userCoins = $res['coins'];

            // Convert Date to string time 
            $dailyAdsDate = strtotime($userDailyAdsDate);
            $currentDate = strtotime(date('Y-m-d'));

            $data = array();

            if ($currentDate != $dailyAdsDate) {
                // If Date Doen't match with today's date
                // Then Update Counter to 0 and date to today's
                $data = array(
                    'daily_ads_counter' => 1,
                    'daily_ads_date' => date('Y-m-d'),
                );
                $response['error'] = false;
                $response['message'] = "111";
            } else {
                // If Date match with today's date
                if ($dailyAdsCounter <= $userCounter) {
                    // If Daily Ads Counter is less than or equal to user's counter then not allow to watch ads
                    $response['error'] = true;
                    $response['message'] = "133";
                } else {
                    // If Counter is not equal or exceding then update with increment
                    $data = array(
                        'daily_ads_counter' => ($userCounter + 1),
                        'coins' => ($userCoins + $dailyAdsCoin)
                    );
                    $response['error'] = false;
                    $response['message'] = "111";
                }
            }

            // Data Array Exists then update User Tracker and 
            if (isset($data) && !empty($data)) {
                $this->set_tracker_data($user_id, $dailyAdsCoin, $this->watched_ads, 0);
                $this->db->where('id', $user_id)->update('tbl_users', $data);
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }
        $this->response($response, REST_Controller::HTTP_OK);
    }

    // Web's Home Settings settings data are retrived in this api
    public function get_web_home_settings_post()
    {
        try {
            $types = [
                'section_1_mode',
                'section1_heading',
                'section1_title1',
                'section1_title2',
                'section1_title3',
                'section1_image1',
                'section1_image2',
                'section1_image3',
                'section1_desc1',
                'section1_desc2',
                'section1_desc3',
                'section_2_mode',
                'section2_heading',
                'section2_title1',
                'section2_title2',
                'section2_title3',
                'section2_title4',
                'section2_desc1',
                'section2_desc2',
                'section2_desc3',
                'section2_desc4',
                'section2_image1',
                'section2_image2',
                'section2_image3',
                'section2_image4',
                'section_3_mode',
                'section3_heading',
                'section3_title1',
                'section3_title2',
                'section3_title3',
                'section3_title4',
                'section3_image1',
                'section3_image2',
                'section3_image3',
                'section3_image4',
                'section3_desc1',
                'section3_desc2',
                'section3_desc3',
                'section3_desc4'
            ];

            $language_id = $this->post('language_id') != "" ? $this->post('language_id') : 14;
            $data = $this->db->where('language_id', $language_id)->where_in('type', $types)->get('tbl_web_settings')->result_array();
            $web_settings_data = array();
            if (is_language_mode_enabled()) {
                $this->db->where('language_id', $language_id);
            }
            $sliderData = $this->db->order_by('id', 'DESC')->get('tbl_slider')->result_array();
            if (!empty($sliderData)) {
                for ($i = 0; $i < count($sliderData); $i++) {
                    $sliderData[$i]['image'] = ($sliderData[$i]['image']) ? base_url() . SLIDER_IMG_PATH . $sliderData[$i]['image'] : '';
                }
            }
            $web_settings_data['sliderData'] = $sliderData;

            if (!empty($data)) {
                for ($i = 0; $i < count($data); $i++) {
                    $type = $data[$i]['type'];
                    $message = $data[$i]['message'];

                    // Images of Home settings
                    $images = ['section1_image1', 'section1_image2', 'section1_image3', 'section2_image1', 'section2_image2', 'section2_image3', 'section2_image4', 'section3_image1', 'section3_image2', 'section3_image3', 'section3_image4'];
                    foreach ($images as $key => $value) {
                        if ($type == $value) {
                            $message = ($message) ? base_url() . WEB_HOME_SETTINGS_LOGO_PATH . $message : '';
                        }
                    }

                    $web_settings_data[$type] = $message;
                }
                $response['error'] = false;
                $response['data'] = $web_settings_data;
            } else {
                if (!empty($sliderData)) {
                    $response['error'] = false;
                    $response['data'] = $web_settings_data;
                } else {
                    $response['error'] = true;
                    $response['message'] = "102";
                }
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }
        $this->response($response, REST_Controller::HTTP_OK);
    }

    // Web's Settings data are retrived in this api
    public function get_web_settings_post()
    {
        try {
            $types = [
                'firebase_api_key',
                'firebase_auth_domain',
                'firebase_database_url',
                'firebase_project_id',
                'firebase_storage_bucket',
                'firebase_messager_sender_id',
                'firebase_app_id',
                'firebase_measurement_id',
                'company_name_footer',
                'email_footer',
                'phone_number_footer',
                'web_link_footer',
                'company_text',
                'address_text',
                'header_logo',
                'footer_logo',
                'sticky_header_logo',
                'quiz_zone_icon',
                'daily_quiz_icon',
                'true_false_icon',
                'fun_learn_icon',
                'self_challange_icon',
                'contest_play_icon',
                'one_one_battle_icon',
                'group_battle_icon',
                'audio_question_icon',
                'math_mania_icon',
                'exam_icon',
                'guess_the_word_icon',
                'primary_color',
                'footer_color',
                'social_media',
                'multi_match_icon'
            ];
            // Here Added language because settings and home settings of web are in same folder and web settings will be always stored with language 14
            $data = $this->db->where('language_id', 14)->where_in('type', $types)->get('tbl_web_settings')->result_array();
            $web_settings_data = array();
            if (!empty($data)) {
                for ($i = 0; $i < count($data); $i++) {
                    $type = $data[$i]['type'];

                    if ($type == 'social_media') {
                        $message = $data[$i]['message'] ? json_decode($data[$i]['message']) : '';
                        if (!empty($message)) {
                            foreach ($message as $key => $value) {
                                $value->icon = ($value->icon) ? base_url() . WEB_SETTINGS_LOGO_PATH . $value->icon : '';
                            }
                        }
                    } else {
                        $message = $data[$i]['message'];
                        // LOGOS of Web settings
                        $logos = ['favicon', 'header_logo', 'footer_logo', 'sticky_header_logo', 'quiz_zone_icon', 'daily_quiz_icon', 'true_false_icon', 'fun_learn_icon', 'self_challange_icon', 'contest_play_icon', 'one_one_battle_icon', 'group_battle_icon', 'audio_question_icon', 'math_mania_icon', 'exam_icon', 'guess_the_word_icon', 'multi_match_icon'];
                        foreach ($logos as $key => $value) {
                            if ($type == $value) {
                                $message = ($message) ? base_url() . WEB_SETTINGS_LOGO_PATH . $message : '';
                            }
                        }
                    }

                    $web_settings_data[$type] = $message;
                }
                $response['error'] = false;
                $response['data'] = $web_settings_data;
            } else {
                $response['error'] = true;
                $response['message'] = "102";
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_user_coin_score_post()
    {
        try {
            $is_user = $this->verify_token();
            if (!$is_user['error']) {
                $user_id = $is_user['user_id'];
                $firebase_id = $is_user['firebase_id'];
            } else {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            if ($user_id) {
                $result = $this->db->select('coins')->where('id', $user_id)->get('tbl_users')->row_array();
                if (!empty($result)) {
                    $my_rank = $this->myGlobalRank($user_id);

                    $result['score'] = ($my_rank) ? $my_rank['score'] : '0';

                    $response['error'] = false;
                    $response['data'] = $result;
                } else {
                    $response['error'] = true;
                    $response['message'] = "102";
                }
            } else {
                $response['error'] = true;
                $response['message'] = "103";
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function set_user_in_app_post()
    {
        try {
            $is_user = $this->verify_token();
            if (!$is_user['error']) {
                $user_id = $is_user['user_id'];
                $firebase_id = $is_user['firebase_id'];
            } else {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }
            if ($user_id && $this->post('product_id')) {
                $product_id = $this->post('product_id');
                if ($this->post('purchase_token') && $this->post('pay_from')) {
                    $purchaseToken = $this->post('purchase_token');
                    $pay_from = $this->post('pay_from');
                    $getCoinStoreData = $this->db->select('coins,type')->where('product_id', $product_id)->get('tbl_coin_store')->row_array();
                    $amount = $getCoinStoreData['coins'] ?? 0;
                    $packageType = $getCoinStoreData['type'] ?? '';
                    $status = 1;

                    $checkToken = $this->db->where('product_id', $product_id)->where('purchase_token', $purchaseToken)->get('tbl_users_in_app')->row_array();
                    if (empty($checkToken)) {
                        // 1=android,2=ios
                        if ($pay_from == 1) {
                            $packageName = is_settings('app_package_name') ?? '';
                            $pathToServiceAccountJsonFile = 'assets/firebase_config.json';
                            $get_file = file_get_contents($pathToServiceAccountJsonFile); //data read from json file
                            $fileData = ($get_file != '') ? json_decode($get_file) : '';
                            $applicationName = ($fileData != '') ? $fileData->project_id ?? '' : '';
                            if ($applicationName != '') {
                                $googleClient = new Google\Client();
                                $googleClient->setScopes([\Google\Service\AndroidPublisher::ANDROIDPUBLISHER]);
                                $googleClient->setApplicationName($applicationName);
                                $googleClient->setAuthConfig($pathToServiceAccountJsonFile);

                                $googleAndroidPublisher = new \Google\Service\AndroidPublisher($googleClient);
                                $validator = new \ReceiptValidator\GooglePlay\Validator($googleAndroidPublisher);

                                try {
                                    $ValidResponse = $validator->setPackageName($packageName)
                                        ->setProductId($product_id)
                                        ->setPurchaseToken($purchaseToken)
                                        ->validatePurchase();

                                    if ($ValidResponse) {

                                        $response1 = $googleAndroidPublisher->purchases_products->get($packageName, $product_id, $purchaseToken);
                                        $orderId = $response1->getOrderId() ?? '';
                                        $checkOrder = $this->db->where('product_id', $product_id)->where('purchase_token', $purchaseToken)->get('tbl_users_in_app')->row_array();

                                        $purchaseTimeMillis = $response1->purchaseTimeMillis ?? '';
                                        if ($purchaseTimeMillis != '') {

                                            // Convert milliseconds to seconds and create a DateTime object
                                            $purchaseTimeSeconds = $purchaseTimeMillis / 1000;
                                            $purchaseDate = new DateTime("@$purchaseTimeSeconds");
                                            $purchaseDate->setTimezone(new DateTimeZone(get_system_timezone())); // Set the desired timezone if needed

                                            $date = $purchaseDate->format('Y-m-d H:i:s');
                                        }

                                        $tracker_data = [
                                            'pay_from' => 1,
                                            'uid' => $firebase_id,
                                            'user_id' => $user_id,
                                            'product_id' => $product_id,
                                            'amount' => $amount ?? 0,
                                            'status' => $status ?? 0,
                                            'transaction_id' => $orderId ?? '',
                                            'date' => ($date != '') ? $date : $this->toDateTime,
                                            'purchase_token' => $purchaseToken,
                                            'responseData' => $response1 ? json_encode($response1) : '',
                                        ];
                                        $insertData = $this->db->insert('tbl_users_in_app', $tracker_data);

                                        if ($insertData) {
                                            if ($packageType != '' && $packageType == 0) {
                                                $coins = $amount ?? 0;
                                                $this->set_coins($user_id, $coins);
                                                //set tracker data
                                                $title = 'boughtCoins';
                                                $status = 0;
                                                $this->set_tracker_data($user_id, $coins, $title, $status);
                                            } else if ($packageType != '' && $packageType == 1) {
                                                $updateAds = [
                                                    'remove_ads' => 1
                                                ];
                                                $this->db->where('id', $user_id)->update('tbl_users', $updateAds);
                                            }
                                            $response['error'] = false;
                                            $response['message'] = "110";
                                        } else {
                                            $response['error'] = true;
                                            $response['message'] = "122";
                                        }
                                    } else {
                                        $response['error'] = true;
                                        $response['message'] = "122";
                                    }
                                } catch (Exception $e) {
                                    $response['error'] = true;
                                    $response['message'] = '122';
                                    $response['message_error'] = $e->getMessage();
                                }
                            } else {
                                $response['error'] = true;
                                $response['message'] = '122';
                            }
                        } else if ($pay_from == 2) {
                            $validator = new iTunesValidator(iTunesValidator::ENDPOINT_PRODUCTION);
                            $receiptBase64Data = $purchaseToken;
                            try {
                                $sharedSecret = is_settings('shared_secrets') ?? ''; // Generated in iTunes Connect's In-App Purchase menu
                                if ($sharedSecret) {
                                    $ValidateResponse = $validator->setSharedSecret($sharedSecret)->setReceiptData($receiptBase64Data)->validate(); // use setSharedSecret() if for recurring subscriptions
                                    if ($ValidateResponse->isValid()) {
                                        foreach ($ValidateResponse->getPurchases() as $purchase) {
                                            $responseData = $purchase;
                                            $getTransactionId = $purchase->getTransactionId();
                                            if ($purchase->getPurchaseDate() != null) {
                                                $getPurchaseDate = $purchase->getPurchaseDate();
                                            }
                                        }
                                        $tracker_data = [
                                            'pay_from' => 2,
                                            'uid' => $firebase_id,
                                            'user_id' => $user_id,
                                            'product_id' => $product_id,
                                            'amount' => $amount ?? 0,
                                            'status' => $status ?? 0,
                                            'transaction_id' => $getTransactionId ?? '',
                                            'date' => isset($getPurchaseDate) ? $getPurchaseDate : $this->toDateTime,
                                            'purchase_token' => $purchaseToken,
                                            'responseData' => json_encode($responseData) ?? ''
                                        ];
                                        $insertData = $this->db->insert('tbl_users_in_app', $tracker_data);
                                        if ($insertData) {
                                            if ($packageType != '' && $packageType == 0) {
                                                $coins = $amount ?? 0;
                                                $this->set_coins($user_id, $coins);
                                                //set tracker data
                                                $title = 'boughtCoins';
                                                $status = 0;
                                                $this->set_tracker_data($user_id, $coins, $title, $status);
                                            } else if ($packageType != '' && $packageType == 1) {
                                                $updateAds = [
                                                    'remove_ads' => 1
                                                ];
                                                $this->db->where('id', $user_id)->update('tbl_users', $updateAds);
                                            }
                                            $response['error'] = false;
                                            $response['message'] = "110";
                                        } else {
                                            $response['error'] = true;
                                            $response['message'] = "122";
                                        }
                                    } else {
                                        $response['error'] = true;
                                        $response['message'] = '122';
                                        $response['message_error'] = $ValidateResponse->getResultCode();
                                    }
                                } else {
                                    $response['error'] = true;
                                    $response['message'] = "103";
                                }
                            } catch (Exception $e) {
                                $response['error'] = true;
                                $response['message'] = '122';
                                $response['message_error'] = $e->getMessage();
                            }
                        } else {
                            $response['error'] = true;
                            $response['message'] = "122";
                        }
                    } else {
                        $response['error'] = true;
                        $response['message'] = "136";
                    }
                } else {
                    $response['error'] = true;
                    $response['message'] = "103";
                }
            } else {
                $response['error'] = true;
                $response['message'] = "103";
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_system_language_list_post()
    {
        try {
            if ($this->post('from')) {
                $from = $this->post('from');
                $this->db->select('name,title');
                switch ($from) {
                    case 1:
                        $this->db->select('app_version,app_rtl_support,app_status,app_default')->where('app_status', 1)->where('app_version!=', '0.0.0');
                        break;
                    case 2:
                        $this->db->select('web_version,web_rtl_support,web_status,web_default')->where('web_status', 1)->where('web_version!=', '0.0.0');
                        break;
                    default:
                        $response = [
                            'error' => true,
                            'message' => "122"
                        ];
                        $this->response($response, REST_Controller::HTTP_OK);
                        return;
                }
                $checkData = $this->db->get('tbl_upload_languages')->result_array();
                if ($checkData) {
                    $response = [
                        'error' => false,
                        'data' => $checkData
                    ];
                } else {
                    $response = [
                        'error' => true,
                        'message' => "102"
                    ];
                }
            } else {
                $response = [
                    'error' => true,
                    'message' => "103"
                ];
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }
        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_system_language_json_post()
    {
        try {
            if ($this->post('from')) {
                $from = $this->post('from');
                $language = $this->post('language') ?? 'english';
                $version = '';
                $rtl_support = '0';
                $status = '0';
                $default = '0';

                switch ($from) {
                    case 1:
                        $path = APP_LANGUAGE_FILE_PATH;
                        $sampleFile = 'app_sample_file.json';
                        break;
                    case 2:
                        $path = WEB_LANGUAGE_FILE_PATH;
                        $sampleFile = 'web_sample_file.json';
                        break;
                    default:
                        $response = [
                            'error' => true,
                            'message' => "122"
                        ];
                        $this->response($response, REST_Controller::HTTP_OK);
                        return;
                }

                $file = $path . $language . '.json';

                if (!file_exists($file)) {
                    $file = $path . $sampleFile;
                } else {
                    $checkData = $this->db->where('name', $language)->get('tbl_upload_languages')->row_array();
                    if ($checkData) {
                        $version = ($from == 1) ? $checkData['app_version'] : $checkData['web_version'];
                        $rtl_support = ($from == 1) ? $checkData['app_rtl_support'] : $checkData['web_rtl_support'];
                        $status = ($from == 1) ? $checkData['app_status'] : $checkData['web_status'];
                        $default = ($from == 1) ? $checkData['app_default'] : $checkData['web_default'];
                    }
                }

                $getFileContent = file_get_contents($file);
                $sampleArray = json_decode($getFileContent, true);

                $response = [
                    'error' => false,
                    'version' => $version,
                    'rtl_support' => $rtl_support,
                    'status' => $status,
                    'default' => $default,
                    'data' => $sampleArray
                ];
            } else {
                $response = [
                    'error' => true,
                    'message' => "103"
                ];
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_multi_match_questions_post()
    {
        try {
            $is_user = $this->verify_token();
            if (!$is_user['error']) {
                $user_id = $is_user['user_id'];
                $firebase_id = $is_user['firebase_id'];
            } else {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            if ($this->post('type') && $this->post('id')) {
                $type = $this->post('type');
                $id = $this->post('id');

                $this->db->where($type, $id);
                $this->db->order_by($this->Order_By);
                $data = $this->db->get('tbl_multi_match')->result_array();
                if (!empty($data)) {
                    for ($i = 0; $i < count($data); $i++) {
                        $seedSource = 'multi_match|' . $user_id . '|' . ($data[$i]['id'] ?? '') . '|' . ($type ?? '') . '|' . ($id ?? '');
                        $data[$i] = $this->remapMultiMatchSequenceQuestion($data[$i], $seedSource);
                        $data[$i]['image'] = ($data[$i]['image']) ? base_url() . MULTIMATCH_QUESTION_IMG_PATH . $data[$i]['image'] : '';
                        $answers = explode(',', trim($data[$i]['answer']));
                        $data[$i]['answer'] = array_map(function ($answer) use ($firebase_id) {
                            return $this->encrypt_data($firebase_id, $answer);
                        }, $answers);
                    }
                    $response['error'] = false;
                    $response['data'] = $data;
                } else {
                    $response['error'] = true;
                    $response['message'] = "102";
                }
            } else {
                $response['error'] = true;
                $response['message'] = "103";
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }
        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_multi_match_questions_by_type_post()
    {
        try {
            $is_user = $this->verify_token();
            if (!$is_user['error']) {
                $user_id = $is_user['user_id'];
                $firebase_id = $is_user['firebase_id'];
            } else {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            if ($this->post('question_type')) {
                $type = $this->post('question_type');
                $language_id = ($this->post('language_id')) ? $this->post('language_id') : "0";
                $fix_question = is_settings('true_false_quiz_fix_question');
                $limit = is_settings('true_false_quiz_total_question');

                $this->db->select('ms.*,c.id as cat_id, sc.id as subcat_id');

                $this->db->where('ms.question_type', $type);
                if (!empty($language_id)) {
                    $this->db->where('ms.language_id', $language_id);
                }
                $this->db->join('tbl_category c', 'ms.category = c.id')->where('c.is_premium', '0');
                $this->db->join('tbl_subcategory sc', 'ms.subcategory = sc.id', 'left');
                $this->db->order_by($this->Order_By);

                if ($fix_question == 1 && $limit) {
                    $this->db->limit($limit, 0);
                }

                $data = $this->db->get('tbl_multi_match ms')->result_array();

                if (!empty($data)) {
                    for ($i = 0; $i < count($data); $i++) {
                        $seedSource = 'multi_match_by_type|' . $user_id . '|' . ($data[$i]['id'] ?? '') . '|' . ($type ?? '') . '|' . ($language_id ?? '');
                        $data[$i] = $this->remapMultiMatchSequenceQuestion($data[$i], $seedSource);
                        $data[$i]['image'] = ($data[$i]['image']) ? base_url() . MULTIMATCH_QUESTION_IMG_PATH . $data[$i]['image'] : '';
                        $answers = explode(',', trim($data[$i]['answer']));
                        $data[$i]['answer'] = array_map(function ($answer) use ($firebase_id) {
                            return $this->encrypt_data($firebase_id, $answer);
                        }, $answers);
                    }
                    $response['error'] = false;
                    $response['data'] = $data;
                } else {
                    $response['error'] = true;
                    $response['message'] = "102";
                }
            } else {
                $response['error'] = true;
                $response['message'] = "103";
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }
        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_multi_match_questions_by_level_post()
    {
        try {
            $is_user = $this->verify_token();
            if (!$is_user['error']) {

                $user_id = $is_user['user_id'];
                $firebase_id = $is_user['firebase_id'];
            } else {

                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }
            if ($this->post('level') && ($this->post('category') || $this->post('subcategory'))) {
                $level = $this->post('level');
                $language_id = ($this->post('language_id')) ? $this->post('language_id') : 0;
                $category_id = $this->post('category');
                $subcategory_id = $this->post('subcategory');
                $fix_question = is_settings('multi_match_fix_level_question');
                $limit = is_settings('multi_match_total_level_question');

                $this->db->select('mq.*,cat.slug as category_slug,subcat.slug as subcategory_slug');
                $this->db->where('level', $level);
                $this->db->join('tbl_category cat', 'cat.id=mq.category', 'left');
                $this->db->join('tbl_subcategory subcat', 'subcat.id=mq.subcategory', 'left');
                if ($this->post('subcategory')) {
                    $this->db->where('mq.subcategory', $subcategory_id);
                } else {
                    $this->db->where('mq.category', $category_id);
                }
                if (!empty($language_id)) {
                    $this->db->where('mq.language_id', $language_id);
                }
                $this->db->order_by($this->Order_By);
                if ($fix_question == 1) {
                    $this->db->limit($limit, 0);
                }
                $data = $this->db->get('tbl_multi_match mq')->result_array();
                $questionData = [];
                if (!empty($data)) {
                    for ($i = 0; $i < count($data); $i++) {
                        $seedSource = 'multi_match_by_level|' . $user_id . '|' . ($data[$i]['id'] ?? '') . '|' . ($level ?? '') . '|' . ($category_id ?? '') . '|' . ($subcategory_id ?? '');
                        $data[$i] = $this->remapMultiMatchSequenceQuestion($data[$i], $seedSource);
                        $data[$i]['image'] = ($data[$i]['image']) ? base_url() . MULTIMATCH_QUESTION_IMG_PATH . $data[$i]['image'] : '';
                        $questionData[] = [
                            'id' => $data[$i]['id'],
                            'answer' => $data[$i]['answer'],
                            'level' => $data[$i]['level']
                        ];
                        $answers = explode(',', trim($data[$i]['answer']));
                        $data[$i]['answer'] = array_map(function ($answer) use ($firebase_id) {
                            return $this->encrypt_data($firebase_id, $answer);
                        }, $answers);
                    }
                    if ($questionData) {
                        $this->set_user_session($user_id, $questionData, 'tbl_user_multi_match_session');
                    }
                    $response['error'] = false;
                    $response['data'] = $data;
                } else {
                    $response['error'] = true;
                    $response['message'] = "102";
                }
            } else {
                $response['error'] = true;
                $response['message'] = "103";
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function multi_match_report_question_post()
    {
        try {
            $is_user = $this->verify_token();
            if (!$is_user['error']) {
                $user_id = $is_user['user_id'];
                $firebase_id = $is_user['firebase_id'];
            } else {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            if ($this->post('question_id') && $user_id && $this->post('message')) {
                $frm_data = array(
                    'question_id' => $this->post('question_id'),
                    'user_id' => $user_id,
                    'message' => $this->post('message'),
                    'date' => $this->toDateTime,
                );
                $this->db->insert('tbl_multi_match_question_reports', $frm_data);
                $response['error'] = false;
                $response['message'] = "109";
            } else {
                $response['error'] = true;
                $response['message'] = "103";
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }
        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function get_multi_match_level_data_post()
    {
        try {
            $is_user = $this->verify_token();
            if (!$is_user['error']) {
                $user_id = $is_user['user_id'];
                $firebase_id = $is_user['firebase_id'];
            } else {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            if ($user_id && ($this->post('category') || $this->post('category_slug'))) {
                $category = $this->post('category') ?? 0;
                $categorySlug = !empty($this->post('category_slug')) ? $this->post('category_slug') : null;
                $subcategory = ($this->post('subcategory')) ? $this->post('subcategory') : 0;
                $subcategorySlug = !empty($this->post('subcategory_slug')) ? $this->post('subcategory_slug') : null;

                if ($subcategory) {
                    $subcategoryData = $this->db->select("id,maincat_id,subcategory_name,slug")->where('id', $subcategory)->get('tbl_subcategory')->row_array();
                    if ($subcategoryData) {
                        $categoryData = $this->getCategoryData($category, $categorySlug);
                        $questionData = $this->getMultiMatchQuestionData($subcategoryData, $categoryData);
                    }
                } elseif ($subcategorySlug) {
                    $subcategoryData = $this->db->select("id,maincat_id,subcategory_name,slug")->where('slug', $subcategorySlug)->get('tbl_subcategory')->row_array();
                    if ($subcategoryData) {
                        $categoryData = $this->getCategoryData($category, $categorySlug);
                        $questionData = $this->getMultiMatchQuestionData($subcategoryData, $categoryData);
                    }
                } else {
                    $categoryData = $this->getCategoryData($category, $categorySlug);
                    $subcategoryData = ['id' => 0];
                    $questionData = $this->getMultiMatchQuestionData($subcategoryData, $categoryData);
                }

                if ((isset($categoryData) && !empty($categoryData)) && (isset($subcategoryData) && !empty($subcategoryData))) {
                    // Get Level Data with its Particular Question Count
                    $max_level = $questionData['max_level'];
                    $counter = range(1, $max_level);
                    $levelData = [];

                    foreach ($counter as $key => $level) {
                        $query = $this->db->query('select count(id) as no_of_que from tbl_multi_match where level = ' . $level . ' and category = ' . $categoryData["id"] . ' and subcategory = ' . $subcategoryData["id"])->row_array();
                        $levelData[$key]['level'] = $level;
                        $levelData[$key]['no_of_ques'] = $query['no_of_que'];
                    }

                    // Get Data 
                    $res = $this->db->select('level')->where('user_id', $user_id)->where('category', $categoryData['id'])->where('subcategory', $subcategoryData['id'])->get('tbl_multi_match_level')->row_array();
                    $data = array(
                        'level' => $res['level'] ?? "1",
                        'no_of_ques' => $questionData['no_of_que'],
                        'max_level' => $questionData['max_level'],
                        'category' => $categoryData ?? [],
                        'subcategory' => $subcategoryData ?? [],
                        'level_data' => $levelData ?? []
                    );
                    $response['error'] = false;
                    $response['data'] = $data;
                } else {
                    $response['error'] = true;
                    $response['message'] = "102";
                }
            } else {
                $response['error'] = true;
                $response['message'] = "103";
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }


        $this->response($response, REST_Controller::HTTP_OK);
    }

    public function set_quiz_coin_score_post()
    {
        try {
            $is_user = $this->verify_token();
            if (!$is_user['error']) {
                $user_id = $is_user['user_id'];
                $firebase_id = $is_user['firebase_id'];
            } else {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            if ($user_id && $this->post('quiz_type')) {
                $category = $this->post('category') ? $this->post('category') : 0;
                $subcategory = $this->post('subcategory') ? $this->post('subcategory') : 0;
                $match_id = $this->post('match_id') ? $this->post('match_id') : 0;
                $is_bot = $this->post('is_bot') ? $this->post('is_bot') : 0;
                $no_of_hint_used = $this->post('no_of_hint_used') ? $this->post('no_of_hint_used') : 0;
                $totalPlayTime = $this->post('total_play_time') ? $this->post('total_play_time') : 0;
                $joined_users_count = $this->post('joined_users_count') ? $this->post('joined_users_count') : 0;
                $quiz_type = $this->post('quiz_type');
                $playQuestions = $this->post('play_questions');
                $lifeline = $this->post('lifeline') ? explode(',', $this->post('lifeline')) : [];

                $quizMap = [
                    "1"   => [
                        'table' => 'tbl_user_quiz_zone_session',
                        'handler' => 'QuizZone',
                        'params' => [$user_id, 'tbl_user_quiz_zone_session', $category, $subcategory, $playQuestions, $lifeline],
                        'requires_session' => true
                    ],
                    "1.1" => [
                        'table' => 'tbl_user_daily_quiz_session',
                        'handler' => 'DailyQuiz',
                        'params' => [$user_id, 'tbl_user_daily_quiz_session', $playQuestions],
                        'requires_session' => true
                    ],
                    "1.2" => [
                        'table' => 'tbl_user_true_false_session',
                        'handler' => 'trueFalse',
                        'params' => [$user_id, 'tbl_user_true_false_session', $playQuestions],
                        'requires_session' => true
                    ],
                    "1.3" => [
                        'handler' => 'randomBattle',
                        'params' => [$user_id, $match_id, $is_bot, $playQuestions],
                        'requires_session' => false
                    ],
                    "1.4" => [
                        'handler' => 'oneVsOneBattle',
                        'params' => [$user_id, $match_id, $playQuestions],
                        'requires_session' => false
                    ],
                    "1.5" => [
                        'handler' => 'groupBattle',
                        'params' => [$user_id, $match_id, $playQuestions, $joined_users_count],
                        'requires_session' => false
                    ],
                    "2"   => [
                        'table' => 'tbl_user_fun_n_learn_session',
                        'handler' => 'funNLearn',
                        'params' => [$user_id, 'tbl_user_fun_n_learn_session', $category, $subcategory, $playQuestions, $totalPlayTime],
                        'requires_session' => true
                    ],
                    "3"   => [
                        'table' => 'tbl_user_guess_the_word_session',
                        'handler' => 'guessTheWord',
                        'params' => [$user_id, 'tbl_user_guess_the_word_session', $category, $subcategory, $playQuestions, $totalPlayTime, $no_of_hint_used],
                        'requires_session' => true
                    ],
                    "4"   => [
                        'table' => 'tbl_user_audio_quiz_session',
                        'handler' => 'audioQuiz',
                        'params' => [$user_id, 'tbl_user_audio_quiz_session', $category, $subcategory, $playQuestions],
                        'requires_session' => true
                    ],
                    "5"   => [
                        'table' => 'tbl_user_maths_quiz_session',
                        'handler' => 'mathsQuiz',
                        'params' => [$user_id, 'tbl_user_maths_quiz_session', $category, $subcategory, $playQuestions],
                        'requires_session' => true
                    ],
                    "6"   => [
                        'table' => 'tbl_user_multi_match_session',
                        'handler' => 'multiMatch',
                        'params' => [$user_id, 'tbl_user_multi_match_session', $category, $subcategory, $playQuestions],
                        'requires_session' => true
                    ],
                    "contest"   => [
                        'table' => 'tbl_user_contest_session',
                        'handler' => 'contest',
                        'params' => [$user_id, 'tbl_user_contest_session', $playQuestions],
                        'requires_session' => true
                    ],
                ];

                $key = (string) $quiz_type;
                if (isset($quizMap[$key])) {
                    $config = $quizMap[$key];
                    $table = '';
                    $handler = $config['handler'];
                    $params = $config['params'];
                    $requiresSession = $config['requires_session'] ?? false;

                    if ($requiresSession) {
                        $table = $config['table'];
                        $batchSize = 500;
                        do {
                            $rows = $this->db->select('id')
                                ->from($table)
                                ->where('date <', $this->twoDayOldDate)
                                ->limit($batchSize)
                                ->get()
                                ->result_array();

                            $idsToDelete = array_column($rows, 'id');

                            if (!empty($idsToDelete)) {
                                $this->db->where_in('id', $idsToDelete);
                                $this->db->delete($table);
                            }

                            $deletedRows = count($idsToDelete);
                        } while ($deletedRows === $batchSize);


                        // Only check session with light query
                        $checkData = $this->db->select('id')
                            ->where('user_id', $user_id)
                            ->limit(1)
                            ->get($table)
                            ->row_array();

                        if (!$checkData) {
                            $response = [
                                'error' => true,
                                'error_msg' => 'Not Valid',
                                'message' => "122"
                            ];
                            $this->response($response, REST_Controller::HTTP_OK);
                            return;
                        }
                    }

                    $res = call_user_func_array([$this, $handler], $params);
                    if ($res) {
                        $response = [
                            'error' => false,
                            'message' => "111",
                            'data' => $res
                        ];
                    } else {
                        $response = [
                            'error' => true,
                            'message' => "102"
                        ];
                    }
                } else {
                    $response = [
                        'error' => true,
                        'error_msg' => 'Quiz Type',
                        'message' => "122"
                    ];
                }
            } else {
                $response['error'] = true;
                $response['message'] = "103";
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    /**
     * Other Functions used for internally 
     */

    function set_quiz_level_data($user_id, $quiz_type, $level, $category, $subcategory = 0)
    {
        $table = '';
        if ($quiz_type == 1) {
            $table = 'tbl_level';
        } else if ($quiz_type == 6) {
            $table = 'tbl_multi_match_level';
        }
        if ($table) {
            $this->db->where('user_id', $user_id)->where('category', $category)->where('subcategory', $subcategory);
            $res = $this->db->get($table)->result_array();
            if (!empty($res)) {
                $data = array(
                    'level' => $level,
                );
                $this->db->where('user_id', $user_id)->where('category', $category)->where('subcategory', $subcategory)->update($table, $data);
            } else {
                $frm_data = array(
                    'user_id' => $user_id,
                    'category' => $category,
                    'subcategory' => $subcategory,
                    'level' => $level,
                );
                $this->db->insert($table, $frm_data);
            }
        }
    }

    function set_users_statistics($user_id, $category_id, $questions_answered, $correct_answers,  $ratio)
    {
        $res = $this->db->where('user_id', $user_id)->get('tbl_users_statistics')->row_array();
        if (!empty($res)) {
            $type = 'big_thing';
            $res2 = $this->db->where('user_id', $user_id)->get('tbl_users_badges')->row_array();
            if (!empty($res2)) {
                if ($res2[$type] == 0 || $res2[$type] == '0') {
                    $res1 = $this->db->where('type', $type)->get('tbl_badges')->row_array();
                    if (!empty($res1)) {
                        $counter = $res1['badge_counter'];
                        if ($counter <= $res['correct_answers']) {
                            $this->set_badges($user_id, $this->BIG_THING, 1);
                        }
                    }
                }
            }

            $qa = $res['questions_answered'];
            $ca = $res['correct_answers'];
            $sc = $res['strong_category'];
            $r1 = $res['ratio1'];
            $wc = $res['weak_category'];
            $r2 = $res['ratio2'];
            $bp = $res['best_position'];

            $my_rank = $this->myGlobalRank($user_id);

            $rank1 = $my_rank['user_rank'];
            if ($rank1 < $bp || $bp == 0) {
                $bp = $rank1;
                $data = array('best_position' => $bp);
                $this->db->where('user_id', $user_id)->update('tbl_users_statistics', $data);
            }

            if ($ratio > 50) {
                /* update strong category */
                /* when ratio is > 50 he is strong in this particular category */
                $data['questions_answered'] = $qa + $questions_answered;
                $data['correct_answers'] = $ca + $correct_answers;
                if ($ratio > $r1 || $sc == 0) {
                    $data['strong_category'] = $category_id;
                    $data['ratio1'] = $ratio;
                }
            } else {
                /* update weak category */
                /* when ratio is < 50 he is weak in this particular category */
                $data['questions_answered'] = $qa + $questions_answered;
                $data['correct_answers'] = $ca + $correct_answers;
                if ($ratio < $r2 || $wc == 0) {
                    $data['weak_category'] = $category_id;
                    $data['ratio2'] = $ratio;
                }
            }
            $data['best_position'] = $bp;
            $this->db->where('user_id', $user_id)->update('tbl_users_statistics', $data);
        } else {
            if ($ratio > 50) {
                $frm_data = array(
                    'user_id' => $user_id,
                    'questions_answered' => $questions_answered,
                    'correct_answers' => $correct_answers,
                    'strong_category' => $category_id,
                    'ratio1' => $ratio,
                    'weak_category' => 0,
                    'ratio2' => 0,
                    'best_position' => 0,
                    'date_created' => $this->toDateTime,
                );
            } else {
                $frm_data = array(
                    'user_id' => $user_id,
                    'questions_answered' => $questions_answered,
                    'correct_answers' => $correct_answers,
                    'strong_category' => 0,
                    'ratio1' => 0,
                    'weak_category' => $category_id,
                    'ratio2' => $ratio,
                    'best_position' => 0,
                    'date_created' => $this->toDateTime,
                );
            }
            $this->db->insert('tbl_users_statistics', $frm_data);
        }
    }

    function set_users_battle_statistics($user_id1, $user_id2, $is_drawn, $winner_id)
    {
        $frm_data = array(
            'user_id1' => $user_id1,
            'user_id2' => $user_id2,
            'is_drawn' => $is_drawn,
            'winner_id' => $winner_id,
            'date_created' => $this->toDateTime,
        );
        $this->db->insert('tbl_battle_statistics', $frm_data);

        if ($is_drawn == 0 || $is_drawn == '0') {
            $this->set_badges($winner_id, $this->COMBAT_WINNER);

            $type = $this->QUIZ_WARRIOR;
            if ($user_id1 == $winner_id) {
                $res = $this->db->where('user_id', $user_id1)->get('tbl_users_badges')->row_array();
                if (!empty($res)) {
                    $counter_name = $type . '_counter';
                    if ($res[$type] == 0 || $res[$type] == '0') {
                        $res1 = $this->db->where('type', $type)->get('tbl_badges')->row_array();
                        if (!empty($res1)) {
                            $counter = $res1['badge_counter'];
                            $user_conter = $res[$counter_name];
                            $user_conter = $user_conter + 1;
                            if ($user_conter < $counter) {
                                $data = [$counter_name => $user_conter];
                                $this->db->where('user_id', $user_id1)->update('tbl_users_badges', $data);

                                $data1 = [$counter_name => 0];
                                $this->db->where('user_id', $user_id2)->update('tbl_users_badges', $data1);
                            } else if ($counter == $user_conter) {
                                $this->set_badges($user_id1, $type, $counter = 0);
                            }
                        }
                    }
                }
            } else if ($user_id2 == $winner_id) {
                $res = $this->db->where('user_id', $user_id2)->get('tbl_users_badges')->row_array();
                if (!empty($res)) {
                    $counter_name = $type . '_counter';
                    if ($res[$type] == 0 || $res[$type] == '0') {
                        $res1 = $this->db->where('type', $type)->get('tbl_badges')->row_array();
                        if (!empty($res1)) {
                            $counter = $res1['badge_counter'];
                            $user_conter = $res[$counter_name];
                            $user_conter = $user_conter + 1;
                            if ($user_conter < $counter) {
                                $data = [$counter_name => $user_conter];
                                $this->db->where('user_id', $user_id2)->update('tbl_users_badges', $data);

                                $data1 = [$counter_name => 0];
                                $this->db->where('user_id', $user_id1)->update('tbl_users_badges', $data1);
                            } else if ($counter == $user_conter) {
                                $this->set_badges($user_id2, $type, $counter = 0);
                            }
                        }
                    }
                }
            }
        }
    }

    function set_user_session($user_id, $questions, $table)
    {
        $checkData = $this->db->where('user_id', $user_id)->get($table)->row_array();
        if ($checkData) {
            $this->db->where('user_id', $user_id)->update($table, ['questions' => json_encode($questions)]);
        } else {
            $frm_data = array(
                'user_id' => $user_id,
                'questions' => json_encode($questions),
                'date' => $this->toDate,
            );
            $this->db->insert($table, $frm_data);
        }
    }

    //1
    function QuizZone($user_id, $table, $category, $subcategory, $playQuestions,  $lifelineData = [])
    {
        $checkData = $this->db->where('user_id', $user_id)->get($table)->row_array();
        if ($checkData) {
            $minimumQuestionsForBadge = $this->minimumQuestionsForBadge;
            $setQuestions = json_decode($checkData['questions'], true);
            $currentLevel = $setQuestions[0]['level'];
            $getMaxLevelData = $this->db->select_max('level')->where('category', $category)->where('subcategory', $subcategory)->get('tbl_question')->row_array();
            $totalLevel = $getMaxLevelData['level'];

            if ($currentLevel <= $totalLevel) {
                $setQuestionMap = [];
                $setQuestionMap = array_column($setQuestions, 'answer', 'id');
                $total_questions = count($setQuestions);
                $correctAnswer = 0;

                $play_questions = json_decode($playQuestions, true);
                foreach ($play_questions as $userAnswer) {
                    $id = $userAnswer['id'];
                    if (isset($setQuestionMap[$id]) && $setQuestionMap[$id] === $userAnswer['answer']) {
                        $correctAnswer++;
                    }
                }
                $questions_answered = count($play_questions);
                $quiz_winning_percentage = is_settings('quiz_winning_percentage');
                $winningPer = ($correctAnswer * 100) / $total_questions;

                if ($lifelineData) {
                    $quiz_zone_lifeline_deduct_coin = is_settings('quiz_zone_lifeline_deduct_coin');
                    $quiz_zone_lifeline_deduct_coin = $quiz_zone_lifeline_deduct_coin ? ('-' . $quiz_zone_lifeline_deduct_coin) : 0;
                    foreach ($lifelineData as $key => $lifeline) {
                        $this->set_coins($user_id, $quiz_zone_lifeline_deduct_coin);
                        $title = $lifeline;
                        $status = 1; //deduct
                        $this->set_tracker_data($user_id, $quiz_zone_lifeline_deduct_coin, $title, $status);
                    }
                }
                $earnCoin = $userScore = 0;

                if ($winningPer >= $quiz_winning_percentage) {
                    $ratio = $winningPer;
                    $wrongAnswer = $total_questions - $correctAnswer;
                    $minimum_coins_winning_percentage = is_settings('minimum_coins_winning_percentage');
                    $maximum_winning_coins = is_settings('maximum_winning_coins');
                    $quiz_zone_correct_answer_credit_score = is_settings('quiz_zone_correct_answer_credit_score');
                    $quiz_zone_wrong_answer_deduct_score = is_settings('quiz_zone_wrong_answer_deduct_score');
                    if ($winningPer >= $minimum_coins_winning_percentage) {
                        $earnCoin = $maximum_winning_coins;
                    } else {
                        $earnCoin = ($maximum_winning_coins - (($minimum_coins_winning_percentage - $winningPer) / 10));
                    }
                    $userScore = ($correctAnswer * $quiz_zone_correct_answer_credit_score) - ($wrongAnswer * $quiz_zone_wrong_answer_deduct_score);
                    $getLevelData = $this->db->select('level')->where('user_id', $user_id)->where('category', $category)->where('subcategory', $subcategory)->get('tbl_level')->row_array();

                    $nextUnlockLevel = $getLevelData['level'] ?? 0;

                    if ($userScore) {
                        $this->set_monthly_leaderboard($user_id, $userScore);
                    }
                    $this->set_users_statistics($user_id, $category, $questions_answered, $correctAnswer,  $ratio);

                    $updateLevel = $currentLevel + 1;
                    $earnCoin = floor($earnCoin);
                    if ($earnCoin && ($updateLevel > $nextUnlockLevel && $updateLevel != $nextUnlockLevel)) {
                        $this->set_quiz_level_data($user_id, 1, $updateLevel, $category, $subcategory);
                        $this->set_coins($user_id, $earnCoin);
                        $title = 'wonQuizZone';
                        $status = 0; //add
                        $this->set_tracker_data($user_id, $earnCoin, $title, $status);
                    } else {
                        $earnCoin = 0;
                    }
                }
                $this->set_badges($user_id, $this->DASHING_DEBUT);
                if (!$lifelineData) {
                    if ($minimumQuestionsForBadge >= $total_questions && $correctAnswer == $total_questions) {
                        $this->set_badges($user_id, $this->BRAINIAC, 1);
                    }
                }
                $this->db->where('id', $checkData['id'])->delete($table);
            }
            $resultData = [
                'user_id' => $user_id,
                'total_questions' => $total_questions ?? 0,
                'correctAnswer' => $correctAnswer ?? 0,
                'winningPer' => $winningPer ?? 0,
                'earnCoin' => (float)$earnCoin ?? 0,
                'userScore' => (float)$userScore ?? 0,
                'totalLevel' => (float)$totalLevel ?? 0,
                'currentLevel' => (float)$currentLevel ?? 0,
            ];
            return $resultData;
        } else {
            return false;
        }
    }

    //1.1
    function DailyQuiz($user_id, $table, $playQuestions)
    {
        $checkData = $this->db->where('user_id', $user_id)->get($table)->row_array();
        if ($checkData) {
            $setQuestions = json_decode($checkData['questions'], true);

            $setQuestionMap = [];
            $setQuestionMap = array_column($setQuestions, 'answer', 'id');
            $total_questions = count($setQuestions);
            $correctAnswer = 0;

            $play_questions = json_decode($playQuestions, true);
            foreach ($play_questions as $userAnswer) {
                $id = $userAnswer['id'];
                if (isset($setQuestionMap[$id]) && $setQuestionMap[$id] === $userAnswer['answer']) {
                    $correctAnswer++;
                }
            }
            $ratio = ($correctAnswer * 100) / $total_questions;

            $this->set_badge_counter($user_id, $this->THIRSTY, 0);

            $this->db->where('id', $checkData['id'])->delete($table);
            $resultData = [
                'user_id' => $user_id,
                'total_questions' => $total_questions,
                'correctAnswer' => $correctAnswer,
                'winningPer' => $ratio,
            ];
            return $resultData;
        } else {
            return false;
        }
    }

    // 1.2
    function trueFalse($user_id, $table, $playQuestions)
    {
        $checkData = $this->db->where('user_id', $user_id)->get($table)->row_array();
        if ($checkData) {
            $setQuestions = json_decode($checkData['questions'], true);

            $setQuestionMap = [];
            $setQuestionMap = array_column($setQuestions, 'answer', 'id');
            $total_questions = count($setQuestions);
            $correctAnswer = 0;

            $play_questions = json_decode($playQuestions, true);
            foreach ($play_questions as $userAnswer) {
                $id = $userAnswer['id'];
                if (isset($setQuestionMap[$id]) && $setQuestionMap[$id] === $userAnswer['answer']) {
                    $correctAnswer++;
                }
            }
            $ratio = ($correctAnswer * 100) / $total_questions;

            $this->db->where('id', $checkData['id'])->delete($table);
            $resultData = [
                'user_id' => $user_id,
                'total_questions' => $total_questions,
                'correctAnswer' => $correctAnswer,
                'winningPer' => $ratio,
            ];
            return $resultData;
        } else {
            return false;
        }
    }

    // 1.3
    function randomBattle($user_id, $match_id, $is_bot, $playQuestions)
    {
        $checkData = $this->db->where('match_id', $match_id)
            ->where('0 IN (set_user1, set_user2)', null, false)
            ->where("NOT FIND_IN_SET($user_id, CONCAT(set_user1, ',', set_user2))", null, false)
            ->get('tbl_battle_questions')->row_array();
        if ($checkData) {
            $userData = json_decode($playQuestions, true);
            $user1_id = $userData['user1_id'];
            $user2_id = $userData['user2_id'];
            $user1_data = $userData['user1_data'];
            $user2_data = $userData['user2_data'];

            $entry_coin = $checkData['entry_coin'];

            $earnCoin = 0;
            $user1CorrectAnswer = 0;
            $user1Points = 0;
            $user2CorrectAnswer = 0;
            $user2Points = 0;
            $winner_user_id = 0;
            $is_drawn = 0;
            $leftUser = 0;
            $score = 0;
            $user1_earnCoin = $user2_earnCoin = 0;

            $setQuestions = json_decode($checkData['questions'], true);

            $correct_answer_credit_score = is_settings('battle_mode_random_correct_answer_credit_score');
            $quickest_correct_answer_extra_score = is_settings('battle_mode_random_quickest_correct_answer_extra_score');
            $second_quickest_correct_answer_extra_score = is_settings('battle_mode_random_second_quickest_correct_answer_extra_score');

            $setQuestionMap = [];
            $setQuestionMap = array_column($setQuestions, 'answer', 'id');
            $total_questions = count($setQuestions);

            [$user1Points, $user1CorrectAnswer, $user1Quickest, $user1QuickestBonus, $user1SecondQuickestBonus] = $this->calculateBattleUserScore($user1_data, $setQuestionMap, $correct_answer_credit_score, $quickest_correct_answer_extra_score, $second_quickest_correct_answer_extra_score);
            [$user2Points, $user2CorrectAnswer, $user2Quickest, $user2QuickestBonus, $user2SecondQuickestBonus] = $this->calculateBattleUserScore($user2_data, $setQuestionMap, $correct_answer_credit_score, $quickest_correct_answer_extra_score, $second_quickest_correct_answer_extra_score);

            if ($user1Points > $user2Points) {
                $winner_user_id = $user1_id;
                $score = $user1Points;
            } else if ($user1Points < $user2Points) {
                $winner_user_id = $user2_id;
                $score = $user2Points;
            } else if (($user1Points == $user2Points) && ($user1_id && $user2_id)) {
                $is_drawn = 1;
                $score = ($user_id == $user1_id) ? $user1Points : (($user_id == $user2_id) ? $user2Points : 0);
            } else if ($user1_id == 0 || $user2_id == 0) {
                $leftUser = 1;
                if ($user1_id) {
                    $winner_user_id = $user1_id;
                    $score = $user1Points;
                } else if ($user2_id) {
                    $winner_user_id = $user2_id;
                    $score = $user2Points;
                }
            }

            if ($is_bot == 0 && $score) {
                $this->set_monthly_leaderboard($user_id, $score);
            }

            if ($is_drawn) {
                $user1_earnCoin = $user2_earnCoin = $entry_coin;
                if ($is_bot == 0) {
                    $this->set_coins($user_id, $entry_coin);
                    $this->set_tracker_data($user_id, $entry_coin, 'wonBattle', 0); //0: add
                    $this->set_users_battle_statistics($user1_id, $user2_id, $is_drawn, $winner_user_id);
                }
            } else if ($winner_user_id) {
                $earnCoinVal = $entry_coin * 2;
                $earnCoin = floor($earnCoinVal);
                if ($winner_user_id == $user1_id) {
                    $user1_earnCoin = $earnCoin;
                } else if ($winner_user_id == $user2_id) {
                    $user2_earnCoin = $earnCoin;
                }
                if ($is_bot == 0 && $user_id == $winner_user_id) {
                    $this->set_coins($user_id, $earnCoin);
                    $this->set_tracker_data($user_id, $earnCoin, 'wonBattle', 0); //0: add
                    $this->set_users_battle_statistics($user1_id, $user2_id, $is_drawn, $winner_user_id);
                }
            }

            if ($is_bot == 0) {
                if ($user1Quickest && $user_id == $user1_id) {
                    $this->set_badges($user_id, $this->ULTIMATE_PLAYER, 1);
                } else if ($user2Quickest && $user_id == $user2_id) {
                    $this->set_badges($user_id, $this->ULTIMATE_PLAYER, 1);
                }
            }

            if ($user_id == $user1_id) {
                $this->db->where('id', $checkData['id'])->update('tbl_battle_questions', ['set_user1' => $user_id]);
            } else if ($user_id == $user2_id) {
                $this->db->where('id', $checkData['id'])->update('tbl_battle_questions', ['set_user2' => $user_id]);
            }

            if ($user1_id == 0 && $user2_id != 0) {
                $this->db->where('id', $checkData['id'])->where('set_user1', 0)->where('set_user2!=', 0)->delete('tbl_battle_questions');
            } else if ($user2_id == 0 && $user1_id != 0) {
                $this->db->where('id', $checkData['id'])->where('set_user1!=', 0)->where('set_user2', 0)->delete('tbl_battle_questions');
            } else if ($user1_id == 0 && $user2_id == 0) {
                $this->db->where('id', $checkData['id'])->delete('tbl_battle_questions');
            } else {
                $this->db->where('id', $checkData['id'])->where('set_user1!=', 0)->where('set_user2!=', 0)->delete('tbl_battle_questions');
            }


            $user1Data = [
                'correctAnswer' => $user1CorrectAnswer ?? 0,
                'userPoints' => $user1Points ?? 0,
                'earnCoin' => (float)$user1_earnCoin ?? 0,
                'is_quickest' => $user1Quickest  ?? false,
                'quickest_bonus' => $user1QuickestBonus  ?? 0,
                'second_quickest_bonus' => $user1SecondQuickestBonus  ?? 0,
            ];

            $user2Data = [
                'correctAnswer' => $user2CorrectAnswer ?? 0,
                'userPoints' => $user2Points ?? 0,
                'earnCoin' => (float)$user2_earnCoin ?? 0,
                'is_quickest' => $user2Quickest ?? false,
                'quickest_bonus' => $user2QuickestBonus  ?? 0,
                'second_quickest_bonus' => $user2SecondQuickestBonus  ?? 0,
            ];

            $resultData = [
                'user_id' => $user_id,
                'entry_coin' => $entry_coin ?? 0,
                'total_questions' => $total_questions ?? 0,
                'user1_id' => $user1_id ?? 0,
                'user2_id' => $user2_id ?? 0,
                'winner_user_id' => $winner_user_id ?? 0,
                'winner_coin' => (float)$earnCoin ?? 0,
                'is_drawn' => $is_drawn ?? 0,
                'leftUser' => $leftUser ?? 0,
                'user1_data' => $user1Data ?? [],
                'user2_data' => $user2Data ?? [],
            ];
            return $resultData;
        } else {
            return false;
        }
    }

    // 1.4
    function oneVsOneBattle($user_id, $match_id, $playQuestions)
    {
        $checkData = $this->db->where('match_id', $match_id)
            ->where('0 IN (set_user1, set_user2)', null, false)
            ->where("NOT FIND_IN_SET($user_id, CONCAT(set_user1, ',', set_user2))", null, false)
            ->get('tbl_battle_questions')->row_array();
        if ($checkData) {
            $userData = json_decode($playQuestions, true);
            $user1_id = $userData['user1_id'];
            $user2_id = $userData['user2_id'];
            $user1_data = $userData['user1_data'];
            $user2_data = $userData['user2_data'];

            $entry_coin = $checkData['entry_coin'];

            $earnCoin = 0;
            $user1CorrectAnswer = 0;
            $user1Points = 0;
            $user2CorrectAnswer = 0;
            $user2Points = 0;
            $winner_user_id = 0;
            $is_drawn = 0;
            $leftUser = 0;
            $score = 0;
            $user1_earnCoin = $user2_earnCoin = 0;

            $setQuestions = json_decode($checkData['questions'], true);

            $correct_answer_credit_score = is_settings('battle_mode_one_correct_answer_credit_score');
            $quickest_correct_answer_extra_score = is_settings('battle_mode_one_quickest_correct_answer_extra_score');
            $second_quickest_correct_answer_extra_score = is_settings('battle_mode_one_second_quickest_correct_answer_extra_score');

            $setQuestionMap = [];
            $setQuestionMap = array_column($setQuestions, 'answer', 'id');
            $total_questions = count($setQuestions);

            [$user1Points, $user1CorrectAnswer, $user1Quickest, $user1QuickestBonus, $user1SecondQuickestBonus] = $this->calculateBattleUserScore($user1_data, $setQuestionMap, $correct_answer_credit_score, $quickest_correct_answer_extra_score, $second_quickest_correct_answer_extra_score);
            [$user2Points, $user2CorrectAnswer, $user2Quickest, $user2QuickestBonus, $user2SecondQuickestBonus] = $this->calculateBattleUserScore($user2_data, $setQuestionMap, $correct_answer_credit_score, $quickest_correct_answer_extra_score, $second_quickest_correct_answer_extra_score);

            if ($user1Points > $user2Points) {
                $winner_user_id = $user1_id;
                $score = $user1Points;
            } else if ($user1Points < $user2Points) {
                $winner_user_id = $user2_id;
                $score = $user2Points;
            } else if (($user1Points == $user2Points) && ($user1_id && $user2_id)) {
                $is_drawn = 1;
                $score = ($user_id == $user1_id) ? $user1Points : (($user_id == $user2_id) ? $user2Points : 0);
            } else if ($user1_id == 0 || $user2_id == 0) {
                $leftUser = 1;
                if ($user1_id) {
                    $winner_user_id = $user1_id;
                    $score = $user1Points;
                } else if ($user2_id) {
                    $winner_user_id = $user2_id;
                    $score = $user2Points;
                }
            }



            if ($score) {
                $this->set_monthly_leaderboard($user_id, $score);
            }

            if ($is_drawn) {
                $user1_earnCoin = $user2_earnCoin = $entry_coin;
                $this->set_coins($user_id, $entry_coin);
                $this->set_tracker_data($user_id, $entry_coin, 'wonBattle', 0); //0: add
                $this->set_users_battle_statistics($user1_id, $user2_id, $is_drawn, $winner_user_id);
            } else if ($winner_user_id) {
                $earnCoinVal = $entry_coin * 2;
                $earnCoin = floor($earnCoinVal);
                if ($winner_user_id == $user1_id) {
                    $user1_earnCoin = $earnCoin;
                } else if ($winner_user_id == $user2_id) {
                    $user2_earnCoin = $earnCoin;
                }
                if ($user_id == $winner_user_id) {
                    $this->set_coins($user_id, $earnCoin);
                    $this->set_tracker_data($user_id, $earnCoin, 'wonBattle', 0); //0: add
                    $this->set_users_battle_statistics($user1_id, $user2_id, $is_drawn, $winner_user_id);
                }
            }

            if ($user1Quickest && $user_id == $user1_id) {
                $this->set_badges($user_id, $this->ULTIMATE_PLAYER, 1);
            } else if ($user2Quickest && $user_id == $user2_id) {
                $this->set_badges($user_id, $this->ULTIMATE_PLAYER, 1);
            }

            if ($user_id == $user1_id) {
                $this->db->where('id', $checkData['id'])->update('tbl_battle_questions', ['set_user1' => $user_id]);
            } else if ($user_id == $user2_id) {
                $this->db->where('id', $checkData['id'])->update('tbl_battle_questions', ['set_user2' => $user_id]);
            }


            if ($user1_id == 0 && $user2_id != 0) {
                $this->db->where('id', $checkData['id'])->where('set_user1', 0)->where('set_user2!=', 0)->delete('tbl_battle_questions');
            } else if ($user2_id == 0 && $user1_id != 0) {
                $this->db->where('id', $checkData['id'])->where('set_user1!=', 0)->where('set_user2', 0)->delete('tbl_battle_questions');
            } else if ($user1_id == 0 && $user2_id == 0) {
                $this->db->where('id', $checkData['id'])->delete('tbl_battle_questions');
            } else {
                $this->db->where('id', $checkData['id'])->where('set_user1!=', 0)->where('set_user2!=', 0)->delete('tbl_battle_questions');
            }

            $user1Data = [
                'correctAnswer' => $user1CorrectAnswer ?? 0,
                'userPoints' => $user1Points ?? 0,
                'earnCoin' => (float)$user1_earnCoin ?? 0,
                'is_quickest' => $user1Quickest  ?? false,
                'quickest_bonus' => $user1QuickestBonus  ?? 0,
                'second_quickest_bonus' => $user1SecondQuickestBonus  ?? 0,
            ];

            $user2Data = [
                'correctAnswer' => $user2CorrectAnswer ?? 0,
                'userPoints' => $user2Points ?? 0,
                'earnCoin' => (float)$user2_earnCoin ?? 0,
                'is_quickest' => $user2Quickest ?? false,
                'quickest_bonus' => $user2QuickestBonus  ?? 0,
                'second_quickest_bonus' => $user2SecondQuickestBonus  ?? 0,
            ];

            $resultData = [
                'user_id' => $user_id,
                'entry_coin' => $entry_coin ?? 0,
                'total_questions' => $total_questions ?? 0,
                'user1_id' => $user1_id ?? 0,
                'user2_id' => $user2_id ?? 0,
                'is_drawn' => $is_drawn ?? 0,
                'leftUser' => $leftUser ?? 0,
                'winner_user_id' => $winner_user_id ?? 0,
                'winner_coin' => (float)$earnCoin ?? 0,
                'user1_data' => $user1Data ?? [],
                'user2_data' => $user2Data ?? [],
            ];
            return $resultData;
        } else {
            return false;
        }
    }

    // 1.5
    function groupBattle($user_id, $room_id, $playQuestions, $joined_users_count)
    {

        $batchSize = 500;

        do {
            $rows = $this->db->select('id')
                ->from('tbl_rooms')
                ->where('date_created <', $this->twoDayOldDateTime)
                ->limit($batchSize)
                ->get()
                ->result_array();

            $idsToDelete = array_column($rows, 'id');

            if (!empty($idsToDelete)) {
                $this->db->where_in('id', $idsToDelete);
                $this->db->delete('tbl_rooms');
            }

            $deletedRows = count($idsToDelete);
        } while ($deletedRows === $batchSize);

        $checkData = $this->db->where('room_id', $room_id)
            ->where('0 IN (set_user1, set_user2, set_user3, set_user4)', null, false)
            ->where("NOT FIND_IN_SET($user_id, CONCAT(set_user1, ',', set_user2, ',', set_user3, ',', set_user4))", null, false)
            ->get('tbl_rooms')->row_array();
        if ($checkData) {
            $userData = json_decode($playQuestions, true);
            $user1_id = $userData['user1_id'];
            $user2_id = $userData['user2_id'];
            $user3_id = $userData['user3_id'];
            $user4_id = $userData['user4_id'];
            $user1_data = $userData['user1_data'];
            $user2_data = $userData['user2_data'];
            $user3_data = $userData['user3_data'];
            $user4_data = $userData['user4_data'];

            $user1CorrectAnswer = $user2CorrectAnswer = $user3CorrectAnswer = $user4CorrectAnswer = 0;

            $setQuestions = json_decode($checkData['questions'], true);
            $setQuestionMap = [];
            $setQuestionMap = array_column($setQuestions, 'answer', 'id');
            $total_questions = count($setQuestions);

            [$user1CorrectAnswer] = $this->calculategroupBattleUserScore($user1_data, $setQuestionMap);
            [$user2CorrectAnswer] = $this->calculategroupBattleUserScore($user2_data, $setQuestionMap);
            [$user3CorrectAnswer] = $this->calculategroupBattleUserScore($user3_data, $setQuestionMap);
            [$user4CorrectAnswer] = $this->calculategroupBattleUserScore($user4_data, $setQuestionMap);

            $data = [
                $user1_id => $user1CorrectAnswer,
                $user2_id => $user2CorrectAnswer,
                $user3_id => $user3CorrectAnswer,
                $user4_id => $user4CorrectAnswer
            ];

            arsort($data);

            $ranks = [];
            $prevValue = null;
            $rank = 0;

            foreach ($data as $userId => $value) {
                if ($value !== $prevValue) {
                    $rank++;
                }
                if ($userId != 0) {
                    $ranks[$userId] = ['rank' => $rank, 'user_id' => $userId, 'correct_answer' => $value];
                }
                $prevValue = $value;
            }

            $total_user_count = count($ranks) ?? 0;
            $firstRankWinners = [];
            foreach ($ranks as $userId => $item) {
                if ($item['rank'] === 1 && $userId != 0) {
                    $firstRankWinners[] = $userId;
                }
            }

            $totalWinner = count($firstRankWinners);
            $entry_coin = $checkData['entry_coin'];
            $earnCoin =  ($totalWinner > 0) ? floor($entry_coin * ($joined_users_count / $totalWinner)) : 0;
            if ($earnCoin) {
                foreach ($firstRankWinners as $winnerUser) {
                    if ($winnerUser == $user_id) {
                        $this->set_coins($user_id, $earnCoin);
                        $this->set_tracker_data($user_id, $earnCoin, 'wonGroupBattle', 0);
                        $this->set_badges($user_id, $this->CLASH_WINNER, 0);
                        break;
                    }
                }
            }


            if ($user_id == $user1_id) {
                $this->db->where('room_id', $room_id)->update('tbl_rooms', ['set_user1' => $user_id]);
            } else if ($user_id == $user2_id) {
                $this->db->where('room_id', $room_id)->update('tbl_rooms', ['set_user2' => $user_id]);
            } else if ($user_id == $user3_id) {
                $this->db->where('room_id', $room_id)->update('tbl_rooms', ['set_user3' => $user_id]);
            } else if ($user_id == $user4_id) {
                $this->db->where('room_id', $room_id)->update('tbl_rooms', ['set_user4' => $user_id]);
            }

            $sql = "DELETE FROM tbl_rooms WHERE room_id = ? AND ((set_user1 != 0) + (set_user2 != 0) + (set_user3 != 0) + (set_user4 != 0)) >= ?";
            $this->db->query($sql, [$room_id, $total_user_count]);

            $resultData = [
                'user_id' => $user_id,
                'total_questions' => $total_questions ?? 0,
                'user1_id' => $user1_id ?? 0,
                'user2_id' => $user2_id ?? 0,
                'user3_id' => $user3_id ?? 0,
                'user4_id' => $user4_id ?? 0,
                'total_user_count' => $total_user_count ?? 0,
                'entry_coin' => $entry_coin ?? 0,
                'totalWinner' => $totalWinner ?? 0,
                'joined_users_count' => $joined_users_count ?? 0,
                'winner_score' => $earnCoin ?? 0,
                'winner' => $firstRankWinners ?? [],
                'user_rank' => $ranks ?? 0,
            ];
            return $resultData;
        } else {
            return false;
        }
    }

    function calculateBattleUserScore($userData, $setQuestionMap, $correct_answer_credit_score, $quickest_bonus, $second_quickest_bonus)
    {
        $points = 0;
        $correctAnswers = 0;
        $allQuickest = true;
        $quikest = 0;
        $second_quikest = 0;

        foreach ($userData as $answer) {
            $id = $answer['id'];
            $time = $answer['second'];

            if (isset($setQuestionMap[$id]) && $setQuestionMap[$id] === $answer['answer']) {
                $correctAnswers++;
                if ($time <= 2) {
                    $quikest += $quickest_bonus;
                    $points += $correct_answer_credit_score + $quickest_bonus;
                } elseif ($time <= 4) {
                    $second_quikest += $second_quickest_bonus;
                    $points += $correct_answer_credit_score + $second_quickest_bonus;
                } else {
                    $points += $correct_answer_credit_score;
                    $allQuickest = false;
                    $quikest = 0;
                    $second_quikest = 0;
                }
            }
        }
        if ($correctAnswers === 0 || (count($userData) != $correctAnswers)) {
            $allQuickest = false;
        }
        return [$points, $correctAnswers, $allQuickest, $quikest, $second_quikest];
    }

    function calculategroupBattleUserScore($userData, $setQuestionMap)
    {
        $correctAnswers = 0;

        if ($userData) {
            foreach ($userData as $answer) {
                $id = $answer['id'];

                if (isset($setQuestionMap[$id]) && $setQuestionMap[$id] === $answer['answer']) {
                    $correctAnswers++;
                }
            }
        }
        return [$correctAnswers];
    }

    // 2
    function funNLearn($user_id, $table, $category, $subcategory, $playQuestions, $totalPlayTime)
    {
        $checkData = $this->db->where('user_id', $user_id)->get($table)->row_array();
        if ($checkData) {
            $setQuestions = json_decode($checkData['questions'], true);
            $type_id = 0;
            $type_id = $setQuestions[0]['fun_n_learn_id'];

            $earnCoin = $userScore = 0;

            $setQuestionMap = [];
            $setQuestionMap = array_column($setQuestions, 'answer', 'id');
            $total_questions = count($setQuestions);
            $correctAnswer = 0;

            $play_questions = json_decode($playQuestions, true);
            foreach ($play_questions as $userAnswer) {
                $id = $userAnswer['id'];
                if (isset($setQuestionMap[$id]) && $setQuestionMap[$id] === $userAnswer['answer']) {
                    $correctAnswer++;
                }
            }
            $quiz_winning_percentage = is_settings('quiz_winning_percentage');
            $winningPer = ($correctAnswer * 100) / $total_questions;

            if ($winningPer >= $quiz_winning_percentage) {
                $ratio = $winningPer;

                $questions_answered = count($play_questions);
                $this->set_users_statistics($user_id, $category, $questions_answered, $correctAnswer,  $ratio);
                $type = 2;
                $res = $this->db->where('user_id', $user_id)->where('type', $type)->where('type_id', $type_id)->where('category', $category)->where('subcategory', $subcategory)->get('tbl_quiz_categories')->result_array();
                if (empty($res)) {
                    $wrongAnswer = $total_questions - $correctAnswer;
                    $minimum_coins_winning_percentage = is_settings('minimum_coins_winning_percentage');
                    $maximum_winning_coins = is_settings('maximum_winning_coins');
                    $fun_n_learn_quiz_correct_answer_credit_score = is_settings('fun_n_learn_quiz_correct_answer_credit_score');
                    $fun_n_learn_quiz_wrong_answer_deduct_score = is_settings('fun_n_learn_quiz_wrong_answer_deduct_score');
                    if ($winningPer >= $minimum_coins_winning_percentage) {
                        $earnCoin = $maximum_winning_coins;
                    } else {
                        $earnCoin = ($maximum_winning_coins - (($minimum_coins_winning_percentage - $winningPer) / 10));
                    }
                    $userScore = ($correctAnswer * $fun_n_learn_quiz_correct_answer_credit_score) - ($wrongAnswer * $fun_n_learn_quiz_wrong_answer_deduct_score);
                    $frm_data = array(
                        'user_id' => $user_id,
                        'type' => $type,
                        'category' => $category,
                        'subcategory' => $subcategory,
                        'type_id' => $type_id,
                    );
                    $this->db->insert('tbl_quiz_categories', $frm_data);
                    if ($userScore) {
                        $this->set_monthly_leaderboard($user_id, $userScore);
                    }
                    $earnCoin = floor($earnCoin);
                    if ($earnCoin) {
                        $this->set_coins($user_id, $earnCoin);
                        $title = 'wonFunNLearn';
                        $status = 0; //add
                        $this->set_tracker_data($user_id, $earnCoin, $title, $status);
                    } else {
                        $earnCoin = 0;
                    }

                    $badgeUnlock = $this->db->select('id,flashback')->where('user_id', $user_id)->get('tbl_users_badges')->row_array();
                    if ($badgeUnlock && ($badgeUnlock['flashback'] == 0)) {
                        $timerPerQuestion = is_settings('fun_and_learn_time_in_seconds') ?? 0;
                        $idealTimeInSeconds = ($total_questions * $timerPerQuestion);
                        if (($total_questions >= 5) && ($total_questions == $correctAnswer) && ($totalPlayTime <= $idealTimeInSeconds)) {
                            $this->set_badges($user_id, $this->FLASHBACK, 1);
                        }
                    }
                }
            }

            $this->db->where('id', $checkData['id'])->delete($table);

            $resultData = [
                'user_id' => $user_id,
                'total_questions' => $total_questions ?? 0,
                'correctAnswer' => $correctAnswer ?? 0,
                'winningPer' => $winningPer ?? 0,
                'earnCoin' => (float)$earnCoin ?? 0,
                'userScore' => (float)$userScore ?? 0
            ];
            return $resultData;
        } else {
            return false;
        }
    }

    // 3
    function guessTheWord($user_id, $table, $category, $subcategory, $playQuestions, $totalPlayTime, $hintUsed)
    {
        $checkData = $this->db->where('user_id', $user_id)->get($table)->row_array();
        if ($checkData) {
            $setQuestions = json_decode($checkData['questions'], true);

            $setQuestionMap = [];
            $setQuestionMap = array_column($setQuestions, 'answer', 'id');
            $total_questions = count($setQuestions);
            $correctAnswer = 0;

            $play_questions = json_decode($playQuestions, true);
            foreach ($play_questions as $userAnswer) {
                $id = $userAnswer['id'];
                if (isset($setQuestionMap[$id]) && strtolower($setQuestionMap[$id]) === strtolower($userAnswer['answer'])) {
                    $correctAnswer++;
                }
            }
            $questions_answered = count($play_questions);
            $quiz_winning_percentage = is_settings('quiz_winning_percentage');
            $winningPer = ($correctAnswer * 100) / $total_questions;

            if ($hintUsed) {
                $guess_the_word_hint_deduct_coin = is_settings('guess_the_word_hint_deduct_coin');
                $hint_deduct_coin = $guess_the_word_hint_deduct_coin ? ($hintUsed * $guess_the_word_hint_deduct_coin) : 0;
                $deduct_coin = $hint_deduct_coin ? ('-' . $hint_deduct_coin) : 0;
                $this->set_coins($user_id, $deduct_coin);
                $title = 'usedHintLifeline';
                $status = 1; //deduct
                $this->set_tracker_data($user_id, $deduct_coin, $title, $status);
            }
            $earnCoin = $userScore = 0;

            if ($winningPer >= $quiz_winning_percentage) {
                $ratio = $winningPer;
                $this->set_users_statistics($user_id, $category, $questions_answered, $correctAnswer,  $ratio);
                $type = 3;
                $type_id = 0;
                $res = $this->db->where('user_id', $user_id)->where('type', $type)->where('type_id', $type_id)->where('category', $category)->where('subcategory', $subcategory)->get('tbl_quiz_categories')->result_array();
                if (empty($res)) {
                    $wrongAnswer = $total_questions - $correctAnswer;
                    $minimum_coins_winning_percentage = is_settings('minimum_coins_winning_percentage');
                    $maximum_winning_coins = is_settings('guess_the_word_max_winning_coin');
                    $guess_the_word_correct_answer_credit_score = is_settings('guess_the_word_correct_answer_credit_score');
                    $guess_the_word_wrong_answer_deduct_score = is_settings('guess_the_word_wrong_answer_deduct_score');
                    if ($winningPer >= $minimum_coins_winning_percentage) {
                        $earnCoin = $maximum_winning_coins;
                    } else {
                        $earnCoin = ($maximum_winning_coins - (($minimum_coins_winning_percentage - $winningPer) / 10));
                    }
                    $userScore = ($correctAnswer * $guess_the_word_correct_answer_credit_score) - ($wrongAnswer * $guess_the_word_wrong_answer_deduct_score);
                    $frm_data = array(
                        'user_id' => $user_id,
                        'type' => $type,
                        'category' => $category,
                        'subcategory' => $subcategory,
                        'type_id' => $type_id,
                    );
                    $this->db->insert('tbl_quiz_categories', $frm_data);

                    if ($userScore) {
                        $this->set_monthly_leaderboard($user_id, $userScore);
                    }
                    $earnCoin = floor($earnCoin);
                    if ($earnCoin) {
                        $this->set_coins($user_id, $earnCoin);
                        $title = 'wonGuessTheWord';
                        $status = 0; //add
                        $this->set_tracker_data($user_id, $earnCoin, $title, $status);
                    } else {
                        $earnCoin = 0;
                    }

                    if (!$hintUsed) {
                        $badgeUnlock = $this->db->select('id,super_sonic')->where('user_id', $user_id)->get('tbl_users_badges')->row_array();
                        if ($badgeUnlock && ($badgeUnlock['super_sonic'] == 0)) {
                            $timerPerQuestion = is_settings('guess_the_word_seconds') ?? 0;
                            $idealTimeInSeconds = ($total_questions * $timerPerQuestion);
                            if (($total_questions >= 5) &&  ($totalPlayTime <= $idealTimeInSeconds)) {
                                $this->set_badges($user_id, $this->SUPER_SONIC, 1);
                            }
                        }
                    }
                }
            }

            $this->db->where('id', $checkData['id'])->delete($table);

            $resultData = [
                'user_id' => $user_id,
                'total_questions' => $total_questions ?? 0,
                'correctAnswer' => $correctAnswer ?? 0,
                'winningPer' => $winningPer ?? 0,
                'earnCoin' => (float)$earnCoin ?? 0,
                'userScore' => (float)$userScore ?? 0,
            ];
            return $resultData;
        } else {
            return false;
        }
    }

    // 4
    function audioQuiz($user_id, $table, $category, $subcategory, $playQuestions)
    {
        $checkData = $this->db->where('user_id', $user_id)->get($table)->row_array();
        if ($checkData) {
            $setQuestions = json_decode($checkData['questions'], true);

            $earnCoin = $userScore = 0;

            $setQuestionMap = [];
            $setQuestionMap = array_column($setQuestions, 'answer', 'id');
            $total_questions = count($setQuestions);
            $correctAnswer = 0;

            $play_questions = json_decode($playQuestions, true);
            foreach ($play_questions as $userAnswer) {
                $id = $userAnswer['id'];
                if (isset($setQuestionMap[$id]) && $setQuestionMap[$id] === $userAnswer['answer']) {
                    $correctAnswer++;
                }
            }
            $quiz_winning_percentage = is_settings('quiz_winning_percentage');
            $winningPer = ($correctAnswer * 100) / $total_questions;

            if ($winningPer >= $quiz_winning_percentage) {
                $ratio = $winningPer;
                $questions_answered = count($play_questions);
                $this->set_users_statistics($user_id, $category, $questions_answered, $correctAnswer,  $ratio);
                $type = 4;
                $type_id = 0;
                $res = $this->db->where('user_id', $user_id)->where('type', $type)->where('type_id', $type_id)->where('category', $category)->where('subcategory', $subcategory)->get('tbl_quiz_categories')->result_array();
                if (empty($res)) {
                    $wrongAnswer = $total_questions - $correctAnswer;
                    $minimum_coins_winning_percentage = is_settings('minimum_coins_winning_percentage');
                    $maximum_winning_coins = is_settings('maximum_winning_coins');
                    $audio_quiz_correct_answer_credit_score = is_settings('audio_quiz_correct_answer_credit_score');
                    $audio_quiz_wrong_answer_deduct_score = is_settings('audio_quiz_wrong_answer_deduct_score');
                    if ($winningPer >= $minimum_coins_winning_percentage) {
                        $earnCoin = $maximum_winning_coins;
                    } else {
                        $earnCoin = ($maximum_winning_coins - (($minimum_coins_winning_percentage - $winningPer) / 10));
                    }

                    $userScore = ($correctAnswer * $audio_quiz_correct_answer_credit_score) - ($wrongAnswer * $audio_quiz_wrong_answer_deduct_score);
                    $frm_data = array(
                        'user_id' => $user_id,
                        'type' => $type,
                        'category' => $category,
                        'subcategory' => $subcategory,
                        'type_id' => $type_id,
                    );
                    $this->db->insert('tbl_quiz_categories', $frm_data);
                    if ($userScore) {
                        $this->set_monthly_leaderboard($user_id, $userScore);
                    }
                    $earnCoin = floor($earnCoin);
                    if ($earnCoin) {
                        $this->set_coins($user_id, $earnCoin);
                        $title = 'wonAudioQuiz';
                        $status = 0; //add
                        $this->set_tracker_data($user_id, $earnCoin, $title, $status);
                    } else {
                        $earnCoin = 0;
                    }
                }
            }

            $this->db->where('id', $checkData['id'])->delete($table);

            $resultData = [
                'user_id' => $user_id,
                'total_questions' => $total_questions ?? 0,
                'correctAnswer' => $correctAnswer ?? 0,
                'winningPer' => $winningPer ?? 0,
                'earnCoin' => (float)$earnCoin ?? 0,
                'userScore' => (float)$userScore ?? 0
            ];
            return $resultData;
        } else {
            return false;
        }
    }

    // 5
    function mathsQuiz($user_id, $table, $category, $subcategory, $playQuestions)
    {
        $checkData = $this->db->where('user_id', $user_id)->get($table)->row_array();
        if ($checkData) {
            $setQuestions = json_decode($checkData['questions'], true);

            $earnCoin = $userScore = 0;

            $setQuestionMap = [];
            $setQuestionMap = array_column($setQuestions, 'answer', 'id');
            $total_questions = count($setQuestions);
            $correctAnswer = 0;

            $play_questions = json_decode($playQuestions, true);
            foreach ($play_questions as $userAnswer) {
                $id = $userAnswer['id'];
                if (isset($setQuestionMap[$id]) && $setQuestionMap[$id] === $userAnswer['answer']) {
                    $correctAnswer++;
                }
            }
            $quiz_winning_percentage = is_settings('quiz_winning_percentage');
            $winningPer = ($correctAnswer * 100) / $total_questions;

            if ($winningPer >= $quiz_winning_percentage) {
                $ratio = $winningPer;
                $questions_answered = count($play_questions);
                $this->set_users_statistics($user_id, $category, $questions_answered, $correctAnswer,  $ratio);
                $type = 5;
                $type_id = 0;
                $res = $this->db->where('user_id', $user_id)->where('type', $type)->where('type_id', $type_id)->where('category', $category)->where('subcategory', $subcategory)->get('tbl_quiz_categories')->result_array();
                if (empty($res)) {
                    $wrongAnswer = $total_questions - $correctAnswer;
                    $minimum_coins_winning_percentage = is_settings('minimum_coins_winning_percentage');
                    $maximum_winning_coins = is_settings('maximum_winning_coins');
                    $maths_quiz_correct_answer_credit_score = is_settings('maths_quiz_correct_answer_credit_score');
                    $maths_quiz_wrong_answer_deduct_score = is_settings('maths_quiz_wrong_answer_deduct_score');
                    if ($winningPer >= $minimum_coins_winning_percentage) {
                        $earnCoin = $maximum_winning_coins;
                    } else {
                        $earnCoin = ($maximum_winning_coins - (($minimum_coins_winning_percentage - $winningPer) / 10));
                    }
                    $userScore = ($correctAnswer * $maths_quiz_correct_answer_credit_score) - ($wrongAnswer * $maths_quiz_wrong_answer_deduct_score);

                    $frm_data = array(
                        'user_id' => $user_id,
                        'type' => $type,
                        'category' => $category,
                        'subcategory' => $subcategory,
                        'type_id' => $type_id,
                    );
                    $this->db->insert('tbl_quiz_categories', $frm_data);
                    if ($userScore) {
                        $this->set_monthly_leaderboard($user_id, $userScore);
                    }
                    $earnCoin = floor($earnCoin);
                    if ($earnCoin) {
                        $this->set_coins($user_id, $earnCoin);
                        $title = 'wonMathQuiz';
                        $status = 0; //add
                        $this->set_tracker_data($user_id, $earnCoin, $title, $status);
                    } else {
                        $earnCoin = 0;
                    }
                }
            }

            $this->db->where('id', $checkData['id'])->delete($table);

            $resultData = [
                'user_id' => $user_id,
                'total_questions' => $total_questions ?? 0,
                'correctAnswer' => $correctAnswer ?? 0,
                'winningPer' => $winningPer ?? 0,
                'earnCoin' => (float)$earnCoin ?? 0,
                'userScore' => (float)$userScore ?? 0
            ];
            return $resultData;
        } else {
            return false;
        }
    }

    // 6
    function multiMatch($user_id, $table, $category, $subcategory, $playQuestions)
    {
        $checkData = $this->db->where('user_id', $user_id)->get($table)->row_array();
        if ($checkData) {
            $setQuestions = json_decode($checkData['questions'], true);
            $currentLevel = $setQuestions[0]['level'];
            $getMaxLevelData = $this->db->select_max('level')->where('category', $category)->where('subcategory', $subcategory)->get('tbl_multi_match')->row_array();
            $totalLevel = $getMaxLevelData['level'];
            $earnCoin = $userScore = 0;

            if ($currentLevel <= $totalLevel) {
                $setQuestionMap = [];
                $setQuestionMap = array_column($setQuestions, 'answer', 'id');
                $total_questions = count($setQuestions);
                $correctAnswer = 0;

                $play_questions = json_decode($playQuestions, true);
                foreach ($play_questions as $userAnswer) {
                    $id = $userAnswer['id'];
                    if (isset($setQuestionMap[$id]) && $setQuestionMap[$id] === $userAnswer['answer']) {
                        $correctAnswer++;
                    }
                }
                $quiz_winning_percentage = is_settings('quiz_winning_percentage');
                $winningPer = ($correctAnswer * 100) / $total_questions;


                if ($winningPer >= $quiz_winning_percentage) {
                    $wrongAnswer = $total_questions - $correctAnswer;
                    $minimum_coins_winning_percentage = is_settings('minimum_coins_winning_percentage');
                    $maximum_winning_coins = is_settings('maximum_winning_coins');
                    $multi_match_correct_answer_credit_score = is_settings('multi_match_correct_answer_credit_score');
                    $multi_match_wrong_answer_deduct_score = is_settings('multi_match_wrong_answer_deduct_score');
                    if ($winningPer >= $minimum_coins_winning_percentage) {
                        $earnCoin = $maximum_winning_coins;
                    } else {
                        $earnCoin = ($maximum_winning_coins - (($minimum_coins_winning_percentage - $winningPer) / 10));
                    }
                    $userScore = ($correctAnswer * $multi_match_correct_answer_credit_score) - ($wrongAnswer * $multi_match_wrong_answer_deduct_score);
                    $getLevelData = $this->db->select('level')->where('user_id', $user_id)->where('category', $category)->where('subcategory', $subcategory)->get('tbl_level')->row_array();

                    $nextUnlockLevel = $getLevelData['level'] ?? 0;

                    if ($userScore) {
                        $this->set_monthly_leaderboard($user_id, $userScore);
                    }

                    $updateLevel = $currentLevel + 1;
                    $earnCoin = floor($earnCoin);
                    if ($earnCoin && ($updateLevel > $nextUnlockLevel && $updateLevel != $nextUnlockLevel)) {
                        $this->set_quiz_level_data($user_id, 6, $updateLevel, $category, $subcategory);
                        $this->set_coins($user_id, $earnCoin);
                        $title = 'wonMultiMatch';
                        $status = 0; //add
                        $this->set_tracker_data($user_id, $earnCoin, $title, $status);
                    } else {
                        $earnCoin = 0;
                    }
                }

                $this->db->where('id', $checkData['id'])->delete($table);
            }
            $resultData = [
                'user_id' => $user_id,
                'total_questions' => $total_questions ?? 0,
                'correctAnswer' => $correctAnswer ?? 0,
                'winningPer' => $winningPer ?? 0,
                'earnCoin' => (float)$earnCoin ?? 0,
                'userScore' => (float)$userScore ?? 0,
                'totalLevel' => (float)$totalLevel ?? 0,
                'currentLevel' => (float)$currentLevel ?? 0,
            ];
            return $resultData;
        } else {
            return false;
        }
    }

    //contest
    function contest($user_id, $table, $playQuestions)
    {
        $checkData = $this->db->where('user_id', $user_id)->get($table)->row_array();
        if ($checkData) {
            $setQuestions = json_decode($checkData['questions'], true);
            $contest_id = $setQuestions[0]['contest_id'];
            $earnCoin = $userScore = 0;
            $correctAnswer = 0;

            $getContest = $this->db->where('contest_id', $contest_id)->where('user_id', $user_id)->get('tbl_contest_leaderboard')->row_array();

            if (empty($getContest)) {
                $setQuestionMap = [];
                $setQuestionMap = array_column($setQuestions, 'answer', 'id');
                $total_questions = count($setQuestions);

                $play_questions = json_decode($playQuestions, true);
                foreach ($play_questions as $userAnswer) {
                    $id = $userAnswer['id'];
                    if (isset($setQuestionMap[$id]) && $setQuestionMap[$id] === $userAnswer['answer']) {
                        $correctAnswer++;
                    }
                }
                $questions_answered = count($play_questions);
                $winningPer = ($correctAnswer * 100) / $total_questions;

                $wrongAnswer = $total_questions - $correctAnswer;
                $contest_mode_correct_credit_score = is_settings('contest_mode_correct_credit_score');
                $contest_mode_wrong_deduct_score = is_settings('contest_mode_wrong_deduct_score');

                $userScore = ($correctAnswer * $contest_mode_correct_credit_score) - ($wrongAnswer * $contest_mode_wrong_deduct_score);

                if ($userScore) {
                    $this->set_monthly_leaderboard($user_id, $userScore);
                }

                $data = array(
                    'user_id' => $user_id,
                    'contest_id' => $contest_id,
                    'questions_attended' => $questions_answered,
                    'correct_answers' => $correctAnswer,
                    'score' => $userScore,
                    'last_updated' => $this->toDateTime,
                    'date_created' => $this->toDateTime,
                );
                $this->db->insert('tbl_contest_leaderboard', $data);
            }


            $this->db->where('id', $checkData['id'])->delete($table);

            $resultData = [
                'user_id' => $user_id,
                'total_questions' => $total_questions ?? 0,
                'correctAnswer' => $correctAnswer ?? 0,
                'winningPer' => $winningPer ?? 0,
                'earnCoin' => (float)$earnCoin ?? 0,
                'userScore' => (float)$userScore ?? 0,
            ];
            return $resultData;
        } else {
            return false;
        }
    }

    public function getBadgeNotificationData($language, $type, $path, $sampleFile, $defaultFile)
    {
        $file = $path . $language . '.json';

        if (!file_exists($file) && $defaultFile) {
            $file = $path . $defaultFile;
            if (!file_exists($file)) {
                $file = $path . $sampleFile;
            }
        } else {
            $file = $path . $sampleFile;
        }

        $content = file_get_contents($file);
        $dataArray = json_decode($content, true);

        $badge_label = $type . '_label';
        $badge_note = $type . '_note';

        return [
            'notification_title' => $dataArray[$badge_label] ?? 'Congratulations!!',
            'notification_body' => $dataArray[$badge_note] ?? 'You have unlocked new badge.'
        ];
    }

    public function set_badges($user_id, $type, $counter = 0)
    {
        $res = $this->db->where('user_id', $user_id)->get('tbl_users_badges')->row_array();
        $counter_name = $type . '_counter';
        if (!empty($res)) {
            if ($res[$type] == 0 || $res[$type] == '0') {
                $res1 = $this->db->where('type', $type)->get('tbl_badges')->row_array();
                if (!empty($res1)) {
                    if ($counter == 0) {
                        $counter = $res1['badge_counter'];
                        $user_counter = $res[$counter_name];
                        $user_counter = $user_counter + 1;
                        if ($user_counter < $counter) {
                            $data = [$counter_name => $user_counter];
                            $this->db->where('user_id', $user_id)->update('tbl_users_badges', $data);
                        } else if (($counter == $user_counter) || $counter == 1) {
                            $power_elite_counter = $res['power_elite_counter'] + 1;
                            $this->set_power_elite_badge($user_id, $power_elite_counter);
                            $data1 = [
                                $counter_name => $user_counter,
                                $type => 1,
                            ];
                            $this->db->where('user_id', $user_id)->update('tbl_users_badges', $data1);
                            //send notification
                            $this->send_badges_notification($user_id, $type);
                        }
                    } else {
                        $power_elite_counter = $res['power_elite_counter'] + 1;
                        $this->set_power_elite_badge($user_id, $power_elite_counter);
                        $data1 = [
                            $type => 1,
                        ];
                        $this->db->where('user_id', $user_id)->update('tbl_users_badges', $data1);
                        //send notification
                        $this->send_badges_notification($user_id, $type);
                    }
                }
            }
        }
    }

    public function set_power_elite_badge($user_id, $counter)
    {
        $type = $this->POWER_ELITE;
        $res = $this->db->where('user_id', $user_id)->get('tbl_users_badges')->row_array();
        $user_conter = $type . '_counter';
        if (!empty($res)) {
            if ($res[$type] == 0 || $res[$type] == '0') {
                $res1 = $this->db->where('type', $type)->get('tbl_badges')->row_array();
                if (!empty($res1)) {
                    $badge_counter = $res1['badge_counter'];

                    if ($counter < $badge_counter) {
                        $data = [$user_conter => $counter];
                        $this->db->where('user_id', $user_id)->update('tbl_users_badges', $data);
                    }

                    if ($counter == $badge_counter) {
                        $data1 = [
                            $type . '_counter' => $counter,
                            $type => 1,
                        ];
                        $this->db->where('user_id', $user_id)->update('tbl_users_badges', $data1);
                        //send notification
                        $this->send_badges_notification($user_id, $type);
                    }
                }
            }
        }
    }

    public function set_badge_counter($user_id, $type)
    {
        $per_date = date('Y-m-d', strtotime("-1 days"));
        $res2 = $this->db->where('user_id', $user_id)->get('tbl_users_badges')->row_array();

        if (!empty($res2)) {
            if ($res2[$type] == 0 || $res2[$type] == '0') {
                $old_date = $res2[$type . '_date'];
                $old_counter = $res2[$type . '_counter'];
                if ($old_date == $per_date) {
                    $res1 = $this->db->where('type', $type)->get('tbl_badges')->row_array();
                    if (!empty($res1)) {
                        $badge_counter = $res1['badge_counter'];
                        $final_counter = $old_counter + 1;
                        if ($final_counter < $badge_counter) {
                            $data1 = [
                                $type . '_date' => $this->toDate,
                                $type . '_counter' => $final_counter,
                            ];
                            $this->db->where('user_id', $user_id)->update('tbl_users_badges', $data1);
                        }
                        if ($final_counter == $badge_counter) {
                            $this->set_badges($user_id, $type, 1);
                        }
                    }
                } else if ($old_date != $this->toDate) {
                    $data1 = [
                        $type . '_date' => $this->toDate,
                        $type . '_counter' => 1,
                    ];
                    $this->db->where('user_id', $user_id)->update('tbl_users_badges', $data1);
                    $res1 = $this->db->where('type', $type)->get('tbl_badges')->row_array();
                    $badge_counter = $res1['badge_counter'];
                    if ($badge_counter == 1) {
                        $this->set_badges($user_id, $type, 1);
                    }
                }
            }
        }
    }

    public function set_coins($user_id, $coins, $is_update = true, $type = 'elite')
    {
        $res = $this->db->where('id', $user_id)->get('tbl_users')->row_array();
        if (!empty($res)) {
            if ($is_update) {
                $net_coins = $res['coins'] + $coins;
                $data = [
                    'coins' => $net_coins,
                ];
                $this->db->where('id', $user_id)->update('tbl_users', $data);
            } else {
                $net_coins = $coins;
            }

            if ($type == 'elite') {
                $res2 = $this->db->where('user_id', $user_id)->get('tbl_users_badges')->row_array();
                if (!empty($res2)) {
                    if ($res2[$type] == 0 || $res2[$type] == '0') {
                        $res1 = $this->db->where('type', $type)->get('tbl_badges')->row_array();
                        if (!empty($res1)) {
                            $counter = $res1['badge_counter'];
                            if ($counter <= $net_coins) {
                                $this->set_badges($user_id, $this->ELITE, 1);
                            }
                        }
                    }
                }
            } else if ($type == 'sharing_caring') {
                $res2 = $this->db->where('user_id', $user_id)->get('tbl_users_badges')->row_array();
                if (!empty($res2)) {
                    if ($res2[$type] == 0 || $res2[$type] == '0') {
                        $res1 = $this->db->where('type', $type)->get('tbl_badges')->row_array();
                        if (!empty($res1)) {
                            $counter = $res1['badge_counter'];
                            if ($counter <= $net_coins) {
                                $this->set_badges($user_id, $this->SHARING_CARING, 1);
                            }
                        }
                    }
                }
            }
        }
    }

    public function set_badges_reward($user_id, $type)
    {
        $res = $this->db->where('user_id', $user_id)->get('tbl_users_badges')->row_array();
        if (!empty($res)) {
            if ($res[$type] == 1 || $res[$type] == '1') {
                $data1 = [
                    $type => 2,
                ];
                $this->db->where('user_id', $user_id)->update('tbl_users_badges', $data1);
            }
        }
    }

    public function send_badges_notification($user_id, $type)
    {
        $res = $this->db->select('id,fcm_id,web_fcm_id,app_language,web_language')->where('id', $user_id)->get('tbl_users')->row_array();
        $fcm_id = $res['fcm_id'];
        $web_fcm_id = $res['web_fcm_id'];

        $user_app_language = $res['app_language'];

        $get_app_default_language = $this->db->select('id,name,app_default')->where('app_default', 1)->get('tbl_upload_languages')->row_array();
        $default_app_language = $get_app_default_language['name'] ?? '';

        $notificationData = $this->getBadgeNotificationData($user_app_language, $type, APP_LANGUAGE_FILE_PATH, 'app_sample_file.json', $default_app_language);

        $notification_title_message = $notificationData['notification_title'] ?? 'Congratulations!!';
        $notification_body_message = $notificationData['notification_body'] ?? 'You have unlocked new badge.';
        $fcmMsg = array(
            'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
            'type' => 'badges',
            'badge_type' => $type,
            'title' => $notification_title_message,
            'body' => $notification_body_message,
        );

        if ($fcm_id && $fcm_id != '' && $fcm_id != 'empty') {
            $registrationID = explode(',', $fcm_id);
            $factory = (new Factory)->withServiceAccount('assets/firebase_config.json');
            $messaging = $factory->createMessaging();
            $message = CloudMessage::new();
            $message = $message->withNotification($fcmMsg)->withData($fcmMsg);
            $messaging->sendMulticast($message, $registrationID);
        }

        $user_web_language = $res['web_language'];

        $get_web_default_language = $this->db->select('id,name,web_default')->where('web_default', 1)->get('tbl_upload_languages')->row_array();
        $default_web_language = $get_web_default_language['name'] ?? '';

        $web_notificationData = $this->getBadgeNotificationData($user_web_language, $type, WEB_LANGUAGE_FILE_PATH, 'web_sample_file.json', $default_web_language);

        $web_notification_title_message = $web_notificationData['notification_title'] ?? 'Congratulations!!';
        $web_notification_body_message = $web_notificationData['notification_body'] ?? 'You have unlocked new badge.';
        $web_fcmMsg = array(
            'click_action' => 'WEB_NOTIFICATION_CLICK',
            'type' => 'badges',
            'badge_type' => $type,
            'title' => $web_notification_title_message,
            'body' => $web_notification_body_message,
        );

        if ($web_fcm_id && $web_fcm_id != '' && $web_fcm_id != 'empty') {
            $registrationID = explode(',', $web_fcm_id);
            $factory = (new Factory)->withServiceAccount('assets/firebase_config.json');
            $messaging = $factory->createMessaging();
            $message = CloudMessage::new();
            $message = $message->withNotification($web_fcmMsg)->withData($web_fcmMsg);
            $messaging->sendMulticast($message, $registrationID);
        }
    }

    public function set_tracker_data($user_id, $points, $type, $status)
    {
        $res = $this->db->select('firebase_id, coins')->where('id', $user_id)->get('tbl_users')->row_array();
        if (!empty($res)) {
            $firebase_id = $res['firebase_id'];
            $tracker_res = $this->db->where('user_id', $user_id)->where('uid', $firebase_id)->get('tbl_tracker')->row_array();
            if (empty($tracker_res) && !empty($res['coins'])) {
                $coins = $res['coins'] - $points;
                if ($coins != 0 || $coins != "0") {
                    $tracker_data = [
                        'user_id' => $user_id,
                        'uid' => $firebase_id,
                        'points' => $coins,
                        'type' => $this->opening_msg,
                        'status' => 1,
                        'date' => $this->toDateTime,
                    ];
                    $this->db->insert('tbl_tracker', $tracker_data);
                }
            }

            $tracker_data = [
                'user_id' => $user_id,
                'uid' => $firebase_id,
                'points' => $points,
                'type' => $type,
                'status' => $status,
                'date' => $this->toDateTime,
            ];
            $this->db->insert('tbl_tracker', $tracker_data);
        }
    }

    public function set_monthly_leaderboard($user_id, $score)
    {
        $month = date('m', strtotime($this->toDate));
        $year = date('Y', strtotime($this->toDate));

        // set data in mothly leaderboard
        $data_m = $this->db->where('user_id', $user_id)->where('MONTH(date_created)', $month)->where('YEAR(date_created)', $year)->get('tbl_leaderboard_monthly')->row_array();
        if (!empty($data_m)) {
            $old1 = $data_m['score'];
            $new1 = $old1 + $score;

            $data['score'] =  $new1;
            $data['last_updated'] = $this->toDateTime;

            $this->db->where('id', $data_m['id'])->where('user_id', $user_id)->update('tbl_leaderboard_monthly', $data);
        } else {
            $score1 = $score;
            $data = array(
                'user_id' => $user_id,
                'score' => $score1,
                'last_updated' => $this->toDateTime,
                'date_created' => $this->toDateTime,
            );
            $this->db->insert('tbl_leaderboard_monthly', $data);
        }

        // set data in daily leaderboard
        $data_d = $this->db->where('user_id', $user_id)->get('tbl_leaderboard_daily')->row_array();
        if (!empty($data_d)) {
            $data_d1 = $this->db->where('user_id', $user_id)->where('DATE(date_created)', $this->toDate)->get('tbl_leaderboard_daily')->row_array();
            if (!empty($data_d1)) {
                $old = $data_d1['score'];
                $new = $old + $score;

                $data1['score'] = $new;

                $this->db->where('id', $data_d1['id'])->where('user_id', $user_id)->update('tbl_leaderboard_daily', $data1);
            } else {
                $score1 = $score;
                $data2 = array(
                    'score' => $score1,
                    'date_created' => $this->toDateTime,
                );
                $this->db->where('id', $data_d['id'])->where('user_id', $user_id)->update('tbl_leaderboard_daily', $data2);
            }
        } else {
            $score1 = $score;
            $data = array(
                'user_id' => $user_id,
                'score' => $score1,
                'date_created' => $this->toDateTime,
            );
            $this->db->insert('tbl_leaderboard_daily', $data);
        }
    }

    public function random_string($length)
    {
        $characters = 'abC0DefGHij1KLMnop2qR3STu4vwxY5ZABc6dEFgh7IJ8klm9NOPQrstUVWXyz';
        $string = '';
        for ($i = 0; $i < $length; $i++) {
            $string .= $characters[mt_rand(0, strlen($characters) - 1)];
        }
        return $string;
    }

    public function checkBattleExists($match_id)
    {
        $res = $this->db->where('match_id', $match_id)->get('tbl_battle_questions')->result_array();
        if (empty($res)) {
            return false;
        } else {
            return true;
        }
    }

    public function verify_user($firebase_id)
    {
        $firebase_config = 'assets/firebase_config.json';
        if (file_exists($firebase_config)) {
            $factory = (new Factory)->withServiceAccount($firebase_config);
            $firebaseauth = $factory->createAuth();
            try {
                $user = (array) $firebaseauth->getUser($firebase_id);
                if ($user['uid'] == $firebase_id) {
                    return true;
                } else {
                    return false;
                }
            } catch (\Kreait\Firebase\Exception\Auth\UserNotFound $e) {
                return false;
            }
        } else {
            return false;
        }
    }

    public function generate_token($user_id, $firebase_id)
    {
        $payload = [
            'iat' => time(), /* issued at time */
            'iss' => 'Quiz',
            'exp' => time() + (30 * 60 * 60 * 24), /* expires after 1 minute */
            'user_id' => $user_id,
            'firebase_id' => $firebase_id,
            'sub' => 'Quiz Authentication',
        ];
        return $this->jwt->encode($payload, $this->JWT_SECRET_KEY);
    }

    public function verify_token()
    {
        try {
            $token = $this->jwt->getBearerToken();
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = $e->getMessage();
            return $response;
        }
        if (!empty($token)) {
            try {
                $res = $this->db->where('api_token', $token)->get('tbl_users')->row_array();
                if (empty($res)) {
                    $response['error'] = true;
                    $response['message'] = '129';
                    return $response;
                } else {
                    $payload = $this->jwt->decode($token, $this->JWT_SECRET_KEY, ['HS256']);
                    if ($payload) {
                        if (isset($payload->user_id) && isset($payload->firebase_id)) {
                            $response['error'] = false;
                            $response['user_id'] = $payload->user_id;
                            $response['firebase_id'] = $payload->firebase_id;
                            $response['status'] = $res['status'];
                            return $response;
                        } else {
                            $response['error'] = true;
                            $response['message'] = '129';
                            return $response;
                        }
                    } else {
                        $response['error'] = true;
                        $response['message'] = '129';
                        return $response;
                    }
                }
            } catch (Exception $e) {
                $response['error'] = true;
                $response['message'] = $e->getMessage();
                return $response;
            }
        } else {
            $response['error'] = true;
            $response['message'] = "125";
            return $response;
        }
    }

    public function encrypt_data($key, $text)
    {
        $iv = openssl_random_pseudo_bytes(16);
        $key .= "0000";
        $encrypted_data = openssl_encrypt($text, 'aes-256-cbc', $key, 0, $iv);
        $data = array("ciphertext" => $encrypted_data, "iv" => bin2hex($iv));
        return $data;
    }

    public function decrypt_data($key, $text, $iv)
    {
        $decrypted_data = '';
        if ($iv) {
            $key .= "0000";
            $decrypted_data = openssl_decrypt($text, 'aes-256-cbc', $key, 0, hex2bin($iv));
        }
        return $decrypted_data;
    }

    function suffleOptions($data, $firebase_id)
    {
        // Create an associative array of options
        $options = array(
            'optiona' => trim($data['optiona']),
            'optionb' => trim($data['optionb']),
        );
        if ($data['question_type'] == 1) {
            $options['optionc'] = trim($data['optionc']);
            $options['optiond'] = trim($data['optiond']);
            if (is_option_e_mode_enabled() && $data['optione'] != null) {
                $options['optione'] = trim($data['optione']);
            }
        }

        // Find the correct answer before shuffling
        $correctAnswer = 'option' . $data['answer'];
        $correctAnswerValue = $options[$correctAnswer];

        // Shuffle the options
        $shuffled_options = $options;
        if ($this->OPTION_SHUFFLE_MODE == 1) {
            shuffle($shuffled_options);
            // Assign the shuffled values back to the original options
            $keys = array_keys($options);
            for ($j = 0; $j < count($keys); $j++) {
                $data[$keys[$j]] = $shuffled_options[$j];
                // Update the correct answer after shuffling
                if ($shuffled_options[$j] == $correctAnswerValue) {
                    $suffledAnswer = chr(ord('a') + $j);  // converts the index $j to a letter like 0 to 'a', 1 to 'b', etc.
                    $data['session_answer'] = $suffledAnswer;
                    $data['answer'] = $this->encrypt_data($firebase_id, $suffledAnswer);
                }
            }
        } else {
            $data['session_answer'] = trim($data['answer']);
            $data['answer'] = $this->encrypt_data($firebase_id, trim($data['answer']));
        }
        return $data;
    }

    function remapMultiMatchSequenceQuestion($data, $seedSource = '')
    {
        if (!isset($data['answer_type']) || intval($data['answer_type']) !== 2) {
            return $data;
        }

        $letters = $this->getMultiMatchOptionLetters($data);
        if (empty($letters)) {
            return $data;
        }

        $answerLetters = $this->normalizeSequenceAnswerLetters($data['answer'] ?? '', $letters);
        if (empty($answerLetters)) {
            return $data;
        }

        $sourceOrder = $this->buildDeterministicLetterPermutation($letters, $seedSource);
        if (empty($sourceOrder)) {
            return $data;
        }

        $originalOptionValues = [];
        foreach ($letters as $letter) {
            $originalOptionValues[$letter] = trim((string)($data['option' . $letter] ?? ''));
        }

        $sourceToTarget = [];
        foreach ($letters as $index => $targetLetter) {
            $sourceLetter = $sourceOrder[$index] ?? $targetLetter;
            $data['option' . $targetLetter] = $originalOptionValues[$sourceLetter] ?? ($originalOptionValues[$targetLetter] ?? '');
            $sourceToTarget[$sourceLetter] = $targetLetter;
        }

        $remappedAnswer = [];
        foreach ($answerLetters as $answerLetter) {
            if (isset($sourceToTarget[$answerLetter])) {
                $remappedAnswer[] = $sourceToTarget[$answerLetter];
            }
        }

        if (!empty($remappedAnswer)) {
            $data['answer'] = implode(',', $remappedAnswer);
        }

        return $data;
    }

    function getMultiMatchOptionLetters($data)
    {
        $letters = ['a', 'b'];
        if (($data['question_type'] ?? '') == 1) {
            $letters[] = 'c';
            $letters[] = 'd';
            $optione = trim((string)($data['optione'] ?? ''));
            if ($optione !== '') {
                $letters[] = 'e';
            }
        }
        return $letters;
    }

    function normalizeSequenceAnswerLetters($answerString, $allowedLetters)
    {
        $allowedLookup = array_fill_keys($allowedLetters, true);
        $tokens = explode(',', strtolower((string)$answerString));
        $normalized = [];

        foreach ($tokens as $token) {
            $letter = trim($token);
            if (isset($allowedLookup[$letter]) && !in_array($letter, $normalized, true)) {
                $normalized[] = $letter;
            }
        }

        return $normalized;
    }

    function buildDeterministicLetterPermutation($letters, $seedSource)
    {
        $pool = array_values($letters);
        $result = [];
        $hash = sha1((string)$seedSource);
        $cursor = 0;

        while (!empty($pool)) {
            if ($cursor + 8 > strlen($hash)) {
                $hash = sha1($hash . '|' . count($result));
                $cursor = 0;
            }

            $chunk = substr($hash, $cursor, 8);
            $cursor += 8;
            $index = hexdec($chunk) % count($pool);

            $result[] = $pool[$index];
            array_splice($pool, $index, 1);
        }

        return $result;
    }

    function getCategoryData($category, $categorySlug)
    {
        if ($category) {
            return $this->db->where('id', $category)->get('tbl_category')->row_array();
        } else if ($categorySlug) {
            return $this->db->where('slug', $categorySlug)->get('tbl_category')->row_array();
        }
        return null;
    }

    function getSubCategoryData($subCategory, $subCategorySlug)
    {
        if ($subCategory) {
            return $this->db->where('id', $subCategory)->get('tbl_subcategory')->row_array();
        } else if ($subCategorySlug) {
            return $this->db->where('slug', $subCategorySlug)->get('tbl_subcategory')->row_array();
        }
        return null;
    }

    function getQuestionData($subcategoryData, $categoryData)
    {
        if ($subcategoryData["id"] != 0) {
            return $this->db->query('select count(id) as no_of_que, MAX(level) as max_level from tbl_question where subcategory  = ' . $subcategoryData["id"])->row_array();
        } else {
            return $this->db->query('select count(id) as no_of_que, MAX(level) as max_level from tbl_question where category = ' . $categoryData["id"] . ' AND subcategory = 0')->row_array();
        }
    }

    function getMultiMatchQuestionData($subcategoryData, $categoryData)
    {
        if ($subcategoryData["id"] != 0) {
            return $this->db->query('select count(id) as no_of_que, MAX(level) as max_level from tbl_multi_match where subcategory  = ' . $subcategoryData["id"])->row_array();
        } else {
            return $this->db->query('select count(id) as no_of_que, MAX(level) as max_level from tbl_multi_match where category = ' . $categoryData["id"] . ' AND subcategory = 0')->row_array();
        }
    }

    function myGlobalRank($user_id, $scope = 'world', $filter_value = '')
    {
        // Build scope filter
        $scope_where = "";
        if ($scope === 'country' && !empty($filter_value)) {
            $scope_where = "AND u.country_code = '" . $this->db->escape_str($filter_value) . "'";
        } elseif ($scope === 'region' && !empty($filter_value)) {
            $scope_where = "AND u.continent = '" . $this->db->escape_str($filter_value) . "'";
        }

        $this->db->reset_query();
        $this->db->select('r.*');
        $this->db->from("(SELECT s.*, @user_rank := @user_rank + 1 AS user_rank FROM (SELECT m.id, m.user_id,u.email, u.name,u.status,u.profile,u.country_code, SUM(m.score) AS score,MAX(last_updated) as last_updated FROM tbl_leaderboard_monthly m JOIN tbl_users u ON u.id = m.user_id WHERE u.status=1 {$scope_where} GROUP BY m.user_id) s, (SELECT @user_rank := 0) init ORDER BY s.score DESC,s.last_updated ASC) r", false);
        $this->db->where('r.user_id', $user_id);
        $this->db->limit(1);
        $my_rank_sql = $this->db->get();
        $my_rank = $my_rank_sql->row_array();
        return  $my_rank;
    }

    /**
     * Check and handle daily login streak
     * Called on app startup
     */
    public function check_daily_streak_post()
    {
        try {
            $is_user = $this->verify_token();
            if ($is_user['error']) {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            $user_id = $is_user['user_id'];
            $firebase_id = $is_user['firebase_id'];

            $this->load->model('Streak_model');
            $result = $this->Streak_model->handle_daily_login($user_id, $firebase_id);

            $response['error'] = false;
            $response['message'] = "Daily streak checked";
            $response['data'] = $result;
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    /**
     * Register or update device mapping
     * Called on app startup after login
     */
    public function register_device_post()
    {
        try {
            $is_user = $this->verify_token();
            if ($is_user['error']) {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            $user_id = $is_user['user_id'];
            $device_id = $this->post('device_id');
            $device_type = $this->post('device_type');  // 'android' or 'ios'
            $device_name = $this->post('device_name') ?? '';

            if (!$device_id || !$device_type) {
                $response['error'] = true;
                $response['message'] = "Missing device information";
                $this->response($response, REST_Controller::HTTP_OK);
                return;
            }

            $this->load->model('Device_model');
            $result = $this->Device_model->register_or_update_device(
                $user_id,
                $device_id,
                $device_type,
                $device_name
            );

            $response['error'] = false;
            $response['message'] = "Device registered";
            $response['data'] = $result;
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    /**
     * Evaluate user activity for fraud indicators
     * Called after quiz completion, ad watch, or payout request
     */
    public function evaluate_user_risk_post()
    {
        try {
            $is_user = $this->verify_token();
            if ($is_user['error']) {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            $user_id = $is_user['user_id'];
            $action_type = $this->post('action_type');  // 'ad_watch', 'quiz_complete', 'payout_request'
            $metadata = $this->post('metadata') ?? [];  // JSON array with additional data

            if (!$action_type) {
                $response['error'] = true;
                $response['message'] = "Missing action_type";
                $this->response($response, REST_Controller::HTTP_OK);
                return;
            }

            $this->load->model('Fraud_model');
            $result = $this->Fraud_model->evaluate_user_activity($user_id, $action_type, $metadata);

            // If marked as suspicious, app should handle gracefully
            $response['error'] = false;
            $response['message'] = "Risk evaluation complete";
            $response['data'] = $result;
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    /**
     * Check payout eligibility for user
     * Verifies minimum active days requirement before allowing withdrawal request
     */
    public function check_payout_eligibility_post()
    {
        try {
            $is_user = $this->verify_token();
            if ($is_user['error']) {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            $user_id = $is_user['user_id'];
            $min_days = (int)is_settings('min_active_days_for_payout');

            // Count days since user registration — each calendar day since
            // sign-up counts as one active day (tbl_daily_streak only stores
            // one row per user, so querying it always returns 1).
            $user_row = $this->db->select('date_registered')
                ->where('id', $user_id)
                ->get('tbl_users')
                ->row();

            $reg_date = new DateTime(date('Y-m-d', strtotime($user_row->date_registered)));
            $today    = new DateTime('today');
            $active_days = (int)$reg_date->diff($today)->days;

            $eligible = (int)$active_days >= $min_days;

            $response['error'] = false;
            $response['data'] = [
                'eligible' => $eligible,
                'active_days' => $active_days,
                'required_days' => $min_days,
                'message' => $eligible
                    ? "You're eligible to withdraw"
                    : "You need " . ($min_days - $active_days) . " more active days to be eligible"
            ];
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    /**
     * Get active sponsor banner for display
     * Tracks impression and handles rotation
     */
    public function get_sponsor_banner_post()
    {
        try {
            $is_user = $this->verify_token();
            // Allow anonymous users to see banners
            $user_id = $is_user['error'] ? null : $is_user['user_id'];

            $this->load->model('Sponsor_model');
            $banner = $this->Sponsor_model->get_active_banner_for_rotation();

            if ($banner) {
                // Record impression
                $this->Sponsor_model->record_impression($banner['id'], $user_id, 'showed');

                $response['error'] = false;
                $response['data'] = $banner;
            } else {
                $response['error'] = false;
                $response['data'] = null;
                $response['message'] = "No active sponsor banner";
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    /**
     * Record sponsor banner click
     * Called when user clicks on sponsor banner
     */
    public function sponsor_banner_click_post()
    {
        try {
            $is_user = $this->verify_token();
            $user_id = $is_user['error'] ? null : $is_user['user_id'];

            $banner_id = $this->post('banner_id');

            if (!$banner_id) {
                $response['error'] = true;
                $response['message'] = "Missing banner_id";
                $this->response($response, REST_Controller::HTTP_OK);
                return;
            }

            $this->load->model('Sponsor_model');
            $this->Sponsor_model->record_impression($banner_id, $user_id, 'clicked');

            $response['error'] = false;
            $response['message'] = "Click recorded";
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    /**
     * Get multiple active sponsor banners for client-side rotation
     */
    public function get_sponsor_banners_post()
    {
        try {
            $this->load->model('Sponsor_model');

            // Log: Check if sponsor banner is enabled
            $is_enabled = is_settings('sponsor_banner_enable');
            log_message('debug', '[SPONSOR_BANNER_API] sponsor_banner_enable setting: ' . ($is_enabled ? 'true' : 'false'));

            $banners = $this->Sponsor_model->get_active_banners(10);
            log_message('debug', '[SPONSOR_BANNER_API] Retrieved banners count: ' . count($banners));

            if (!$banners || count($banners) === 0) {
                log_message('debug', '[SPONSOR_BANNER_API] No active banners found, returning empty array');
                $response['error'] = false;
                $response['message'] = 'no_active_banner';
                $response['data'] = [];
                $this->response($response, REST_Controller::HTTP_OK);
                return;
            }

            log_message('debug', '[SPONSOR_BANNER_API] Processing ' . count($banners) . ' banners');
            $res = [];
            foreach ($banners as $banner) {
                log_message('debug', '[SPONSOR_BANNER_API] Banner: ' . $banner['sponsor_name'] . ' (ID: ' . $banner['id'] . ')');
                $res[] = [
                    'banner_id' => (string)$banner['id'],
                    'sponsor_name' => $banner['sponsor_name'],
                    'title' => $banner['title'],
                    'image_url' => !empty($banner['image_url']) ? $banner['image_url'] : (base_url() . SPONSOR_BANNER_IMG_PATH . $banner['image_path']),
                    'redirect_url' => $banner['redirect_url'],
                    'impression_limit' => (int)$banner['impression_limit'],
                ];
            }

            log_message('debug', '[SPONSOR_BANNER_API] Returning ' . count($res) . ' banners');
            $response['error'] = false;
            $response['message'] = 'success';
            $response['data'] = $res;
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = '122';
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    /**
     * Offer boost earnings (double coins)
     * Called after quiz completion
     */
    public function offer_boost_earnings_post()
    {
        try {
            $is_user = $this->verify_token();
            if ($is_user['error']) {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            $quiz_coins = (int)$this->post('coins');
            $multiplier = (int)is_settings('boost_earnings_coin_multiplier');
            $requires_ad = (int)is_settings('boost_earnings_watch_ad_required');

            $boosted_coins = $quiz_coins * $multiplier;

            $response['error'] = false;
            $response['data'] = [
                'original_coins' => $quiz_coins,
                'boosted_coins' => $boosted_coins,
                'multiplier' => $multiplier,
                'requires_ad_watch' => $requires_ad,
                'coin_difference' => $boosted_coins - $quiz_coins
            ];
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    /**
     * Apply boost earnings (grant double coins after ad watch)
     * Called after user watches ad for boost
     */
    public function apply_boost_earnings_post()
    {
        try {
            $is_user = $this->verify_token();
            if ($is_user['error']) {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            $user_id = $is_user['user_id'];
            $firebase_id = $is_user['firebase_id'];
            $quiz_coins = (int)$this->post('coins');
            $multiplier = (int)is_settings('boost_earnings_coin_multiplier');

            $boosted_coins = $quiz_coins * $multiplier;

            // Award boosted coins
            $this->set_coins($user_id, $boosted_coins);
            $this->set_tracker_data($user_id, $boosted_coins, 'quiz_boost', 1);

            $response['error'] = false;
            $response['message'] = "111";
            $response['data'] = [
                'coins_awarded' => $boosted_coins,
                'user_coins' => $this->db->select('coins')
                    ->where('id', $user_id)
                    ->get('tbl_users')
                    ->row()
                    ->coins
            ];
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    /**
     * Get watch & unlock premium configuration
     * Returns number of ads needed to unlock instead of coin payment
     */
    public function get_watch_unlock_config_post()
    {
        try {
            $ad_count = (int)is_settings('watch_unlock_ad_count');
            $enabled = (int)is_settings('watch_unlock_enable');

            $response['error'] = false;
            $response['data'] = [
                'enabled' => $enabled,
                'ad_count_required' => $ad_count,
                'message' => "Watch $ad_count ads to unlock premium content"
            ];
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    /**
     * Get rollout switches used by ad placements.
     * This endpoint is safe to call before login.
     */
    public function get_ad_rollout_settings_post()
    {
        try {
            $response['error'] = false;
            $response['data'] = [
                'utility_interstitials' => (int)(is_settings('ad_rollout_utility_interstitials') ?: 1),
                'wallet_banner_placement' => (int)(is_settings('ad_rollout_wallet_banner_placement') ?: 1),
                'coin_store_banner_placement' => (int)(is_settings('ad_rollout_coin_store_banner_placement') ?: 1),
                'rewarded_fallback' => (int)(is_settings('ad_rollout_rewarded_fallback') ?: 1),
                'compliance_upload_enabled' => (int)(is_settings('ad_compliance_upload_enabled') ?: 1),
                'compliance_upload_batch_size' => (int)(is_settings('ad_compliance_upload_batch_size') ?: 25),
            ];
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = '122';
            $response['error_msg'] = $e->getMessage();
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    /**
     * Upload batched ad compliance events from client.
     */
    public function submit_ad_compliance_events_post()
    {
        try {
            $is_user = $this->verify_token();
            if ($is_user['error']) {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            if ((int)(is_settings('ad_compliance_upload_enabled') ?: 1) === 0) {
                $response['error'] = true;
                $response['message'] = 'Compliance upload disabled';
                $this->response($response, REST_Controller::HTTP_OK);
                return;
            }

            $events_payload = $this->post('events');
            if (empty($events_payload)) {
                $response['error'] = true;
                $response['message'] = 'Missing events payload';
                $this->response($response, REST_Controller::HTTP_OK);
                return;
            }

            if (is_string($events_payload)) {
                $decoded = json_decode($events_payload, true);
                $events = is_array($decoded) ? $decoded : [];
            } else {
                $events = is_array($events_payload) ? $events_payload : [];
            }

            if (empty($events)) {
                $response['error'] = true;
                $response['message'] = 'Invalid events payload';
                $this->response($response, REST_Controller::HTTP_OK);
                return;
            }

            $max_batch_size = (int)(is_settings('ad_compliance_upload_batch_size') ?: 25);
            $max_batch_size = max(1, min(100, $max_batch_size));
            $limited_events = array_slice($events, 0, $max_batch_size);

            $inserted = 0;
            $skipped = 0;

            foreach ($limited_events as $event_item) {
                if (!is_array($event_item)) {
                    $skipped++;
                    continue;
                }

                $event_name = isset($event_item['event']) ? trim((string)$event_item['event']) : '';
                if ($event_name === '') {
                    $skipped++;
                    continue;
                }

                $raw_ts = isset($event_item['ts']) ? (string)$event_item['ts'] : '';
                $event_ts = !empty($raw_ts) ? date('Y-m-d H:i:s', strtotime($raw_ts)) : null;
                if ($event_ts === '1970-01-01 00:00:00') {
                    $event_ts = null;
                }

                $row = [
                    'user_id' => $is_user['user_id'],
                    'firebase_id' => $is_user['firebase_id'],
                    'event_name' => substr($event_name, 0, 100),
                    'event_ts' => $event_ts,
                    'event_payload' => json_encode($event_item),
                    'platform' => isset($event_item['platform']) ? substr((string)$event_item['platform'], 0, 20) : null,
                    'app_version' => isset($event_item['app_version']) ? substr((string)$event_item['app_version'], 0, 20) : null,
                    'ip_address' => substr((string)$this->input->ip_address(), 0, 45),
                    'created_at' => $this->toDateTime,
                ];

                $this->db->insert('tbl_ad_compliance_events', $row);
                if ($this->db->affected_rows() > 0) {
                    $inserted++;
                } else {
                    $skipped++;
                }
            }

            $response['error'] = false;
            $response['message'] = 'Compliance events processed';
            $response['data'] = [
                'received' => count($events),
                'processed' => count($limited_events),
                'inserted' => $inserted,
                'skipped' => $skipped,
            ];
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = '122';
            $response['error_msg'] = $e->getMessage();
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    // Link old and new referral systems
    /**
     * Creates tbl_referrals entry when friends_code is used (for bonus tracking)
     */
    private function link_to_bonus_referral_system($referrer_id, $referee_id, $friends_code, $ip, $device_id)
    {
        try {
            // Get referrer uid
            $referrer = $this->db->select('uid')->where('id', $referrer_id)->get('tbl_users')->row();
            $referee = $this->db->select('uid')->where('id', $referee_id)->get('tbl_users')->row();

            if (!$referrer || !$referee) {
                return;
            }

            // Check if referrer has referral code in new system
            $this->load->model('Referral_model');
            $code_check = $this->db->where('user_id', $referrer_id)->get('tbl_referral_codes')->row();

            // Generate referral code if doesn't exist
            if (!$code_check) {
                $this->Referral_model->generate_referral_code($referrer_id, $referrer->uid);
                $code_check = $this->db->where('user_id', $referrer_id)->get('tbl_referral_codes')->row();
            }

            if ($code_check) {
                // Create referral tracking entry for bonus system
                $referral_data = [
                    'referrer_id' => $referrer_id,
                    'referrer_uid' => $referrer->uid,
                    'referee_id' => $referee_id,
                    'referee_uid' => $referee->uid,
                    'referral_code' => $code_check->referral_code,
                    'signup_date' => date('Y-m-d H:i:s'),
                    'signup_ip' => $ip,
                    'signup_device_id' => $device_id,
                    'status' => 'pending'
                ];

                // Check if already exists (avoid duplicates)
                $existing = $this->db->where('referee_id', $referee_id)->get('tbl_referrals')->row();
                if (!$existing) {
                    $this->db->insert('tbl_referrals', $referral_data);

                    // Update total referrals count
                    $this->db->where('user_id', $referrer_id)
                        ->set('total_referrals', 'total_referrals + 1', FALSE)
                        ->update('tbl_referral_codes');
                }
            }
        } catch (Exception $e) {
            // Silent fail - don't break the signup process
            log_message('error', 'Failed to link referral systems: ' . $e->getMessage());
        }
    }

    /**
     * =====================================================================
    // REFERRAL SYSTEM API ENDPOINTS (ANTI-FARMING PROTECTION)
    // =====================================================================

    /**
     * Generate referral code for user
     * Each user gets one unique referral code
     */
    public function generate_referral_code_post()
    {
        try {
            $is_user = $this->verify_token();
            if ($is_user['error']) {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            $user_id = $is_user['user_id'];
            $uid = $is_user['uid'];

            $this->load->model('Referral_model');
            $result = $this->Referral_model->generate_referral_code($user_id, $uid);

            $response['error'] = $result['error'];
            $response['message'] = $result['message'];
            if (!$result['error']) {
                $response['data'] = [
                    'referral_code' => $result['referral_code']
                ];
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "Failed to generate referral code";
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    /**
     * Apply referral code during signup
     * Validates code and creates referral relationship with fraud checks
     */
    public function apply_referral_code_post()
    {
        try {
            $is_user = $this->verify_token();
            if ($is_user['error']) {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            $user_id = $is_user['user_id'];
            $uid = $is_user['uid'];
            $referral_code = $this->post('referral_code');
            $device_id = $this->post('device_id') ?? 'unknown';

            if (!$referral_code) {
                $response['error'] = true;
                $response['message'] = "Referral code is required";
                $this->response($response, REST_Controller::HTTP_OK);
                return;
            }

            // Get user's IP address
            $ip_address = $this->input->ip_address();

            $this->load->model('Referral_model');
            $result = $this->Referral_model->apply_referral_code(
                $referral_code,
                $user_id,
                $uid,
                $ip_address,
                $device_id
            );

            $response['error'] = $result['error'];
            $response['message'] = $result['message'];
            if (!$result['error']) {
                $response['data'] = [
                    'referral_id' => $result['referral_id'],
                    'fraud_detected' => $result['fraud_detected'],
                    'status' => 'pending'
                ];
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "Failed to apply referral code";
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    /**
     * Get user's referral statistics
     * Returns referral code, earnings, and pending referrals
     */
    public function get_referral_stats_post()
    {
        try {
            $is_user = $this->verify_token();
            if ($is_user['error']) {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            $user_id = $is_user['user_id'];

            $this->load->model('Referral_model');
            $stats = $this->Referral_model->get_user_referral_stats($user_id);

            // Attach live bonus config so the app never shows hardcoded thresholds
            $bonus_system_enable = is_settings('referral_bonus_system_enable');
            $min_days_row    = $this->db->where('type', 'referral_reward_min_active_days')->get('tbl_settings')->row();
            $min_quizzes_row = $this->db->where('type', 'referral_reward_min_quizzes')->get('tbl_settings')->row();
            $bonus_ref_row   = $this->db->where('type', 'referral_bonus_referrer_coins')->get('tbl_settings')->row();
            $bonus_ee_row    = $this->db->where('type', 'referral_bonus_referee_coins')->get('tbl_settings')->row();

            $stats['bonus_config'] = [
                'enabled'              => $bonus_system_enable == '1',
                'min_active_days'      => $min_days_row    ? (int)$min_days_row->message    : 7,
                'min_quizzes'          => $min_quizzes_row ? (int)$min_quizzes_row->message : 50,
                'referrer_bonus_coins' => $bonus_ref_row   ? (int)$bonus_ref_row->message   : 0,
                'referee_bonus_coins'  => $bonus_ee_row    ? (int)$bonus_ee_row->message    : 0,
            ];

            $response['error'] = false;
            $response['message'] = "Referral stats retrieved";
            $response['data'] = $stats;
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "Failed to get referral stats";
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    /**
     * Update referee activity after quiz completion
     * This tracks progress toward reward eligibility
     * Called automatically after each quiz - no manual trigger needed
     */
    public function update_referee_activity_post()
    {
        try {
            $is_user = $this->verify_token();
            if ($is_user['error']) {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            $user_id = $is_user['user_id'];
            $coins_earned = (int)$this->post('coins_earned', 0);
            $quiz_played = (int)$this->post('quiz_played', 1);

            $this->load->model('Referral_model');
            $this->Referral_model->update_referee_activity($user_id, $coins_earned, $quiz_played);

            $response['error'] = false;
            $response['message'] = "Activity updated";
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "Failed to update activity";
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    /**
     * Check if user is eligible for referral reward
     * Returns progress toward requirements
     */
    public function check_referral_eligibility_post()
    {
        try {
            $is_user = $this->verify_token();
            if ($is_user['error']) {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            $user_id = $is_user['user_id'];

            // Check if user is a referee
            $referral = $this->db->where('referee_id', $user_id)
                ->where_in('status', ['pending', 'qualified'])
                ->get('tbl_referrals')
                ->row();

            if (!$referral) {
                $response['error'] = false;
                $response['message'] = "Not a referred user";
                $response['data'] = [
                    'is_referee' => false
                ];
                $this->response($response, REST_Controller::HTTP_OK);
                return;
            }

            // Get requirements
            $min_days = (int)$this->db->where('type', 'referral_reward_min_active_days')->get('tbl_settings')->row()->message;
            $min_quizzes = (int)$this->db->where('type', 'referral_reward_min_quizzes')->get('tbl_settings')->row()->message;
            // Bug fix: use the correct settings keys (referral_bonus_*, not referral_reward_*)
            $referrer_reward = (int)$this->db->where('type', 'referral_bonus_referrer_coins')->get('tbl_settings')->row()->message;
            $referee_reward = (int)$this->db->where('type', 'referral_bonus_referee_coins')->get('tbl_settings')->row()->message;

            $days_remaining = max(0, $min_days - $referral->referee_active_days);
            $quizzes_remaining = max(0, $min_quizzes - $referral->referee_quizzes_played);
            $is_eligible = ($days_remaining == 0 && $quizzes_remaining == 0);

            $response['error'] = false;
            $response['message'] = $is_eligible ? "Eligible for reward!" : "Keep playing to unlock reward";
            $response['data'] = [
                'is_referee' => true,
                'status' => $referral->status,
                'progress' => [
                    'active_days' => $referral->referee_active_days,
                    'required_days' => $min_days,
                    'days_remaining' => $days_remaining,
                    'quizzes_played' => $referral->referee_quizzes_played,
                    'required_quizzes' => $min_quizzes,
                    'quizzes_remaining' => $quizzes_remaining
                ],
                'rewards' => [
                    'you_will_get' => $referee_reward,
                    'referrer_will_get' => $referrer_reward
                ],
                'is_eligible' => $is_eligible
            ];
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "Failed to check eligibility";
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    /**
     * Fetch active/upcoming/past leagues for the authenticated user.
     */
    public function get_leagues_post()
    {
        try {
            $is_user = $this->verify_token();
            if ($is_user['error']) {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            $user_id = (int)$is_user['user_id'];
            $timezone = $this->post('timezone') ? $this->post('timezone') : $this->systemTimezone;
            $gmt_format = $this->post('gmt_format') ? $this->post('gmt_format') : $this->systemTimezoneGMT;
            $language_id = ($this->post('language_id') && is_numeric($this->post('language_id'))) ? (int)$this->post('language_id') : 0;
            $toDateTime = (new DateTime('now', new DateTimeZone($timezone)))->format('Y-m-d H:i:00');

            $languageFilter = $language_id > 0 ? " AND l.language_id = $language_id" : '';

            $activeQuery = "SELECT l.*,\n                (SELECT COUNT(*) FROM tbl_league_user lu WHERE lu.league_id = l.id AND lu.status IN ('opt-in','active')) AS participants,\n                (SELECT lu.status FROM tbl_league_user lu WHERE lu.league_id = l.id AND lu.user_id = $user_id LIMIT 1) AS user_status\n                FROM tbl_league l\n                WHERE l.status = 1 $languageFilter\n                AND CONVERT_TZ('" . $toDateTime . "', '+00:00', '" . $gmt_format . "')\n                    BETWEEN CONVERT_TZ(l.start_date, '+00:00', '" . $gmt_format . "')\n                    AND CONVERT_TZ(l.end_date, '+00:00', '" . $gmt_format . "')\n                ORDER BY l.start_date DESC";
            $active = $this->db->query($activeQuery)->result_array();

            $upcomingQuery = "SELECT l.*,\n                (SELECT COUNT(*) FROM tbl_league_user lu WHERE lu.league_id = l.id AND lu.status = 'opt-in') AS participants,\n                (SELECT lu.status FROM tbl_league_user lu WHERE lu.league_id = l.id AND lu.user_id = $user_id LIMIT 1) AS user_status\n                FROM tbl_league l\n                WHERE l.status = 1 $languageFilter\n                AND CONVERT_TZ('" . $toDateTime . "', '+00:00', '" . $gmt_format . "') < CONVERT_TZ(l.start_date, '+00:00', '" . $gmt_format . "')\n                ORDER BY l.start_date ASC";
            $upcoming = $this->db->query($upcomingQuery)->result_array();

            $pastQuery = "SELECT l.*,\n                (SELECT COUNT(*) FROM tbl_league_user lu WHERE lu.league_id = l.id AND lu.status IN ('opt-in','active')) AS participants,\n                (SELECT lu.status FROM tbl_league_user lu WHERE lu.league_id = l.id AND lu.user_id = $user_id LIMIT 1) AS user_status\n                FROM tbl_league l\n                INNER JOIN tbl_league_user lu_self ON lu_self.league_id = l.id AND lu_self.user_id = $user_id\n                WHERE l.status = 1 $languageFilter\n                AND CONVERT_TZ('" . $toDateTime . "', '+00:00', '" . $gmt_format . "') > CONVERT_TZ(l.end_date, '+00:00', '" . $gmt_format . "')\n                ORDER BY l.end_date DESC";
            $past = $this->db->query($pastQuery)->result_array();

            foreach ($active as &$row) {
                $row['start_date'] = date('d-M H:i', strtotime($row['start_date']));
                $row['end_date'] = date('d-M H:i', strtotime($row['end_date']));
                $row['image'] = !empty($row['image']) ? (base_url() . LEAGUE_IMG_PATH . $row['image']) : '';
            }
            foreach ($upcoming as &$row) {
                $row['start_date'] = date('d-M H:i', strtotime($row['start_date']));
                $row['end_date'] = date('d-M H:i', strtotime($row['end_date']));
                $row['image'] = !empty($row['image']) ? (base_url() . LEAGUE_IMG_PATH . $row['image']) : '';
            }
            foreach ($past as &$row) {
                $row['start_date'] = date('d-M', strtotime($row['start_date']));
                $row['end_date'] = date('d-M', strtotime($row['end_date']));
                $row['image'] = !empty($row['image']) ? (base_url() . LEAGUE_IMG_PATH . $row['image']) : '';
            }

            $response['active_leagues'] = [
                'error' => empty($active),
                'message' => empty($active) ? 'No active leagues found' : 'Active leagues fetched',
                'data' => $active
            ];
            $response['upcoming_leagues'] = [
                'error' => empty($upcoming),
                'message' => empty($upcoming) ? 'No upcoming leagues found' : 'Upcoming leagues fetched',
                'data' => $upcoming
            ];
            $response['past_leagues'] = [
                'error' => empty($past),
                'message' => empty($past) ? 'No past leagues found' : 'Past leagues fetched',
                'data' => $past
            ];
        } catch (Exception $e) {
            $response['active_leagues'] = ['error' => true, 'message' => 'Failed to fetch active leagues', 'data' => []];
            $response['upcoming_leagues'] = ['error' => true, 'message' => 'Failed to fetch upcoming leagues', 'data' => []];
            $response['past_leagues'] = ['error' => true, 'message' => 'Failed to fetch past leagues', 'data' => []];
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    /**
     * Free opt-in to an upcoming league. Coins are charged later at league start.
     */
    public function opt_in_league_post()
    {
        try {
            $is_user = $this->verify_token();
            if ($is_user['error']) {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            $user_id = (int)$is_user['user_id'];
            $league_id = $this->post('league_id') && is_numeric($this->post('league_id')) ? (int)$this->post('league_id') : 0;
            $device_token = $this->post('device_token') ? trim($this->post('device_token')) : null;

            if ($league_id <= 0) {
                $response['error'] = true;
                $response['message'] = 'League id is required';
                $this->response($response, REST_Controller::HTTP_OK);
                return;
            }

            $league = $this->db->where('id', $league_id)->where('status', 1)->get('tbl_league')->row_array();
            if (empty($league)) {
                $response['error'] = true;
                $response['message'] = 'League not found';
                $this->response($response, REST_Controller::HTTP_OK);
                return;
            }

            $now = date('Y-m-d H:i:s');
            if (strtotime($league['start_date']) <= strtotime($now)) {
                $response['error'] = true;
                $response['message'] = 'League already started. Join directly from live leagues.';
                $this->response($response, REST_Controller::HTTP_OK);
                return;
            }

            $existing = $this->db->where('league_id', $league_id)->where('user_id', $user_id)->get('tbl_league_user')->row_array();
            if (!empty($existing)) {
                $response['error'] = false;
                $response['message'] = 'Already opted in';
                $response['data'] = [
                    'league_id' => $league_id,
                    'status' => $existing['status']
                ];
                $this->response($response, REST_Controller::HTTP_OK);
                return;
            }

            $insert = [
                'league_id' => $league_id,
                'user_id' => $user_id,
                'status' => 'opt-in',
                'opted_in_at' => $now,
                'device_token' => $device_token,
                'notifications_enabled' => 1,
                'date_created' => $now,
            ];

            $this->db->insert('tbl_league_user', $insert);

            $response['error'] = false;
            $response['message'] = 'Opt-in successful';
            $response['data'] = [
                'league_id' => $league_id,
                'status' => 'opt-in'
            ];
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = 'Failed to opt in league';
            $response['error_msg'] = $e->getMessage();
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    /**
     * Join a live league (deduct coins once) and activate user participation.
     */
    public function join_league_post()
    {
        try {
            $is_user = $this->verify_token();
            if ($is_user['error']) {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            $user_id = (int)$is_user['user_id'];
            $league_id = $this->post('league_id') && is_numeric($this->post('league_id')) ? (int)$this->post('league_id') : 0;

            if ($league_id <= 0) {
                $response['error'] = true;
                $response['message'] = 'League id is required';
                $this->response($response, REST_Controller::HTTP_OK);
                return;
            }

            $league = $this->db->where('id', $league_id)->where('status', 1)->get('tbl_league')->row_array();
            if (empty($league)) {
                $response['error'] = true;
                $response['message'] = 'League not found';
                $this->response($response, REST_Controller::HTTP_OK);
                return;
            }

            $existing = $this->db->where('league_id', $league_id)->where('user_id', $user_id)->get('tbl_league_user')->row_array();
            if (!empty($existing) && $existing['status'] === 'active') {
                $response['error'] = false;
                $response['message'] = 'Already joined';
                $this->response($response, REST_Controller::HTTP_OK);
                return;
            }

            $user = $this->db->where('id', $user_id)->get('tbl_users')->row_array();
            $available_coins = isset($user['coins']) ? (int)$user['coins'] : 0;
            $entry = (int)$league['entry'];

            if ($available_coins < $entry) {
                $response['error'] = true;
                $response['message'] = 'Insufficient coins';
                $response['data'] = [
                    'required' => $entry,
                    'available' => $available_coins,
                ];
                $this->response($response, REST_Controller::HTTP_OK);
                return;
            }

            $this->db->trans_start();

            $updatedCoins = $available_coins - $entry;
            $this->db->where('id', $user_id)->update('tbl_users', ['coins' => $updatedCoins]);

            $now = date('Y-m-d H:i:s');
            if (!empty($existing)) {
                $this->db->where('league_id', $league_id)->where('user_id', $user_id)->update('tbl_league_user', [
                    'status' => 'active',
                    'joined_at' => $now,
                    'coins_paid' => $entry,
                ]);
            } else {
                $this->db->insert('tbl_league_user', [
                    'league_id' => $league_id,
                    'user_id' => $user_id,
                    'status' => 'active',
                    'opted_in_at' => null,
                    'joined_at' => $now,
                    'coins_paid' => $entry,
                    'notifications_enabled' => 1,
                    'date_created' => $now,
                ]);
            }

            $lb = $this->db->where('league_id', $league_id)->where('user_id', $user_id)->get('tbl_league_leaderboard')->row_array();
            if (empty($lb)) {
                $this->db->insert('tbl_league_leaderboard', [
                    'league_id' => $league_id,
                    'user_id' => $user_id,
                    'cumulative_best_score' => 0,
                    'games_played' => 0,
                    'date_created' => $now,
                ]);
            }

            $this->db->trans_complete();

            if ($this->db->trans_status() === false) {
                $response['error'] = true;
                $response['message'] = 'Failed to join league';
                $this->response($response, REST_Controller::HTTP_OK);
                return;
            }

            $response['error'] = false;
            $response['message'] = 'League joined successfully';
            $response['data'] = [
                'league_id' => $league_id,
                'coins_deducted' => $entry,
                'coins_remaining' => $updatedCoins,
            ];
        } catch (Exception $e) {
            $this->db->trans_rollback();
            $response['error'] = true;
            $response['message'] = 'Failed to join league';
            $response['error_msg'] = $e->getMessage();
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    /**
     * Fetch current day quiz for a joined league.
     */
    public function get_league_daily_quiz_post()
    {
        try {
            $is_user = $this->verify_token();
            if ($is_user['error']) {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            $user_id = (int)$is_user['user_id'];
            $league_id = $this->post('league_id') && is_numeric($this->post('league_id')) ? (int)$this->post('league_id') : 0;

            if ($league_id <= 0) {
                $response['error'] = true;
                $response['message'] = 'League id is required';
                $this->response($response, REST_Controller::HTTP_OK);
                return;
            }

            $leagueUser = $this->db->where('league_id', $league_id)->where('user_id', $user_id)->where('status', 'active')->get('tbl_league_user')->row_array();
            if (empty($leagueUser)) {
                $response['error'] = true;
                $response['message'] = 'User is not active in this league';
                $this->response($response, REST_Controller::HTTP_OK);
                return;
            }

            $league = $this->db->where('id', $league_id)->where('status', 1)->get('tbl_league')->row_array();
            if (empty($league)) {
                $response['error'] = true;
                $response['message'] = 'League not found';
                $this->response($response, REST_Controller::HTTP_OK);
                return;
            }

            $today = date('Y-m-d');
            $start = date('Y-m-d', strtotime($league['start_date']));
            $dayDiff = floor((strtotime($today) - strtotime($start)) / 86400);
            $quizDay = (int)$dayDiff + 1;
            if ($quizDay < 1) {
                $response['error'] = true;
                $response['message'] = 'League has not started yet';
                $this->response($response, REST_Controller::HTTP_OK);
                return;
            }

            $dailyQuiz = $this->db->where('league_id', $league_id)->where('quiz_day', $quizDay)->get('tbl_league_daily_quiz')->row_array();
            if (empty($dailyQuiz)) {
                $response['error'] = true;
                $response['message'] = 'Daily quiz not configured for today';
                $this->response($response, REST_Controller::HTTP_OK);
                return;
            }

            $playsToday = $this->db->where('league_id', $league_id)->where('user_id', $user_id)->where('quiz_day', $quizDay)->get('tbl_league_submission')->num_rows();
            $playsRemaining = max(0, 5 - $playsToday);

            if ($playsRemaining <= 0) {
                $response['error'] = true;
                $response['message'] = 'Daily play limit reached';
                $this->response($response, REST_Controller::HTTP_OK);
                return;
            }

            $questionQuery = "SELECT q.* FROM tbl_league_daily_quiz_questions lq\n                INNER JOIN tbl_contest_question q ON q.id = lq.question_id\n                WHERE lq.daily_quiz_id = " . (int)$dailyQuiz['id'] . "\n                ORDER BY lq.question_order ASC";
            $questions = $this->db->query($questionQuery)->result_array();

            $adAlreadyShown = $this->db->where('league_id', $league_id)
                ->where('user_id', $user_id)
                ->where('quiz_day', $quizDay)
                ->where('ad_shown', 1)
                ->get('tbl_league_submission')
                ->num_rows() > 0;

            $response['error'] = false;
            $response['message'] = 'Daily quiz fetched';
            $response['data'] = [
                'league_id' => $league_id,
                'league_day' => $quizDay,
                'daily_quiz_id' => (int)$dailyQuiz['id'],
                'plays_today' => $playsToday,
                'plays_remaining' => $playsRemaining,
                'show_ad' => !$adAlreadyShown,
                'questions' => $questions,
            ];
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = 'Failed to fetch daily quiz';
            $response['error_msg'] = $e->getMessage();
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    /**
     * Submit league quiz score and update cumulative leaderboard.
     */
    public function submit_league_quiz_post()
    {
        try {
            $is_user = $this->verify_token();
            if ($is_user['error']) {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            $user_id = (int)$is_user['user_id'];
            $league_id = $this->post('league_id') && is_numeric($this->post('league_id')) ? (int)$this->post('league_id') : 0;
            $daily_quiz_id = $this->post('daily_quiz_id') && is_numeric($this->post('daily_quiz_id')) ? (int)$this->post('daily_quiz_id') : 0;
            $correct_answers = $this->post('correct_answers') && is_numeric($this->post('correct_answers')) ? (int)$this->post('correct_answers') : 0;
            $total_questions = $this->post('total_questions') && is_numeric($this->post('total_questions')) ? (int)$this->post('total_questions') : 0;
            $ad_shown = $this->post('ad_shown') && is_numeric($this->post('ad_shown')) ? (int)$this->post('ad_shown') : 0;

            if ($league_id <= 0 || $daily_quiz_id <= 0 || $total_questions <= 0) {
                $response['error'] = true;
                $response['message'] = 'Required parameters are missing';
                $this->response($response, REST_Controller::HTTP_OK);
                return;
            }

            $dailyQuiz = $this->db->where('id', $daily_quiz_id)->where('league_id', $league_id)->get('tbl_league_daily_quiz')->row_array();
            if (empty($dailyQuiz)) {
                $response['error'] = true;
                $response['message'] = 'Invalid daily quiz';
                $this->response($response, REST_Controller::HTTP_OK);
                return;
            }

            $quizDay = (int)$dailyQuiz['quiz_day'];
            $playsToday = $this->db->where('league_id', $league_id)->where('user_id', $user_id)->where('quiz_day', $quizDay)->get('tbl_league_submission')->num_rows();
            if ($playsToday >= 5) {
                $response['error'] = true;
                $response['message'] = 'Daily play limit reached';
                $this->response($response, REST_Controller::HTTP_OK);
                return;
            }

            $wrong_answers = max(0, $total_questions - $correct_answers);
            $score = ($correct_answers * 8) - ($wrong_answers * 8);
            $todayDate = date('Y-m-d');
            $now = date('Y-m-d H:i:s');

            $this->db->trans_start();

            $this->db->insert('tbl_league_submission', [
                'league_id' => $league_id,
                'user_id' => $user_id,
                'daily_quiz_id' => $daily_quiz_id,
                'quiz_day' => $quizDay,
                'score' => $score,
                'correct_answers' => $correct_answers,
                'wrong_answers' => $wrong_answers,
                'total_questions' => $total_questions,
                'ad_shown' => $ad_shown > 0 ? 1 : 0,
                'submission_date' => $todayDate,
                'submitted_at' => $now,
                'date_created' => $now,
            ]);

            $dailyBestRows = $this->db->query("SELECT quiz_day, MAX(score) as best_score FROM tbl_league_submission WHERE league_id = $league_id AND user_id = $user_id GROUP BY quiz_day")->result_array();
            $cumulative = 0;
            $dailyBest = [];
            foreach ($dailyBestRows as $row) {
                $best = (float)$row['best_score'];
                $day = (int)$row['quiz_day'];
                $cumulative += $best;
                $dailyBest[] = ['day' => $day, 'score' => $best];
            }

            $gamesPlayed = count($dailyBest);
            $lb = $this->db->where('league_id', $league_id)->where('user_id', $user_id)->get('tbl_league_leaderboard')->row_array();
            if (empty($lb)) {
                $this->db->insert('tbl_league_leaderboard', [
                    'league_id' => $league_id,
                    'user_id' => $user_id,
                    'cumulative_best_score' => $cumulative,
                    'daily_best_scores' => json_encode($dailyBest),
                    'games_played' => $gamesPlayed,
                    'last_updated' => $now,
                    'date_created' => $now,
                ]);
            } else {
                $this->db->where('league_id', $league_id)->where('user_id', $user_id)->update('tbl_league_leaderboard', [
                    'cumulative_best_score' => $cumulative,
                    'daily_best_scores' => json_encode($dailyBest),
                    'games_played' => $gamesPlayed,
                    'last_updated' => $now,
                ]);
            }

            $rankQuery = "SELECT rank FROM (SELECT user_id, ROW_NUMBER() OVER (ORDER BY cumulative_best_score DESC, last_updated ASC) AS rank FROM tbl_league_leaderboard WHERE league_id = $league_id) t WHERE t.user_id = $user_id";
            $rankRow = $this->db->query($rankQuery)->row_array();
            $userRank = !empty($rankRow) ? (int)$rankRow['rank'] : 0;

            $this->db->trans_complete();
            if ($this->db->trans_status() === false) {
                $response['error'] = true;
                $response['message'] = 'Failed to submit league quiz';
                $this->response($response, REST_Controller::HTTP_OK);
                return;
            }

            $response['error'] = false;
            $response['message'] = 'League quiz submitted';
            $response['data'] = [
                'score' => $score,
                'correct_answers' => $correct_answers,
                'wrong_answers' => $wrong_answers,
                'cumulative_score' => $cumulative,
                'user_rank' => $userRank,
                'games_played' => $gamesPlayed,
                'plays_remaining' => max(0, 5 - ($playsToday + 1)),
            ];
        } catch (Exception $e) {
            $this->db->trans_rollback();
            $response['error'] = true;
            $response['message'] = 'Failed to submit league quiz';
            $response['error_msg'] = $e->getMessage();
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    /**
     * Fetch paginated league leaderboard with top-3 summary.
     */
    public function get_league_leaderboard_post()
    {
        try {
            $is_user = $this->verify_token();
            if ($is_user['error']) {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            $user_id = (int)$is_user['user_id'];
            $league_id = $this->post('league_id') && is_numeric($this->post('league_id')) ? (int)$this->post('league_id') : 0;
            $limit = $this->post('limit') && is_numeric($this->post('limit')) ? (int)$this->post('limit') : 15;
            $offset = $this->post('offset') && is_numeric($this->post('offset')) ? (int)$this->post('offset') : 0;

            if ($league_id <= 0) {
                $response['error'] = true;
                $response['message'] = 'League id is required';
                $this->response($response, REST_Controller::HTTP_OK);
                return;
            }

            $baseSelect = "SELECT ll.user_id, ll.cumulative_best_score as score, ll.last_updated, u.name, u.profile,\n                ROW_NUMBER() OVER (ORDER BY ll.cumulative_best_score DESC, ll.last_updated ASC) AS user_rank\n                FROM tbl_league_leaderboard ll\n                INNER JOIN tbl_users u ON u.id = ll.user_id\n                WHERE ll.league_id = $league_id";

            $topThree = $this->db->query("SELECT * FROM (" . $baseSelect . ") x ORDER BY x.user_rank ASC LIMIT 3")->result_array();
            $rows = $this->db->query("SELECT * FROM (" . $baseSelect . ") x ORDER BY x.user_rank ASC LIMIT $offset, $limit")->result_array();
            $totalRow = $this->db->query("SELECT COUNT(*) as total FROM tbl_league_leaderboard WHERE league_id = $league_id")->row_array();
            $total = !empty($totalRow) ? (int)$totalRow['total'] : 0;

            $userRank = $this->db->query("SELECT user_rank, score FROM (" . $baseSelect . ") x WHERE x.user_id = $user_id LIMIT 1")->row_array();

            $response['error'] = false;
            $response['message'] = 'League leaderboard fetched';
            $response['data'] = [
                'top_three' => $topThree,
                'leaderboard' => $rows,
                'user_rank' => !empty($userRank) ? (int)$userRank['user_rank'] : null,
                'user_score' => !empty($userRank) ? (float)$userRank['score'] : 0,
                'total' => $total,
            ];
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = 'Failed to fetch league leaderboard';
            $response['error_msg'] = $e->getMessage();
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    /**
     * Update league notification preference for the authenticated user.
     */
    public function update_league_notification_preference_post()
    {
        try {
            $is_user = $this->verify_token();
            if ($is_user['error']) {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            $user_id = (int)$is_user['user_id'];
            $league_id = $this->post('league_id') && is_numeric($this->post('league_id')) ? (int)$this->post('league_id') : 0;
            $notifications_enabled = $this->post('notifications_enabled');
            $device_token = $this->post('device_token') ? trim($this->post('device_token')) : null;

            if ($league_id <= 0) {
                $response['error'] = true;
                $response['message'] = 'League id is required';
                $this->response($response, REST_Controller::HTTP_OK);
                return;
            }

            if ($notifications_enabled === null || !is_numeric($notifications_enabled)) {
                $response['error'] = true;
                $response['message'] = 'notifications_enabled must be 0 or 1';
                $this->response($response, REST_Controller::HTTP_OK);
                return;
            }

            $notifications_enabled = ((int)$notifications_enabled > 0) ? 1 : 0;
            $league_user = $this->db->where('league_id', $league_id)->where('user_id', $user_id)->get('tbl_league_user')->row_array();

            if (empty($league_user)) {
                $response['error'] = true;
                $response['message'] = 'League participation not found for user';
                $this->response($response, REST_Controller::HTTP_OK);
                return;
            }

            $update = [
                'notifications_enabled' => $notifications_enabled,
            ];
            if (!empty($device_token)) {
                $update['device_token'] = $device_token;
            }

            $this->db->where('league_id', $league_id)->where('user_id', $user_id)->update('tbl_league_user', $update);

            $response['error'] = false;
            $response['message'] = 'League notification preference updated';
            $response['data'] = [
                'league_id' => $league_id,
                'notifications_enabled' => $notifications_enabled,
            ];
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = 'Failed to update league notification preference';
            $response['error_msg'] = $e->getMessage();
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    /**
     * GET /api/blog/posts
     * Get all blog posts with pagination and filters
     */
    public function blog_posts_get()
    {
        try {
            $this->load->model('Blog_model');

            // Get request parameters
            $page = $this->input->get('page', TRUE) ?: 1;
            $limit = $this->input->get('limit', TRUE) ?: 10;
            $search = $this->input->get('search', TRUE) ?: '';
            $category = $this->input->get('category', TRUE) ?: '';
            $sort = $this->input->get('sort', TRUE) ?: 'created_at';
            $order = $this->input->get('order', TRUE) ?: 'DESC';

            // Validate sort and order
            $allowed_sorts = ['created_at', 'title', 'views', 'updated_at'];
            $sort = in_array($sort, $allowed_sorts) ? $sort : 'created_at';
            $order = strtoupper($order) === 'ASC' ? 'ASC' : 'DESC';

            // Get posts
            $result = $this->Blog_model->get_posts($page, $limit, $category, $search, $sort, $order);

            // Format posts
            $formatted_posts = array_map(function ($post) {
                return $this->Blog_model->format_post($post);
            }, $result['posts']);

            $response['error'] = false;
            $response['message'] = 'Blog posts retrieved successfully';
            $response['data'] = [
                'posts' => $formatted_posts,
                'pagination' => [
                    'current_page' => (int) $result['page'],
                    'total_pages' => (int) $result['pages'],
                    'total_posts' => (int) $result['total'],
                    'per_page' => (int) $result['limit'],
                    'has_next' => $result['page'] < $result['pages'],
                    'has_prev' => $result['page'] > 1
                ]
            ];
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = 'Failed to retrieve blog posts: ' . $e->getMessage();
            $response['data'] = [];
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    /**
     * GET /api/blog/post/{slug}
     * Get single blog post by slug
     */
    public function blog_post_get()
    {
        try {
            $this->load->model('Blog_model');

            $slug = $this->uri->segment(4); // Get slug from URL

            if (empty($slug)) {
                $response['error'] = true;
                $response['message'] = 'Post slug is required';
                $response['data'] = [];
                $this->response($response, REST_Controller::HTTP_OK);
                return;
            }

            // Get post
            $post = $this->Blog_model->get_post_by_slug($slug);

            if (empty($post)) {
                $response['error'] = true;
                $response['message'] = 'Post not found';
                $response['data'] = [];
                $this->response($response, REST_Controller::HTTP_OK);
                return;
            }

            // Increment view count
            $this->Blog_model->increment_views($post['id']);

            // Update post with new view count
            $post['views'] = $this->Blog_model->get_post_views($post['id']);

            $response['error'] = false;
            $response['message'] = 'Blog post retrieved successfully';
            $response['data'] = [
                'post' => $this->Blog_model->format_post($post)
            ];
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = 'Failed to retrieve blog post: ' . $e->getMessage();
            $response['data'] = [];
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    /**
     * GET /api/blog/categories
     * Get all blog categories with post counts
     */
    public function blog_categories_get()
    {
        try {
            $this->load->model('Blog_model');

            // Get categories
            $categories = $this->Blog_model->get_categories();

            // Format categories
            $formatted_categories = array_map(function ($category) {
                return $this->Blog_model->format_category($category);
            }, $categories);

            $response['error'] = false;
            $response['message'] = 'Blog categories retrieved successfully';
            $response['data'] = [
                'categories' => $formatted_categories
            ];
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = 'Failed to retrieve blog categories: ' . $e->getMessage();
            $response['data'] = [];
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    /**
     * GET /api/blog/featured
     * Get featured blog posts
     */
    public function blog_featured_get()
    {
        try {
            $this->load->model('Blog_model');

            $limit = $this->input->get('limit', TRUE) ?: 5;
            $limit = (int) $limit;

            // Get featured posts
            $posts = $this->Blog_model->get_featured_posts($limit);

            // Format posts
            $formatted_posts = array_map(function ($post) {
                return $this->Blog_model->format_post($post);
            }, $posts);

            $response['error'] = false;
            $response['message'] = 'Featured blog posts retrieved successfully';
            $response['data'] = [
                'posts' => $formatted_posts,
                'pagination' => [
                    'current_page' => 1,
                    'total_pages' => 1,
                    'total_posts' => count($posts),
                    'per_page' => $limit,
                    'has_next' => false,
                    'has_prev' => false
                ]
            ];
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = 'Failed to retrieve featured posts: ' . $e->getMessage();
            $response['data'] = [];
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    /**
     * GET /api/blog/related/{id}
     * Get related blog posts by post ID
     */
    public function blog_related_get()
    {
        try {
            $this->load->model('Blog_model');

            $post_id = $this->uri->segment(4); // Get post ID from URL
            $limit = $this->input->get('limit', TRUE) ?: 4;
            $limit = (int) $limit;
            $post_id = (int) $post_id;

            if (empty($post_id)) {
                $response['error'] = true;
                $response['message'] = 'Post ID is required';
                $response['data'] = [];
                $this->response($response, REST_Controller::HTTP_OK);
                return;
            }

            // Get the original post to get its category
            $post = $this->Blog_model->get_post_by_id($post_id);

            if (empty($post)) {
                $response['error'] = true;
                $response['message'] = 'Post not found';
                $response['data'] = [];
                $this->response($response, REST_Controller::HTTP_OK);
                return;
            }

            // Get related posts
            $posts = $this->Blog_model->get_related_posts($post_id, $post['category_id'], $limit);

            // Format posts
            $formatted_posts = array_map(function ($p) {
                return $this->Blog_model->format_post($p);
            }, $posts);

            $response['error'] = false;
            $response['message'] = 'Related blog posts retrieved successfully';
            $response['data'] = [
                'posts' => $formatted_posts,
                'pagination' => [
                    'current_page' => 1,
                    'total_pages' => 1,
                    'total_posts' => count($posts),
                    'per_page' => $limit,
                    'has_next' => false,
                    'has_prev' => false
                ]
            ];
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = 'Failed to retrieve related posts: ' . $e->getMessage();
            $response['data'] = [];
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    /**
     * POST /api/blog/post/{id}/view
     * Increment post view count
     */
    public function blog_view_post()
    {
        try {
            $this->load->model('Blog_model');

            $post_id = $this->uri->segment(4); // Get post ID from URL
            $post_id = (int) $post_id;

            if (empty($post_id)) {
                $response['error'] = true;
                $response['message'] = 'Post ID is required';
                $response['data'] = [];
                $this->response($response, REST_Controller::HTTP_OK);
                return;
            }

            // Increment views
            $views = $this->Blog_model->increment_views($post_id);

            $response['error'] = false;
            $response['message'] = 'View count updated successfully';
            $response['data'] = [
                'views' => (int) $views
            ];
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = 'Failed to update view count: ' . $e->getMessage();
            $response['data'] = [];
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    // ========================================
    // ENGAGEMENT TIME TRACKING ENDPOINTS
    // ========================================

    /**
     * Submit user session duration
     * POST /Api/submit_session_duration
     * 
     * @param string access_token User's API token
     * @param string session_start Session start datetime (Y-m-d H:i:s)
     * @param string session_end Session end datetime (Y-m-d H:i:s)
     * @param int duration_seconds Session duration in seconds
     */
    public function submit_session_duration_post()
    {
        try {
            $is_user = $this->verify_token();
            if (!$is_user['error']) {
                $user_id = $is_user['user_id'];
            } else {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            $session_start = $this->post('session_start');
            $session_end = $this->post('session_end');
            $duration_seconds = (int) $this->post('duration_seconds');

            // Validation
            if (empty($session_start) || empty($session_end) || $duration_seconds <= 0) {
                $response['error'] = true;
                $response['message'] = 'Invalid session data';
                $this->response($response, REST_Controller::HTTP_OK);
                return;
            }

            // Prevent fraud: max 12 hours per session
            if ($duration_seconds > 43200) {
                $response['error'] = true;
                $response['message'] = 'Session duration exceeds maximum limit';
                $this->response($response, REST_Controller::HTTP_OK);
                return;
            }

            // Insert session record
            $session_data = array(
                'user_id' => $user_id,
                'session_start' => $session_start,
                'session_end' => $session_end,
                'duration_seconds' => $duration_seconds,
                'date_created' => date('Y-m-d', strtotime($session_end))
            );
            $this->db->insert('tbl_user_engagement', $session_data);

            // Update engagement leaderboards
            $this->update_engagement_leaderboards($user_id, $duration_seconds, $session_end);

            $response['error'] = false;
            $response['message'] = 'Session recorded successfully';
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = 'Failed to record session';
            $response['error_msg'] = $e->getMessage();
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    /**
     * Update user location manually
     * POST /Api/update_user_location
     * 
     * @param string access_token User's API token
     * @param string country_code ISO 3166-1 alpha-2 country code
     */
    public function update_user_location_post()
    {
        try {
            $is_user = $this->verify_token();
            if (!$is_user['error']) {
                $user_id = $is_user['user_id'];
            } else {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            $country_code = strtoupper($this->post('country_code'));

            if (empty($country_code)) {
                $response['error'] = true;
                $response['message'] = 'Country code is required';
                $this->response($response, REST_Controller::HTTP_OK);
                return;
            }

            // Validate country code and get info
            $this->load->library('Geolocation');
            $country_info = $this->geolocation->getCountryInfo($country_code);

            if (!$country_info) {
                $response['error'] = true;
                $response['message'] = 'Invalid country code';
                $this->response($response, REST_Controller::HTTP_OK);
                return;
            }

            // Update user location
            $update_data = array(
                'country_code' => $country_info->country_code,
                'country_name' => $country_info->country_name,
                'continent' => $country_info->continent,
                'region_auto_detected' => 0
            );

            $this->db->where('id', $user_id)->update('tbl_users', $update_data);

            $response['error'] = false;
            $response['message'] = 'Location updated successfully';
            $response['data'] = $update_data;
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = 'Failed to update location';
            $response['error_msg'] = $e->getMessage();
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    /**
     * Get weekly engagement leaderboard
     * POST /Api/get_weekly_engagement_leaderboard
     */
    public function get_weekly_engagement_leaderboard_post()
    {
        try {
            $is_user = $this->verify_token();
            if (!$is_user['error']) {
                $user_id = $is_user['user_id'];
            } else {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            $offset = ($this->post('offset')) ? $this->post('offset') : 0;
            $limit = ($this->post('limit')) ? $this->post('limit') : 25;
            $scope = ($this->post('scope')) ? $this->post('scope') : 'world';
            $filter_value = $this->post('filter_value');

            $week_number = date('W');
            $year = date('Y');

            // Build scope filter
            $scope_where = '';
            if ($scope === 'country' && !empty($filter_value)) {
                $scope_where = "AND u.country_code = '{$filter_value}'";
            } elseif ($scope === 'region' && !empty($filter_value)) {
                $scope_where = "AND u.continent = '{$filter_value}'";
            }

            $sub_query = "(SELECT s.*, @user_rank := @user_rank + 1 AS user_rank FROM (SELECT e.id, e.user_id, u.email, u.name, u.profile, u.country_code, u.continent, e.total_minutes, e.last_updated FROM tbl_leaderboard_engagement_weekly e JOIN tbl_users u ON u.id = e.user_id WHERE u.status = 1 AND e.week_number = {$week_number} AND e.year = {$year} {$scope_where} GROUP BY e.user_id) s, (SELECT @user_rank := 0) init ORDER BY s.total_minutes DESC, s.last_updated ASC)";

            $this->db->select('r.*');
            $this->db->from("$sub_query r", false);

            $total = $this->db->count_all_results('', false);
            $this->db->order_by('r.user_rank', 'ASC');
            if ($limit) {
                $this->db->limit($limit, $offset);
            }

            $result = $this->db->get();
            $data = $result->result_array();

            $fallback_data = null;
            if (count($data) < 3) {
                $fallback_data = $this->getEngagementLeaderboardFromSessions(
                    $user_id,
                    'weekly',
                    $scope,
                    $filter_value,
                    $offset,
                    $limit
                );
                if (!empty($fallback_data['data']) && count($fallback_data['data']) > count($data)) {
                    $data = $fallback_data['data'];
                    $total = $fallback_data['total'];
                } else {
                    $fallback_data = null;
                }
            }

            if (!empty($data)) {
                for ($i = 0; $i < count($data); $i++) {
                    if (filter_var($data[$i]['profile'], FILTER_VALIDATE_URL) === false) {
                        $data[$i]['profile'] = ($data[$i]['profile']) ? base_url() . USER_IMG_PATH . $data[$i]['profile'] : '';
                    }
                }

                if ($fallback_data) {
                    $topThreeUsersData = $fallback_data['top_three_ranks'] ?? array();
                    $user_rank = $fallback_data['my_rank'] ?? array();
                } else {
                    // Get top 3
                    $this->db->reset_query();
                    $this->db->from("($sub_query) r");
                    $this->db->select('r.*');
                    $this->db->order_by('r.user_rank', 'ASC');
                    $this->db->limit(3);
                    $top_three_result = $this->db->get();
                    $topThreeUsersData = $top_three_result->result_array();

                    for ($i = 0; $i < count($topThreeUsersData); $i++) {
                        if (filter_var($topThreeUsersData[$i]['profile'], FILTER_VALIDATE_URL) === false) {
                            $topThreeUsersData[$i]['profile'] = ($topThreeUsersData[$i]['profile']) ? base_url() . USER_IMG_PATH . $topThreeUsersData[$i]['profile'] : '';
                        }
                    }

                    // Get user's rank
                    $my_rank = $this->myEngagementRank($user_id, 'weekly', $scope, $filter_value);
                    if (!empty($my_rank)) {
                        if (filter_var($my_rank['profile'], FILTER_VALIDATE_URL) === false) {
                            $my_rank['profile'] = (!empty($my_rank['profile'])) ? base_url() . USER_IMG_PATH . $my_rank['profile'] : '';
                        }
                        $user_rank = $my_rank;
                    } else {
                        $user_rank = array(
                            'user_id' => $user_id,
                            'total_minutes' => '0',
                            'user_rank' => '0',
                            'email' => '',
                            'name' => '',
                            'profile' => '',
                        );
                    }
                }

                $response['error'] = false;
                $response['total'] = "$total";
                $response['data'] = array(
                    'my_rank' => $user_rank,
                    'other_users_rank' => $data,
                    'top_three_ranks' => $topThreeUsersData ?? array()
                );
            } else {
                $response['error'] = false;
                $response['total'] = "0";
                $response['data'] = array(
                    'my_rank' => array(
                        'user_id' => $user_id,
                        'total_minutes' => '0',
                        'user_rank' => '0',
                        'email' => '',
                        'name' => '',
                        'profile' => '',
                    ),
                    'other_users_rank' => array(),
                    'top_three_ranks' => array()
                );
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = 'Failed to fetch leaderboard';
            $response['error_msg'] = $e->getMessage();
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    /**
     * Get monthly engagement leaderboard
     * POST /Api/get_monthly_engagement_leaderboard
     */
    public function get_monthly_engagement_leaderboard_post()
    {
        try {
            $is_user = $this->verify_token();
            if (!$is_user['error']) {
                $user_id = $is_user['user_id'];
            } else {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            $offset = ($this->post('offset')) ? $this->post('offset') : 0;
            $limit = ($this->post('limit')) ? $this->post('limit') : 25;
            $scope = ($this->post('scope')) ? $this->post('scope') : 'world';
            $filter_value = $this->post('filter_value');

            $month = date('m');
            $year = date('Y');

            // Build scope filter
            $scope_where = '';
            if ($scope === 'country' && !empty($filter_value)) {
                $scope_where = "AND u.country_code = '{$filter_value}'";
            } elseif ($scope === 'region' && !empty($filter_value)) {
                $scope_where = "AND u.continent = '{$filter_value}'";
            }

            $sub_query = "(SELECT s.*, @user_rank := @user_rank + 1 AS user_rank FROM (SELECT e.id, e.user_id, u.email, u.name, u.profile, u.country_code, u.continent, e.total_minutes, e.last_updated FROM tbl_leaderboard_engagement_monthly e JOIN tbl_users u ON u.id = e.user_id WHERE u.status = 1 AND e.month = {$month} AND e.year = {$year} {$scope_where} GROUP BY e.user_id) s, (SELECT @user_rank := 0) init ORDER BY s.total_minutes DESC, s.last_updated ASC)";

            $this->db->select('r.*');
            $this->db->from("$sub_query r", false);

            $total = $this->db->count_all_results('', false);
            $this->db->order_by('r.user_rank', 'ASC');
            if ($limit) {
                $this->db->limit($limit, $offset);
            }

            $result = $this->db->get();
            $data = $result->result_array();

            $fallback_data = null;
            if (count($data) < 3) {
                $fallback_data = $this->getEngagementLeaderboardFromSessions(
                    $user_id,
                    'monthly',
                    $scope,
                    $filter_value,
                    $offset,
                    $limit
                );
                if (!empty($fallback_data['data']) && count($fallback_data['data']) > count($data)) {
                    $data = $fallback_data['data'];
                    $total = $fallback_data['total'];
                } else {
                    $fallback_data = null;
                }
            }

            if (!empty($data)) {
                for ($i = 0; $i < count($data); $i++) {
                    if (filter_var($data[$i]['profile'], FILTER_VALIDATE_URL) === false) {
                        $data[$i]['profile'] = ($data[$i]['profile']) ? base_url() . USER_IMG_PATH . $data[$i]['profile'] : '';
                    }
                }

                if ($fallback_data) {
                    $topThreeUsersData = $fallback_data['top_three_ranks'] ?? array();
                    $user_rank = $fallback_data['my_rank'] ?? array();
                } else {
                    // Get top 3
                    $this->db->reset_query();
                    $this->db->from("($sub_query) r");
                    $this->db->select('r.*');
                    $this->db->order_by('r.user_rank', 'ASC');
                    $this->db->limit(3);
                    $top_three_result = $this->db->get();
                    $topThreeUsersData = $top_three_result->result_array();

                    for ($i = 0; $i < count($topThreeUsersData); $i++) {
                        if (filter_var($topThreeUsersData[$i]['profile'], FILTER_VALIDATE_URL) === false) {
                            $topThreeUsersData[$i]['profile'] = ($topThreeUsersData[$i]['profile']) ? base_url() . USER_IMG_PATH . $topThreeUsersData[$i]['profile'] : '';
                        }
                    }

                    // Get user's rank
                    $my_rank = $this->myEngagementRank($user_id, 'monthly', $scope, $filter_value);
                    if (!empty($my_rank)) {
                        if (filter_var($my_rank['profile'], FILTER_VALIDATE_URL) === false) {
                            $my_rank['profile'] = (!empty($my_rank['profile'])) ? base_url() . USER_IMG_PATH . $my_rank['profile'] : '';
                        }
                        $user_rank = $my_rank;
                    } else {
                        $user_rank = array(
                            'user_id' => $user_id,
                            'total_minutes' => '0',
                            'user_rank' => '0',
                            'email' => '',
                            'name' => '',
                            'profile' => '',
                        );
                    }
                }

                $response['error'] = false;
                $response['total'] = "$total";
                $response['data'] = array(
                    'my_rank' => $user_rank,
                    'other_users_rank' => $data,
                    'top_three_ranks' => $topThreeUsersData ?? array()
                );
            } else {
                $response['error'] = false;
                $response['total'] = "0";
                $response['data'] = array(
                    'my_rank' => array(
                        'user_id' => $user_id,
                        'total_minutes' => '0',
                        'user_rank' => '0',
                        'email' => '',
                        'name' => '',
                        'profile' => '',
                    ),
                    'other_users_rank' => array(),
                    'top_three_ranks' => array()
                );
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = 'Failed to fetch leaderboard';
            $response['error_msg'] = $e->getMessage();
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    /**
     * Get all-time engagement leaderboard
     * POST /Api/get_alltime_engagement_leaderboard
     */
    public function get_alltime_engagement_leaderboard_post()
    {
        try {
            $is_user = $this->verify_token();
            if (!$is_user['error']) {
                $user_id = $is_user['user_id'];
            } else {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            $offset = ($this->post('offset')) ? $this->post('offset') : 0;
            $limit = ($this->post('limit')) ? $this->post('limit') : 25;
            $scope = ($this->post('scope')) ? $this->post('scope') : 'world';
            $filter_value = $this->post('filter_value');

            // Build scope filter
            $scope_where = '';
            if ($scope === 'country' && !empty($filter_value)) {
                $scope_where = "AND u.country_code = '{$filter_value}'";
            } elseif ($scope === 'region' && !empty($filter_value)) {
                $scope_where = "AND u.continent = '{$filter_value}'";
            }

            $sub_query = "(SELECT s.*, @user_rank := @user_rank + 1 AS user_rank FROM (SELECT e.id, e.user_id, u.email, u.name, u.profile, u.country_code, u.continent, e.total_minutes, e.last_updated FROM tbl_leaderboard_engagement_alltime e JOIN tbl_users u ON u.id = e.user_id WHERE u.status = 1 {$scope_where} GROUP BY e.user_id) s, (SELECT @user_rank := 0) init ORDER BY s.total_minutes DESC, s.last_updated ASC)";

            $this->db->select('r.*');
            $this->db->from("$sub_query r", false);

            $total = $this->db->count_all_results('', false);
            $this->db->order_by('r.user_rank', 'ASC');
            if ($limit) {
                $this->db->limit($limit, $offset);
            }

            $result = $this->db->get();
            $data = $result->result_array();

            $fallback_data = null;
            if (count($data) < 3) {
                $fallback_data = $this->getEngagementLeaderboardFromSessions(
                    $user_id,
                    'alltime',
                    $scope,
                    $filter_value,
                    $offset,
                    $limit
                );
                if (!empty($fallback_data['data']) && count($fallback_data['data']) > count($data)) {
                    $data = $fallback_data['data'];
                    $total = $fallback_data['total'];
                } else {
                    $fallback_data = null;
                }
            }

            if (!empty($data)) {
                for ($i = 0; $i < count($data); $i++) {
                    if (filter_var($data[$i]['profile'], FILTER_VALIDATE_URL) === false) {
                        $data[$i]['profile'] = ($data[$i]['profile']) ? base_url() . USER_IMG_PATH . $data[$i]['profile'] : '';
                    }
                }

                if ($fallback_data) {
                    $topThreeUsersData = $fallback_data['top_three_ranks'] ?? array();
                    $user_rank = $fallback_data['my_rank'] ?? array();
                } else {
                    // Get top 3
                    $this->db->reset_query();
                    $this->db->from("($sub_query) r");
                    $this->db->select('r.*');
                    $this->db->order_by('r.user_rank', 'ASC');
                    $this->db->limit(3);
                    $top_three_result = $this->db->get();
                    $topThreeUsersData = $top_three_result->result_array();

                    for ($i = 0; $i < count($topThreeUsersData); $i++) {
                        if (filter_var($topThreeUsersData[$i]['profile'], FILTER_VALIDATE_URL) === false) {
                            $topThreeUsersData[$i]['profile'] = ($topThreeUsersData[$i]['profile']) ? base_url() . USER_IMG_PATH . $topThreeUsersData[$i]['profile'] : '';
                        }
                    }

                    // Get user's rank
                    $my_rank = $this->myEngagementRank($user_id, 'alltime', $scope, $filter_value);
                    if (!empty($my_rank)) {
                        if (filter_var($my_rank['profile'], FILTER_VALIDATE_URL) === false) {
                            $my_rank['profile'] = (!empty($my_rank['profile'])) ? base_url() . USER_IMG_PATH . $my_rank['profile'] : '';
                        }
                        $user_rank = $my_rank;
                    } else {
                        $user_rank = array(
                            'user_id' => $user_id,
                            'total_minutes' => '0',
                            'user_rank' => '0',
                            'email' => '',
                            'name' => '',
                            'profile' => '',
                        );
                    }
                }

                $response['error'] = false;
                $response['total'] = "$total";
                $response['data'] = array(
                    'my_rank' => $user_rank,
                    'other_users_rank' => $data,
                    'top_three_ranks' => $topThreeUsersData ?? array()
                );
            } else {
                $response['error'] = false;
                $response['total'] = "0";
                $response['data'] = array(
                    'my_rank' => array(
                        'user_id' => $user_id,
                        'total_minutes' => '0',
                        'user_rank' => '0',
                        'email' => '',
                        'name' => '',
                        'profile' => '',
                    ),
                    'other_users_rank' => array(),
                    'top_three_ranks' => array()
                );
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = 'Failed to fetch leaderboard';
            $response['error_msg'] = $e->getMessage();
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    /**
     * Get weekly score leaderboard with scope filtering
     * Scope can be: world, country, or region (continent)
     */
    public function get_weekly_score_leaderboard_post()
    {
        try {
            $is_user = $this->verify_token();
            if (!$is_user['error']) {
                $user_id = $is_user['user_id'];
                $firebase_id = $is_user['firebase_id'];
            } else {
                $this->response($is_user, REST_Controller::HTTP_OK);
                return false;
            }

            $offset = ($this->post('offset')) ? $this->post('offset') : 0;
            $limit = ($this->post('limit')) ? $this->post('limit') : 25;
            $scope = ($this->post('scope')) ? $this->post('scope') : 'world';
            $filter_value = ($this->post('filter_value')) ? $this->post('filter_value') : '';

            $week_number = date('W', strtotime($this->toDate));
            $year = date('Y', strtotime($this->toDate));

            // Build scope filter
            $scope_where = "";
            if ($scope === 'country' && !empty($filter_value)) {
                $scope_where = "AND u.country_code = '" . $this->db->escape_str($filter_value) . "'";
            } elseif ($scope === 'region' && !empty($filter_value)) {
                $scope_where = "AND u.continent = '" . $this->db->escape_str($filter_value) . "'";
            }

            $sort = 'r.user_rank';
            $order = 'ASC';

            $sub_query = "SELECT s.*, @user_rank := @user_rank + 1 user_rank FROM ( SELECT w.id, user_id, u.email, u.name, u.profile, u.country_code, SUM(score) as score, date_created, MAX(last_updated) as last_updated FROM tbl_leaderboard_weekly w join tbl_users u on u.id = w.user_id WHERE u.status=1 AND w.week_number=$week_number AND w.year=$year {$scope_where} GROUP BY user_id) s, (SELECT @user_rank := 0) init ORDER BY score DESC, last_updated ASC";

            $this->db->reset_query();
            $this->db->from("($sub_query) r");

            $total = $this->db->count_all_results('', false);

            $this->db->select('r.*');
            $this->db->order_by($sort, $order);

            if ($limit) {
                $this->db->limit($limit, $offset);
            }

            $other_user_rank_sql = $this->db->get();
            $data = $other_user_rank_sql->result_array();

            if ($user_id) {
                if (!empty($data)) {
                    for ($i = 0; $i < count($data); $i++) {
                        if (filter_var($data[$i]['profile'], FILTER_VALIDATE_URL) === false) {
                            $data[$i]['profile'] = ($data[$i]['profile']) ? base_url() . USER_IMG_PATH . $data[$i]['profile'] : '';
                        }
                    }

                    $this->db->reset_query();
                    $this->db->from("($sub_query) r");
                    $this->db->select('r.*');
                    $this->db->order_by($sort, $order);
                    $this->db->limit(3);
                    $topThree_sql = $this->db->get();
                    $topThreeUsersData = $topThree_sql->result_array();

                    for ($i = 0; $i < count($topThreeUsersData); $i++) {
                        if (filter_var($topThreeUsersData[$i]['profile'], FILTER_VALIDATE_URL) === false) {
                            $topThreeUsersData[$i]['profile'] = ($topThreeUsersData[$i]['profile']) ? base_url() . USER_IMG_PATH . $topThreeUsersData[$i]['profile'] : '';
                        }
                    }

                    $this->db->reset_query();
                    $this->db->from("($sub_query) r");
                    $this->db->select('r.*');
                    $this->db->where('r.user_id', $user_id);
                    $this->db->limit(1);
                    $user_rank_sql = $this->db->get();
                    $my_rank = $user_rank_sql->row_array();

                    if (!empty($my_rank)) {
                        if (filter_var($my_rank['profile'], FILTER_VALIDATE_URL) === false) {
                            $my_rank['profile'] = (!empty($my_rank['profile'])) ? base_url() . USER_IMG_PATH . $my_rank['profile'] : '';
                        }
                        $user_rank = $my_rank;
                    } else {
                        $my_rank = array(
                            'user_id' => $user_id,
                            'score' => '0',
                            'user_rank' => '0',
                            'email' => '',
                            'name' => '',
                            'profile' => '',
                            'country_code' => '',
                        );
                        $user_rank = $my_rank;
                    }
                }
                $response['error'] = false;
                $response['total'] = "$total";
                $response['data'] = array(
                    'my_rank' => $user_rank ?? array(
                        'user_id' => $user_id,
                        'score' => '0',
                        'user_rank' => '0',
                        'email' => '',
                        'name' => '',
                        'profile' => '',
                        'country_code' => '',
                    ),
                    'other_users_rank' => $data,
                    'top_three_ranks' => $topThreeUsersData ?? array()
                );
            } else {
                $response['error'] = true;
                $response['message'] = "102";
            }
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = "122";
            $response['error_msg'] = $e->getMessage();
        }

        $this->response($response, REST_Controller::HTTP_OK);
    }

    // ========================================
    // HELPER METHODS FOR ENGAGEMENT TRACKING
    // ========================================

    /**
     * Update all engagement leaderboards (weekly, monthly, all-time)
     * 
     * @param int $user_id User ID
     * @param int $duration_seconds Session duration in seconds
     * @param string $timestamp Session end timestamp
     */
    private function update_engagement_leaderboards($user_id, $duration_seconds, $timestamp)
    {
        $minutes = round($duration_seconds / 60, 2);
        $week_number = date('W', strtotime($timestamp));
        $year = date('Y', strtotime($timestamp));
        $month = date('m', strtotime($timestamp));

        // Update weekly engagement
        $weekly_data = $this->db->where('user_id', $user_id)
            ->where('week_number', $week_number)
            ->where('year', $year)
            ->get('tbl_leaderboard_engagement_weekly')
            ->row_array();

        if (!empty($weekly_data)) {
            $new_total = $weekly_data['total_minutes'] + $minutes;
            $this->db->where('id', $weekly_data['id'])
                ->update('tbl_leaderboard_engagement_weekly', [
                    'total_minutes' => $new_total,
                    'last_updated' => $this->toDateTime
                ]);
        } else {
            $this->db->insert('tbl_leaderboard_engagement_weekly', [
                'user_id' => $user_id,
                'total_minutes' => $minutes,
                'week_number' => $week_number,
                'year' => $year,
                'last_updated' => $this->toDateTime,
                'date_created' => $this->toDateTime
            ]);
        }

        // Update monthly engagement
        $monthly_data = $this->db->where('user_id', $user_id)
            ->where('month', $month)
            ->where('year', $year)
            ->get('tbl_leaderboard_engagement_monthly')
            ->row_array();

        if (!empty($monthly_data)) {
            $new_total = $monthly_data['total_minutes'] + $minutes;
            $this->db->where('id', $monthly_data['id'])
                ->update('tbl_leaderboard_engagement_monthly', [
                    'total_minutes' => $new_total,
                    'last_updated' => $this->toDateTime
                ]);
        } else {
            $this->db->insert('tbl_leaderboard_engagement_monthly', [
                'user_id' => $user_id,
                'total_minutes' => $minutes,
                'month' => $month,
                'year' => $year,
                'last_updated' => $this->toDateTime,
                'date_created' => $this->toDateTime
            ]);
        }

        // Update all-time engagement
        $alltime_data = $this->db->where('user_id', $user_id)
            ->get('tbl_leaderboard_engagement_alltime')
            ->row_array();

        if (!empty($alltime_data)) {
            $new_total = $alltime_data['total_minutes'] + $minutes;
            $this->db->where('id', $alltime_data['id'])
                ->update('tbl_leaderboard_engagement_alltime', [
                    'total_minutes' => $new_total,
                    'last_updated' => $this->toDateTime
                ]);
        } else {
            $this->db->insert('tbl_leaderboard_engagement_alltime', [
                'user_id' => $user_id,
                'total_minutes' => $minutes,
                'last_updated' => $this->toDateTime,
                'date_created' => $this->toDateTime
            ]);
        }
    }

    /**
     * Build engagement leaderboard from session data for a period.
     *
     * @param int $user_id
     * @param string $period weekly|monthly|alltime
     * @param string $scope world|country|region
     * @param string|null $filter_value
     * @param int $offset
     * @param int $limit
     * @return array
     */
    private function getEngagementLeaderboardFromSessions($user_id, $period, $scope, $filter_value, $offset, $limit)
    {
        $week_number = date('W');
        $year = date('Y');
        $month = date('m');

        $scope_where = '';
        if ($scope === 'country' && !empty($filter_value)) {
            $scope_where = "AND u.country_code = '{$filter_value}'";
        } elseif ($scope === 'region' && !empty($filter_value)) {
            $scope_where = "AND u.continent = '{$filter_value}'";
        }

        $period_where = '';
        if ($period === 'weekly') {
            $period_where = "AND YEAR(e.session_end) = {$year} AND WEEK(e.session_end, 1) = {$week_number}";
        } elseif ($period === 'monthly') {
            $period_where = "AND YEAR(e.session_end) = {$year} AND MONTH(e.session_end) = {$month}";
        }

        $sub_query = "(SELECT s.*, @user_rank := @user_rank + 1 AS user_rank FROM (SELECT u.id AS user_id, u.email, u.name, u.profile, u.country_code, u.continent, ROUND(SUM(e.duration_seconds) / 60, 2) AS total_minutes, MAX(e.session_end) AS last_updated FROM tbl_user_engagement e JOIN tbl_users u ON u.id = e.user_id WHERE u.status = 1 {$period_where} {$scope_where} GROUP BY e.user_id) s, (SELECT @user_rank := 0) init ORDER BY s.total_minutes DESC, s.last_updated ASC)";

        $this->db->select('r.*');
        $this->db->from("$sub_query r", false);
        $total = $this->db->count_all_results('', false);
        $this->db->order_by('r.user_rank', 'ASC');
        if ($limit) {
            $this->db->limit($limit, $offset);
        }
        $result = $this->db->get();
        $data = $result->result_array();

        // Format profile URLs
        for ($i = 0; $i < count($data); $i++) {
            if (filter_var($data[$i]['profile'], FILTER_VALIDATE_URL) === false) {
                $data[$i]['profile'] = ($data[$i]['profile']) ? base_url() . USER_IMG_PATH . $data[$i]['profile'] : '';
            }
        }

        // Top 3
        $this->db->reset_query();
        $this->db->from("($sub_query) r");
        $this->db->select('r.*');
        $this->db->order_by('r.user_rank', 'ASC');
        $this->db->limit(3);
        $top_three_result = $this->db->get();
        $topThreeUsersData = $top_three_result->result_array();

        for ($i = 0; $i < count($topThreeUsersData); $i++) {
            if (filter_var($topThreeUsersData[$i]['profile'], FILTER_VALIDATE_URL) === false) {
                $topThreeUsersData[$i]['profile'] = ($topThreeUsersData[$i]['profile']) ? base_url() . USER_IMG_PATH . $topThreeUsersData[$i]['profile'] : '';
            }
        }

        // My rank
        $this->db->reset_query();
        $this->db->select('r.*');
        $this->db->from("$sub_query r", false);
        $this->db->where('r.user_id', $user_id);
        $my_rank = $this->db->get()->row_array();

        if (!empty($my_rank)) {
            if (filter_var($my_rank['profile'], FILTER_VALIDATE_URL) === false) {
                $my_rank['profile'] = (!empty($my_rank['profile'])) ? base_url() . USER_IMG_PATH . $my_rank['profile'] : '';
            }
        } else {
            $my_rank = array(
                'user_id' => $user_id,
                'total_minutes' => '0',
                'user_rank' => '0',
                'email' => '',
                'name' => '',
                'profile' => '',
            );
        }

        return array(
            'data' => $data,
            'total' => $total,
            'top_three_ranks' => $topThreeUsersData ?? array(),
            'my_rank' => $my_rank,
        );
    }

    /**
     * Get user's engagement rank
     * 
     * @param int $user_id User ID
     * @param string $period Period: weekly, monthly, alltime
     * @param string $scope Scope: world, country, region
     * @param string $filter_value Filter value for scope
     * @return array|null User's rank data
     */
    private function myEngagementRank($user_id, $period, $scope = 'world', $filter_value = null)
    {
        $week_number = date('W');
        $year = date('Y');
        $month = date('m');

        // Build scope filter
        $scope_where = '';
        if ($scope === 'country' && !empty($filter_value)) {
            $scope_where = "AND u.country_code = '{$filter_value}'";
        } elseif ($scope === 'region' && !empty($filter_value)) {
            $scope_where = "AND u.continent = '{$filter_value}'";
        }

        // Build period filter and table name
        $period_where = '';
        $table = '';
        if ($period === 'weekly') {
            $table = 'tbl_leaderboard_engagement_weekly';
            $period_where = "AND e.week_number = {$week_number} AND e.year = {$year}";
        } elseif ($period === 'monthly') {
            $table = 'tbl_leaderboard_engagement_monthly';
            $period_where = "AND e.month = {$month} AND e.year = {$year}";
        } else {
            $table = 'tbl_leaderboard_engagement_alltime';
        }

        $sub_query = "(SELECT s.*, @user_rank := @user_rank + 1 AS user_rank FROM (SELECT e.id, e.user_id, u.email, u.name, u.profile, u.country_code, u.continent, e.total_minutes, e.last_updated FROM {$table} e JOIN tbl_users u ON u.id = e.user_id WHERE u.status = 1 {$period_where} {$scope_where} GROUP BY e.user_id) s, (SELECT @user_rank := 0) init ORDER BY s.total_minutes DESC, s.last_updated ASC)";

        $this->db->select('r.*');
        $this->db->from("$sub_query r", false);
        $this->db->where('r.user_id', $user_id);
        $result = $this->db->get()->row_array();

        return $result;
    }
}
