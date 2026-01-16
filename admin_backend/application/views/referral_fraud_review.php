<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta content="width=device-width, initial-scale=1, maximum-scale=1, shrink-to-fit=no" name="viewport">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>Fraud Review | <?php echo (is_settings('app_name')) ? is_settings('app_name') : "" ?></title>

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
                        <h1>Suspicious Referrals <small>Manual Fraud Review</small></h1>
                    </div>
                    <div class="section-body">

                        <!-- Alert for pending reviews -->
                        <?php
                        $pending_review = $this->db->query("
                            SELECT COUNT(*) as count FROM tbl_referral_fraud_checks 
                            WHERE resolved = 0 AND severity IN ('high', 'critical')
                        ")->row()->count;

                        if ($pending_review > 0):
                        ?>
                            <div class="alert alert-warning alert-has-icon">
                                <div class="alert-icon"><i class="fas fa-exclamation-triangle"></i></div>
                                <div class="alert-body">
                                    <div class="alert-title">Action Required</div>
                                    You have <strong><?= $pending_review ?></strong> high-priority fraud cases requiring manual review.
                                </div>
                            </div>
                        <?php endif; ?>

                        <!-- Suspicious Referrals Table -->
                        <div class="row">
                            <div class="col-12">
                                <div class="card">
                                    <div class="card-header">
                                        <h4>Flagged Referrals</h4>
                                        <div class="card-header-action">
                                            <a href="<?= base_url('referral-dashboard') ?>" class="btn btn-primary">
                                                <i class="fas fa-arrow-left"></i> Back to Dashboard
                                            </a>
                                        </div>
                                    </div>
                                    <div class="card-body">
                                        <div class="table-responsive">
                                            <table class="table table-striped" id="fraud-table">
                                                <thead>
                                                    <tr>
                                                        <th>ID</th>
                                                        <th>Referrer</th>
                                                        <th>Referee</th>
                                                        <th>Signup Info</th>
                                                        <th>Fraud Type</th>
                                                        <th>Severity</th>
                                                        <th>Evidence</th>
                                                        <th>Status</th>
                                                        <th>Actions</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <?php
                                                    $suspicious = $this->db->query("
                                                        SELECT 
                                                            r.*,
                                                            u1.name as referrer_name,
                                                            u1.email as referrer_email,
                                                            u2.name as referee_name,
                                                            u2.email as referee_email,
                                                            fc.id as fraud_id,
                                                            fc.check_type,
                                                            fc.severity,
                                                            fc.details,
                                                            fc.detected_at,
                                                            fc.resolved
                                                        FROM tbl_referral_fraud_checks fc
                                                        INNER JOIN tbl_referrals r ON fc.referral_id = r.id
                                                        LEFT JOIN tbl_users u1 ON r.referrer_id = u1.id
                                                        LEFT JOIN tbl_users u2 ON r.referee_id = u2.id
                                                        WHERE fc.resolved = 0
                                                        ORDER BY fc.severity DESC, fc.detected_at DESC
                                                    ")->result();

                                                    $severity_class = [
                                                        'low' => 'info',
                                                        'medium' => 'warning',
                                                        'high' => 'danger',
                                                        'critical' => 'dark'
                                                    ];

                                                    $fraud_labels = [
                                                        'duplicate_ip' => 'Duplicate IP',
                                                        'duplicate_device' => 'Duplicate Device',
                                                        'same_device_multiple_accounts' => 'Same Device Multiple',
                                                        'rapid_signups' => 'Rapid Signups',
                                                        'fake_activity' => 'Fake Activity',
                                                        'suspicious_pattern' => 'Suspicious Pattern'
                                                    ];

                                                    foreach ($suspicious as $fraud):
                                                        $details = json_decode($fraud->details, true);
                                                    ?>
                                                        <tr id="row-<?= $fraud->fraud_id ?>">
                                                            <td><?= $fraud->id ?></td>
                                                            <td>
                                                                <strong><?= $fraud->referrer_name ?></strong><br>
                                                                <small class="text-muted"><?= $fraud->referrer_email ?></small>
                                                            </td>
                                                            <td>
                                                                <strong><?= $fraud->referee_name ?></strong><br>
                                                                <small class="text-muted"><?= $fraud->referee_email ?></small>
                                                            </td>
                                                            <td>
                                                                <small>
                                                                    <strong>IP:</strong> <?= $fraud->signup_ip ?><br>
                                                                    <strong>Device:</strong> <?= substr($fraud->signup_device_id, 0, 20) ?>...<br>
                                                                    <strong>Date:</strong> <?= date('M d, Y', strtotime($fraud->signup_date)) ?>
                                                                </small>
                                                            </td>
                                                            <td>
                                                                <span class="badge badge-<?= $severity_class[$fraud->severity] ?? 'secondary' ?>">
                                                                    <?= $fraud_labels[$fraud->check_type] ?? ucfirst(str_replace('_', ' ', $fraud->check_type)) ?>
                                                                </span>
                                                            </td>
                                                            <td>
                                                                <span class="badge badge-<?= $severity_class[$fraud->severity] ?? 'secondary' ?>">
                                                                    <?= strtoupper($fraud->severity) ?>
                                                                </span>
                                                            </td>
                                                            <td>
                                                                <button class="btn btn-sm btn-info" data-toggle="modal" data-target="#evidenceModal<?= $fraud->fraud_id ?>">
                                                                    <i class="fas fa-eye"></i> View
                                                                </button>
                                                            </td>
                                                            <td>
                                                                <span class="badge badge-<?= $status_class[$fraud->status] ?? 'warning' ?>">
                                                                    <?= ucfirst($fraud->status) ?>
                                                                </span>
                                                            </td>
                                                            <td>
                                                                <div class="btn-group">
                                                                    <button class="btn btn-sm btn-success approve-btn" data-id="<?= $fraud->fraud_id ?>" data-referral-id="<?= $fraud->id ?>">
                                                                        <i class="fas fa-check"></i> Approve
                                                                    </button>
                                                                    <button class="btn btn-sm btn-danger reject-btn" data-id="<?= $fraud->fraud_id ?>" data-referral-id="<?= $fraud->id ?>">
                                                                        <i class="fas fa-times"></i> Reject
                                                                    </button>
                                                                </div>
                                                            </td>
                                                        </tr>

                                                        <!-- Evidence Modal -->
                                                        <div class="modal fade" id="evidenceModal<?= $fraud->fraud_id ?>" tabindex="-1" role="dialog">
                                                            <div class="modal-dialog modal-lg" role="document">
                                                                <div class="modal-content">
                                                                    <div class="modal-header">
                                                                        <h5 class="modal-title">Fraud Evidence Details</h5>
                                                                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                                                            <span aria-hidden="true">&times;</span>
                                                                        </button>
                                                                    </div>
                                                                    <div class="modal-body">
                                                                        <h6>Fraud Type: <?= $fraud_labels[$fraud->check_type] ?? $fraud->check_type ?></h6>
                                                                        <p><strong>Detected:</strong> <?= date('M d, Y H:i:s', strtotime($fraud->detected_at)) ?></p>
                                                                        <p><strong>Severity:</strong> <span class="badge badge-<?= $severity_class[$fraud->severity] ?>"><?= strtoupper($fraud->severity) ?></span></p>

                                                                        <hr>
                                                                        <h6>Evidence Details:</h6>
                                                                        <pre style="background: #f4f4f4; padding: 15px; border-radius: 5px;"><?= json_encode($details, JSON_PRETTY_PRINT) ?></pre>

                                                                        <hr>
                                                                        <h6>Referral Information:</h6>
                                                                        <ul>
                                                                            <li><strong>Referral ID:</strong> <?= $fraud->id ?></li>
                                                                            <li><strong>Referral Code:</strong> <code><?= $fraud->referral_code ?></code></li>
                                                                            <li><strong>Signup IP:</strong> <?= $fraud->signup_ip ?></li>
                                                                            <li><strong>Device ID:</strong> <?= $fraud->signup_device_id ?></li>
                                                                            <li><strong>Active Days:</strong> <?= $fraud->referee_active_days ?></li>
                                                                            <li><strong>Quizzes Played:</strong> <?= $fraud->referee_quizzes_played ?></li>
                                                                        </ul>
                                                                    </div>
                                                                    <div class="modal-footer">
                                                                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    <?php endforeach; ?>

                                                    <?php if (empty($suspicious)): ?>
                                                        <tr>
                                                            <td colspan="9" class="text-center">
                                                                <div class="empty-state" style="padding: 40px;">
                                                                    <div class="empty-state-icon">
                                                                        <i class="fas fa-check-circle" style="font-size: 48px; color: #28a745;"></i>
                                                                    </div>
                                                                    <h2>All Clear!</h2>
                                                                    <p class="lead">No suspicious referrals requiring review at this time.</p>
                                                                </div>
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

    <script>
        $(document).ready(function() {
            // Approve fraud check
            $('.approve-btn').click(function() {
                let fraudId = $(this).data('id');
                let referralId = $(this).data('referral-id');

                if (confirm('Are you sure you want to approve this referral? This will clear the fraud flag.')) {
                    $.ajax({
                        url: '<?= base_url('admin/resolve-fraud') ?>',
                        method: 'POST',
                        data: {
                            fraud_id: fraudId,
                            referral_id: referralId,
                            action: 'approve',
                            <?= $this->security->get_csrf_token_name() ?>: '<?= $this->security->get_csrf_hash() ?>'
                        },
                        success: function(response) {
                            $('#row-' + fraudId).fadeOut();
                            alert('Fraud flag cleared. Referral approved.');
                        },
                        error: function() {
                            alert('Error approving referral. Please try again.');
                        }
                    });
                }
            });

            // Reject referral
            $('.reject-btn').click(function() {
                let fraudId = $(this).data('id');
                let referralId = $(this).data('referral-id');

                if (confirm('Are you sure you want to reject this referral? No rewards will be given.')) {
                    $.ajax({
                        url: '<?= base_url('admin/resolve-fraud') ?>',
                        method: 'POST',
                        data: {
                            fraud_id: fraudId,
                            referral_id: referralId,
                            action: 'reject',
                            <?= $this->security->get_csrf_token_name() ?>: '<?= $this->security->get_csrf_hash() ?>'
                        },
                        success: function(response) {
                            $('#row-' + fraudId).fadeOut();
                            alert('Referral rejected. No rewards will be distributed.');
                        },
                        error: function() {
                            alert('Error rejecting referral. Please try again.');
                        }
                    });
                }
            });
        });
    </script>
</body>

</html>
