<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta content="width=device-width, initial-scale=1, maximum-scale=1, shrink-to-fit=no" name="viewport">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>Referral System Settings | <?php echo (is_settings('app_name')) ? is_settings('app_name') : "" ?></title>

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
                        <h1>Referral System Settings <small>Configure Anti-Farming & Bonus Rewards</small></h1>
                    </div>
                    <div class="section-body">

                        <?php if ($this->session->flashdata('success')): ?>
                            <div class="alert alert-success alert-dismissible show fade">
                                <div class="alert-body">
                                    <button class="close" data-dismiss="alert">
                                        <span>&times;</span>
                                    </button>
                                    <?= $this->session->flashdata('success') ?>
                                </div>
                            </div>
                        <?php endif; ?>

                        <?php if ($this->session->flashdata('error')): ?>
                            <div class="alert alert-danger alert-dismissible show fade">
                                <div class="alert-body">
                                    <button class="close" data-dismiss="alert">
                                        <span>&times;</span>
                                    </button>
                                    <?= $this->session->flashdata('error') ?>
                                </div>
                            </div>
                        <?php endif; ?>

                        <!-- System Overview -->
                        <div class="row">
                            <div class="col-12">
                                <div class="card">
                                    <div class="card-header">
                                        <h4>Tiered Referral System Overview</h4>
                                    </div>
                                    <div class="card-body">
                                        <div class="alert alert-info">
                                            <h6><strong>How It Works:</strong></h6>
                                            <ol>
                                                <li><strong>Instant Reward (Old System):</strong> Users get immediate coins when someone signs up with their <code>friends_code</code> (set in System Configurations)</li>
                                                <li><strong>Bonus Reward (New System):</strong> After the referee is active for X days and plays Y quizzes, BOTH users get bonus coins</li>
                                                <li><strong>Result:</strong> Real engaged users get full rewards, fake accounts get only instant rewards (saving you money)</li>
                                            </ol>
                                            <p class="mb-0"><strong>Example:</strong> Instant: 20+50 coins → After 7 days + 10 quizzes → Bonus: +30+50 coins → Total for real users: 50+100 coins</p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Settings Form -->
                        <form method="post" action="<?= base_url('admin/save-referral-settings') ?>">
                            <input type="hidden" name="<?= $this->security->get_csrf_token_name(); ?>" value="<?= $this->security->get_csrf_hash(); ?>">

                            <!-- Bonus System Enable/Disable -->
                            <div class="row">
                                <div class="col-12">
                                    <div class="card">
                                        <div class="card-header">
                                            <h4>Enable/Disable Bonus System</h4>
                                        </div>
                                        <div class="card-body">
                                            <div class="form-group">
                                                <label class="d-block">Bonus Referral System</label>
                                                <label class="custom-switch mt-2">
                                                    <input type="checkbox" name="referral_bonus_system_enable" class="custom-switch-input" 
                                                           value="1" <?= (is_settings('referral_bonus_system_enable') == '1') ? 'checked' : '' ?>>
                                                    <span class="custom-switch-indicator"></span>
                                                    <span class="custom-switch-description">Enable bonus rewards after activity requirements</span>
                                                </label>
                                                <small class="form-text text-muted">If disabled, only instant rewards (old system) will be given. Enable for fraud protection.</small>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Activity Requirements -->
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="card">
                                        <div class="card-header">
                                            <h4>Activity Requirements</h4>
                                        </div>
                                        <div class="card-body">
                                            <div class="form-group">
                                                <label>Minimum Active Days <small class="text-danger">*</small></label>
                                                <input type="number" name="referral_reward_min_active_days" class="form-control" 
                                                       value="<?= is_settings('referral_reward_min_active_days') ?: 7 ?>" 
                                                       min="1" max="30" required>
                                                <small class="form-text text-muted">Number of days the referee must be active (play at least 1 quiz/day)</small>
                                            </div>
                                            <div class="form-group">
                                                <label>Minimum Quizzes Played <small class="text-danger">*</small></label>
                                                <input type="number" name="referral_reward_min_quizzes" class="form-control" 
                                                       value="<?= is_settings('referral_reward_min_quizzes') ?: 10 ?>" 
                                                       min="1" max="100" required>
                                                <small class="form-text text-muted">Total quizzes the referee must play to qualify</small>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="col-md-6">
                                    <div class="card">
                                        <div class="card-header">
                                            <h4>Bonus Reward Amounts</h4>
                                        </div>
                                        <div class="card-body">
                                            <div class="alert alert-warning">
                                                <strong>Note:</strong> These are BONUS amounts given AFTER requirements are met. 
                                                Instant rewards are configured in System Configurations (refer_coin, earn_coin).
                                            </div>
                                            <div class="form-group">
                                                <label>Referrer Bonus Coins <small class="text-danger">*</small></label>
                                                <input type="number" name="referral_bonus_referrer_coins" class="form-control" 
                                                       value="<?= is_settings('referral_bonus_referrer_coins') ?: 30 ?>" 
                                                       min="0" required>
                                                <small class="form-text text-muted">Bonus coins given to person who shared the code (on top of instant reward)</small>
                                            </div>
                                            <div class="form-group">
                                                <label>Referee Bonus Coins <small class="text-danger">*</small></label>
                                                <input type="number" name="referral_bonus_referee_coins" class="form-control" 
                                                       value="<?= is_settings('referral_bonus_referee_coins') ?: 50 ?>" 
                                                       min="0" required>
                                                <small class="form-text text-muted">Bonus coins given to person who used the code (on top of instant reward)</small>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Fraud Prevention Settings -->
                            <div class="row">
                                <div class="col-12">
                                    <div class="card">
                                        <div class="card-header">
                                            <h4>Fraud Prevention Thresholds</h4>
                                        </div>
                                        <div class="card-body">
                                            <div class="row">
                                                <div class="col-md-3">
                                                    <div class="form-group">
                                                        <label>Max Referrals Per Day</label>
                                                        <input type="number" name="referral_max_per_day" class="form-control" 
                                                               value="<?= is_settings('referral_max_per_day') ?: 5 ?>" 
                                                               min="1" max="50">
                                                        <small class="form-text text-muted">Flag if a user refers more than this many people in one day</small>
                                                    </div>
                                                </div>
                                                <div class="col-md-3">
                                                    <div class="form-group">
                                                        <label>Max Per Device</label>
                                                        <input type="number" name="referral_max_per_device" class="form-control" 
                                                               value="<?= is_settings('referral_max_per_device') ?: 3 ?>" 
                                                               min="1" max="10">
                                                        <small class="form-text text-muted">Flag if same device signs up multiple times with same code</small>
                                                    </div>
                                                </div>
                                                <div class="col-md-3">
                                                    <div class="form-group">
                                                        <label>Max Same IP Count</label>
                                                        <input type="number" name="referral_same_ip_max_count" class="form-control" 
                                                               value="<?= is_settings('referral_same_ip_max_count') ?: 2 ?>" 
                                                               min="1" max="10">
                                                        <small class="form-text text-muted">Flag if same IP address signs up multiple times</small>
                                                    </div>
                                                </div>
                                                <div class="col-md-3">
                                                    <div class="form-group">
                                                        <label>Block Same IP</label>
                                                        <br>
                                                        <label class="custom-switch mt-2">
                                                            <input type="checkbox" name="referral_block_same_ip" class="custom-switch-input" 
                                                                   value="1" <?= (is_settings('referral_block_same_ip') == '1') ? 'checked' : '' ?>>
                                                            <span class="custom-switch-indicator"></span>
                                                            <span class="custom-switch-description">Block duplicate IPs</span>
                                                        </label>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="row">
                                                <div class="col-md-6">
                                                    <div class="form-group">
                                                        <label>Verify Device Unique</label>
                                                        <br>
                                                        <label class="custom-switch mt-2">
                                                            <input type="checkbox" name="referral_verify_device_unique" class="custom-switch-input" 
                                                                   value="1" <?= (is_settings('referral_verify_device_unique') == '1') ? 'checked' : '' ?>>
                                                            <span class="custom-switch-indicator"></span>
                                                            <span class="custom-switch-description">Verify each device is unique</span>
                                                        </label>
                                                    </div>
                                                </div>
                                                <div class="col-md-6">
                                                    <div class="form-group">
                                                        <label>Verify Email Unique</label>
                                                        <br>
                                                        <label class="custom-switch mt-2">
                                                            <input type="checkbox" name="referral_verify_email_unique" class="custom-switch-input" 
                                                                   value="1" <?= (is_settings('referral_verify_email_unique') == '1') ? 'checked' : '' ?>>
                                                            <span class="custom-switch-indicator"></span>
                                                            <span class="custom-switch-description">Verify each email is unique</span>
                                                        </label>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Save Button -->
                            <div class="row">
                                <div class="col-12">
                                    <div class="card">
                                        <div class="card-body">
                                            <button type="submit" class="btn btn-primary btn-lg">
                                                <i class="fas fa-save"></i> Save Settings
                                            </button>
                                            <a href="<?= base_url('referral-dashboard') ?>" class="btn btn-secondary btn-lg">
                                                <i class="fas fa-arrow-left"></i> Back to Dashboard
                                            </a>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </form>

                        <!-- Current Configuration Summary -->
                        <div class="row">
                            <div class="col-12">
                                <div class="card">
                                    <div class="card-header">
                                        <h4>Current Configuration Summary</h4>
                                    </div>
                                    <div class="card-body">
                                        <table class="table table-bordered">
                                            <tr>
                                                <th width="40%">Setting</th>
                                                <th width="30%">Current Value</th>
                                                <th width="30%">Description</th>
                                            </tr>
                                            <tr>
                                                <td><strong>Instant Reward (Referrer)</strong></td>
                                                <td><?= is_settings('refer_coin') ?: 'Not set' ?> coins</td>
                                                <td>Given immediately when someone signs up</td>
                                            </tr>
                                            <tr>
                                                <td><strong>Instant Reward (Referee)</strong></td>
                                                <td><?= is_settings('earn_coin') ?: 'Not set' ?> coins</td>
                                                <td>Given immediately to new user</td>
                                            </tr>
                                            <tr>
                                                <td><strong>Bonus Reward (Referrer)</strong></td>
                                                <td><?= is_settings('referral_bonus_referrer_coins') ?: '30' ?> coins</td>
                                                <td>Given after activity requirements met</td>
                                            </tr>
                                            <tr>
                                                <td><strong>Bonus Reward (Referee)</strong></td>
                                                <td><?= is_settings('referral_bonus_referee_coins') ?: '50' ?> coins</td>
                                                <td>Given after activity requirements met</td>
                                            </tr>
                                            <tr class="table-info">
                                                <td><strong>TOTAL for Real Users</strong></td>
                                                <td>
                                                    <?php
                                                    $total_referrer = (int)(is_settings('refer_coin') ?: 0) + (int)(is_settings('referral_bonus_referrer_coins') ?: 30);
                                                    $total_referee = (int)(is_settings('earn_coin') ?: 0) + (int)(is_settings('referral_bonus_referee_coins') ?: 50);
                                                    echo $total_referrer . ' + ' . $total_referee . ' = ' . ($total_referrer + $total_referee) . ' coins';
                                                    ?>
                                                </td>
                                                <td>Combined instant + bonus rewards</td>
                                            </tr>
                                            <tr class="table-warning">
                                                <td><strong>TOTAL for Fake Accounts</strong></td>
                                                <td>
                                                    <?php
                                                    $fake_total = (int)(is_settings('refer_coin') ?: 0) + (int)(is_settings('earn_coin') ?: 0);
                                                    echo $fake_total . ' coins (only instant)';
                                                    ?>
                                                </td>
                                                <td>Only get instant rewards (bonus blocked by fraud detection)</td>
                                            </tr>
                                            <tr class="table-success">
                                                <td><strong>Coins Saved Per Fake Account</strong></td>
                                                <td>
                                                    <?php
                                                    $saved = (int)(is_settings('referral_bonus_referrer_coins') ?: 30) + (int)(is_settings('referral_bonus_referee_coins') ?: 50);
                                                    echo $saved . ' coins';
                                                    ?>
                                                </td>
                                                <td>Revenue protected by anti-farming system</td>
                                            </tr>
                                        </table>
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
