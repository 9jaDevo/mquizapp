<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta content="width=device-width, initial-scale=1, maximum-scale=1, shrink-to-fit=no" name="viewport">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>League Management | <?php echo (is_settings('app_name')) ? is_settings('app_name') : ''; ?></title>
    <?php base_url() . include 'include.php'; ?>
</head>

<body>
    <div id="app">
        <div class="main-wrapper">
            <?php base_url() . include 'header.php'; ?>

            <div class="main-content">
                <section class="section">
                    <div class="section-header">
                        <h1>League Management</h1>
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
                                        <h4>Create League</h4>
                                    </div>
                                    <div class="card-body">
                                        <form method="post" action="<?php echo base_url('league'); ?>" class="needs-validation" novalidate enctype="multipart/form-data">
                                            <input type="hidden" name="<?php echo $this->security->get_csrf_token_name(); ?>" value="<?php echo $this->security->get_csrf_hash(); ?>">
                                            <input type="hidden" name="btnadd" value="1">

                                            <div class="row">
                                                <div class="form-group col-md-6 col-sm-12">
                                                    <label>Name <small class="text-danger">*</small></label>
                                                    <input type="text" name="name" class="form-control" placeholder="League name" required>
                                                </div>
                                                <div class="form-group col-md-6 col-sm-12">
                                                    <label>Language</label>
                                                    <select name="language_id" class="form-control">
                                                        <option value="0">All Languages</option>
                                                        <?php if (!empty($language)): foreach ($language as $l): ?>
                                                                <?php $languageLabel = !empty($l->language) ? $l->language : (!empty($l->name) ? $l->name : ('Language #' . (int)$l->id)); ?>
                                                                <option value="<?php echo (int)$l->id; ?>"><?php echo htmlspecialchars($languageLabel, ENT_QUOTES, 'UTF-8'); ?></option>
                                                        <?php endforeach;
                                                        endif; ?>
                                                    </select>
                                                </div>
                                            </div>

                                            <div class="row">
                                                <div class="form-group col-md-6 col-sm-12">
                                                    <label>Start Date <small class="text-danger">*</small></label>
                                                    <input type="datetime-local" name="start_date" class="form-control" required>
                                                </div>
                                                <div class="form-group col-md-6 col-sm-12">
                                                    <label>End Date <small class="text-danger">*</small></label>
                                                    <input type="datetime-local" name="end_date" class="form-control" required>
                                                </div>
                                            </div>

                                            <div class="row">
                                                <div class="form-group col-md-6 col-sm-12">
                                                    <label>Entry Coins <small class="text-danger">*</small></label>
                                                    <input type="number" name="entry" class="form-control" placeholder="Entry coins" value="0" min="0" required>
                                                </div>
                                                <div class="form-group col-md-6 col-sm-12">
                                                    <label>Description</label>
                                                    <textarea name="description" class="form-control" rows="3" placeholder="Description"></textarea>
                                                </div>
                                            </div>

                                            <div class="row">
                                                <div class="form-group col-md-6 col-sm-12">
                                                    <label>League Image <small class="text-muted">(optional)</small></label>
                                                    <input type="file" name="file" class="form-control" accept="image/*">
                                                    <small class="text-muted">Allowed: jpg, jpeg, png, webp</small>
                                                </div>
                                            </div>

                                            <div class="form-group">
                                                <button type="submit" class="<?php echo BUTTON_CLASS; ?>">Create League</button>
                                                <a href="<?php echo base_url('league-daily-quiz'); ?>" class="btn btn-outline-primary ml-2">Assign Daily Quiz</a>
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
                                        <h4>Existing Leagues</h4>
                                    </div>
                                    <div class="card-body table-responsive">
                                        <table class="table table-bordered table-striped">
                                            <thead>
                                                <tr>
                                                    <th>ID</th>
                                                    <th>Name</th>
                                                    <th>Image</th>
                                                    <th>Start</th>
                                                    <th>End</th>
                                                    <th>Entry</th>
                                                    <th>Status</th>
                                                    <th>Actions</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <?php if (!empty($league)): foreach ($league as $row): ?>
                                                        <?php $rowImage = $row->image ?? ''; ?>
                                                        <tr>
                                                            <td><?php echo (int)$row->id; ?></td>
                                                            <td><?php echo htmlspecialchars($row->name, ENT_QUOTES, 'UTF-8'); ?></td>
                                                            <td>
                                                                <?php if (!empty($rowImage)): ?>
                                                                    <img src="<?php echo base_url(LEAGUE_IMG_PATH . $rowImage); ?>" alt="league-image" style="width:60px;height:40px;object-fit:cover;border-radius:6px;">
                                                                <?php else: ?>
                                                                    <span class="text-muted">-</span>
                                                                <?php endif; ?>
                                                            </td>
                                                            <td><?php echo htmlspecialchars($row->start_date, ENT_QUOTES, 'UTF-8'); ?></td>
                                                            <td><?php echo htmlspecialchars($row->end_date, ENT_QUOTES, 'UTF-8'); ?></td>
                                                            <td><?php echo (int)$row->entry; ?></td>
                                                            <td>
                                                                <?php if ((int)$row->status === 1): ?>
                                                                    <span class="badge badge-success">Active</span>
                                                                <?php else: ?>
                                                                    <span class="badge badge-secondary">Inactive</span>
                                                                <?php endif; ?>
                                                            </td>
                                                            <td>
                                                                <?php
                                                                $editLanguageId = isset($row->language_id) ? (int)$row->language_id : 0;
                                                                $editDescription = isset($row->description) ? $row->description : '';
                                                                ?>
                                                                <button
                                                                    type="button"
                                                                    class="btn btn-sm btn-warning"
                                                                    onclick="openEditLeagueModal(this)"
                                                                    data-id="<?php echo (int)$row->id; ?>"
                                                                    data-name="<?php echo htmlspecialchars($row->name, ENT_QUOTES, 'UTF-8'); ?>"
                                                                    data-language-id="<?php echo $editLanguageId; ?>"
                                                                    data-start-date="<?php echo htmlspecialchars($row->start_date, ENT_QUOTES, 'UTF-8'); ?>"
                                                                    data-end-date="<?php echo htmlspecialchars($row->end_date, ENT_QUOTES, 'UTF-8'); ?>"
                                                                    data-entry="<?php echo (int)$row->entry; ?>"
                                                                    data-image="<?php echo !empty($rowImage) ? htmlspecialchars($rowImage, ENT_QUOTES, 'UTF-8') : ''; ?>"
                                                                    data-description="<?php echo htmlspecialchars($editDescription, ENT_QUOTES, 'UTF-8'); ?>">
                                                                    Edit
                                                                </button>
                                                                <button type="button" class="btn btn-sm btn-danger ml-1" onclick="deleteLeague(<?php echo (int)$row->id; ?>)">Delete</button>
                                                                <a class="btn btn-sm btn-primary" href="<?php echo base_url('league-prize/' . (int)$row->id); ?>">Prizes</a>
                                                                <a class="btn btn-sm btn-success" href="<?php echo base_url('league-prize-distribute/' . (int)$row->id); ?>">Distribute</a>
                                                            </td>
                                                        </tr>
                                                    <?php endforeach;
                                                else: ?>
                                                    <tr>
                                                        <td colspan="8" class="text-center">No leagues found.</td>
                                                    </tr>
                                                <?php endif; ?>
                                            </tbody>
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

    <div class="modal fade" id="editLeagueModal" tabindex="-1" role="dialog" aria-labelledby="editLeagueModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="editLeagueModalLabel">Edit League</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <form method="post" action="<?php echo base_url('league'); ?>" class="needs-validation" novalidate enctype="multipart/form-data">
                    <div class="modal-body">
                        <input type="hidden" name="<?php echo $this->security->get_csrf_token_name(); ?>" value="<?php echo $this->security->get_csrf_hash(); ?>">
                        <input type="hidden" name="btnupdate" value="1">
                        <input type="hidden" name="edit_id" id="edit_id" value="">
                        <input type="hidden" name="old_image" id="edit_old_image" value="">

                        <div class="row">
                            <div class="form-group col-md-6 col-sm-12">
                                <label>Name <small class="text-danger">*</small></label>
                                <input type="text" name="name" id="edit_name" class="form-control" required>
                            </div>
                            <div class="form-group col-md-6 col-sm-12">
                                <label>Language</label>
                                <select name="language_id" id="edit_language_id" class="form-control">
                                    <option value="0">All Languages</option>
                                    <?php if (!empty($language)): foreach ($language as $l): ?>
                                            <?php $languageLabel = !empty($l->language) ? $l->language : (!empty($l->name) ? $l->name : ('Language #' . (int)$l->id)); ?>
                                            <option value="<?php echo (int)$l->id; ?>"><?php echo htmlspecialchars($languageLabel, ENT_QUOTES, 'UTF-8'); ?></option>
                                    <?php endforeach;
                                    endif; ?>
                                </select>
                            </div>
                        </div>

                        <div class="row">
                            <div class="form-group col-md-6 col-sm-12">
                                <label>Start Date <small class="text-danger">*</small></label>
                                <input type="datetime-local" name="start_date" id="edit_start_date" class="form-control" required>
                            </div>
                            <div class="form-group col-md-6 col-sm-12">
                                <label>End Date <small class="text-danger">*</small></label>
                                <input type="datetime-local" name="end_date" id="edit_end_date" class="form-control" required>
                            </div>
                        </div>

                        <div class="row">
                            <div class="form-group col-md-6 col-sm-12">
                                <label>Entry Coins <small class="text-danger">*</small></label>
                                <input type="number" name="entry" id="edit_entry" class="form-control" min="0" required>
                            </div>
                            <div class="form-group col-md-6 col-sm-12">
                                <label>Description</label>
                                <textarea name="description" id="edit_description" class="form-control" rows="3"></textarea>
                            </div>
                        </div>

                        <div class="row">
                            <div class="form-group col-md-6 col-sm-12">
                                <label>League Image <small class="text-muted">(leave blank to keep current)</small></label>
                                <input type="file" name="update_file" id="edit_update_file" class="form-control" accept="image/*">
                            </div>
                            <div class="form-group col-md-6 col-sm-12" id="edit_image_preview_wrap" style="display:none;">
                                <label>Current Image</label>
                                <div>
                                    <img id="edit_image_preview" src="" alt="current-league-image" style="width:120px;height:80px;object-fit:cover;border-radius:8px;">
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                        <button type="submit" class="<?php echo BUTTON_CLASS; ?>">Update League</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <?php base_url() . include 'footer.php'; ?>

    <script>
        function normalizeDateTimeForInput(value) {
            if (!value) {
                return '';
            }

            var normalized = value.replace(' ', 'T');
            return normalized.length >= 16 ? normalized.substring(0, 16) : normalized;
        }

        function openEditLeagueModal(button) {
            document.getElementById('edit_id').value = button.getAttribute('data-id') || '';
            document.getElementById('edit_name').value = button.getAttribute('data-name') || '';
            document.getElementById('edit_language_id').value = button.getAttribute('data-language-id') || '0';
            document.getElementById('edit_start_date').value = normalizeDateTimeForInput(button.getAttribute('data-start-date'));
            document.getElementById('edit_end_date').value = normalizeDateTimeForInput(button.getAttribute('data-end-date'));
            document.getElementById('edit_entry').value = button.getAttribute('data-entry') || '0';
            document.getElementById('edit_description').value = button.getAttribute('data-description') || '';

            var imageName = button.getAttribute('data-image') || '';
            document.getElementById('edit_old_image').value = imageName;

            var previewWrap = document.getElementById('edit_image_preview_wrap');
            var previewImg = document.getElementById('edit_image_preview');
            if (imageName) {
                previewImg.src = '<?php echo base_url(LEAGUE_IMG_PATH); ?>' + imageName;
                previewWrap.style.display = '';
            } else {
                previewImg.src = '';
                previewWrap.style.display = 'none';
            }

            $('#editLeagueModal').modal('show');
        }

        function deleteLeague(id) {
            if (!confirm('Are you sure you want to delete this league? This action cannot be undone.')) {
                return;
            }

            var xhr = new XMLHttpRequest();
            xhr.open('POST', '<?php echo base_url('delete_league'); ?>', true);
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