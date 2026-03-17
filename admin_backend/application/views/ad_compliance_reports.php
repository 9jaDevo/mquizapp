<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta content="width=device-width, initial-scale=1, maximum-scale=1, shrink-to-fit=no" name="viewport">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>Ad Compliance Reports | <?php echo (is_settings('app_name')) ? is_settings('app_name') : '' ?></title>

    <?php base_url() . include 'include.php'; ?>
</head>

<body>
    <div id="app">
        <div class="main-wrapper">
            <?php base_url() . include 'header.php'; ?>

            <div class="main-content">
                <section class="section">
                    <div class="section-header">
                        <h1>Ad Compliance Reports <small class="text-small">Uploaded client-side audit events</small></h1>
                    </div>

                    <div class="section-body">
                        <div class="row">
                            <div class="col-12">
                                <div class="card">
                                    <div class="card-body">
                                        <form method="get" class="row align-items-end">
                                            <div class="form-group col-md-3 col-sm-12">
                                                <label>Date From</label>
                                                <input type="date" name="date_from" class="form-control" value="<?= $date_from ?>">
                                            </div>
                                            <div class="form-group col-md-3 col-sm-12">
                                                <label>Date To</label>
                                                <input type="date" name="date_to" class="form-control" value="<?= $date_to ?>">
                                            </div>
                                            <div class="form-group col-md-4 col-sm-12">
                                                <label>Event Name (optional)</label>
                                                <input type="text" name="event_name" class="form-control" placeholder="Example: interstitial_cap_hit" value="<?= htmlspecialchars($event_name, ENT_QUOTES, 'UTF-8') ?>">
                                            </div>
                                            <div class="form-group col-md-2 col-sm-12">
                                                <button type="submit" class="btn btn-primary btn-block">Apply</button>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-6 col-12">
                                <div class="card">
                                    <div class="card-header">
                                        <h4>Summary by Event</h4>
                                    </div>
                                    <div class="card-body table-responsive">
                                        <table class="table table-sm table-striped" aria-describedby="summary by event">
                                            <thead>
                                                <tr>
                                                    <th>Event</th>
                                                    <th>Total</th>
                                                    <th>Users</th>
                                                    <th>Last Seen</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <?php if (empty($event_summary)) { ?>
                                                    <tr>
                                                        <td colspan="4" class="text-center text-muted">No events found</td>
                                                    </tr>
                                                <?php } else { ?>
                                                    <?php foreach ($event_summary as $row) { ?>
                                                        <tr>
                                                            <td><?= htmlspecialchars($row['event_name'], ENT_QUOTES, 'UTF-8') ?></td>
                                                            <td><?= (int)$row['total_events'] ?></td>
                                                            <td><?= (int)$row['unique_users'] ?></td>
                                                            <td><?= htmlspecialchars((string)$row['last_seen'], ENT_QUOTES, 'UTF-8') ?></td>
                                                        </tr>
                                                    <?php } ?>
                                                <?php } ?>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>

                            <div class="col-md-6 col-12">
                                <div class="card">
                                    <div class="card-header">
                                        <h4>Daily Totals</h4>
                                    </div>
                                    <div class="card-body table-responsive">
                                        <table class="table table-sm table-striped" aria-describedby="daily totals">
                                            <thead>
                                                <tr>
                                                    <th>Date</th>
                                                    <th>Total Events</th>
                                                    <th>Unique Users</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <?php if (empty($daily_summary)) { ?>
                                                    <tr>
                                                        <td colspan="3" class="text-center text-muted">No events found</td>
                                                    </tr>
                                                <?php } else { ?>
                                                    <?php foreach ($daily_summary as $row) { ?>
                                                        <tr>
                                                            <td><?= htmlspecialchars($row['event_day'], ENT_QUOTES, 'UTF-8') ?></td>
                                                            <td><?= (int)$row['total_events'] ?></td>
                                                            <td><?= (int)$row['unique_users'] ?></td>
                                                        </tr>
                                                    <?php } ?>
                                                <?php } ?>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-12">
                                <div class="card">
                                    <div class="card-header">
                                        <h4>Recent Events (latest 200)</h4>
                                    </div>
                                    <div class="card-body table-responsive">
                                        <table class="table table-sm table-striped" aria-describedby="recent events">
                                            <thead>
                                                <tr>
                                                    <th>ID</th>
                                                    <th>Event</th>
                                                    <th>User ID</th>
                                                    <th>User</th>
                                                    <th>Platform</th>
                                                    <th>App Version</th>
                                                    <th>Created At</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <?php if (empty($recent_events)) { ?>
                                                    <tr>
                                                        <td colspan="7" class="text-center text-muted">No events found</td>
                                                    </tr>
                                                <?php } else { ?>
                                                    <?php foreach ($recent_events as $row) { ?>
                                                        <tr>
                                                            <td><?= (int)$row['id'] ?></td>
                                                            <td><?= htmlspecialchars($row['event_name'], ENT_QUOTES, 'UTF-8') ?></td>
                                                            <td><?= (int)$row['user_id'] ?></td>
                                                            <td><?= htmlspecialchars((string)$row['user_name'], ENT_QUOTES, 'UTF-8') ?></td>
                                                            <td><?= htmlspecialchars((string)$row['platform'], ENT_QUOTES, 'UTF-8') ?></td>
                                                            <td><?= htmlspecialchars((string)$row['app_version'], ENT_QUOTES, 'UTF-8') ?></td>
                                                            <td><?= htmlspecialchars((string)$row['created_at'], ENT_QUOTES, 'UTF-8') ?></td>
                                                        </tr>
                                                    <?php } ?>
                                                <?php } ?>
                                            </tbody>
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
</body>

</html>