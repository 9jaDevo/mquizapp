<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta content="width=device-width, initial-scale=1, maximum-scale=1, shrink-to-fit=no" name="viewport">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>League Prize Management | <?php echo (is_settings('app_name')) ? is_settings('app_name') : ''; ?></title>
    <?php base_url() . include 'include.php'; ?>
</head>

<body>
    <div id="app">
        <div class="main-wrapper">
            <?php base_url() . include 'header.php'; ?>

            <div class="main-content">
                <section class="section">
                    <div class="section-header">
                        <h1>League Prize Management</h1>
                    </div>

                    <div class="section-body">
                        <?php if ($this->session->flashdata('success')): ?>
                            <div class="alert alert-success"><?php echo $this->session->flashdata('success'); ?></div>
                        <?php endif; ?>
                        <?php if ($this->session->flashdata('error')): ?>
                            <div class="alert alert-danger"><?php echo $this->session->flashdata('error'); ?></div>
                        <?php endif; ?>

                        <div class="row">
                            <div class="col-12">
                                <div class="card">
                                    <div class="card-header">
                                        <h4>Add Prize Tier</h4>
                                    </div>
                                    <div class="card-body">
                                        <form method="post" action="<?php echo base_url('league-prize/' . (int)$league_id); ?>" class="needs-validation" novalidate>
                                            <input type="hidden" name="<?php echo $this->security->get_csrf_token_name(); ?>" value="<?php echo $this->security->get_csrf_hash(); ?>">
                                            <input type="hidden" name="btnadd" value="1">
                                            <input type="hidden" name="league_id" value="<?php echo (int)$league_id; ?>">
                                            <?php $nextRank = !empty($max) ? ((int)$max[0]->total + 1) : 1; ?>

                                            <div class="row">
                                                <div class="form-group col-md-6 col-sm-12">
                                                    <label>Top Winner Rank</label>
                                                    <input type="number" name="winner" class="form-control" value="<?php echo (int)$nextRank; ?>" readonly required>
                                                </div>
                                                <div class="form-group col-md-6 col-sm-12">
                                                    <label>Prize Coins <small class="text-danger">*</small></label>
                                                    <input type="number" name="points" min="0" class="form-control" required>
                                                </div>
                                            </div>

                                            <div class="form-group">
                                                <button type="submit" class="<?php echo BUTTON_CLASS; ?>">Add Prize Tier</button>
                                                <a href="<?php echo base_url('league-prize-distribute/' . (int)$league_id); ?>" class="btn btn-success ml-2">Distribute Prizes</a>
                                                <a href="<?php echo base_url('league'); ?>" class="btn btn-outline-secondary ml-2">Back to Leagues</a>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-12">
                                <div class="card">
                                    <div class="card-header">
                                        <h4>Configured Prize Tiers</h4>
                                    </div>
                                    <div class="card-body table-responsive">
                                        <table class="table table-bordered table-striped">
                                            <thead>
                                                <tr>
                                                    <th>ID</th>
                                                    <th>Rank</th>
                                                    <th>Coins</th>
                                                    <th>Actions</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <?php if (!empty($prizes)): foreach ($prizes as $p): ?>
                                                        <tr>
                                                            <td><?php echo (int)$p->id; ?></td>
                                                            <td><?php echo (int)$p->top_winner; ?></td>
                                                            <td><?php echo (int)$p->points; ?></td>
                                                            <td>
                                                                <form method="post" action="<?php echo base_url('league-prize/' . (int)$league_id); ?>" class="form-inline d-inline-block">
                                                                    <input type="hidden" name="<?php echo $this->security->get_csrf_token_name(); ?>" value="<?php echo $this->security->get_csrf_hash(); ?>">
                                                                    <input type="hidden" name="btnupdate" value="1">
                                                                    <input type="hidden" name="edit_id" value="<?php echo (int)$p->id; ?>">
                                                                    <input type="number" name="points" min="0" value="<?php echo (int)$p->points; ?>" class="form-control form-control-sm mr-2" required>
                                                                    <button type="submit" class="btn btn-sm btn-primary">Update</button>
                                                                </form>
                                                                <button type="button" class="btn btn-sm btn-danger ml-2" onclick="deletePrize(<?php echo (int)$p->id; ?>)">Delete</button>
                                                            </td>
                                                        </tr>
                                                    <?php endforeach;
                                                else: ?>
                                                    <tr>
                                                        <td colspan="4" class="text-center">No prize tiers configured.</td>
                                                    </tr>
                                                <?php endif; ?>
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

    <script>
        function deletePrize(id) {
            if (!confirm('Are you sure you want to delete this prize tier?')) {
                return;
            }

            var xhr = new XMLHttpRequest();
            xhr.open('POST', '<?php echo base_url('delete_league_prize'); ?>', true);
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4) {
                    if (xhr.status === 200 && xhr.responseText) {
                        window.location.reload();
                    } else {
                        alert('Delete failed or permission denied.');
                    }
                }
            };

            var csrfName = '<?php echo $this->security->get_csrf_token_name(); ?>';
            var csrfHash = '<?php echo $this->security->get_csrf_hash(); ?>';
            var payload = 'id=' + encodeURIComponent(id) + '&' + encodeURIComponent(csrfName) + '=' + encodeURIComponent(csrfHash);
            xhr.send(payload);
        }
    </script>
</body>

</html>