<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta content="width=device-width, initial-scale=1, maximum-scale=1, shrink-to-fit=no" name="viewport">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>Sponsor Banner Detail | <?php echo (is_settings('app_name')) ? is_settings('app_name') : "" ?></title>

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
                        <h1>Banner Analytics <small class="text-small">View detailed performance metrics</small></h1>
                        <div class="section-header-button">
                            <a href="<?= base_url('Sponsors'); ?>" class="btn btn-secondary">Back to Banners</a>
                        </div>
                    </div>
                    <div class="section-body">
                        <?php if (!empty($banner)): ?>
                        <div class="row">
                            <div class="col-12">
                                <div class="card">
                                    <div class="card-header">
                                        <h4><?= $banner['sponsor_name']; ?> - <?= $banner['title']; ?></h4>
                                    </div>
                                    <div class="card-body">
                                        <div class="row">
                                            <div class="col-md-4">
                                                <img src="<?= $banner['image_url']; ?>" alt="<?= $banner['title']; ?>" style="max-width: 100%; height: auto; border-radius: 4px;">
                                            </div>
                                            <div class="col-md-8">
                                                <p><strong>URL:</strong> <a href="<?= $banner['redirect_url']; ?>" target="_blank"><?= $banner['redirect_url']; ?></a></p>
                                                <p><strong>Date Range:</strong> <?= date('M d, Y', strtotime($banner['start_date'])); ?> - <?= date('M d, Y', strtotime($banner['end_date'])); ?></p>
                                                <p><strong>Status:</strong> 
                                                    <?php if ($banner['is_active']): ?>
                                                        <span class="badge badge-success">Active</span>
                                                    <?php else: ?>
                                                        <span class="badge badge-secondary">Inactive</span>
                                                    <?php endif; ?>
                                                </p>
                                                <p><strong>Priority:</strong> <?= $banner['priority']; ?></p>
                                                <p><strong>Impression Limit:</strong> <?= ($banner['impression_limit'] == 0) ? 'Unlimited' : $banner['impression_limit'] . ' per ' . ucfirst($banner['impression_period']); ?></p>
                                                <p><strong>Current Impressions:</strong> <?= $banner['current_impressions']; ?></p>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Analytics Cards -->
                        <div class="row mt-4">
                            <div class="col-md-3 col-sm-6">
                                <div class="card">
                                    <div class="card-body">
                                        <h2 class="text-primary"><?= $analytics['total_impressions'] ?? 0; ?></h2>
                                        <p>Total Impressions</p>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-3 col-sm-6">
                                <div class="card">
                                    <div class="card-body">
                                        <h2 class="text-success"><?= $analytics['total_clicks'] ?? 0; ?></h2>
                                        <p>Total Clicks</p>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-3 col-sm-6">
                                <div class="card">
                                    <div class="card-body">
                                        <h2 class="text-info"><?= round($analytics['ctr'] ?? 0, 2); ?>%</h2>
                                        <p>Click-Through Rate</p>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-3 col-sm-6">
                                <div class="card">
                                    <div class="card-body">
                                        <h2 class="text-warning"><?= $analytics['unique_users'] ?? 0; ?></h2>
                                        <p>Unique Users</p>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Daily Impressions Chart -->
                        <div class="row mt-4">
                            <div class="col-12">
                                <div class="card">
                                    <div class="card-header">
                                        <h4>Daily Impressions (Last 30 Days)</h4>
                                    </div>
                                    <div class="card-body">
                                        <canvas id="impressionsChart"></canvas>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Actions -->
                        <div class="row mt-4">
                            <div class="col-12">
                                <div class="card">
                                    <div class="card-header">
                                        <h4>Actions</h4>
                                    </div>
                                    <div class="card-body">
                                        <form method="post" enctype="multipart/form-data">
                                            <input type="hidden" name="<?= $this->security->get_csrf_token_name(); ?>" value="<?= $this->security->get_csrf_hash(); ?>">

                                            <div class="row">
                                                <div class="form-group col-md-6">
                                                    <label class="control-label">Title</label>
                                                    <input type="text" name="title" class="form-control" value="<?= $banner['title']; ?>" required>
                                                </div>
                                                <div class="form-group col-md-6">
                                                    <label class="control-label">Sponsor Name</label>
                                                    <input type="text" name="sponsor_name" class="form-control" value="<?= $banner['sponsor_name']; ?>" required>
                                                </div>
                                            </div>

                                            <div class="row">
                                                <div class="form-group col-md-6">
                                                    <label class="control-label">Redirect URL</label>
                                                    <input type="url" name="redirect_url" class="form-control" value="<?= $banner['redirect_url']; ?>" required>
                                                </div>
                                                <div class="form-group col-md-6">
                                                    <label class="control-label">New Image (Optional)</label>
                                                    <input type="file" name="image" class="form-control-file" accept="image/*">
                                                    <small class="form-text text-muted">Leave blank to keep current image</small>
                                                </div>
                                            </div>

                                            <div class="row">
                                                <div class="form-group col-md-3">
                                                    <label class="control-label">Start Date</label>
                                                    <input type="date" name="start_date" class="form-control" value="<?= $banner['start_date']; ?>" required>
                                                </div>
                                                <div class="form-group col-md-3">
                                                    <label class="control-label">End Date</label>
                                                    <input type="date" name="end_date" class="form-control" value="<?= $banner['end_date']; ?>" required>
                                                </div>
                                                <div class="form-group col-md-3">
                                                    <label class="control-label">Priority</label>
                                                    <input type="number" name="priority" class="form-control" value="<?= $banner['priority']; ?>" min="1" max="100" required>
                                                </div>
                                                <div class="form-group col-md-3">
                                                    <label class="control-label">Active</label>
                                                    <select name="is_active" class="form-control">
                                                        <option value="1" <?= ($banner['is_active']) ? 'selected' : ''; ?>>Yes</option>
                                                        <option value="0" <?= (!$banner['is_active']) ? 'selected' : ''; ?>>No</option>
                                                    </select>
                                                </div>
                                            </div>

                                            <hr>

                                            <div class="row">
                                                <div class="form-group col-sm-12">
                                                    <input type="submit" name="btnupdate" value="Update Banner" class="<?= BUTTON_CLASS ?>" />
                                                    <a href="<?= base_url('Sponsors'); ?>" class="btn btn-secondary">Cancel</a>
                                                </div>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <?php else: ?>
                        <div class="alert alert-danger">Banner not found</div>
                        <?php endif; ?>
                    </div>

                </section>
            </div>
        </div>
    </div>

    <?php base_url() . include 'footer.php'; ?>

    <script type="text/javascript">
        var chartData = <?= json_encode($daily_data ?? []); ?>;
        
        if (chartData && chartData.labels) {
            new Chart(document.getElementById('impressionsChart'), {
                type: 'line',
                data: {
                    labels: chartData.labels,
                    datasets: [{
                        label: 'Impressions',
                        data: chartData.impressions,
                        borderColor: '#1abc9c',
                        backgroundColor: 'rgba(26, 188, 156, 0.1)',
                        tension: 0.4,
                        fill: true
                    }, {
                        label: 'Clicks',
                        data: chartData.clicks,
                        borderColor: '#f39c12',
                        backgroundColor: 'rgba(243, 156, 18, 0.1)',
                        tension: 0.4,
                        fill: true
                    }]
                },
                options: {
                    responsive: true,
                    scales: {
                        y: {
                            beginAtZero: true
                        }
                    },
                    plugins: {
                        legend: {
                            position: 'bottom'
                        }
                    }
                }
            });
        }
    </script>

</body>

</html>
