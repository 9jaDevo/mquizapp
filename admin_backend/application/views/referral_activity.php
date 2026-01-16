<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta content="width=device-width, initial-scale=1, maximum-scale=1, shrink-to-fit=no" name="viewport">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>Referral Activity Log | <?php echo (is_settings('app_name')) ? is_settings('app_name') : "" ?></title>

    <?php base_url() . include 'include.php'; ?>
</head>

<body>
    <div id="app">
        <div class="main-wrapper">
            <?php base_url() . include 'header.php'; ?>

            <!-- Main Content -->
            <div class="main-content">
                <section class="section">
                    <div class="section-header">
                        <h1>Referral Activity Log <small>Track Referee Progress</small></h1>
                    </div>
                    <div class="section-body">

                        <!-- Filters -->
                        <div class="row">
                            <div class="col-12">
                                <div class="card">
                                    <div class="card-header">
                                        <h4>Filter Activity</h4>
                                    </div>
                                    <div class="card-body">
                                        <form method="GET" action="">
                                            <div class="row">
                                                <div class="col-md-3">
                                                    <div class="form-group">
                                                        <label>Status</label>
                                                        <select name="status" class="form-control">
                                                            <option value="">All Statuses</option>
                                                            <option value="pending" <?= (isset($_GET['status']) && $_GET['status'] == 'pending') ? 'selected' : '' ?>>Pending</option>
                                                            <option value="qualified" <?= (isset($_GET['status']) && $_GET['status'] == 'qualified') ? 'selected' : '' ?>>Qualified</option>
                                                            <option value="rewarded" <?= (isset($_GET['status']) && $_GET['status'] == 'rewarded') ? 'selected' : '' ?>>Rewarded</option>
                                                            <option value="rejected" <?= (isset($_GET['status']) && $_GET['status'] == 'rejected') ? 'selected' : '' ?>>Rejected</option>
                                                        </select>
                                                    </div>
                                                </div>
                                                <div class="col-md-3">
                                                    <div class="form-group">
                                                        <label>Date From</label>
                                                        <input type="date" name="from_date" class="form-control" value="<?= $_GET['from_date'] ?? '' ?>">
                                                    </div>
                                                </div>
                                                <div class="col-md-3">
                                                    <div class="form-group">
                                                        <label>Date To</label>
                                                        <input type="date" name="to_date" class="form-control" value="<?= $_GET['to_date'] ?? '' ?>">
                                                    </div>
                                                </div>
                                                <div class="col-md-3">
                                                    <div class="form-group">
                                                        <label>&nbsp;</label>
                                                        <button type="submit" class="btn btn-primary btn-block">
                                                            <i class="fas fa-filter"></i> Filter
                                                        </button>
                                                    </div>
                                                </div>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Activity Table -->
                        <div class="row">
                            <div class="col-12">
                                <div class="card">
                                    <div class="card-header">
                                        <h4>Referee Activity Tracking</h4>
                                        <div class="card-header-action">
                                            <a href="<?= base_url('referral-dashboard') ?>" class="btn btn-primary">
                                                <i class="fas fa-arrow-left"></i> Back to Dashboard
                                            </a>
                                        </div>
                                    </div>
                                    <div class="card-body">
                                        <div class="table-responsive">
                                            <table class="table table-striped" id="activity-table">
                                                <thead>
                                                    <tr>
                                                        <th>Referral ID</th>
                                                        <th>Referee</th>
                                                        <th>Referrer</th>
                                                        <th>Signup Date</th>
                                                        <th>Progress</th>
                                                        <th>Status</th>
                                                        <th>Last Activity</th>
                                                        <th>Actions</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <?php
                                                    // Build query based on filters
                                                    $this->db->select('r.*, 
                                                        u1.name as referrer_name,
                                                        u2.name as referee_name,
                                                        u2.email as referee_email,
                                                        (SELECT MAX(activity_date) FROM tbl_referral_activity WHERE referral_id = r.id) as last_activity_date')
                                                        ->from('tbl_referrals r')
                                                        ->join('tbl_users u1', 'r.referrer_id = u1.id', 'left')
                                                        ->join('tbl_users u2', 'r.referee_id = u2.id', 'left');

                                                    if (isset($_GET['status']) && $_GET['status'] != '') {
                                                        $this->db->where('r.status', $_GET['status']);
                                                    }

                                                    if (isset($_GET['from_date']) && $_GET['from_date'] != '') {
                                                        $this->db->where('DATE(r.signup_date) >=', $_GET['from_date']);
                                                    }

                                                    if (isset($_GET['to_date']) && $_GET['to_date'] != '') {
                                                        $this->db->where('DATE(r.signup_date) <=', $_GET['to_date']);
                                                    }

                                                    $referrals = $this->db->order_by('r.id', 'DESC')
                                                        ->limit(100)
                                                        ->get()
                                                        ->result();

                                                    $min_days = (int)is_settings('referral_reward_min_active_days') ?: 7;
                                                    $min_quizzes = (int)is_settings('referral_reward_min_quizzes') ?: 10;

                                                    $status_class = [
                                                        'pending' => 'warning',
                                                        'qualified' => 'info',
                                                        'rewarded' => 'success',
                                                        'rejected' => 'danger'
                                                    ];

                                                    foreach ($referrals as $ref):
                                                        $days_progress = min(100, ($ref->referee_active_days / $min_days) * 100);
                                                        $quiz_progress = min(100, ($ref->referee_quizzes_played / $min_quizzes) * 100);
                                                    ?>
                                                        <tr>
                                                            <td><strong>#<?= $ref->id ?></strong></td>
                                                            <td>
                                                                <strong><?= $ref->referee_name ?></strong><br>
                                                                <small class="text-muted"><?= $ref->referee_email ?></small>
                                                            </td>
                                                            <td><?= $ref->referrer_name ?></td>
                                                            <td><?= date('M d, Y', strtotime($ref->signup_date)) ?></td>
                                                            <td>
                                                                <small><strong>Active Days:</strong></small>
                                                                <div class="progress" style="height: 20px;">
                                                                    <div class="progress-bar <?= $days_progress >= 100 ? 'bg-success' : 'bg-primary' ?>" 
                                                                         style="width: <?= $days_progress ?>%">
                                                                        <?= $ref->referee_active_days ?> / <?= $min_days ?>
                                                                    </div>
                                                                </div>
                                                                <small><strong>Quizzes:</strong></small>
                                                                <div class="progress" style="height: 20px;">
                                                                    <div class="progress-bar <?= $quiz_progress >= 100 ? 'bg-success' : 'bg-info' ?>" 
                                                                         style="width: <?= $quiz_progress ?>%">
                                                                        <?= $ref->referee_quizzes_played ?> / <?= $min_quizzes ?>
                                                                    </div>
                                                                </div>
                                                            </td>
                                                            <td>
                                                                <span class="badge badge-<?= $status_class[$ref->status] ?? 'secondary' ?>">
                                                                    <?= ucfirst($ref->status) ?>
                                                                </span>
                                                            </td>
                                                            <td>
                                                                <?php if ($ref->last_activity_date): ?>
                                                                    <?= date('M d, Y', strtotime($ref->last_activity_date)) ?>
                                                                <?php else: ?>
                                                                    <span class="text-muted">No activity</span>
                                                                <?php endif; ?>
                                                            </td>
                                                            <td>
                                                                <button class="btn btn-sm btn-info" data-toggle="modal" data-target="#activityModal<?= $ref->id ?>">
                                                                    <i class="fas fa-eye"></i> Details
                                                                </button>
                                                            </td>
                                                        </tr>

                                                        <!-- Activity Details Modal -->
                                                        <div class="modal fade" id="activityModal<?= $ref->id ?>" tabindex="-1" role="dialog">
                                                            <div class="modal-dialog modal-lg" role="document">
                                                                <div class="modal-content">
                                                                    <div class="modal-header">
                                                                        <h5 class="modal-title">Daily Activity Log - <?= $ref->referee_name ?></h5>
                                                                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                                                            <span aria-hidden="true">&times;</span>
                                                                        </button>
                                                                    </div>
                                                                    <div class="modal-body">
                                                                        <h6>Referral Information</h6>
                                                                        <ul>
                                                                            <li><strong>Referral ID:</strong> <?= $ref->id ?></li>
                                                                            <li><strong>Code Used:</strong> <code><?= $ref->referral_code ?></code></li>
                                                                            <li><strong>Signup Date:</strong> <?= date('F d, Y', strtotime($ref->signup_date)) ?></li>
                                                                            <li><strong>Status:</strong> <span class="badge badge-<?= $status_class[$ref->status] ?>"><?= ucfirst($ref->status) ?></span></li>
                                                                        </ul>

                                                                        <hr>
                                                                        <h6>Daily Activity Breakdown</h6>
                                                                        <?php
                                                                        $daily_activity = $this->db->where('referral_id', $ref->id)
                                                                            ->order_by('activity_date', 'DESC')
                                                                            ->get('tbl_referral_activity')
                                                                            ->result();
                                                                        ?>

                                                                        <?php if (!empty($daily_activity)): ?>
                                                                            <div class="table-responsive">
                                                                                <table class="table table-sm table-striped">
                                                                                    <thead>
                                                                                        <tr>
                                                                                            <th>Date</th>
                                                                                            <th>Quizzes Played</th>
                                                                                            <th>Coins Earned</th>
                                                                                            <th>Time Spent</th>
                                                                                            <th>Active?</th>
                                                                                        </tr>
                                                                                    </thead>
                                                                                    <tbody>
                                                                                        <?php foreach ($daily_activity as $day): ?>
                                                                                            <tr>
                                                                                                <td><?= date('M d, Y', strtotime($day->activity_date)) ?></td>
                                                                                                <td><?= $day->quizzes_played ?></td>
                                                                                                <td><?= $day->coins_earned ?></td>
                                                                                                <td><?= gmdate('H:i:s', $day->time_spent_seconds) ?></td>
                                                                                                <td>
                                                                                                    <?php if ($day->is_active_day): ?>
                                                                                                        <i class="fas fa-check-circle text-success"></i>
                                                                                                    <?php else: ?>
                                                                                                        <i class="fas fa-times-circle text-danger"></i>
                                                                                                    <?php endif; ?>
                                                                                                </td>
                                                                                            </tr>
                                                                                        <?php endforeach; ?>
                                                                                    </tbody>
                                                                                </table>
                                                                            </div>
                                                                        <?php else: ?>
                                                                            <p class="text-muted">No activity recorded yet.</p>
                                                                        <?php endif; ?>
                                                                    </div>
                                                                    <div class="modal-footer">
                                                                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    <?php endforeach; ?>

                                                    <?php if (empty($referrals)): ?>
                                                        <tr>
                                                            <td colspan="8" class="text-center">
                                                                <p class="text-muted" style="padding: 40px;">No referrals found with current filters.</p>
                                                            </td>
                                                        </tr>
                                                    <?php endif; ?>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                    </div>
                </section>
            </div>

            <?php base_url() . include 'footer.php'; ?>
        </div>
    </div>

    <?php base_url() . include 'include_bottom.php'; ?>
</body>

</html>
