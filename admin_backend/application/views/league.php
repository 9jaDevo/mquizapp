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
                                        <form method="post" action="<?php echo base_url('league'); ?>" class="needs-validation" novalidate>
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
                                                    <th>Start</th>
                                                    <th>End</th>
                                                    <th>Entry</th>
                                                    <th>Status</th>
                                                    <th>Actions</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <?php if (!empty($league)): foreach ($league as $row): ?>
                                                        <tr>
                                                            <td><?php echo (int)$row->id; ?></td>
                                                            <td><?php echo htmlspecialchars($row->name, ENT_QUOTES, 'UTF-8'); ?></td>
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
                                                                <a class="btn btn-sm btn-primary" href="<?php echo base_url('league-prize/' . (int)$row->id); ?>">Prizes</a>
                                                                <a class="btn btn-sm btn-success" href="<?php echo base_url('league-prize-distribute/' . (int)$row->id); ?>">Distribute</a>
                                                            </td>
                                                        </tr>
                                                    <?php endforeach;
                                                else: ?>
                                                    <tr>
                                                        <td colspan="7" class="text-center">No leagues found.</td>
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

    <?php base_url() . include 'footer.php'; ?>
</body>

</html>