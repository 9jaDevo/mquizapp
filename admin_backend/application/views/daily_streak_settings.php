<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta content="width=device-width, initial-scale=1, maximum-scale=1, shrink-to-fit=no" name="viewport">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>Daily Streak Settings | <?php echo (is_settings('app_name')) ? is_settings('app_name') : "" ?></title>

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
                        <h1>Daily Streak Settings <small class="text-small">Configure daily login rewards and bonuses</small></h1>
                    </div>
                    <div class="section-body">
                        <div class="row">
                            <div class="col-12">
                                <div class="card">
                                    <div class="card-header">
                                        <h4>Streak Configuration</h4>
                                    </div>
                                    <div class="card-body">
                                        <form method="post" class="needs-validation" novalidate="">
                                            <input type="hidden" name="<?= $this->security->get_csrf_token_name(); ?>" value="<?= $this->security->get_csrf_hash(); ?>">

                                            <div class="row">
                                                <div class="form-group col-md-6 col-sm-12">
                                                    <label class="control-label">Daily Streak Coin Reward <small class="text-danger">*</small></label>
                                                    <input type="number" id="daily_streak_coin_reward" name="daily_streak_coin_reward" required class="form-control" 
                                                           value="<?= (!empty($daily_streak_coin_reward)) ? $daily_streak_coin_reward['message'] : 10; ?>"
                                                           min="1" max="1000" placeholder="Coins per day">
                                                    <small class="form-text text-muted">Coins awarded for each consecutive day logged in</small>
                                                </div>
                                            </div>

                                            <hr>

                                            <div class="row">
                                                <div class="form-group col-md-6 col-sm-12">
                                                    <label class="control-label">Bonus Threshold <small class="text-danger">*</small></label>
                                                    <input type="number" id="daily_streak_bonus_threshold" name="daily_streak_bonus_threshold" required class="form-control" 
                                                           value="<?= (!empty($daily_streak_bonus_threshold)) ? $daily_streak_bonus_threshold['message'] : 7; ?>"
                                                           min="1" max="365" placeholder="Days">
                                                    <small class="form-text text-muted">Trigger bonus every N days (e.g., 7 = weekly bonus)</small>
                                                </div>
                                                <div class="form-group col-md-6 col-sm-12">
                                                    <label class="control-label">Bonus Coin Amount <small class="text-danger">*</small></label>
                                                    <input type="number" id="daily_streak_bonus_coin" name="daily_streak_bonus_coin" required class="form-control" 
                                                           value="<?= (!empty($daily_streak_bonus_coin)) ? $daily_streak_bonus_coin['message'] : 50; ?>"
                                                           min="1" max="10000" placeholder="Bonus coins">
                                                    <small class="form-text text-muted">Extra coins awarded at milestone days</small>
                                                </div>
                                            </div>

                                            <hr>

                                            <div class="row">
                                                <div class="form-group col-md-2 col-sm-6">
                                                    <label class="control-label">Enable Multiplier</label><br>
                                                    <input type="checkbox" id="daily_streak_multiplier_enable_btn" data-plugin="switchery" <?php
                                                                                                                                            if (!empty($daily_streak_multiplier_enable) && $daily_streak_multiplier_enable['message'] == '1') {
                                                                                                                                                echo 'checked';
                                                                                                                                            }
                                                                                                                                            ?>>

                                                    <input type="hidden" id="daily_streak_multiplier_enable" name="daily_streak_multiplier_enable" value="<?= ($daily_streak_multiplier_enable) ? $daily_streak_multiplier_enable['message'] : 0; ?>">
                                                </div>
                                                <div class="form-group col-md-10 col-sm-6">
                                                    <label class="control-label">&nbsp;</label>
                                                    <div class="alert alert-warning mb-0">
                                                        <strong>Multiplier Logic:</strong> When enabled, coins increase by 10% per day (max 3x).
                                                        <br>Example: Day 1 = 10 coins, Day 2 = 12 coins, Day 3 = 13 coins... Day 20+ = 30 coins (capped)
                                                    </div>
                                                </div>
                                            </div>

                                            <hr>

                                            <div class="row">
                                                <div class="col-md-12">
                                                    <div class="alert alert-info">
                                                        <h5><strong>💡 Streak Logic:</strong></h5>
                                                        <ul>
                                                            <li>User logs in daily → earns <strong>daily_streak_coin_reward</strong> coins</li>
                                                            <li>Every <strong>daily_streak_bonus_threshold</strong> days → earns additional <strong>daily_streak_bonus_coin</strong> coins</li>
                                                            <li>Missing a day resets streak count to 0 (user can restart next day)</li>
                                                            <li>Example: 10 coins/day + 7-day bonus of 50 coins = user gets 70 coins on day 7</li>
                                                        </ul>
                                                    </div>
                                                </div>
                                            </div>

                                            <div class="row">
                                                <div class="form-group col-sm-12">
                                                    <input type="submit" name="btnupdate" value="Update Settings" class="<?= BUTTON_CLASS ?>" />
                                                </div>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Statistics Card -->
                        <div class="row mt-4">
                            <div class="col-md-6 col-sm-12">
                                <div class="card">
                                    <div class="card-header">
                                        <h4>Active Streaks</h4>
                                    </div>
                                    <div class="card-body">
                                        <h2 class="text-primary"><?= (!empty($total_active_streaks)) ? $total_active_streaks : 0; ?></h2>
                                        <p>Users with active streaks</p>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-6 col-sm-12">
                                <div class="card">
                                    <div class="card-header">
                                        <h4>Average Streak</h4>
                                    </div>
                                    <div class="card-body">
                                        <h2 class="text-success"><?= (!empty($avg_streak)) ? round($avg_streak, 1) : 0; ?> days</h2>
                                        <p>Average streak length across active users</p>
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

    <script type="text/javascript">
        $('[data-plugin="switchery"]').each(function(index, element) {
            var init = new Switchery(element, {
                size: 'small',
                color: '#1abc9c',
                secondaryColor: '#f1556c'
            });
        });
    </script>

    <script type="text/javascript">
        var multiplierBtn = document.querySelector('#daily_streak_multiplier_enable_btn');
        if (multiplierBtn) {
            multiplierBtn.onchange = function() {
                if (multiplierBtn.checked) {
                    $('#daily_streak_multiplier_enable').val(1);
                } else {
                    $('#daily_streak_multiplier_enable').val(0);
                }
            };
        }
    </script>

</body>

</html>
