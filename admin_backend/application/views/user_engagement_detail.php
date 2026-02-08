<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta content="width=device-width, initial-scale=1, maximum-scale=1, shrink-to-fit=no" name="viewport">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>User Engagement Detail | <?php echo (is_settings('app_name')) ? is_settings('app_name') : "" ?></title>

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
                        <h1>User Engagement Details <small>Session history and activity</small></h1>
                    </div>
                    <div class="section-body">

                        <!-- User Info Card -->
                        <div class="row">
                            <div class="col-12">
                                <div class="card">
                                    <div class="card-header">
                                        <h4>User Information</h4>
                                        <div class="card-header-action">
                                            <a href="<?= base_url() ?>engagement-dashboard" class="btn btn-primary">
                                                <i class="fas fa-arrow-left"></i> Back to Dashboard
                                            </a>
                                        </div>
                                    </div>
                                    <div class="card-body">
                                        <div class="row">
                                            <div class="col-md-2 text-center">
                                                <?php
                                                $profile_img = $user->profile ? base_url() . 'images/profile/' . $user->profile : base_url() . 'images/profile/default.png';
                                                ?>
                                                <img src="<?= $profile_img ?>" alt="avatar" width="100" height="100" class="rounded-circle">
                                            </div>
                                            <div class="col-md-5">
                                                <table class="table table-sm">
                                                    <tr>
                                                        <td><strong>Name:</strong></td>
                                                        <td><?= $user->name ?></td>
                                                    </tr>
                                                    <tr>
                                                        <td><strong>Email:</strong></td>
                                                        <td><?= $user->email ?></td>
                                                    </tr>
                                                    <tr>
                                                        <td><strong>User ID:</strong></td>
                                                        <td><?= $user->id ?></td>
                                                    </tr>
                                                </table>
                                            </div>
                                            <div class="col-md-5">
                                                <table class="table table-sm">
                                                    <tr>
                                                        <td><strong>Country:</strong></td>
                                                        <td><?= $user->country_name ?? 'N/A' ?></td>
                                                    </tr>
                                                    <tr>
                                                        <td><strong>Continent:</strong></td>
                                                        <td><?= $user->continent ?? 'N/A' ?></td>
                                                    </tr>
                                                    <tr>
                                                        <td><strong>Country Code:</strong></td>
                                                        <td><?= $user->country_code ?? 'N/A' ?></td>
                                                    </tr>
                                                </table>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Engagement Statistics -->
                        <div class="row">
                            <div class="col-lg-3 col-md-6">
                                <div class="card card-statistic-1">
                                    <div class="card-icon bg-primary">
                                        <i class="fas fa-clock"></i>
                                    </div>
                                    <div class="card-wrap">
                                        <div class="card-header">
                                            <h4>Total Engagement</h4>
                                        </div>
                                        <div class="card-body">
                                            <?php
                                            if ($engagement) {
                                                $hours = floor($engagement->total_minutes / 60);
                                                $minutes = $engagement->total_minutes % 60;
                                                echo $hours . 'h ' . $minutes . 'm';
                                            } else {
                                                echo '0h 0m';
                                            }
                                            ?>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-lg-3 col-md-6">
                                <div class="card card-statistic-1">
                                    <div class="card-icon bg-success">
                                        <i class="fas fa-history"></i>
                                    </div>
                                    <div class="card-wrap">
                                        <div class="card-header">
                                            <h4>Total Sessions</h4>
                                        </div>
                                        <div class="card-body">
                                            <?= $sessions->total_sessions ?? 0 ?>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-lg-3 col-md-6">
                                <div class="card card-statistic-1">
                                    <div class="card-icon bg-warning">
                                        <i class="fas fa-stopwatch"></i>
                                    </div>
                                    <div class="card-wrap">
                                        <div class="card-header">
                                            <h4>Avg Session</h4>
                                        </div>
                                        <div class="card-body">
                                            <?php
                                            if ($sessions && $sessions->avg_duration) {
                                                $avg_min = round($sessions->avg_duration / 60, 1);
                                                echo $avg_min . ' min';
                                            } else {
                                                echo '0 min';
                                            }
                                            ?>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-lg-3 col-md-6">
                                <div class="card card-statistic-1">
                                    <div class="card-icon bg-danger">
                                        <i class="fas fa-crown"></i>
                                    </div>
                                    <div class="card-wrap">
                                        <div class="card-header">
                                            <h4>Longest Session</h4>
                                        </div>
                                        <div class="card-body">
                                            <?php
                                            if ($sessions && $sessions->max_duration) {
                                                $max_hours = floor($sessions->max_duration / 3600);
                                                $max_min = floor(($sessions->max_duration % 3600) / 60);
                                                echo $max_hours . 'h ' . $max_min . 'm';
                                            } else {
                                                echo '0h 0m';
                                            }
                                            ?>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Activity Timeline -->
                        <div class="row">
                            <div class="col-md-6">
                                <div class="card">
                                    <div class="card-header">
                                        <h4>Activity Timeline</h4>
                                    </div>
                                    <div class="card-body">
                                        <div class="table-responsive">
                                            <table class="table table-sm">
                                                <tr>
                                                    <td><strong>First Session:</strong></td>
                                                    <td>
                                                        <?php
                                                        if ($sessions && $sessions->first_session) {
                                                            echo date('d M Y H:i', strtotime($sessions->first_session));
                                                        } else {
                                                            echo 'N/A';
                                                        }
                                                        ?>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td><strong>Last Session:</strong></td>
                                                    <td>
                                                        <?php
                                                        if ($sessions && $sessions->last_session) {
                                                            echo date('d M Y H:i', strtotime($sessions->last_session));
                                                        } else {
                                                            echo 'N/A';
                                                        }
                                                        ?>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td><strong>Last Updated:</strong></td>
                                                    <td>
                                                        <?php
                                                        if ($engagement && $engagement->last_updated) {
                                                            echo date('d M Y H:i', strtotime($engagement->last_updated));
                                                        } else {
                                                            echo 'N/A';
                                                        }
                                                        ?>
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <?php if (has_permissions('delete', 'engagement_tracking')) { ?>
                                <div class="col-md-6">
                                    <div class="card">
                                        <div class="card-header">
                                            <h4>Admin Actions</h4>
                                        </div>
                                        <div class="card-body">
                                            <div class="alert alert-warning">
                                                <strong>Warning:</strong> These actions cannot be undone.
                                            </div>
                                            <button class="btn btn-danger btn-block mb-2" onclick="deleteAllSessions()">
                                                <i class="fas fa-trash"></i> Delete All Sessions
                                            </button>
                                            <button class="btn btn-warning btn-block mb-2" onclick="flagUser()">
                                                <i class="fas fa-flag"></i> Flag as Suspicious
                                            </button>
                                            <a href="<?= base_url() ?>Table/user_engagement_sessions?user_id=<?= $user_id ?>&limit=10000"
                                                class="btn btn-info btn-block" download>
                                                <i class="fas fa-download"></i> Download Sessions CSV
                                            </a>
                                        </div>
                                    </div>
                                </div>
                            <?php } ?>
                        </div>

                        <!-- Session History Table -->
                        <div class="row">
                            <div class="col-12">
                                <div class="card">
                                    <div class="card-header">
                                        <h4>Session History</h4>
                                    </div>
                                    <div class="card-body">
                                        <table aria-describedby="mydesc" class='table-striped' id='user_sessions_table'
                                            data-toggle="table"
                                            data-url="<?= base_url() . 'Table/user_engagement_sessions' ?>"
                                            data-side-pagination="server"
                                            data-pagination="true"
                                            data-page-list="[10, 25, 50, 100, All]"
                                            data-search="true"
                                            data-toolbar="#toolbar"
                                            data-show-columns="true"
                                            data-show-refresh="true"
                                            data-sort-name="session_start"
                                            data-sort-order="desc"
                                            data-query-params="queryParams">
                                            <thead>
                                                <tr>
                                                    <th scope="col" data-field="id" data-sortable="true">ID</th>
                                                    <th scope="col" data-field="session_start" data-sortable="true">Start Time</th>
                                                    <th scope="col" data-field="session_end" data-sortable="true">End Time</th>
                                                    <th scope="col" data-field="formatted_duration" data-sortable="false">Duration</th>
                                                    <th scope="col" data-field="duration_seconds" data-sortable="true" data-visible="false">Seconds</th>
                                                    <th scope="col" data-field="is_suspicious" data-sortable="true" data-formatter="suspiciousFormatter">Status</th>
                                                    <th scope="col" data-field="date_created" data-sortable="true">Created</th>
                                                </tr>
                                            </thead>
                                        </table>
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

    <script>
        function queryParams(p) {
            return {
                "user_id": <?= $user_id ?>,
                sort: p.sort,
                order: p.order,
                offset: p.offset,
                limit: p.limit,
                search: p.search
            };
        }

        function suspiciousFormatter(value, row) {
            if (value == 1 || value == true) {
                return '<span class="badge badge-danger"><i class="fas fa-exclamation-triangle"></i> Suspicious</span>';
            } else {
                return '<span class="badge badge-success"><i class="fas fa-check"></i> Normal</span>';
            }
        }

        function deleteAllSessions() {
            swal({
                title: 'Are you sure?',
                text: 'This will delete all engagement sessions for this user. This cannot be undone!',
                icon: 'warning',
                buttons: true,
                dangerMode: true,
            }).then((willDelete) => {
                if (willDelete) {
                    // TODO: Implement AJAX call to delete endpoint
                    iziToast.info({
                        title: 'Info',
                        message: 'Delete functionality will be implemented in admin control endpoints',
                        position: 'topRight'
                    });
                }
            });
        }

        function flagUser() {
            swal({
                title: 'Flag User as Suspicious?',
                text: 'This will mark the user for review.',
                icon: 'warning',
                buttons: true,
            }).then((willFlag) => {
                if (willFlag) {
                    // TODO: Implement AJAX call to flag endpoint
                    iziToast.info({
                        title: 'Info',
                        message: 'Flag functionality will be implemented in admin control endpoints',
                        position: 'topRight'
                    });
                }
            });
        }
    </script>

</body>

</html>