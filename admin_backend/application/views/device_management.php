<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta content="width=device-width, initial-scale=1, maximum-scale=1, shrink-to-fit=no" name="viewport">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>Device Management | <?php echo (is_settings('app_name')) ? is_settings('app_name') : "" ?></title>

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
                        <h1>Device Management <small class="text-small">Prevent multi-accounting and enforce one device per user</small></h1>
                    </div>
                    <div class="section-body">
                        <!-- Settings Card -->
                        <div class="row">
                            <div class="col-12">
                                <div class="card">
                                    <div class="card-header">
                                        <h4>Enforcement Settings</h4>
                                    </div>
                                    <div class="card-body">
                                        <form method="post" class="needs-validation" novalidate="">
                                            <input type="hidden" name="<?= $this->security->get_csrf_token_name(); ?>" value="<?= $this->security->get_csrf_hash(); ?>">

                                            <div class="row">
                                                <div class="form-group col-md-4 col-sm-12">
                                                    <label class="control-label">One Device Per Account</label><br>
                                                    <input type="checkbox" id="device_one_account_enforcement_btn" data-plugin="switchery" <?php
                                                                                                                                            if (!empty($device_one_account_enforcement) && $device_one_account_enforcement['message'] == '1') {
                                                                                                                                                echo 'checked';
                                                                                                                                            }
                                                                                                                                            ?>>

                                                    <input type="hidden" id="device_one_account_enforcement" name="device_one_account_enforcement" value="<?= ($device_one_account_enforcement) ? $device_one_account_enforcement['message'] : 0; ?>">
                                                    <small class="form-text text-muted">When enabled, automatically detects and blocks multi-account scenarios</small>
                                                </div>
                                            </div>

                                            <hr>

                                            <div class="row">
                                                <div class="form-group col-md-6 col-sm-12">
                                                    <label class="control-label">Suspension Action</label>
                                                    <select name="device_suspension_action" class="form-control">
                                                        <option value="warn" <?= (!empty($device_suspension_action) && $device_suspension_action['message'] == 'warn') ? 'selected' : ''; ?>>Send Warning Only</option>
                                                        <option value="suspend" <?= (!empty($device_suspension_action) && $device_suspension_action['message'] == 'suspend') ? 'selected' : ''; ?>>Suspend Account</option>
                                                    </select>
                                                    <small class="form-text text-muted">Action to take when multi-account is detected</small>
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

                        <!-- Suspicious Devices Alert -->
                        <?php if (!empty($suspicious_devices) && count($suspicious_devices) > 0): ?>
                        <div class="row mt-4">
                            <div class="col-12">
                                <div class="alert alert-danger">
                                    <h4><strong>⚠️ Alert: Suspicious Devices Detected</strong></h4>
                                    <p><?= count($suspicious_devices); ?> device(s) linked to multiple accounts:</p>
                                    <ul>
                                        <?php foreach ($suspicious_devices as $device): ?>
                                        <li><strong><?= $device->device_id; ?></strong> - <?= $device->account_count; ?> accounts</li>
                                        <?php endforeach; ?>
                                    </ul>
                                </div>
                            </div>
                        </div>
                        <?php endif; ?>

                        <!-- Devices Table -->
                        <div class="row mt-4">
                            <div class="col-12">
                                <div class="card">
                                    <div class="card-header">
                                        <h4>Registered Devices</h4>
                                    </div>
                                    <div class="card-body">
                                        <div class="table-responsive">
                                            <table class="table table-striped table-bordered">
                                                <thead>
                                                    <tr>
                                                        <th>Device ID</th>
                                                        <th>User</th>
                                                        <th>Device Type</th>
                                                        <th>Status</th>
                                                        <th>First Login</th>
                                                        <th>Last Login</th>
                                                        <th>Action</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <?php if (!empty($devices)): ?>
                                                        <?php foreach ($devices as $device): ?>
                                                        <tr>
                                                            <td><code><?= substr($device->device_id, 0, 20); ?>...</code></td>
                                                            <td><?= !empty($device->user_email) ? $device->user_email : 'Unknown'; ?></td>
                                                            <td><?= ucfirst($device->device_type); ?></td>
                                                            <td>
                                                                <?php if ($device->status == 'active'): ?>
                                                                    <span class="badge badge-success">Active</span>
                                                                <?php else: ?>
                                                                    <span class="badge badge-danger">Suspended</span><br>
                                                                    <small><?= $device->suspension_reason; ?></small>
                                                                <?php endif; ?>
                                                            </td>
                                                            <td><?= date('M d, Y', strtotime($device->first_login)); ?></td>
                                                            <td><?= date('M d, Y H:i', strtotime($device->last_login)); ?></td>
                                                            <td>
                                                                <?php if ($device->status == 'active'): ?>
                                                                    <button class="btn btn-sm btn-danger suspend-device" data-device-id="<?= $device->device_id; ?>">Suspend</button>
                                                                <?php else: ?>
                                                                    <span class="text-muted">-</span>
                                                                <?php endif; ?>
                                                            </td>
                                                        </tr>
                                                        <?php endforeach; ?>
                                                    <?php else: ?>
                                                        <tr>
                                                            <td colspan="7" class="text-center text-muted">No devices registered yet</td>
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
        var enforcementBtn = document.querySelector('#device_one_account_enforcement_btn');
        if (enforcementBtn) {
            enforcementBtn.onchange = function() {
                if (enforcementBtn.checked) {
                    $('#device_one_account_enforcement').val(1);
                } else {
                    $('#device_one_account_enforcement').val(0);
                }
            };
        }

        $(document).on('click', '.suspend-device', function() {
            var device_id = $(this).data('device-id');
            var reason = prompt('Enter suspension reason:');
            if (reason) {
                $.ajax({
                    type: 'POST',
                    url: '<?= base_url('Device/suspend_device'); ?>',
                    data: {
                        device_id: device_id,
                        reason: reason,
                        '<?= $this->security->get_csrf_token_name(); ?>': '<?= $this->security->get_csrf_hash(); ?>'
                    },
                    success: function(response) {
                        if (response.error === false) {
                            alert('Device suspended successfully');
                            location.reload();
                        } else {
                            alert('Error: ' + response.message);
                        }
                    }
                });
            }
        });
    </script>

</body>

</html>
