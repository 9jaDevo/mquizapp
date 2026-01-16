<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta content="width=device-width, initial-scale=1, maximum-scale=1, shrink-to-fit=no" name="viewport">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title><?= lang('questions_for_quiz'); ?> | <?php echo (is_settings('app_name')) ? is_settings('app_name') : "" ?></title>

    <?php base_url() . include 'include.php'; ?>
    <link href="<?= base_url(); ?>assets/css/select2.css" rel="stylesheet" type="text/css">

</head>

<body>
    <div id="app">
        <div class="main-wrapper">
            <?php base_url() . include 'header.php'; ?>

            <!-- Main Content -->
            <div class="main-content">
                <section class="section">
                    <div class="section-header">
                        <h1><?= lang('create_and_manage_questions'); ?></h1>

                    </div>
                    <div class="section-body">
                        <div class="row">
                            <div class="col-12">
                                <div class="card">
                                    <div class="card-header">
                                        <h4><?= lang('create_questions'); ?></h4>
                                    </div>
                                    <div class="card-body">
                                        <form id="frmQuestion" method="post" class="needs-validation" novalidate="" enctype="multipart/form-data">
                                            <input type="hidden" name="<?= $this->security->get_csrf_token_name(); ?>" value="<?= $this->security->get_csrf_hash(); ?>">

                                            <div class="row">
                                                <div class="form-group col-md-3 col-sm-12">
                                                    <label class="control-label"><?= lang('quiz_type'); ?> <small class="text-danger">*</small></label>
                                                    <select name="quiz_type" id="quiz_type" class="form-control" required>
                                                        <option value=""><?= lang('select_quiz'); ?></option>
                                                        <?php foreach (json_decode($quiz_type) as $quiz) { ?>
                                                            <option value="<?= $quiz->id ?>"><?= $quiz->name ?></option>
                                                        <?php } ?>
                                                    </select>
                                                </div>
                                                <?php if (is_language_mode_enabled()) { ?>
                                                    <div class="form-group col-md-3 col-sm-12">
                                                        <label class="control-label"><?= lang('language'); ?> <small class="text-danger">*</small></label>
                                                        <select name="language_id" id="language_id" class="form-control" required>
                                                            <option value=""><?= lang('select_language'); ?></option>
                                                            <?php foreach ($language as $lang) { ?>
                                                                <option value="<?= $lang->id ?>"><?= $lang->language ?></option>
                                                            <?php } ?>
                                                        </select>
                                                    </div>
                                                <?php } ?>
                                                <div class="form-group col-md-3 col-sm-12 contestData">
                                                    <label class="control-label"><?= lang('contest'); ?> <small class="text-danger">*</small></label>
                                                    <select name="contest_id" id="contest_id" class="form-control">
                                                        <option value=""><?= lang('select_contest'); ?></option>
                                                    </select>
                                                </div>
                                                <div class="form-group col-md-3 col-sm-12 examData">
                                                    <label class="control-label"><?= lang('exam'); ?> <small class="text-danger">*</small></label>
                                                    <select name="exam_id" id="exam_id" class="form-control">
                                                        <option value=""><?= lang('select_exam'); ?></option>

                                                    </select>
                                                </div>
                                                <div class="form-group col-md-3 col-sm-12 no_contest_exam">
                                                    <label class="control-label"><?= lang('main_category'); ?> <small class="text-danger">*</small></label>
                                                    <select id="category" name="category" class="form-control">
                                                        <option value=""><?= lang('select_main_category'); ?></option>
                                                    </select>
                                                </div>
                                                <div class="form-group col-md-3 col-sm-12 no_contest_exam">
                                                    <label class="control-label"><?= lang('sub_category'); ?></label>
                                                    <select id="subcategory" name="subcategory" class="form-control">
                                                        <option value=""><?= lang('select_sub_category'); ?></option>
                                                    </select>
                                                </div>

                                            </div>
                                            <div class="row">
                                                <div class="form-group col-md-3 col-sm-12 questionType">
                                                    <label class="control-label"><?= lang('question_type'); ?> <small class="text-danger">*</small></label>
                                                    <div>
                                                        <div class="form-check-inline bg-light p-2">
                                                            <label class="form-check-label">
                                                                <input type="radio" class="form-check-input" name="question_type" value="1" required><?= lang('options'); ?>
                                                            </label>
                                                            <label class="form-check-label">
                                                                <input type="radio" class="form-check-input" name="question_type" value="2"><?= lang('true_false'); ?>
                                                            </label>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="form-group col-md-3 col-sm-12 answerType">
                                                    <label class="control-label"><?= lang('answer_type'); ?> <small class="text-danger">*</small></label>
                                                    <div>
                                                        <div class="form-check-inline bg-light p-2">
                                                            <label class="form-check-label">
                                                                <input type="radio" class="form-check-input" name="answer_type" value="1"><?= lang('multiselect'); ?>
                                                            </label>
                                                            <label class="form-check-label">
                                                                <input type="radio" class="form-check-input" name="answer_type" value="2"><?= lang('sequence'); ?>
                                                            </label>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="form-group col-md-3 col-sm-12 quizLevel">
                                                    <label class="control-label"><?= lang('level'); ?> <small class="text-danger">*</small></label>
                                                    <input type='number' name='level' id="level" class='form-control' min="1" value="">
                                                </div>
                                                <div class="form-group col-md-6 col-sm-12 contestData">
                                                    <label class="control-label"><?= lang('description'); ?></label>
                                                    <textarea type='text' name='contest_detail' class='form-control' rows="4"></textarea>
                                                </div>
                                                <div class="form-group col-md-3 col-sm-12 examData">
                                                    <label class="control-label"><?= lang('marks'); ?> <small class="text-danger">*</small></label>
                                                    <input type='number' name='marks' id="marks" class='form-control' min="1">
                                                </div>
                                                <div class="form-group col-md-6 col-sm-12 examData">
                                                    <label class="control-label"><?= lang('description'); ?></label>
                                                    <textarea type='text' name='exam_detail' class='form-control' rows="4"></textarea>
                                                </div>
                                            </div>
                                            <div class="row">
                                                <div class="form-group col-md-3 col-sm-12">
                                                    <label class="control-label"><?= lang('no_of_question_generate'); ?> <small class="text-danger">*</small></label>
                                                    <input type='number' name='no_of_question_generate' id="no_of_question_generate" class='form-control' required min="1" max="25">
                                                    <span id="no_of_question_generate_err" class="text-danger"></span>
                                                </div>
                                            </div>
                                            <div class="row">
                                                <div class="form-group col-sm-12">
                                                    <input type="hidden" name="btnadd" value="1">
                                                    <input type="submit" id="btnfrmadd" value="<?= lang('submit'); ?>" class="<?= BUTTON_CLASS ?>" />
                                                </div>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-12">
                                <div class="card">
                                    <div class="card-header">
                                        <h4><?= lang('manage_questions'); ?> <small><?= lang('view_update_delete'); ?></small></h4>
                                    </div>
                                    <div class="card-body">
                                        <div class="row">
                                            <div class="form-group col-md-2">
                                                <select id="filter_quiz_type" class="form-control" required>
                                                    <option value=""><?= lang('select_quiz'); ?></option>
                                                    <?php foreach (json_decode($quiz_type) as $quiz) { ?>
                                                        <option value="<?= $quiz->id ?>"><?= $quiz->name ?></option>
                                                    <?php } ?>
                                                </select>
                                            </div>

                                            <?php if (is_language_mode_enabled()) { ?>
                                                <div class="form-group col-md-2">
                                                    <select id="filter_language" class="form-control" required>
                                                        <option value=""><?= lang('select_language'); ?></option>
                                                        <?php foreach ($language as $lang) { ?>
                                                            <option value="<?= $lang->id ?>"><?= $lang->language ?></option>
                                                        <?php } ?>
                                                    </select>
                                                </div>
                                            <?php } ?>
                                            <div class="form-group col-md-2 filter_no_contest_exam">
                                                <select id="filter_category" class="form-control" required>
                                                    <option value=""><?= lang('select_main_category'); ?></option>
                                                </select>
                                            </div>
                                            <div class='form-group col-md-2 filter_no_contest_exam'>
                                                <select id='filter_subcategory' class='form-control' required>
                                                    <option value=''><?= lang('select_sub_category'); ?></option>
                                                </select>
                                            </div>
                                            <div class="form-group col-md-2 filterContestData">
                                                <select id="filter_contest_id" class="form-control">
                                                    <option value=""><?= lang('select_contest'); ?></option>

                                                </select>
                                            </div>
                                            <div class="form-group col-md-2 filterExamData">
                                                <select id="filter_exam_id" class="form-control">
                                                    <option value=""><?= lang('select_exam'); ?></option>

                                                </select>
                                            </div>
                                            <div class="form-group col-md-2">
                                                <select id="filter_status" class="form-control">
                                                    <option value=""><?= lang('all'); ?></option>
                                                    <option value="0"><?= lang('draft'); ?></option>
                                                    <option value="1"><?= lang('moved'); ?></option>

                                                </select>
                                            </div>
                                            <div class='form-group col-md-2'>
                                                <button class='<?= BUTTON_CLASS ?> btn-block form-control' id='filter_btn'><?= lang('filter_data'); ?></button>
                                            </div>
                                        </div>
                                        <div id="toolbar">
                                            <?php if (has_permissions('delete', 'ai_question_bank')) { ?>
                                                <button class="btn btn-danger" id="delete_multiple_questions" title="<?= lang('delete_selected_questions'); ?>"><em class='fa fa-trash'></em></button>
                                            <?php } ?>
                                            <?php if (has_permissions('create', 'ai_question_bank')) { ?>
                                                <button class="btn btn-danger" id="move_multiple_questions" title="<?= lang('move_selected_questions'); ?>"><em class='fa fa-undo'></em></button>
                                            <?php } ?>
                                        </div>
                                        <table aria-describedby="mydesc" class='table-striped' id='question_list' data-toggle="table" data-url="<?= base_url() . 'Table/ai_question' ?>" data-click-to-select="true" data-side-pagination="server" data-pagination="true" data-page-list="[5, 10, 20, 50, 100, 200, All]" data-search="true" data-toolbar="#toolbar" data-show-columns="true" data-show-refresh="true" data-trim-on-search="false" data-mobile-responsive="true" data-sort-name="id" data-sort-order="desc" data-pagination-successively-size="3" data-maintain-selected="true" data-show-export="true" data-export-types='["csv","excel","pdf"]' data-export-options='{ "fileName": "ai-question-list-<?= date('d-m-y') ?>" }' data-query-params="queryParams">
                                            <thead>
                                                <tr>
                                                    <th scope="col" data-force-hide="true" data-field="state" data-checkbox="true" data-formatter="checkStatus"></th>
                                                    <th scope="col" data-field="id" data-sortable="true"><?= lang('id'); ?></th>
                                                    <th scope="col" data-field="status" data-sortable="true" data-formatter="statusFormatter"><?= lang('status'); ?></th>
                                                    <th scope="col" data-field="quiz_type" data-sortable="true" data-formatter="quizTypeFormatter"><?= lang('quiz_type'); ?></th>
                                                    <th scope="col" data-field="category" data-sortable="true" data-visible='false'><?= lang('main_category'); ?></th>
                                                    <th scope="col" data-field="subcategory" data-sortable="true" data-visible='false'><?= lang('sub_category'); ?></th>
                                                    <?php if (is_language_mode_enabled()) { ?>
                                                        <th scope="col" data-field="language_id" data-sortable="true" data-visible='false'><?= lang('language_id'); ?></th>
                                                        <th scope="col" data-field="language" data-sortable="true" data-visible='true'><?= lang('language'); ?></th>
                                                    <?php } ?>
                                                    <th scope="col" data-field="question" data-sortable="true"><?= lang('question'); ?></th>
                                                    <th scope="col" data-field="question_type" data-sortable="true" data-visible='false'><?= lang('question_type'); ?></th>
                                                    <th scope="col" data-field="answer_type" data-sortable="true" data-visible='false'><?= lang('answer_type'); ?></th>
                                                    <th scope="col" data-field="optiona" data-sortable="false"><?= lang('option_a'); ?></th>
                                                    <th scope="col" data-field="optionb" data-sortable="false"><?= lang('option_b'); ?></th>
                                                    <th scope="col" data-field="optionc" data-sortable="false"><?= lang('option_c'); ?></th>
                                                    <th scope="col" data-field="optiond" data-sortable="false"><?= lang('option_d'); ?></th>
                                                    <?php if (is_option_e_mode_enabled()) { ?>
                                                        <th scope="col" data-field="optione" data-sortable="false"><?= lang('option_e'); ?></th>
                                                    <?php } ?>
                                                    <th scope="col" data-field="answer" data-sortable="false" data-visible='false'><?= lang('answer'); ?></th>
                                                    <th scope="col" data-field="note" data-sortable="true" data-visible='false'><?= lang('note'); ?></th>
                                                    <th scope="col" data-field="level" data-sortable="true"><?= lang('level'); ?></th>
                                                    <th scope="col" data-force-hide="true" data-field="operate" data-sortable="false" data-events="actionEvents"><?= lang('operate'); ?></th>
                                                </tr>
                                            </thead>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>

                    </div>
                </section>
            </div>
        </div>
    </div>


    <div class="modal fade" tabindex="-1" role="dialog" id="editDataModal">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title"><?= lang('edit_question'); ?></h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <div class="card-body">
                        <form id="frmUpdateQuestion" method="post" class="needs-validation" novalidate="" enctype="multipart/form-data">
                            <input type="hidden" name="<?= $this->security->get_csrf_token_name(); ?>" value="<?= $this->security->get_csrf_hash(); ?>">
                            <input type='hidden' name="edit_id" id="edit_id" value="" />

                            <div class="row">
                                <div class="form-group col-md-12 col-sm-12">
                                    <label class="control-label"><?= lang('question'); ?> <small class="text-danger">*</small></label>
                                    <textarea id="question" name="question" class="form-control" required></textarea>
                                </div>
                            </div>
                            <div class="row editQuestionAnswerType">
                                <div class="form-group col-md-6 col-sm-12 editQuestionType">
                                    <label class="control-label"><?= lang('question_type'); ?> <small class="text-danger">*</small></label>
                                    <div>
                                        <div class="form-check-inline bg-light p-2">
                                            <label class="form-check-label">
                                                <input type="radio" class="form-check-input" name="edit_question_type" value="1"><?= lang('options'); ?>
                                            </label>
                                            <label class="form-check-label">
                                                <input type="radio" class="form-check-input" name="edit_question_type" value="2"><?= lang('true_false'); ?>
                                            </label>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group col-md-6 col-sm-12 editAnswerType">
                                    <label class="control-label"><?= lang('answer_type'); ?> <small class="text-danger">*</small></label>
                                    <div>
                                        <div class="form-check-inline bg-light p-2">
                                            <label class="form-check-label">
                                                <input type="radio" class="form-check-input" name="edit_answer_type" value="1"><?= lang('multiselect'); ?>
                                            </label>
                                            <label class="form-check-label">
                                                <input type="radio" class="form-check-input" name="edit_answer_type" value="2"><?= lang('sequence'); ?>
                                            </label>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="row editOptionab">
                                <div class="form-group col-md-6 col-sm-6">
                                    <label class="control-label"><?= lang('option_a'); ?> <small class="text-danger">*</small></label>
                                    <textarea class="form-control" id="a" name="a"></textarea>
                                </div>
                                <div class="form-group col-md-6 col-sm-6">
                                    <label class="control-label"><?= lang('option_b'); ?> <small class="text-danger">*</small></label>
                                    <textarea class="form-control" id="b" name="b"></textarea>
                                </div>
                            </div>
                            <div class="editOptioncd">
                                <div class="row">
                                    <div class="form-group col-md-6 col-sm-6">
                                        <label class="control-label"><?= lang('option_c'); ?> <small class="text-danger">*</small></label>
                                        <textarea class="form-control" id="c" name="c"></textarea>
                                    </div>
                                    <div class="form-group col-md-6 col-sm-6">
                                        <label class="control-label"><?= lang('option_d'); ?> <small class="text-danger">*</small></label>
                                        <textarea class="form-control" id="d" name="d"></textarea>
                                    </div>
                                </div>
                                <?php if (is_option_e_mode_enabled()) { ?>
                                    <div class="row">
                                        <div class="form-group col-md-6 col-sm-12">
                                            <label class="control-label"><?= lang('option_e'); ?> <small class="text-danger">*</small></label>
                                            <textarea class="form-control" id="e" name="e" required></textarea>
                                        </div>
                                    </div>
                                <?php } ?>
                            </div>
                            <div class="row editLevelAnswer">
                                <div class="form-group col-md-6 col-sm-12 editAnswer">
                                    <label class="control-label"><?= lang('answer'); ?> <small class="text-danger">*</small></label>
                                    <select name='quiz_answer' id='answer' class='form-control'>
                                        <option value=''><?= lang('select_right_answer'); ?></option>
                                        <option value='a'><?= lang('a'); ?></option>
                                        <option value='b'><?= lang('b'); ?></option>
                                        <option class='editOptioncd' value='c'><?= lang('c'); ?></option>
                                        <option class='editOptioncd' value='d'><?= lang('d'); ?></option>
                                        <?php if (is_option_e_mode_enabled()) { ?>
                                            <option class='editOptioncd' value='e'><?= lang('e'); ?></option>
                                        <?php } ?>
                                    </select>
                                </div>
                                <div class="form-group col-md-6 col-sm-12 editMultiAnswer" id="option1_answer1">
                                    <label class="control-label"><?= lang('answer'); ?> <small class="text-danger">*</small></label><br>
                                    <select name='answer[]' id="answer1" class='form-control select2' style="width: 100%;" data-placeholder="<?= lang('select_right_answer'); ?>" multiple="multiple">
                                        <option value='a'><?= lang('a'); ?></option>
                                        <option value='b'><?= lang('b'); ?></option>
                                        <option value='c'><?= lang('c'); ?></option>
                                        <option value='d'><?= lang('d'); ?></option>
                                        <?php if (is_option_e_mode_enabled()) { ?>
                                            <option value='e'><?= lang('e'); ?></option>
                                        <?php } ?>
                                    </select>
                                </div>
                                <div class="form-group col-md-6 col-sm-12 editMultiAnswer" id="option2_answer1">
                                    <label class="control-label"><?= lang('answer'); ?></label><br>
                                    <select name='answer[]' id="answer_tf" class='form-control select2' style="width: 100%;" data-placeholder="<?= lang('select_right_answer'); ?>" multiple="multiple">
                                        <option value='a'><?= lang('a'); ?></option>
                                        <option value='b'><?= lang('b'); ?></option>
                                    </select>
                                </div>
                                <div class="form-group col-md-6 col-sm-12 answer_order editMultiAnswer" id="option1_answer2">
                                    <label class="control-label"><?= lang('answer'); ?></label>
                                    <input type='text' name='text_answer' class='form-control answer_type2' id="option1_answer2_answer_type2">
                                    <ol id="sortable-row" class="mt-3">
                                        <li id=a><?= lang('a'); ?></li>
                                        <li id=b><?= lang('b'); ?></li>
                                        <li id=c><?= lang('c'); ?></li>
                                        <li id=d><?= lang('d'); ?></li>
                                        <?php if (is_option_e_mode_enabled()) { ?>
                                            <li id=e><?= lang('e'); ?></li>
                                        <?php } ?>
                                    </ol>
                                </div>
                                <div class="form-group col-md-6 col-sm-12 answer_order editMultiAnswer" id="option2_answer2">
                                    <label class="control-label"><?= lang('answer'); ?></label>
                                    <input type='text' name='text_answer' class='form-control answer_type2' id="option2_answer2_answer_type2">
                                    <ol id="sortable-row-1" class="mt-3">
                                        <li id=a><?= lang('a'); ?></li>
                                        <li id=b><?= lang('b'); ?></li>
                                    </ol>
                                </div>
                                <div class="form-group col-md-6 col-sm-12 editLevel">
                                    <label class="control-label"><?= lang('level'); ?> <small class="text-danger">*</small></label>
                                    <input type='number' name='level' id="edit_level" class='form-control' min="1">
                                </div>
                            </div>
                            <div class="row editTextAnswer">
                                <div class="form-group col-md-12 col-sm-12">
                                    <label class="control-label"><?= lang('answer'); ?></label>
                                    <input type='text' name='textAnswer' id="textAnswer" class='form-control'>
                                </div>
                            </div>
                            <div class="row editNote">
                                <div class="form-group col-md-12 col-sm-12">
                                    <label class="control-label"><?= lang('note'); ?></label>
                                    <small><?= lang('this_will_be_showing_with_review_selection_only'); ?></small>
                                    <textarea name='note' id="note" class='form-control'></textarea>
                                </div>
                            </div>
                            <div class="float-right">
                                <button type="button" class="btn btn-secondary" data-dismiss="modal"><?= lang('close'); ?></button>
                                <input name="btnupdate" id="btnfrmupdate" type="submit" value="<?= lang('save_changes'); ?>" class="<?= BUTTON_CLASS ?>">
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <?php base_url() . include 'footer.php'; ?>
    <script src="//code.jquery.com/ui/1.11.2/jquery-ui.js"></script>
    <script src="<?= base_url(); ?>assets/js/select2.js" type="text/javascript"></script>

    <script type="text/javascript">
        $("input[name='question_type'][value='1']").prop('checked', true);
        $("input[name='answer_type'][value='1']").prop('checked', true);
        $('.contestData').hide('fast');
        $('.examData').hide('fast');
        $('.answerType').hide('fast');
        $('.no_contest_exam').show('fast');

        function questionValidate(no_of_question_generate) {
            if (no_of_question_generate.trim() !== '') {
                if (no_of_question_generate <= 0) {
                    $("#no_of_question_generate_err").show();
                    $("#no_of_question_generate").focus();
                    $("#no_of_question_generate_err").text('<?= lang("minimum_one_need_for_generate_questions"); ?>');
                } else if (no_of_question_generate < 25) {
                    $("#no_of_question_generate_err").hide();
                } else if (no_of_question_generate > 25) {
                    $("#no_of_question_generate_err").show();
                    $("#no_of_question_generate").focus();
                    $("#no_of_question_generate_err").text('<?= lang("you_can_generate_maximum_twenty_five_questions_at_once"); ?>');
                }
            }
        }

        $("#no_of_question_generate").on('input', function() {
            var no_of_question_generate = $("#no_of_question_generate").val();
            questionValidate(no_of_question_generate);
        });

        $('#frmQuestion').submit(function() {
            $('#btnfrmadd').prop('disabled', true).val("<?= lang('please_wait') ?>");

            var no_of_question_generate = $("#no_of_question_generate").val();
            questionValidate(no_of_question_generate);

            if (!this.checkValidity()) {
                setTimeout(function() {
                    $('#btnfrmadd').prop('disabled', false).val("<?= lang('submit') ?>");
                }, 2000);
                return false;
            }

        });

        var base_url = "<?php echo base_url(); ?>";
        let type;

        $('#quiz_type').on('change', function(e) {
            var quizType = $('#quiz_type').val() ?? 1;

            switch (parseInt(quizType)) {
                case 1:
                    type = 'sub-category';
                    $('.no_contest_exam').show('fast');
                    $('.questionType').show('fast');
                    $('input[name="question_type"]').attr('required', true);
                    $('.quizLevel').show('fast');
                    $('#level').attr('required', true);
                    $('.answerType').hide('fast');
                    $('input[name="answer_type"]').removeAttr('required');
                    $('.contestData').hide('fast');
                    $('.examData').hide('fast');
                    $('#marks').removeAttr('required');
                    $('#category').attr('required', true);
                    $('#contest_id').removeAttr('required');
                    $('#exam_id').removeAttr('required');
                    break;

                case 3:
                    type = 'guess-the-word-category';
                    $('.no_contest_exam').show('fast');
                    $('.contestData').hide('fast');
                    $('.examData').hide('fast');
                    $('#marks').removeAttr('required');
                    $('.quizLevel').hide('fast');
                    $('#level').removeAttr('required');
                    $('.questionType').hide('fast');
                    $('input[name="question_type"]').removeAttr('required');
                    $('.answerType').hide('fast');
                    $('input[name="answer_type"]').removeAttr('required');
                    $('#category').attr('required', true);
                    $('#contest_id').removeAttr('required');
                    $('#exam_id').removeAttr('required');
                    break;

                case 6:
                    type = 'multi-match-category';
                    $('.quizLevel').show('fast');
                    $('#level').attr('required', true);
                    $('.questionType').show('fast');
                    $('input[name="question_type"]').attr('required', true);
                    $('.answerType').show('fast');
                    $('input[name="answer_type"]').attr('required', true);
                    $('.contestData').hide('fast');
                    $('.examData').hide('fast');
                    $('#marks').removeAttr('required');
                    $('.no_contest_exam').show('fast');
                    $('#category').attr('required', true);
                    $('#contest_id').removeAttr('required');
                    $('#exam_id').removeAttr('required');
                    break;

                case 7:
                    // contest
                    $('.contestData').show('fast');
                    $('.examData').hide('fast');
                    $('.questionType').show('fast');
                    $('input[name="question_type"]').attr('required', true);
                    $('.answerType').hide('fast');
                    $('input[name="answer_type"]').removeAttr('required');
                    $('.quizLevel').hide('fast');
                    $('#level').removeAttr('required');
                    $('.no_contest_exam').hide('fast');
                    $('#marks').removeAttr('required');
                    $('#category').removeAttr('required');
                    $('#contest_id').attr('required', true);
                    $('#exam_id').removeAttr('required');
                    break;

                case 8:
                    // exam
                    $('.examData').show('fast');
                    $('#marks').attr('required', true);
                    $('.contestData').hide('fast');
                    $('.questionType').show('fast');
                    $('input[name="question_type"]').attr('required', true);
                    $('.answerType').hide('fast');
                    $('input[name="answer_type"]').removeAttr('required');
                    $('.quizLevel').hide('fast');
                    $('#level').removeAttr('required');
                    $('.no_contest_exam').hide('fast');
                    $('#category').removeAttr('required');
                    $('#contest_id').removeAttr('required');
                    $('#exam_id').attr('required', true);
                    break;

                default:
                    type = 'sub-category';
                    $('.no_contest_exam').show('fast');
                    $('.questionType').show('fast');
                    $('input[name="question_type"]').attr('required', true);
                    $('.quizLevel').show('fast');
                    $('#level').attr('required', true);
                    $('.answerType').hide('fast');
                    $('input[name="answer_type"]').removeAttr('required');
                    $('.contestData').hide('fast');
                    $('.examData').hide('fast');
                    $('#marks').removeAttr('required');
                    $('#category').attr('required', true);
                    $('#contest_id').removeAttr('required');
                    $('#exam_id').removeAttr('required');
            }

            <?php if (is_language_mode_enabled()) { ?>
                $('#language_id').val('').trigger("change");
            <?php } else { ?>
                getCategorySubcategoryData(0, quizType)
            <?php } ?>

        });

        $('#language_id').on('change', function(e, row_language_id, row_category, row_subcategory) {
            var language_id = $('#language_id').val();
            var quizType = $('#quiz_type').val();
            getCategorySubcategoryData(language_id = 0, quizType, row_language_id = 0, row_category = 0, row_subcategory = 0)
        });


        $('#category').on('change', function(e, row_category, row_subcategroy) {
            var category_id = $('#category').val();
            $.ajax({
                type: 'POST',
                url: base_url + 'get_subcategories_of_category',
                data: 'category_id=' + category_id,
                beforeSend: function() {
                    $('#subcategory').html('<option value=""><?= lang('please_wait'); ?></option>');
                },
                success: function(result) {
                    $('#subcategory').html(result);
                    if (category_id == row_category && row_subcategroy != 0)
                        $('#subcategory').val(row_subcategroy);
                }
            });
        });

        function getCategorySubcategoryData(language_id, quizType, row_language_id, row_category, row_subcategory) {
            if (quizType != 7 && quizType != 8) {
                $.ajax({
                    type: 'POST',
                    url: base_url + 'get_categories_of_language',
                    data: 'language_id=' + language_id + '&type=' + type,
                    beforeSend: function() {
                        $('#category').html('<option value=""><?= lang('please_wait'); ?></option>');
                    },
                    success: function(result) {
                        $('#category').html(result).trigger("change");
                        if (language_id == row_language_id && row_category != 0)
                            $('#category').val(row_category).trigger("change", [row_category, row_subcategory]);
                    }
                });
            } else if (quizType == 7) {
                $.ajax({
                    type: 'POST',
                    url: base_url + 'get_contest_of_language',
                    data: 'language_id=' + language_id,
                    beforeSend: function() {
                        $('#contest_id').html('<option value=""><?= lang('please_wait'); ?></option>');
                    },
                    success: function(result) {
                        $('#contest_id').html(result).trigger("change");
                    }
                });
            } else if (quizType == 8) {
                $.ajax({
                    type: 'POST',
                    url: base_url + 'get_exam_of_language',
                    data: 'language_id=' + language_id,
                    beforeSend: function() {
                        $('#exam_id').html('<option value=""><?= lang('please_wait'); ?></option>');
                    },
                    success: function(result) {
                        $('#exam_id').html(result).trigger("change");
                    }
                });
            }
        }
    </script>

    <script type="text/javascript">
        $('.filterContestData').hide('fast');
        $('.filterExamData').hide('fast');

        function checkStatus(value, row) {
            if (row.status == 1 && $('#status').val()) {
                $('#move_multiple_questions').hide('fast');
                return {
                    disabled: false
                };
            } else if (row.status == 1) {
                $('#move_multiple_questions').show('fast');
                return {
                    disabled: true
                };
            }
        }

        function statusFormatter(value, row) {
            status = '';
            if (row.status == 1) {
                status = "<span class='badge badge-success'><?= lang('moved'); ?></span>";
            } else {
                status = "<span class='badge badge-warning'><?= lang('draft'); ?></span>";
            }
            return status;
        }

        function quizTypeFormatter(value, row) {
            switch (parseInt(row.quiz_type)) {
                case 1:
                    quizType = "<span class='badge badge-primary'><?= lang('quiz_zone'); ?></span>";
                    break;
                case 3:
                    quizType = "<span class='badge badge-light'><?= lang('guess_the_word'); ?></span>";
                    break;
                case 6:
                    quizType = "<span class='badge badge-danger'><?= lang('multi_match'); ?></span>";
                    break;
                case 7:
                    quizType = "<span class='badge badge-secondary'><?= lang('contests'); ?></span>";
                    break;
                case 8:
                    quizType = "<span class='badge badge-success'><?= lang('exam_module'); ?></span>";
                    break;
                default:
                    quizType = '';
                    break;
            }
            return quizType;
        }

        $(document).on('click', '.moveQuestion', function() {
            if (confirm("<?= lang('sure_to_move_question_in_quiz_once_moved_then_not_revoked'); ?>")) {
                var id = $(this).attr("data-id");
                is_multiple = 0;
                $.ajax({
                    url: base_url + 'moveQuestion',
                    type: "POST",
                    data: 'id=' + id + '&is_multiple=' + is_multiple,
                    success: function(result) {
                        console.log(result);

                        if (result && result.trim() !== '') {
                            SuccessMsg("<?= lang('question_moved_successfully'); ?>");
                            $('#question_list').bootstrapTable('refresh');
                        } else {
                            var PERMISSION_ERROR_MSG = "<?= lang(PERMISSION_ERROR_MSG); ?>";
                            ErrorMsg(PERMISSION_ERROR_MSG);
                        }
                    }
                });
            }
        });

        $('#move_multiple_questions').on('click', function(e) {
            var base_url = "<?php echo base_url(); ?>";
            is_multiple = 1;
            table = $('#question_list');
            move_button = $('#move_multiple_questions');
            selected = table.bootstrapTable('getSelections');
            ids = "";
            $.each(selected, function(i, e) {
                ids += e.id + ",";
            });
            ids = ids.slice(0, -1);
            if (ids == "") {
                alert("<?= lang('please_select_questions_to_move'); ?>");
            } else {
                if (confirm("<?= lang('sure_to_move_all_questions'); ?>")) {
                    $.ajax({
                        type: "POST",
                        url: base_url + 'moveQuestion',
                        data: 'ids=' + ids + '&is_multiple=' + is_multiple,
                        beforeSend: function() {
                            move_button.html('<i class="fa fa-spinner fa-pulse"></i>');
                        },
                        success: function(result) {
                            if (result == 1) {
                                alert("<?= lang('question_moved_successfully'); ?>");
                            } else {
                                alert("<?= lang('not_moved_question_try_again'); ?>");
                            }
                            move_button.html('<i class="fa fa-undo"></i>');
                            table.bootstrapTable('refresh');
                        }
                    });
                }
            }
        });


        $('#filter_quiz_type').on('change', function(e) {
            var filter_quiz_type = $('#filter_quiz_type').val() ?? 1;

            switch (parseInt(filter_quiz_type)) {
                case 1:
                    type = 'sub-category';
                    $('.filterContestData').hide('fast');
                    $('.filterExamData').hide('fast');
                    $('.filter_no_contest_exam').show('fast');

                    break;

                case 3:
                    type = 'guess-the-word-category';

                    $('.filterContestData').hide('fast');
                    $('.filterExamData').hide('fast');
                    $('.filter_no_contest_exam').show('fast');

                    break;

                case 6:
                    type = 'multi-match-category';

                    $('.filterContestData').hide('fast');
                    $('.filterExamData').hide('fast');
                    $('.filter_no_contest_exam').show('fast');

                    break;

                case 7:
                    // contest

                    $('.filterContestData').show('fast');
                    $('.filterExamData').hide('fast');
                    $('.filter_no_contest_exam').hide('fast');

                    break;

                case 8:
                    // exam

                    $('.filterContestData').hide('fast');
                    $('.filterExamData').show('fast');
                    $('.filter_no_contest_exam').hide('fast');

                    break;

                default:
                    type = 'sub-category';

                    $('.filterContestData').hide('fast');
                    $('.filterExamData').hide('fast');
                    $('.filter_no_contest_exam').show('fast');


            }

            <?php if (is_language_mode_enabled()) { ?>
                $('#filter_language').val('').trigger("change");
            <?php } else { ?>
                getFilterCategorySubcategoryData(0, filter_quiz_type)
            <?php } ?>

        });

        $('#filter_language').on('change', function(e, row_language_id, row_category, row_subcategory) {
            var language_id = $('#filter_language').val();
            var filterQuizType = $('#filter_quiz_type').val()
            getFilterCategorySubcategoryData(language_id, filterQuizType, row_language_id, row_category, row_subcategory);
        });

        $('#filter_category').on('change', function(e, row_category, row_subcategroy) {
            var category_id = $('#filter_category').val();
            $.ajax({
                type: 'POST',
                url: base_url + 'get_subcategories_of_category',
                data: 'category_id=' + category_id,
                beforeSend: function() {
                    $('#filter_subcategory').html('<option value=""><?= lang('please_wait'); ?></option>');
                },
                success: function(result) {
                    $('#filter_subcategory').html(result);
                    if (category_id == row_category && row_subcategroy != 0)
                        $('#filter_subcategory').val(row_subcategroy);
                }
            });
        });

        function getFilterCategorySubcategoryData(language_id = 0, filterQuizType, row_language_id = 0, row_category = 0, row_subcategory = 0) {
            if (filterQuizType != 7 && filterQuizType != 8) {
                $.ajax({
                    type: 'POST',
                    url: base_url + 'get_categories_of_language',
                    data: 'language_id=' + language_id + '&type=' + type,
                    beforeSend: function() {
                        $('#filter_category').html('<option value=""><?= lang('please_wait'); ?></option>');
                    },
                    success: function(result) {
                        $('#filter_category').html(result).trigger("change");
                        if (language_id == row_language_id && row_category != 0)
                            $('#filter_category').val(row_category).trigger("change", [row_category, row_subcategory]);
                    }
                });
            } else if (filterQuizType == 7) {
                $.ajax({
                    type: 'POST',
                    url: base_url + 'get_contest_of_language',
                    data: 'language_id=' + language_id,
                    beforeSend: function() {
                        $('#filter_contest_id').html('<option value=""><?= lang('please_wait'); ?></option>');
                    },
                    success: function(result) {
                        $('#filter_contest_id').html(result).trigger("change");
                    }
                });
            } else if (filterQuizType == 8) {
                $.ajax({
                    type: 'POST',
                    url: base_url + 'get_exam_of_language',
                    data: 'language_id=' + language_id,
                    beforeSend: function() {
                        $('#filter_exam_id').html('<option value=""><?= lang('please_wait'); ?></option>');
                    },
                    success: function(result) {
                        $('#filter_exam_id').html(result).trigger("change");
                    }
                });
            }
        }

        $('#filter_btn').on('click', function(e) {
            $('#question_list').bootstrapTable('refresh');
        });

        $('#delete_multiple_questions').on('click', function(e) {
            var base_url = "<?php echo base_url(); ?>";
            sec = 'tbl_ai_questions';
            is_image = 0;
            table = $('#question_list');
            delete_button = $('#delete_multiple_questions');
            selected = table.bootstrapTable('getSelections');
            ids = "";
            $.each(selected, function(i, e) {
                ids += e.id + ",";
            });
            ids = ids.slice(0, -1);
            if (ids == "") {
                alert("<?= lang('please_select_questions_to_delete'); ?>");
            } else {
                if (confirm("<?= lang('sure_to_delete_all_questions'); ?>")) {
                    $.ajax({
                        type: "POST",
                        url: base_url + 'delete_multiple',
                        data: 'ids=' + ids + '&sec=' + sec + '&is_image=' + is_image,
                        beforeSend: function() {
                            delete_button.html('<i class="fa fa-spinner fa-pulse"></i>');
                        },
                        success: function(result) {
                            if (result == 1) {
                                alert("<?= lang('questions_deleted_successfully'); ?>");
                            } else {
                                alert("<?= lang('not_delete_question_try_again'); ?>");
                            }
                            delete_button.html('<i class="fa fa-trash"></i>');
                            table.bootstrapTable('refresh');
                        }
                    });
                }
            }
        });

        $(document).on('click', '.delete-data', function() {
            if (confirm("<?= lang('sure_to_delete_questions_releated_data_deleted'); ?>")) {
                var base_url = "<?php echo base_url(); ?>";
                id = $(this).data("id");
                $.ajax({
                    url: base_url + 'delete-ai-questions',
                    type: "POST",
                    data: 'id=' + id,
                    success: function(result) {
                        if (result && result.trim() !== '') {
                            $('#question_list').bootstrapTable('refresh');
                        } else {
                            var PERMISSION_ERROR_MSG = "<?= lang(PERMISSION_ERROR_MSG); ?>";
                            ErrorMsg(PERMISSION_ERROR_MSG);
                        }
                    }
                });
            }
        });

        function queryParams(p) {
            return {
                "language": $('#filter_language').val(),
                "category": $('#filter_category').val(),
                "subcategory": $('#filter_subcategory').val(),
                "contest_id": $('#filter_contest_id').val(),
                "exam_id": $('#filter_exam_id').val(),
                "quiz_type": $('#filter_quiz_type').val(),
                "status": $('#filter_status').val(),
                sort: p.sort,
                order: p.order,
                offset: p.offset,
                limit: p.limit,
                search: p.search
            };
        }
    </script>

    <script>
        $(".select2").each(function() {
            $(this).select2({
                placeholder: $(this).data('placeholder')
            });
        });

        $(function() {
            // Initialize sortable for both lists
            $("#sortable-row, #sortable-row-1").sortable({
                update: function(event, ui) {
                    saveOrder($(this).attr("id"));
                }
            });
        });

        function saveOrder(listId) {
            var selectedOrder = [];
            // Get the IDs of list items for the updated sortable list
            $(`ol#${listId} li`).each(function() {
                selectedOrder.push($(this).attr("id"));
            });
            console.log(selectedOrder.join(','));

            // Update the value of .answer_type2 with the selected order
            $('.answer_type2').val(selectedOrder.join(','));
        }
    </script>
    <script>
        function updateOptions(questionType, answerType) {
            $('#option1_answer1,#option1_answer2, #option2_answer1, #option2_answer2').hide('fast');

            if (questionType == 1 && answerType == 1) {
                $('#option1_answer1').show('fast');
                $('.editOptioncd').show('fast');
                $('.answer_type2').val('').removeAttr('readonly');
            } else if (questionType == 1 && answerType == 2) {
                $('#option1_answer2').show('fast');
                $('.editOptioncd').show('fast');
                answerType = 'a,b,c,d';
                <?php if (is_option_e_mode_enabled()) { ?>
                    $('#e').attr("required", "required");
                    answerType += ',e';
                <?php } ?>
                $('.answer_type2').val(answerType).attr('readonly', 'readonly');
            } else if (questionType == 2 && answerType == 1) {
                $('#option2_answer1').show('fast');
                $('.editOptioncd').hide('fast');
                $('.answer_type2').val('').removeAttr('readonly');
            } else if (questionType == 2 && answerType == 2) {
                $('#option2_answer2').show('fast');
                $('.editOptioncd').hide('fast');
                answerType = 'a,b';
                $('.answer_type2').val(answerType).attr('readonly', 'readonly');
            }
        }

        function quizTypeData(quiz_type) {
            $('#question').attr('required', true);
            switch (parseInt(quiz_type)) {
                case 1:
                    $('.editQuestionAnswerType').show('fast');
                    $('.editAnswer').show('fast');
                    $('.editTextAnswer').hide('fast');
                    $('.editAnswerType').hide('fast');
                    $('.editMultiAnswer').hide('fast');
                    $('.editLevelAnswer').show('fast');

                    $('input[name="edit_question_type"]').attr('required', true);
                    $('#a').attr('required', true);
                    $('#b').attr('required', true);

                    break;
                case 3:
                    $('.editTextAnswer').show('fast');
                    $('.editQuestionAnswerType').hide('fast');
                    $('.editOptionab').hide('fast');
                    $('.editOptioncd').hide('fast');
                    $('.editLevelAnswer').hide('fast');
                    $('.editAnswer').hide('fast');
                    $('.editMultiAnswer').hide('fast');

                    $('input[name="edit_question_type"]').removeAttr('required');

                    break;
                case 6:

                    $('.editTextAnswer').hide('fast');
                    $('.editQuestionAnswerType').show('fast');
                    $('.editLevelAnswer').show('fast');
                    $('.editAnswer').hide('fast');
                    $('.editAnswerType').show('fast');
                    $('.editMultiAnswer').show('fast');

                    break;

                case 7:
                    // contest
                    $('.editLevel').hide('fast');
                    $('.editQuestionAnswerType').show('fast');
                    $('.editAnswer').show('fast');
                    $('.editTextAnswer').hide('fast');
                    $('.editAnswerType').hide('fast');
                    $('.editMultiAnswer').hide('fast');

                    $('input[name="edit_question_type"]').attr('required', true);
                    $('#a').attr('required', true);
                    $('#b').attr('required', true);
                    break;
                case 8:
                    // exam
                    $('.editTextAnswer').hide('fast');
                    $('.editAnswerType').hide('fast');
                    $('.editQuestionAnswerType').show('fast');
                    $('.editAnswer').show('fast');
                    $('.editMultiAnswer').hide('fast');
                    $('.editLevel').hide('fast');

                    $('input[name="edit_question_type"]').attr('required', true);
                    $('#a').attr('required', true);
                    $('#b').attr('required', true);
                    break;
                default:
                    $('.editQuestionAnswerType').show('fast');
                    $('.editAnswer').show('fast');
                    $('.editTextAnswer').hide('fast');
                    $('.editAnswerType').hide('fast');
                    $('.editMultiAnswer').hide('fast');
                    $('.editLevelAnswer').show('fast');
            }
        }


        function setAttrData(quiz_type, question_type, answer_type = 0) {

            const req = id => $('#' + id).attr('required', true);
            const unreq = id => $('#' + id).removeAttr('required');
            const reqInputs = names => names.forEach(n => $('input[name="' + n + '"]').attr('required', true));
            const unreqInputs = names => names.forEach(n => $('input[name="' + n + '"]').removeAttr('required'));



            const allFields = ['a', 'b', 'c', 'd', 'e', 'answer', 'textAnswer', 'answer1', 'answer_tf', 'option1_answer2_answer_type2', 'option2_answer2_answer_type2', 'edit_level'];
            allFields.forEach(unreq);
            unreqInputs(['edit_question_type', 'edit_answer_type']);

            // Common
            req('question');

            const handleOptions = () => {
                req('a');
                req('b');
                if (question_type == 1) {
                    req('c');
                    req('d');
                    <?php if (is_option_e_mode_enabled()) { ?>
                        req('e');
                    <?php } ?>
                } else {
                    ['c', 'd', 'e'].forEach(unreq);
                }
            };

            switch (parseInt(quiz_type)) {
                case 1:
                    reqInputs(['edit_question_type']);
                    handleOptions();
                    req('answer');
                    req('edit_level');
                    unreq('textAnswer');
                    unreqInputs(['edit_answer_type']);
                    unreq('answer1');
                    unreq('answer_tf');
                    unreq('option1_answer2_answer_type2');
                    unreq('option2_answer2_answer_type2');
                    break;
                case 3:
                    req('textAnswer');
                    unreqInputs(['edit_question_type', 'edit_answer_type']);
                    break;
                case 6:
                    reqInputs(['edit_question_type', 'edit_answer_type']);
                    handleOptions();
                    req('edit_level');
                    unreq('answer');
                    unreq('textAnswer');

                    if (answer_type == 1) {
                        ['option1_answer2_answer_type2', 'option2_answer2_answer_type2'].forEach(unreq);
                        if (question_type == 1) {
                            req('answer1');
                        } else {
                            req('answer_tf');
                        }
                    } else if (answer_type == 2) {
                        ['answer1', 'answer_tf'].forEach(unreq);
                        if (question_type == 1) {
                            req('option1_answer2_answer_type2');
                        } else {
                            req('option2_answer2_answer_type2');
                        }
                    }
                    break;
                case 7:
                    // contest
                    reqInputs(['edit_question_type']);
                    handleOptions();
                    req('answer');
                    unreq('textAnswer');
                    unreq('edit_level');
                    unreqInputs(['edit_answer_type']);
                    ['answer1', 'answer_tf', 'option1_answer2_answer_type2', 'option2_answer2_answer_type2'].forEach(unreq);
                    break;
                case 8:
                    // exam
                    reqInputs(['edit_question_type']);
                    handleOptions();
                    req('answer');
                    unreq('textAnswer');
                    unreq('edit_level');
                    unreqInputs(['edit_answer_type']);
                    ['answer1', 'answer_tf', 'option1_answer2_answer_type2', 'option2_answer2_answer_type2'].forEach(unreq);
                    break;
                default:
            }
        }


        var quizTypeVal = 0;
        window.actionEvents = {
            'click .edit-data': function(e, value, row, index) {
                var quiz_type = quizTypeVal = row.quiz_type ?? 1;
                var questionType = row.question_type ?? 0;
                var answerType = row.answer_type ?? 0;
                var answer = row.answer ?? '';


                quizTypeData(quiz_type);
                setAttrData(quiz_type, questionType, answerType)
                $('#edit_id').val(row.id);
                $('#question').val(row.question);
                $('#note').val(row.note);

                if (quiz_type == 3) {
                    $('#textAnswer').val(row.answer);
                } else {
                    $('.editOptionab').show('fast');
                    $('#a').val(row.optiona);
                    $('#b').val(row.optionb);
                    $('#c').val(row.optionc);
                    $('#d').val(row.optiond);
                    $('#e').val(row.optione);
                    if (quiz_type != 7 && quiz_type != 8) {
                        $('#edit_level').val(row.level);
                    }
                    $("input[name='edit_question_type'][value='" + row.question_type + "']").prop('checked', true);
                    $("input[name='edit_answer_type'][value='" + row.answer_type + "']").prop('checked', true);
                    if (quiz_type != 6) {
                        $('#answer').val(row.answer);
                    } else if (quiz_type == 6) {
                        updateOptions(questionType, answerType);
                    }
                }

                if (questionType == 1) {
                    $('.editOptioncd').show('fast');
                    if (quiz_type == 6) {
                        if (answerType == 1) {
                            let selectedValues = answer.split(',');
                            $('#answer1').val(selectedValues).trigger('change');
                        } else if (answerType == 2) {
                            $('.answer_type2').val(answer);
                            var elems = $('ol#sortable-row').children('li');
                            $('ol#sortable-row').html();
                            var newOrder = (answer).split(',');
                            var temp = [];
                            for (i = 0; i < newOrder.length; i++) {
                                for (j = 0; j < elems.length; j++) {
                                    if (elems[j].id === newOrder[i]) {
                                        temp.push(elems[j]);
                                        break;
                                    }

                                }
                            }
                            $('ol#sortable-row').prepend(temp);
                        }
                    }
                } else if (questionType == 2) {
                    $('.editOptioncd').hide('fast');
                    if (quiz_type == 6) {
                        if (answerType == 1) {
                            let selectedValues = answer.split(',');
                            $('#answer_tf').val(selectedValues).trigger('change');
                        } else if (answerType == 2) {
                            $('.answer_type2').val(answer);
                            var elems = $('ol#sortable-row-1').children('li');
                            $('ol#sortable-row-1').html();
                            var newOrder = (answer).split(',');
                            var temp = [];
                            for (i = 0; i < newOrder.length; i++) {
                                for (j = 0; j < elems.length; j++) {
                                    if (elems[j].id === newOrder[i]) {
                                        temp.push(elems[j]);
                                        break;
                                    }

                                }
                            }
                            $('ol#sortable-row-1').prepend(temp);
                        }
                    }
                }
            }


        }

        $('input[name="edit_question_type"], input[name="edit_answer_type"]').on("click", function() {
            var questionType = $('input[name="edit_question_type"]:checked').val();
            answerType = 0;
            if (quizTypeVal == 6) {
                var answerType = $('input[name="edit_answer_type"]:checked').val();
                $('.answer_type2').val('').removeAttr('readonly');
                updateOptions(questionType, answerType);
            } else {
                $('#answer').val('').trigger('change');
                if (questionType == 1) {
                    $('.editOptioncd').show('fast');
                } else if (questionType == 2) {
                    $('.editOptioncd').hide('fast');
                }
            }
            setAttrData(quizTypeVal, questionType, answerType)
        });
    </script>

</body>

</html>