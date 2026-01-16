<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta content="width=device-width, initial-scale=1, maximum-scale=1, shrink-to-fit=no" name="viewport">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>Fraud Detection Dashboard | <?php echo (is_settings('app_name')) ? is_settings('app_name') : "" ?></title>

    <?php base_url() . include 'include.php'; ?>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>

<body>
    <div id="app">
        <div class="main-wrapper">
            <?php base_url() . include 'header.php'; ?>

            <!-- Main Content -->
            <div class="main-content">
                <section class="section">
                    <div class="section-header">
                        <h1>Fraud Detection Dashboard <small class="text-small">Review and manage suspicious activities</small></h1>
                    </div>
                    <div class="section-body">
                        <!-- Settings Card -->
                        <div class="row">
                            <div class="col-12">
                                <div class="card">
                                    <div class="card-header">
                                        <h4>Fraud Detection Thresholds</h4>
                                    </div>
                                    <div class="card-body">
                                        <form method="post" class="needs-validation" novalidate="">
                                            <input type="hidden" name="<?= $this->security->get_csrf_token_name(); ?>" value="<?= $this->security->get_csrf_hash(); ?>">

                                            <div class="row">
                                                <div class="form-group col-md-6 col-sm-12">
                                                    <label class="control-label">Daily Ad Watch Limit</label>
                                                    <input type="number" name="fraud_daily_ad_limit" class="form-control" value="<?= (!empty($fraud_daily_ad_limit)) ? $fraud_daily_ad_limit['message'] : 100; ?>" min="10" max="1000">
                                                    <small class="form-text text-muted">Max ads user can watch per day</small>
                                                </div>
                                                <div class="form-group col-md-6 col-sm-12">
                                                    <label class="control-label">Quiz Accuracy Threshold (%)</label>
                                                    <input type="number" name="fraud_quiz_accuracy_threshold" class="form-control" value="<?= (!empty($fraud_quiz_accuracy_threshold)) ? $fraud_quiz_accuracy_threshold['message'] : 95; ?>" min="50" max="100">
                                                    <small class="form-text text-muted">Minimum accuracy for cheating detection</small>
                                                </div>
                                            </div>

                                            <div class="row">
                                                <div class="form-group col-md-6 col-sm-12">
                                                    <label class="control-label">Quiz Speed Threshold (seconds)</label>
                                                    <input type="number" name="fraud_quiz_speed_seconds" class="form-control" value="<?= (!empty($fraud_quiz_speed_seconds)) ? $fraud_quiz_speed_seconds['message'] : 10; ?>" min="1" max="60">
                                                    <small class="form-text text-muted">Minimum time per question</small>
                                                </div>
                                                <div class="form-group col-md-6 col-sm-12">
                                                    <label class="control-label">New Account Withdrawal Lock (days)</label>
                                                    <input type="number" name="fraud_new_account_withdrawal_days" class="form-control" value="<?= (!empty($fraud_new_account_withdrawal_days)) ? $fraud_new_account_withdrawal_days['message'] : 7; ?>" min="1" max="30">
                                                    <small class="form-text text-muted">Days before new accounts can withdraw</small>
                                                </div>
                                            </div>

                                            <hr>

                                            <div class="row">
                                                <div class="form-group col-sm-12">
                                                    <input type="submit" name="btnupdate" value="Update Thresholds" class="<?= BUTTON_CLASS ?>" />
                                                </div>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Statistics -->
                        <div class="row mt-4">
                            <div class="col-md-3 col-sm-6">
                                <div class="card">
                                    <div class="card-body">
                                        <h2 class="text-danger"><?= (!empty($total_detections)) ? $total_detections : 0; ?></h2>
                                        <p>Total Detections</p>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-3 col-sm-6">
                                <div class="card">
                                    <div class="card-body">
                                        <h2 class="text-warning"><?= (!empty($pending_review)) ? $pending_review : 0; ?></h2>
                                        <p>Pending Review</p>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-3 col-sm-6">
                                <div class="card">
                                    <div class="card-body">
                                        <h2 class="text-success"><?= (!empty($resolved)) ? $resolved : 0; ?></h2>
                                        <p>Resolved</p>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-3 col-sm-6">
                                <div class="card">
                                    <div class="card-body">
                                        <h2 class="text-info"><?= (!empty($suspended)) ? $suspended : 0; ?></h2>
                                        <p>Suspended Accounts</p>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Fraud Types Chart -->
                        <div class="row mt-4">
                            <div class="col-md-6">
                                <div class="card">
                                    <div class="card-header">
                                        <h4>By Detection Type</h4>
                                    </div>
                                    <div class="card-body">
                                        <canvas id="typeChart"></canvas>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="card">
                                    <div class="card-header">
                                        <h4>By Severity</h4>
                                    </div>
                                    <div class="card-body">
                                        <canvas id="severityChart"></canvas>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Detections Table -->
                        <div class="row mt-4">
                            <div class="col-12">
                                <div class="card">
                                    <div class="card-header">
                                        <h4>Unresolved Detections (Page <?= (!empty($current_page)) ? $current_page : 1; ?>)</h4>
                                    </div>
                                    <div class="card-body">
                                        <div class="table-responsive">
                                            <table class="table table-striped table-bordered">
                                                <thead>
                                                    <tr>
                                                        <th>User</th>
                                                        <th>Type</th>
                                                        <th>Severity</th>
                                                        <th>Reason</th>
                                                        <th>Detected</th>
                                                        <th>Action</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <?php if (!empty($detections)): ?>
                                                        <?php foreach ($detections as $detection): ?>
                                                        <tr>
                                                            <td><?= $detection->user_email; ?></td>
                                                            <td><?= ucfirst(str_replace('_', ' ', $detection->detection_type)); ?></td>
                                                            <td>
                                                                <?php 
                                                                    $severityClass = 'badge-secondary';
                                                                    if ($detection->severity == 'low') $severityClass = 'badge-info';
                                                                    elseif ($detection->severity == 'medium') $severityClass = 'badge-warning';
                                                                    elseif ($detection->severity == 'high') $severityClass = 'badge-danger';
                                                                    elseif ($detection->severity == 'critical') $severityClass = 'badge-dark';
                                                                ?>
                                                                <span class="badge <?= $severityClass; ?>"><?= ucfirst($detection->severity); ?></span>
                                                            </td>
                                                            <td><?= $detection->reason; ?></td>
                                                            <td><?= date('M d, Y H:i', strtotime($detection->created_at)); ?></td>
                                                            <td>
                                                                <button class="btn btn-sm btn-primary view-detail" data-detection-id="<?= $detection->id; ?>">Review</button>
                                                            </td>
                                                        </tr>
                                                        <?php endforeach; ?>
                                                    <?php else: ?>
                                                        <tr>
                                                            <td colspan="6" class="text-center text-muted">No unresolved detections</td>
                                                        </tr>
                                                    <?php endif; ?>
                                                </tbody>
                                            </table>
                                        </div>

                                        <!-- Pagination -->
                                        <?php if (!empty($pagination)): ?>
                                        <nav aria-label="Page navigation">
                                            <ul class="pagination justify-content-center">
                                                <?= $pagination; ?>
                                            </ul>
                                        </nav>
                                        <?php endif; ?>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                </section>
            </div>
        </div>
    </div>

    <!-- Review Modal -->
    <div class="modal fade" id="reviewModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Review Detection</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <div id="detailContent">
                        <p class="text-center"><i class="fas fa-spinner fa-spin"></i> Loading...</p>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                    <button type="button" class="btn btn-warning" id="warningBtn">Send Warning</button>
                    <button type="button" class="btn btn-danger" id="suspendBtn">Suspend Account</button>
                </div>
            </div>
        </div>
    </div>

    <?php base_url() . include 'footer.php'; ?>

    <script type="text/javascript">
        // Chart data
        var chartData = <?= json_encode($chart_data ?? []); ?>;
        
        if (chartData.type_data) {
            new Chart(document.getElementById('typeChart'), {
                type: 'doughnut',
                data: {
                    labels: chartData.type_data.labels,
                    datasets: [{
                        data: chartData.type_data.data,
                        backgroundColor: ['#FF6384', '#36A2EB', '#FFCE56', '#4BC0C0']
                    }]
                },
                options: {
                    responsive: true,
                    plugins: {
                        legend: {
                            position: 'bottom'
                        }
                    }
                }
            });
        }

        if (chartData.severity_data) {
            new Chart(document.getElementById('severityChart'), {
                type: 'bar',
                data: {
                    labels: chartData.severity_data.labels,
                    datasets: [{
                        label: 'Count',
                        data: chartData.severity_data.data,
                        backgroundColor: ['#1abc9c', '#f39c12', '#e74c3c', '#c0392b']
                    }]
                },
                options: {
                    responsive: true,
                    scales: {
                        y: {
                            beginAtZero: true
                        }
                    }
                }
            });
        }

        $(document).on('click', '.view-detail', function() {
            var detection_id = $(this).data('detection-id');
            var currentButton = $(this);
            
            $.ajax({
                type: 'POST',
                url: '<?= base_url('Fraud/view_detection'); ?>',
                data: {
                    detection_id: detection_id,
                    '<?= $this->security->get_csrf_token_name(); ?>': '<?= $this->security->get_csrf_hash(); ?>'
                },
                success: function(response) {
                    $('#detailContent').html(response);
                    $('#reviewModal').modal('show');
                }
            });
        });

        $(document).on('click', '#warningBtn', function() {
            var detection_id = $('#detectionId').val();
            var notes = $('#resolutionNotes').val();
            resolveDetection(detection_id, 'warning', notes);
        });

        $(document).on('click', '#suspendBtn', function() {
            if (confirm('Are you sure you want to suspend this account?')) {
                var detection_id = $('#detectionId').val();
                var notes = $('#resolutionNotes').val();
                resolveDetection(detection_id, 'suspend', notes);
            }
        });

        function resolveDetection(detection_id, action, notes) {
            $.ajax({
                type: 'POST',
                url: '<?= base_url('Fraud/resolve_detection'); ?>',
                data: {
                    detection_id: detection_id,
                    action: action,
                    notes: notes,
                    '<?= $this->security->get_csrf_token_name(); ?>': '<?= $this->security->get_csrf_hash(); ?>'
                },
                success: function(response) {
                    if (response.error === false) {
                        alert('Detection resolved successfully');
                        $('#reviewModal').modal('hide');
                        location.reload();
                    } else {
                        alert('Error: ' + response.message);
                    }
                }
            });
        }
    </script>

</body>

</html>
