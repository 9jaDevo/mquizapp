<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta content="width=device-width, initial-scale=1, maximum-scale=1, shrink-to-fit=no" name="viewport">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>Payout Eligibility Settings | <?php echo (is_settings('app_name')) ? is_settings('app_name') : "" ?></title>

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
                        <h1>Payout Eligibility Settings <small class="text-small">Configure withdrawal requirements and validation</small></h1>
                    </div>
                    <div class="section-body">
                        <div class="row">
                            <div class="col-12">
                                <div class="card">
                                    <div class="card-header">
                                        <h4>Payout Requirements</h4>
                                    </div>
                                    <div class="card-body">
                                        <form method="post" class="needs-validation" novalidate="">
                                            <input type="hidden" name="<?= $this->security->get_csrf_token_name(); ?>" value="<?= $this->security->get_csrf_hash(); ?>">

                                            <div class="row">
                                                <div class="form-group col-md-6 col-sm-12">
                                                    <label class="control-label">Minimum Active Days for Payout <small class="text-danger">*</small></label>
                                                    <input type="number" id="min_active_days_for_payout" name="min_active_days_for_payout" required class="form-control" 
                                                           value="<?= (!empty($min_active_days_for_payout)) ? $min_active_days_for_payout['message'] : 20; ?>"
                                                           min="1" max="365" placeholder="Days">
                                                    <small class="form-text text-muted">User must have this many active days to withdraw</small>
                                                </div>
                                                <div class="form-group col-md-6 col-sm-12">
                                                    <label class="control-label">Activity Tracking Window <small class="text-danger">*</small></label>
                                                    <input type="number" id="activity_tracking_window_days" name="activity_tracking_window_days" required class="form-control" 
                                                           value="<?= (!empty($activity_tracking_window_days)) ? $activity_tracking_window_days['message'] : 30; ?>"
                                                           min="1" max="365" placeholder="Days">
                                                    <small class="form-text text-muted">Lookback window for counting active days (e.g., 30 = last 30 days)</small>
                                                </div>
                                            </div>

                                            <hr>

                                            <div class="row">
                                                <div class="col-md-12">
                                                    <div class="alert alert-info">
                                                        <h5><strong>📋 Payout Eligibility Logic:</strong></h5>
                                                        <ul>
                                                            <li>User can request withdrawal only if they have at least <strong>min_active_days_for_payout</strong> active days</li>
                                                            <li>Active days are counted within the last <strong>activity_tracking_window_days</strong> days</li>
                                                            <li>An "active day" = day when user logged in and earned coins</li>
                                                            <li>Example: If min=20 and window=30, user needs 20 days active in last 30 days to withdraw</li>
                                                            <li><strong>Use Case:</strong> Prevents new accounts from instantly withdrawing with stolen ad clicks</li>
                                                        </ul>
                                                    </div>
                                                </div>
                                            </div>

                                            <hr>

                                            <div class="row">
                                                <div class="form-group col-md-6 col-sm-12">
                                                    <label class="control-label">Enable Payout Eligibility Check</label><br>
                                                    <input type="checkbox" id="payout_eligibility_check_btn" data-plugin="switchery" checked>

                                                    <input type="hidden" id="payout_eligibility_check" name="payout_eligibility_check" value="1">
                                                    <small class="form-text text-muted">When disabled, users can withdraw regardless of active days</small>
                                                </div>
                                            </div>

                                            <hr>

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

                        <!-- Example Scenarios -->
                        <div class="row mt-4">
                            <div class="col-md-6">
                                <div class="card">
                                    <div class="card-header">
                                        <h4>✅ Eligible User</h4>
                                    </div>
                                    <div class="card-body">
                                        <ul>
                                            <li><strong>Account Age:</strong> 60 days old</li>
                                            <li><strong>Active Days (last 30):</strong> 22 days</li>
                                            <li><strong>Requirement:</strong> 20 active days</li>
                                            <li><strong>Status:</strong> <span class="badge badge-success">CAN WITHDRAW</span></li>
                                        </ul>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="card">
                                    <div class="card-header">
                                        <h4>❌ Ineligible User</h4>
                                    </div>
                                    <div class="card-body">
                                        <ul>
                                            <li><strong>Account Age:</strong> 3 days old</li>
                                            <li><strong>Active Days (last 30):</strong> 2 days</li>
                                            <li><strong>Requirement:</strong> 20 active days</li>
                                            <li><strong>Status:</strong> <span class="badge badge-danger">CANNOT WITHDRAW YET</span></li>
                                            <li><strong>Message:</strong> "You need 18 more active days"</li>
                                        </ul>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Integration Info -->
                        <div class="row mt-4">
                            <div class="col-12">
                                <div class="card">
                                    <div class="card-header">
                                        <h4>Integration Points</h4>
                                    </div>
                                    <div class="card-body">
                                        <h5>API Endpoint: <code>check_payout_eligibility_post()</code></h5>
                                        <p>Called from Flutter app before showing "Withdraw" button on wallet screen</p>

                                        <hr>

                                        <h5>Database Tables Used:</h5>
                                        <ul>
                                            <li><strong>tbl_daily_streak:</strong> Tracks daily login dates (counts active days)</li>
                                            <li><strong>tbl_users:</strong> User account creation date</li>
                                            <li><strong>tbl_settings:</strong> Configuration (min_active_days_for_payout, activity_tracking_window_days)</li>
                                        </ul>

                                        <hr>

                                        <h5>Response Example:</h5>
                                        <pre>{
  "error": false,
  "eligible": true,
  "active_days": 22,
  "required_days": 20,
  "message": "You are eligible to withdraw funds!"
}

OR

{
  "error": false,
  "eligible": false,
  "active_days": 2,
  "required_days": 20,
  "message": "You need 18 more active days to be eligible"
}</pre>
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

        var checkBtn = document.querySelector('#payout_eligibility_check_btn');
        if (checkBtn) {
            checkBtn.onchange = function() {
                $('#payout_eligibility_check').val(this.checked ? 1 : 0);
            };
        }
    </script>

</body>

</html>
