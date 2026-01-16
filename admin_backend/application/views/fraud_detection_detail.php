<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta content="width=device-width, initial-scale=1, maximum-scale=1, shrink-to-fit=no" name="viewport">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>Fraud Detection Detail | <?php echo (is_settings('app_name')) ? is_settings('app_name') : "" ?></title>

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
                        <h1>Fraud Detection Review <small class="text-small">Investigate and resolve suspicious activities</small></h1>
                    </div>
                    <div class="section-body">
                        <?php if (!empty($detection)): ?>
                        <div class="row">
                            <div class="col-12">
                                <div class="card">
                                    <div class="card-header">
                                        <h4>Detection Details</h4>
                                    </div>
                                    <div class="card-body">
                                        <input type="hidden" id="detectionId" value="<?= $detection->id; ?>">
                                        
                                        <div class="row">
                                            <div class="col-md-6">
                                                <p><strong>User:</strong> <?= $detection->user_email; ?></p>
                                                <p><strong>Detection Type:</strong> <span class="badge badge-primary"><?= ucfirst(str_replace('_', ' ', $detection->detection_type)); ?></span></p>
                                                <p><strong>Severity:</strong> 
                                                    <?php 
                                                        $severityClass = 'badge-secondary';
                                                        if ($detection->severity == 'low') $severityClass = 'badge-info';
                                                        elseif ($detection->severity == 'medium') $severityClass = 'badge-warning';
                                                        elseif ($detection->severity == 'high') $severityClass = 'badge-danger';
                                                        elseif ($detection->severity == 'critical') $severityClass = 'badge-dark';
                                                    ?>
                                                    <span class="badge <?= $severityClass; ?>"><?= ucfirst($detection->severity); ?></span>
                                                </p>
                                            </div>
                                            <div class="col-md-6">
                                                <p><strong>Detected At:</strong> <?= date('M d, Y H:i:s', strtotime($detection->created_at)); ?></p>
                                                <p><strong>Status:</strong> <span class="badge badge-warning"><?= ucfirst($detection->resolved); ?></span></p>
                                                <p><strong>Reason:</strong> <?= $detection->reason; ?></p>
                                            </div>
                                        </div>

                                        <hr>

                                        <div class="row">
                                            <div class="col-12">
                                                <h5 class="mb-3"><strong>Metadata</strong></h5>
                                                <div class="alert alert-light">
                                                    <pre><?php 
                                                        $metadata = json_decode($detection->metadata, true);
                                                        echo json_encode($metadata, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
                                                    ?></pre>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- User Activity History -->
                        <div class="row mt-4">
                            <div class="col-12">
                                <div class="card">
                                    <div class="card-header">
                                        <h4>User Activity History (Last 30 Days)</h4>
                                    </div>
                                    <div class="card-body">
                                        <div class="table-responsive">
                                            <table class="table table-striped table-sm">
                                                <thead>
                                                    <tr>
                                                        <th>Date & Time</th>
                                                        <th>Activity Type</th>
                                                        <th>Data</th>
                                                        <th>Coins</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <?php if (!empty($user_activity)): ?>
                                                        <?php foreach ($user_activity as $activity): ?>
                                                        <tr>
                                                            <td><?= date('M d, Y H:i', strtotime($activity->date)); ?></td>
                                                            <td><code><?= $activity->type; ?></code></td>
                                                            <td><?= $activity->data; ?></td>
                                                            <td><?= $activity->coins; ?></td>
                                                        </tr>
                                                        <?php endforeach; ?>
                                                    <?php else: ?>
                                                        <tr>
                                                            <td colspan="4" class="text-center text-muted">No activity found</td>
                                                        </tr>
                                                    <?php endif; ?>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Resolution Panel -->
                        <div class="row mt-4">
                            <div class="col-12">
                                <div class="card">
                                    <div class="card-header">
                                        <h4>Resolution</h4>
                                    </div>
                                    <div class="card-body">
                                        <?php if ($detection->resolved == 'unresolved'): ?>
                                        <div class="form-group">
                                            <label class="control-label">Notes</label>
                                            <textarea id="resolutionNotes" class="form-control" rows="4" placeholder="Add investigation notes here..."></textarea>
                                        </div>

                                        <div class="form-group">
                                            <label class="control-label">Action</label>
                                            <div class="btn-group w-100" role="group">
                                                <button type="button" class="btn btn-warning" id="warningBtn" style="width: 33%;">Send Warning</button>
                                                <button type="button" class="btn btn-danger" id="suspendBtn" style="width: 33%;">Suspend Account</button>
                                                <button type="button" class="btn btn-info" id="closeBtn" style="width: 34%;">Close Case (No Action)</button>
                                            </div>
                                        </div>
                                        <?php else: ?>
                                        <div class="alert alert-info">
                                            <p><strong>Resolved:</strong> <?= date('M d, Y H:i', strtotime($detection->updated_at)); ?></p>
                                            <p><strong>Action Taken:</strong> <span class="badge badge-info"><?= ucfirst($detection->action_taken); ?></span></p>
                                            <?php if ($detection->notes): ?>
                                            <p><strong>Notes:</strong> <?= $detection->notes; ?></p>
                                            <?php endif; ?>
                                        </div>
                                        <?php endif; ?>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <?php else: ?>
                        <div class="alert alert-danger">Detection not found</div>
                        <?php endif; ?>
                    </div>

                </section>
            </div>
        </div>
    </div>

    <?php base_url() . include 'footer.php'; ?>

    <script type="text/javascript">
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

        $(document).on('click', '#closeBtn', function() {
            var detection_id = $('#detectionId').val();
            var notes = $('#resolutionNotes').val();
            resolveDetection(detection_id, 'none', notes);
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
                        window.location.href = '<?= base_url('Fraud'); ?>';
                    } else {
                        alert('Error: ' + response.message);
                    }
                }
            });
        }
    </script>

</body>

</html>
