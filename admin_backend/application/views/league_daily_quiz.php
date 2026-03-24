<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta content="width=device-width, initial-scale=1, maximum-scale=1, shrink-to-fit=no" name="viewport">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>League Daily Quiz | <?php echo (is_settings('app_name')) ? is_settings('app_name') : ''; ?></title>
    <?php base_url() . include 'include.php'; ?>
</head>

<body>
    <div id="app">
        <div class="main-wrapper">
            <?php base_url() . include 'header.php'; ?>

            <div class="main-content">
                <section class="section">
                    <div class="section-header">
                        <h1>League Daily Quiz Assignment</h1>
                    </div>

                    <div class="section-body">
                        <?php if ($this->session->flashdata('success')): ?>
                            <div class="alert alert-success"><?php echo $this->session->flashdata('success'); ?></div>
                        <?php endif; ?>
                        <?php if ($this->session->flashdata('error')): ?>
                            <div class="alert alert-danger"><?php echo $this->session->flashdata('error'); ?></div>
                        <?php endif; ?>

                        <div class="row">
                            <div class="col-12">
                                <div class="card">
                                    <div class="card-header">
                                        <h4>Assign Daily Quiz</h4>
                                    </div>
                                    <div class="card-body">
                                        <form method="post" action="<?php echo base_url('league-daily-quiz'); ?>" class="needs-validation" novalidate>
                                            <input type="hidden" name="<?php echo $this->security->get_csrf_token_name(); ?>" value="<?php echo $this->security->get_csrf_hash(); ?>">
                                            <input type="hidden" name="btnadd" value="1">

                                            <div class="row">
                                                <div class="form-group col-md-4 col-sm-12">
                                                    <label>League <small class="text-danger">*</small></label>
                                                    <select name="league_id" class="form-control" required>
                                                        <option value="">Select league</option>
                                                        <?php if (!empty($league)): foreach ($league as $l): ?>
                                                                <option value="<?php echo (int)$l->id; ?>"><?php echo htmlspecialchars($l->name, ENT_QUOTES, 'UTF-8'); ?></option>
                                                        <?php endforeach;
                                                        endif; ?>
                                                    </select>
                                                </div>

                                                <div class="form-group col-md-4 col-sm-12">
                                                    <label>Quiz Day <small class="text-danger">*</small></label>
                                                    <input type="number" name="quiz_day" min="1" class="form-control" required>
                                                </div>

                                                <div class="form-group col-md-4 col-sm-12">
                                                    <label>Quiz Date <small class="text-danger">*</small></label>
                                                    <input type="date" name="quiz_date" class="form-control" required>
                                                </div>
                                            </div>

                                            <div class="row">
                                                <div class="form-group col-12">
                                                    <label>Assignment Mode <small class="text-danger">*</small></label>
                                                    <div>
                                                        <div class="custom-control custom-radio custom-control-inline">
                                                            <input type="radio" id="assignment_mode_manual" name="assignment_mode" value="manual" class="custom-control-input" checked>
                                                            <label class="custom-control-label" for="assignment_mode_manual">Manual (existing flow)</label>
                                                        </div>
                                                        <div class="custom-control custom-radio custom-control-inline">
                                                            <input type="radio" id="assignment_mode_auto" name="assignment_mode" value="auto" class="custom-control-input">
                                                            <label class="custom-control-label" for="assignment_mode_auto">Automatic (category-based)</label>
                                                        </div>
                                                    </div>
                                                    <small class="text-muted">Automatic mode only changes admin assignment workflow. Mobile API response contracts remain unchanged.</small>
                                                </div>
                                            </div>

                                            <div class="row" id="manualAssignmentSection">
                                                <div class="form-group col-12">
                                                    <label>Questions (multi-select) <small class="text-danger">*</small></label>
                                                    <select name="question_ids[]" id="manual_question_ids" class="form-control" multiple size="12" required>
                                                        <?php if (!empty($questions)): foreach ($questions as $q): ?>
                                                                <option value="<?php echo (int)$q->id; ?>"><?php echo (int)$q->id . ' - ' . htmlspecialchars(substr($q->question, 0, 120), ENT_QUOTES, 'UTF-8'); ?></option>
                                                        <?php endforeach;
                                                        endif; ?>
                                                    </select>
                                                    <small class="text-muted">Hold Ctrl/Cmd to select multiple questions.</small>
                                                </div>
                                            </div>

                                            <div class="row" id="autoAssignmentSection" style="display:none;">
                                                <div class="form-group col-md-4 col-sm-12">
                                                    <label>Category <small class="text-danger">*</small></label>
                                                    <select name="category_id" id="auto_category_id" class="form-control">
                                                        <option value="">Select category</option>
                                                        <?php if (!empty($categories)): foreach ($categories as $cat): ?>
                                                                <?php $catLabel = !empty($cat->category_name) ? $cat->category_name : (!empty($cat->name) ? $cat->name : ('Category #' . (int)$cat->id)); ?>
                                                                <option value="<?php echo (int)$cat->id; ?>"><?php echo htmlspecialchars($catLabel, ENT_QUOTES, 'UTF-8'); ?></option>
                                                        <?php endforeach;
                                                        endif; ?>
                                                    </select>
                                                </div>

                                                <div class="form-group col-md-4 col-sm-12">
                                                    <label>Subcategory (optional)</label>
                                                    <select name="subcategory_id" id="auto_subcategory_id" class="form-control">
                                                        <option value="0">All subcategories</option>
                                                        <?php if (!empty($subcategories)): foreach ($subcategories as $sub): ?>
                                                                <?php $subLabel = !empty($sub->subcategory_name) ? $sub->subcategory_name : (!empty($sub->name) ? $sub->name : ('Subcategory #' . (int)$sub->id)); ?>
                                                                <option value="<?php echo (int)$sub->id; ?>" data-maincat="<?php echo (int)$sub->maincat_id; ?>"><?php echo htmlspecialchars($subLabel, ENT_QUOTES, 'UTF-8'); ?></option>
                                                        <?php endforeach;
                                                        endif; ?>
                                                    </select>
                                                </div>

                                                <div class="form-group col-md-4 col-sm-12">
                                                    <label>Question Count <small class="text-danger">*</small></label>
                                                    <input type="number" name="question_count" id="auto_question_count" class="form-control" min="1" max="100" value="20">
                                                </div>

                                                <div class="form-group col-md-4 col-sm-12">
                                                    <label>Easy %</label>
                                                    <input type="number" name="easy_percent" id="auto_easy_percent" class="form-control" min="0" max="100" value="30">
                                                </div>

                                                <div class="form-group col-md-4 col-sm-12">
                                                    <label>Medium %</label>
                                                    <input type="number" name="medium_percent" id="auto_medium_percent" class="form-control" min="0" max="100" value="50">
                                                </div>

                                                <div class="form-group col-md-4 col-sm-12">
                                                    <label>Hard %</label>
                                                    <input type="number" name="hard_percent" id="auto_hard_percent" class="form-control" min="0" max="100" value="20">
                                                </div>

                                                <div class="form-group col-12">
                                                    <small class="text-muted">If strict filters cannot fill the requested count, the system will auto-relax filters (subcategory, then difficulty, then language) to complete assignment.</small>
                                                </div>
                                            </div>

                                            <div class="form-group">
                                                <button type="submit" class="<?php echo BUTTON_CLASS; ?>">Assign Daily Quiz</button>
                                                <a href="<?php echo base_url('league'); ?>" class="btn btn-outline-secondary ml-2">Back to Leagues</a>
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
                                        <h4>Assigned Daily Quiz Links</h4>
                                    </div>
                                    <div class="card-body table-responsive">
                                        <table class="table table-bordered table-striped">
                                            <thead>
                                                <tr>
                                                    <th>ID</th>
                                                    <th>League</th>
                                                    <th>Quiz Day</th>
                                                    <th>Quiz Date</th>
                                                    <th>Questions</th>
                                                    <th>Assigned On</th>
                                                    <th>Actions</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <?php if (!empty($assignments)): foreach ($assignments as $item): ?>
                                                        <tr>
                                                            <td><?php echo (int)$item->id; ?></td>
                                                            <td>
                                                                <select name="league_id" form="update_assignment_<?php echo (int)$item->id; ?>" class="form-control form-control-sm mr-2" required>
                                                                    <?php if (!empty($league)): foreach ($league as $l): ?>
                                                                            <option value="<?php echo (int)$l->id; ?>" <?php echo ((int)$l->id === (int)$item->league_id) ? 'selected' : ''; ?>><?php echo htmlspecialchars($l->name, ENT_QUOTES, 'UTF-8'); ?></option>
                                                                    <?php endforeach;
                                                                    endif; ?>
                                                                </select>
                                                            </td>
                                                            <td>
                                                                <input type="number" name="quiz_day" form="update_assignment_<?php echo (int)$item->id; ?>" min="1" value="<?php echo (int)$item->quiz_day; ?>" class="form-control form-control-sm" required>
                                                            </td>
                                                            <td>
                                                                <input type="date" name="quiz_date" form="update_assignment_<?php echo (int)$item->id; ?>" value="<?php echo htmlspecialchars(substr((string)$item->quiz_date, 0, 10), ENT_QUOTES, 'UTF-8'); ?>" class="form-control form-control-sm" required>
                                                            </td>
                                                            <td><?php echo (int)$item->question_count; ?></td>
                                                            <td><?php echo htmlspecialchars($item->date_assigned, ENT_QUOTES, 'UTF-8'); ?></td>
                                                            <td>
                                                                <form id="update_assignment_<?php echo (int)$item->id; ?>" method="post" action="<?php echo base_url('league-daily-quiz'); ?>" class="d-inline-block">
                                                                    <input type="hidden" name="<?php echo $this->security->get_csrf_token_name(); ?>" value="<?php echo $this->security->get_csrf_hash(); ?>">
                                                                    <input type="hidden" name="btnupdate" value="1">
                                                                    <input type="hidden" name="edit_id" value="<?php echo (int)$item->id; ?>">
                                                                    <button type="submit" class="btn btn-sm btn-primary">Update</button>
                                                                </form>
                                                                <button type="button" class="btn btn-sm btn-danger ml-2" onclick="deleteDailyQuiz(<?php echo (int)$item->id; ?>)">Delete</button>
                                                            </td>
                                                        </tr>
                                                    <?php endforeach;
                                                else: ?>
                                                    <tr>
                                                        <td colspan="7" class="text-center">No daily quiz links assigned yet.</td>
                                                    </tr>
                                                <?php endif; ?>
                                            </tbody>
                                        </table>
                                        <small class="text-muted">Note: To update question set/order, re-assign the same League + Quiz Day using the form above.</small>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>
            </div>
        </div>
    </div>

    <?php base_url() . include 'footer.php'; ?>
    <script>
        (function() {
            var manualMode = document.getElementById('assignment_mode_manual');
            var autoMode = document.getElementById('assignment_mode_auto');
            var manualSection = document.getElementById('manualAssignmentSection');
            var autoSection = document.getElementById('autoAssignmentSection');
            var manualQuestionIds = document.getElementById('manual_question_ids');
            var autoCategory = document.getElementById('auto_category_id');
            var autoQuestionCount = document.getElementById('auto_question_count');
            var autoSubcategory = document.getElementById('auto_subcategory_id');

            function toggleSections() {
                var isAuto = autoMode.checked;
                manualSection.style.display = isAuto ? 'none' : '';
                autoSection.style.display = isAuto ? '' : 'none';

                manualQuestionIds.required = !isAuto;
                autoCategory.required = isAuto;
                autoQuestionCount.required = isAuto;
            }

            function filterSubcategories() {
                var selectedCategory = autoCategory.value;
                var options = autoSubcategory.querySelectorAll('option[data-maincat]');
                options.forEach(function(option) {
                    option.style.display = (!selectedCategory || option.getAttribute('data-maincat') === selectedCategory) ? '' : 'none';
                });

                if (autoSubcategory.selectedOptions.length > 0 && autoSubcategory.selectedOptions[0].style.display === 'none') {
                    autoSubcategory.value = '0';
                }
            }

            manualMode.addEventListener('change', toggleSections);
            autoMode.addEventListener('change', toggleSections);
            autoCategory.addEventListener('change', filterSubcategories);

            toggleSections();
            filterSubcategories();
        })();

        function deleteDailyQuiz(id) {
            if (!confirm('Are you sure you want to delete this daily quiz link?')) {
                return;
            }

            var xhr = new XMLHttpRequest();
            xhr.open('POST', '<?php echo base_url('delete_league_daily_quiz'); ?>', true);
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4) {
                    if (xhr.status === 200 && xhr.responseText) {
                        window.location.reload();
                    } else {
                        alert('Delete failed or permission denied.');
                    }
                }
            };

            var csrfName = '<?php echo $this->security->get_csrf_token_name(); ?>';
            var csrfHash = '<?php echo $this->security->get_csrf_hash(); ?>';
            var payload = 'id=' + encodeURIComponent(id) + '&' + encodeURIComponent(csrfName) + '=' + encodeURIComponent(csrfHash);
            xhr.send(payload);
        }
    </script>
</body>

</html>