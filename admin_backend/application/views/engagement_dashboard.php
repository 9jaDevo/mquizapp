<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta content="width=device-width, initial-scale=1, maximum-scale=1, shrink-to-fit=no" name="viewport">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>Engagement Tracking Dashboard | <?php echo (is_settings('app_name')) ? is_settings('app_name') : "" ?></title>

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
                        <h1>Engagement Tracking Dashboard <small>Monitor User Activity & Time Spent</small></h1>
                    </div>
                    <div class="section-body">

                        <!-- Statistics Cards -->
                        <div class="row">
                            <div class="col-lg-3 col-md-6 col-sm-6 col-12">
                                <div class="card card-statistic-1">
                                    <div class="card-icon bg-primary">
                                        <i class="fas fa-users"></i>
                                    </div>
                                    <div class="card-wrap">
                                        <div class="card-header">
                                            <h4>Active Users</h4>
                                        </div>
                                        <div class="card-body">
                                            <?php
                                            $active_users = $this->db->select('COUNT(DISTINCT user_id) as count')
                                                ->from('tbl_user_engagement')
                                                ->get()->row()->count;
                                            echo number_format($active_users);
                                            ?>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-lg-3 col-md-6 col-sm-6 col-12">
                                <div class="card card-statistic-1">
                                    <div class="card-icon bg-warning">
                                        <i class="fas fa-clock"></i>
                                    </div>
                                    <div class="card-wrap">
                                        <div class="card-header">
                                            <h4>Total Hours</h4>
                                        </div>
                                        <div class="card-body">
                                            <?php
                                            $total_seconds = $this->db->select('SUM(duration_seconds) as total')
                                                ->from('tbl_user_engagement')
                                                ->get()->row()->total ?? 0;
                                            $total_hours = floor($total_seconds / 3600);
                                            echo number_format($total_hours);
                                            ?>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-lg-3 col-md-6 col-sm-6 col-12">
                                <div class="card card-statistic-1">
                                    <div class="card-icon bg-success">
                                        <i class="fas fa-chart-line"></i>
                                    </div>
                                    <div class="card-wrap">
                                        <div class="card-header">
                                            <h4>Avg Session (mins)</h4>
                                        </div>
                                        <div class="card-body">
                                            <?php
                                            $avg_seconds = $this->db->select('AVG(duration_seconds) as avg')
                                                ->from('tbl_user_engagement')
                                                ->get()->row()->avg ?? 0;
                                            $avg_minutes = round($avg_seconds / 60, 1);
                                            echo $avg_minutes;
                                            ?>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-lg-3 col-md-6 col-sm-6 col-12">
                                <div class="card card-statistic-1">
                                    <div class="card-icon bg-info">
                                        <i class="fas fa-globe"></i>
                                    </div>
                                    <div class="card-wrap">
                                        <div class="card-header">
                                            <h4>Countries</h4>
                                        </div>
                                        <div class="card-body">
                                            <?php
                                            $countries = $this->db->select('COUNT(DISTINCT u.country_code) as count')
                                                ->from('tbl_user_engagement e')
                                                ->join('tbl_users u', 'u.id = e.user_id', 'left')
                                                ->where('u.country_code IS NOT NULL')
                                                ->get()->row()->count;
                                            echo number_format($countries);
                                            ?>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Quick Links -->
                        <div class="row">
                            <div class="col-12">
                                <div class="card">
                                    <div class="card-header">
                                        <h4>Quick Access</h4>
                                    </div>
                                    <div class="card-body">
                                        <div class="row">
                                            <div class="col-md-3 col-sm-6 mb-3">
                                                <a href="<?= base_url() ?>engagement-analytics" class="btn btn-block btn-primary">
                                                    <i class="fas fa-chart-bar"></i> Analytics & Reports
                                                </a>
                                            </div>
                                            <div class="col-md-3 col-sm-6 mb-3">
                                                <a href="<?= base_url() ?>engagement-leaderboard/weekly" class="btn btn-block btn-success">
                                                    <i class="fas fa-trophy"></i> Weekly Leaderboard
                                                </a>
                                            </div>
                                            <div class="col-md-3 col-sm-6 mb-3">
                                                <a href="<?= base_url() ?>engagement-leaderboard/monthly" class="btn btn-block btn-warning">
                                                    <i class="fas fa-calendar-alt"></i> Monthly Leaderboard
                                                </a>
                                            </div>
                                            <div class="col-md-3 col-sm-6 mb-3">
                                                <a href="<?= base_url() ?>engagement-leaderboard/alltime" class="btn btn-block btn-info">
                                                    <i class="fas fa-star"></i> All-Time Leaderboard
                                                </a>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Top Engaged Users -->
                        <div class="row">
                            <div class="col-12">
                                <div class="card">
                                    <div class="card-header">
                                        <h4>Top Engaged Users</h4>
                                        <div class="card-header-action">
                                            <a href="<?= base_url() ?>engagement-leaderboard/alltime" class="btn btn-primary">View All</a>
                                        </div>
                                    </div>
                                    <div class="card-body p-0">
                                        <div class="table-responsive">
                                            <table class="table table-striped mb-0">
                                                <thead>
                                                    <tr>
                                                        <th>Rank</th>
                                                        <th>User</th>
                                                        <th>Country</th>
                                                        <th>Total Time</th>
                                                        <th>Action</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <?php
                                                    $top_users = $this->db->select('e.user_id, e.total_minutes, u.name, u.profile, u.country_name')
                                                        ->from('tbl_leaderboard_engagement_alltime e')
                                                        ->join('tbl_users u', 'u.id = e.user_id', 'left')
                                                        ->where('u.status', 1)
                                                        ->order_by('e.total_minutes', 'DESC')
                                                        ->limit(10)
                                                        ->get()->result();

                                                    $rank = 1;
                                                    foreach ($top_users as $user) {
                                                        $hours = floor($user->total_minutes / 60);
                                                        $minutes = $user->total_minutes % 60;
                                                        $profile_img = $user->profile ? base_url() . 'images/profile/' . $user->profile : base_url() . 'images/profile/default.png';
                                                    ?>
                                                        <tr>
                                                            <td><?= $rank++ ?></td>
                                                            <td>
                                                                <img src="<?= $profile_img ?>" alt="avatar" width="30" height="30" class="rounded-circle mr-1">
                                                                <?= $user->name ?>
                                                            </td>
                                                            <td><?= $user->country_name ?? 'N/A' ?></td>
                                                            <td><?= $hours ?>h <?= $minutes ?>m</td>
                                                            <td>
                                                                <a href="<?= base_url() ?>user-engagement-detail/<?= $user->user_id ?>" class="btn btn-sm btn-primary">
                                                                    <i class="fas fa-eye"></i> View
                                                                </a>
                                                            </td>
                                                        </tr>
                                                    <?php } ?>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Recent Activity -->
                        <div class="row">
                            <div class="col-12">
                                <div class="card">
                                    <div class="card-header">
                                        <h4>Recent Sessions</h4>
                                    </div>
                                    <div class="card-body p-0">
                                        <div class="table-responsive">
                                            <table class="table table-striped mb-0">
                                                <thead>
                                                    <tr>
                                                        <th>User</th>
                                                        <th>Duration</th>
                                                        <th>Started</th>
                                                        <th>Ended</th>
                                                        <th>Status</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <?php
                                                    $recent = $this->db->select('e.*, u.name, u.profile')
                                                        ->from('tbl_user_engagement e')
                                                        ->join('tbl_users u', 'u.id = e.user_id', 'left')
                                                        ->order_by('e.session_start', 'DESC')
                                                        ->limit(10)
                                                        ->get()->result();

                                                    foreach ($recent as $session) {
                                                        $hours = floor($session->duration_seconds / 3600);
                                                        $minutes = floor(($session->duration_seconds % 3600) / 60);
                                                        $seconds = $session->duration_seconds % 60;
                                                        $is_suspicious = $session->duration_seconds > 43200; // > 12 hours
                                                        $profile_img = $session->profile ? base_url() . 'images/profile/' . $session->profile : base_url() . 'images/profile/default.png';
                                                    ?>
                                                        <tr>
                                                            <td>
                                                                <img src="<?= $profile_img ?>" alt="avatar" width="30" height="30" class="rounded-circle mr-1">
                                                                <?= $session->name ?>
                                                            </td>
                                                            <td><?= $hours ?>h <?= $minutes ?>m <?= $seconds ?>s</td>
                                                            <td><?= date('d M Y H:i', strtotime($session->session_start)) ?></td>
                                                            <td><?= date('d M Y H:i', strtotime($session->session_end)) ?></td>
                                                            <td>
                                                                <?php if ($is_suspicious) { ?>
                                                                    <span class="badge badge-danger"><i class="fas fa-exclamation-triangle"></i> Suspicious</span>
                                                                <?php } else { ?>
                                                                    <span class="badge badge-success"><i class="fas fa-check"></i> Normal</span>
                                                                <?php } ?>
                                                            </td>
                                                        </tr>
                                                    <?php } ?>
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
        </div>
    </div>

    <?php base_url() . include 'footer.php'; ?>

</body>

</html>