<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta content="width=device-width, initial-scale=1, maximum-scale=1, shrink-to-fit=no" name="viewport">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>Sponsor Banners | <?php echo (is_settings('app_name')) ? is_settings('app_name') : "" ?></title>

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
                        <h1>Sponsor Banners <small class="text-small">Manage and track sponsor advertisements</small></h1>
                        <div class="section-header-button">
                            <button class="btn <?= BUTTON_CLASS ?>" data-toggle="modal" data-target="#bannerModal" id="addBannerBtn">
                                <i class="fas fa-plus"></i> Add Banner
                            </button>
                        </div>
                    </div>
                    <div class="section-body">
                        <?php if ($this->session->flashdata('success')): ?>
                            <div class="alert alert-success alert-dismissible show fade">
                                <div class="alert-body">
                                    <button class="close" data-dismiss="alert"><span>×</span></button>
                                    <?= $this->session->flashdata('success'); ?>
                                </div>
                            </div>
                        <?php endif; ?>
                        <?php if ($this->session->flashdata('error')): ?>
                            <div class="alert alert-danger alert-dismissible show fade">
                                <div class="alert-body">
                                    <button class="close" data-dismiss="alert"><span>×</span></button>
                                    <?= $this->session->flashdata('error'); ?>
                                </div>
                            </div>
                        <?php endif; ?>
                        <!-- Settings Card -->
                        <div class="row">
                            <div class="col-12">
                                <div class="card">
                                    <div class="card-header">
                                        <h4>Banner Settings</h4>
                                    </div>
                                    <div class="card-body">
                                        <form method="post" class="needs-validation" novalidate="">
                                            <input type="hidden" name="<?= $this->security->get_csrf_token_name(); ?>" value="<?= $this->security->get_csrf_hash(); ?>">

                                            <div class="row">
                                                <div class="form-group col-md-3 col-sm-12">
                                                    <label class="control-label">Enable Banners</label><br>
                                                    <input type="checkbox" id="sponsor_banner_enable_btn" data-plugin="switchery" <?php
                                                                                                                                    if (!empty($sponsor_banner_enable) && $sponsor_banner_enable == '1') {
                                                                                                                                        echo 'checked';
                                                                                                                                    }
                                                                                                                                    ?>>

                                                    <input type="hidden" id="sponsor_banner_enable" name="sponsor_banner_enable" value="<?= ($sponsor_banner_enable) ? $sponsor_banner_enable : 0; ?>">
                                                </div>
                                                <div class="form-group col-md-3 col-sm-12">
                                                    <label class="control-label">Rotation Delay (seconds)</label>
                                                    <input type="number" name="sponsor_banner_rotation_seconds" class="form-control" value="<?= (!empty($sponsor_banner_rotation_seconds)) ? $sponsor_banner_rotation_seconds : 5; ?>" min="1" max="60">
                                                </div>
                                                <div class="form-group col-md-3 col-sm-12">
                                                    <label class="control-label">Track User ID</label><br>
                                                    <input type="checkbox" id="sponsor_banner_analytics_track_user_btn" data-plugin="switchery" <?php
                                                                                                                                                if (!empty($sponsor_banner_analytics_track_user) && $sponsor_banner_analytics_track_user == '1') {
                                                                                                                                                    echo 'checked';
                                                                                                                                                }
                                                                                                                                                ?>>

                                                    <input type="hidden" id="sponsor_banner_analytics_track_user" name="sponsor_banner_analytics_track_user" value="<?= ($sponsor_banner_analytics_track_user) ? $sponsor_banner_analytics_track_user : 0; ?>">
                                                    <small class="form-text text-muted">For analytics tracking</small>
                                                </div>
                                            </div>

                                            <hr>

                                            <div class="row">
                                                <div class="form-group col-sm-12">
                                                    <input type="submit" name="btnupdate_settings" value="Update Settings" class="<?= BUTTON_CLASS ?>" />
                                                </div>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Banners Table -->
                        <div class="row mt-4">
                            <div class="col-12">
                                <div class="card">
                                    <div class="card-header">
                                        <h4>Active Banners</h4>
                                    </div>
                                    <div class="card-body">
                                        <div class="table-responsive">
                                            <table class="table table-striped table-bordered">
                                                <thead>
                                                    <tr>
                                                        <th>Sponsor</th>
                                                        <th>Title</th>
                                                        <th>Status</th>
                                                        <th>Impressions</th>
                                                        <th>Impressions Today</th>
                                                        <th>CTR</th>
                                                        <th>Date Range</th>
                                                        <th>Action</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <?php if (!empty($banners)): ?>
                                                        <?php foreach ($banners as $banner): ?>
                                                        <tr>
                                                            <td><?= $banner->sponsor_name; ?></td>
                                                            <td><?= $banner->title; ?></td>
                                                            <td>
                                                                <?php if ($banner->is_active): ?>
                                                                    <span class="badge badge-success">Active</span>
                                                                <?php else: ?>
                                                                    <span class="badge badge-secondary">Inactive</span>
                                                                <?php endif; ?>
                                                            </td>
                                                            <td><?= $banner->total_impressions ?? 0; ?></td>
                                                            <td><?= $banner->today_impressions ?? 0; ?></td>
                                                            <td>
                                                                <?php 
                                                                    $ctr = ($banner->total_impressions > 0) ? ($banner->total_clicks / $banner->total_impressions * 100) : 0;
                                                                    echo round($ctr, 2) . '%';
                                                                ?>
                                                            </td>
                                                            <td><?= date('M d', strtotime($banner->start_date)); ?> - <?= date('M d', strtotime($banner->end_date)); ?></td>
                                                            <td>
                                                                <button class="btn btn-sm btn-info view-banner" data-banner-id="<?= $banner->id; ?>">View</button>
                                                                <button class="btn btn-sm btn-danger delete-banner" data-banner-id="<?= $banner->id; ?>">Delete</button>
                                                            </td>
                                                        </tr>
                                                        <?php endforeach; ?>
                                                    <?php else: ?>
                                                        <tr>
                                                            <td colspan="8" class="text-center text-muted">No banners created yet</td>
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

    <!-- Banner Modal -->
    <div class="modal fade" id="bannerModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <form method="post" action="<?= base_url('sponsor-banners'); ?>" enctype="multipart/form-data" class="needs-validation" novalidate="">
                    <div class="modal-header">
                        <h5 class="modal-title">Add/Edit Banner</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <input type="hidden" name="<?= $this->security->get_csrf_token_name(); ?>" value="<?= $this->security->get_csrf_hash(); ?>">
                        <input type="hidden" id="bannerId" name="id" value="">
                        <input type="hidden" name="btnadd" value="1">

                        <div class="form-group">
                            <label class="control-label">Sponsor Name <small class="text-danger">*</small></label>
                            <input type="text" id="sponsorName" name="sponsor_name" class="form-control" required placeholder="e.g., TechCorp Inc.">
                        </div>

                        <div class="form-group">
                            <label class="control-label">Banner Title <small class="text-danger">*</small></label>
                            <input type="text" id="bannerTitle" name="title" class="form-control" required placeholder="e.g., Download Our App">
                        </div>

                        <div class="form-group">
                            <label class="control-label">Image <small class="text-danger">*</small></label>
                            <input type="file" id="bannerImage" name="banner_image" class="form-control-file" accept="image/*" required>
                            <small class="form-text text-muted">Recommended: 300x150px, JPG/PNG</small>
                        </div>

                        <div class="form-group">
                            <label class="control-label">Redirect URL (optional)</label>
                            <input type="url" id="redirectUrl" name="redirect_url" class="form-control" placeholder="https://example.com">
                        </div>

                        <hr>

                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label class="control-label">Start Date <small class="text-danger">*</small></label>
                                    <input type="date" id="startDate" name="start_date" class="form-control" required>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label class="control-label">End Date <small class="text-danger">*</small></label>
                                    <input type="date" id="endDate" name="end_date" class="form-control" required>
                                </div>
                            </div>
                        </div>

                        <hr>

                        <div class="row">
                            <div class="col-md-4">
                                <div class="form-group">
                                    <label class="control-label">Impression Limit</label>
                                    <input type="number" id="impressionLimit" name="impression_limit" class="form-control" value="0" min="0" placeholder="0 = unlimited">
                                    <small class="form-text text-muted">0 = no limit</small>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="form-group">
                                    <label class="control-label">Period</label>
                                    <select name="impression_period" class="form-control">
                                        <option value="daily">Daily</option>
                                        <option value="weekly">Weekly</option>
                                        <option value="monthly">Monthly</option>
                                    </select>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="form-group">
                                    <label class="control-label">Priority</label>
                                    <input type="number" id="priority" name="priority" class="form-control" value="1" min="1" max="100">
                                    <small class="form-text text-muted">Higher = shown first</small>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn <?= BUTTON_CLASS ?>">Save Banner</button>
                    </div>
                </form>
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

        var enableBtn = document.querySelector('#sponsor_banner_enable_btn');
        if (enableBtn) {
            enableBtn.onchange = function() {
                $('#sponsor_banner_enable').val(this.checked ? 1 : 0);
            };
        }

        var trackBtn = document.querySelector('#sponsor_banner_analytics_track_user_btn');
        if (trackBtn) {
            trackBtn.onchange = function() {
                $('#sponsor_banner_analytics_track_user').val(this.checked ? 1 : 0);
            };
        }

        $(document).on('click', '#addBannerBtn', function() {
            $('#bannerId').val('');
            $('#sponsorName').val('');
            $('#bannerTitle').val('');
            $('#redirectUrl').val('');
            $('#startDate').val('');
            $('#endDate').val('');
            $('#impressionLimit').val('0');
            $('#priority').val('1');
            $('#bannerModal .modal-title').text('Add Banner');
            var imageInput = document.getElementById('bannerImage');
            if (imageInput) {
                imageInput.setAttribute('required', 'required');
                imageInput.value = '';
            }
        });

        // Debug form submission
        $('#bannerModal form').on('submit', function(e) {
            console.log('Form submitting...');
            
            // Log all form data
            var formData = new FormData(this);
            console.log('Form Data:');
            for (var pair of formData.entries()) {
                console.log(pair[0] + ': ' + pair[1]);
            }
            
            // Check if btnadd button exists
            var btnAdd = $(this).find('button[name="btnadd"]');
            console.log('btnadd button found:', btnAdd.length);
            
            // Allow form to submit normally
            return true;
        });

        $(document).on('click', '.view-banner', function() {
            var banner_id = $(this).data('banner-id');
            window.location.href = '<?= base_url('sponsor-banners'); ?>/view/' + banner_id;
        });

        $(document).on('click', '.delete-banner', function() {
            if (confirm('Are you sure you want to delete this banner?')) {
                var banner_id = $(this).data('banner-id');
                $.ajax({
                    type: 'POST',
                    url: '<?= base_url('Sponsors/delete'); ?>',
                    data: {
                        id: banner_id,
                        '<?= $this->security->get_csrf_token_name(); ?>': '<?= $this->security->get_csrf_hash(); ?>'
                    },
                    dataType: 'json',
                    success: function(response) {
                        var ok = (response && response.error === false) || response === true || response.success === true;
                        if (ok) {
                            alert('Banner deleted successfully');
                            location.reload();
                        } else {
                            alert('Error: ' + (response.message || 'Unknown error'));
                        }
                    },
                    error: function(xhr, status, error) {
                        alert('Error deleting banner: ' + error);
                        console.error('Delete error:', xhr.responseText);
                    }
                });
            }
        });
    </script>

</body>

</html>
