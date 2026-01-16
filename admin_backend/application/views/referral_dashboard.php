<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta content="width=device-width, initial-scale=1, maximum-scale=1, shrink-to-fit=no" name="viewport">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>Referral Dashboard | <?php echo (is_settings('app_name')) ? is_settings('app_name') : "" ?></title>

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
                        <h1>Referral System Dashboard <small>Enhanced Anti-Farming Protection</small></h1>
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
                                            <h4>Total Referrals</h4>
                                        </div>
                                        <div class="card-body">
                                            <?php
                                            $total = $this->db->count_all('tbl_referrals');
                                            echo $total;
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
                                            <h4>Pending</h4>
                                        </div>
                                        <div class="card-body">
                                            <?php
                                            $pending = $this->db->where('status', 'pending')->count_all_results('tbl_referrals');
                                            echo $pending;
                                            ?>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-lg-3 col-md-6 col-sm-6 col-12">
                                <div class="card card-statistic-1">
                                    <div class="card-icon bg-success">
                                        <i class="fas fa-check-circle"></i>
                                    </div>
                                    <div class="card-wrap">
                                        <div class="card-header">
                                            <h4>Rewarded</h4>
                                        </div>
                                        <div class="card-body">
                                            <?php
                                            $rewarded = $this->db->where('status', 'rewarded')->count_all_results('tbl_referrals');
                                            echo $rewarded;
                                            ?>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-lg-3 col-md-6 col-sm-6 col-12">
                                <div class="card card-statistic-1">
                                    <div class="card-icon bg-danger">
                                        <i class="fas fa-ban"></i>
                                    </div>
                                    <div class="card-wrap">
                                        <div class="card-header">
                                            <h4>Blocked (Fraud)</h4>
                                        </div>
                                        <div class="card-body">
                                            <?php
                                            $rejected = $this->db->where('status', 'rejected')->count_all_results('tbl_referrals');
                                            echo $rejected;
                                            ?>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Revenue Impact -->
                        <div class="row">
                            <div class="col-lg-6 col-md-6 col-sm-12">
                                <div class="card card-statistic-1">
                                    <div class="card-icon bg-success">
                                        <i class="fas fa-coins"></i>
                                    </div>
                                    <div class="card-wrap">
                                        <div class="card-header">
                                            <h4>Coins Distributed</h4>
                                        </div>
                                        <div class="card-body">
                                            <?php
                                            $coins_given = $this->db->select_sum('referrer_coins_rewarded')
                                                ->select_sum('referee_coins_rewarded')
                                                ->where('status', 'rewarded')
                                                ->get('tbl_referrals')
                                                ->row();
                                            $total_coins = ($coins_given->referrer_coins_rewarded ?? 0) + ($coins_given->referee_coins_rewarded ?? 0);
                                            echo number_format($total_coins);
                                            ?>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-lg-6 col-md-6 col-sm-12">
                                <div class="card card-statistic-1">
                                    <div class="card-icon bg-info">
                                        <i class="fas fa-shield-alt"></i>
                                    </div>
                                    <div class="card-wrap">
                                        <div class="card-header">
                                            <h4>Coins Saved (Fraud Blocked)</h4>
                                        </div>
                                        <div class="card-body">
                                            <?php
                                            // Estimate: rejected referrals * average reward
                                            $bonus_referrer = (int)is_settings('referral_bonus_referrer_coins') ?: 30;
                                            $bonus_referee = (int)is_settings('referral_bonus_referee_coins') ?: 50;
                                            $coins_saved = $rejected * ($bonus_referrer + $bonus_referee);
                                            echo number_format($coins_saved);
                                            ?>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Recent Referrals Table -->
                        <div class="row">
                            <div class="col-12">
                                <div class="card">
                                    <div class="card-header">
                                        <h4>Recent Referrals</h4>
                                        <div class="card-header-action">
                                            <a href="<?= base_url('referral-fraud-review') ?>" class="btn btn-warning">
                                                <i class="fas fa-exclamation-triangle"></i> Review Suspicious
                                            </a>
                                        </div>
                                    </div>
                                    <div class="card-body">
                                        <div class="table-responsive">
                                            <table class="table table-striped">
                                                <thead>
                                                    <tr>
                                                        <th>ID</th>
                                                        <th>Referrer</th>
                                                        <th>Referee</th>
                                                        <th>Code</th>
                                                        <th>Signup Date</th>
                                                        <th>Active Days</th>
                                                        <th>Quizzes</th>
                                                        <th>Status</th>
                                                        <th>Fraud Flags</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <?php
                                                    $recent = $this->db->select('r.*, 
                                                        u1.name as referrer_name, 
                                                        u2.name as referee_name,
                                                        (SELECT COUNT(*) FROM tbl_referral_fraud_checks WHERE referral_id = r.id AND resolved = 0) as fraud_count')
                                                        ->from('tbl_referrals r')
                                                        ->join('tbl_users u1', 'r.referrer_id = u1.id', 'left')
                                                        ->join('tbl_users u2', 'r.referee_id = u2.id', 'left')
                                                        ->order_by('r.id', 'DESC')
                                                        ->limit(20)
                                                        ->get()
                                                        ->result();

                                                    foreach ($recent as $ref):
                                                        $status_class = [
                                                            'pending' => 'warning',
                                                            'qualified' => 'info',
                                                            'rewarded' => 'success',
                                                            'rejected' => 'danger'
                                                        ];
                                                    ?>
                                                        <tr>
                                                            <td><?= $ref->id ?></td>
                                                            <td><?= $ref->referrer_name ?></td>
                                                            <td><?= $ref->referee_name ?></td>
                                                            <td><code><?= $ref->referral_code ?></code></td>
                                                            <td><?= date('M d, Y', strtotime($ref->signup_date)) ?></td>
                                                            <td><?= $ref->referee_active_days ?> / 7</td>
                                                            <td><?= $ref->referee_quizzes_played ?> / 10</td>
                                                            <td><span class="badge badge-<?= $status_class[$ref->status] ?? 'secondary' ?>"><?= ucfirst($ref->status) ?></span></td>
                                                            <td>
                                                                <?php if ($ref->fraud_count > 0): ?>
                                                                    <span class="badge badge-danger">
                                                                        <i class="fas fa-flag"></i> <?= $ref->fraud_count ?>
                                                                    </span>
                                                                <?php else: ?>
                                                                    <span class="badge badge-success">
                                                                        <i class="fas fa-check"></i> Clean
                                                                    </span>
                                                                <?php endif; ?>
                                                            </td>
                                                        </tr>
                                                    <?php endforeach; ?>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Top Referrers -->
                        <div class="row">
                            <div class="col-12">
                                <div class="card">
                                    <div class="card-header">
                                        <h4>Top Referrers</h4>
                                    </div>
                                    <div class="card-body">
                                        <div class="table-responsive">
                                            <table class="table table-striped">
                                                <thead>
                                                    <tr>
                                                        <th>Rank</th>
                                                        <th>User</th>
                                                        <th>Referral Code</th>
                                                        <th>Total Referrals</th>
                                                        <th>Successful</th>
                                                        <th>Coins Earned</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <?php
                                                    $top_referrers = $this->db->select('rc.*, u.name, u.email')
                                                        ->from('tbl_referral_codes rc')
                                                        ->join('tbl_users u', 'rc.user_id = u.id', 'left')
                                                        ->where('rc.total_referrals >', 0)
                                                        ->order_by('rc.successful_referrals', 'DESC')
                                                        ->limit(10)
                                                        ->get()
                                                        ->result();

                                                    $rank = 1;
                                                    foreach ($top_referrers as $top):
                                                    ?>
                                                        <tr>
                                                            <td><?= $rank++ ?></td>
                                                            <td>
                                                                <strong><?= $top->name ?></strong><br>
                                                                <small class="text-muted"><?= $top->email ?></small>
                                                            </td>
                                                            <td><code><?= $top->referral_code ?></code></td>
                                                            <td><?= $top->total_referrals ?></td>
                                                            <td><?= $top->successful_referrals ?></td>
                                                            <td><?= number_format($top->total_coins_earned) ?> coins</td>
                                                        </tr>
                                                    <?php endforeach; ?>
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
