<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <title>League Prize Management</title>
</head>
<body>
<h2>League Prize Management</h2>

<?php if ($this->session->flashdata('success')): ?>
    <p style="color:green;"><?php echo $this->session->flashdata('success'); ?></p>
<?php endif; ?>
<?php if ($this->session->flashdata('error')): ?>
    <p style="color:red;"><?php echo $this->session->flashdata('error'); ?></p>
<?php endif; ?>

<form method="post" action="<?php echo base_url('league-prize/' . (int)$league_id); ?>">
    <input type="hidden" name="btnadd" value="1" />
    <input type="hidden" name="league_id" value="<?php echo (int)$league_id; ?>" />
    <?php $nextRank = !empty($max) ? ((int)$max[0]->total + 1) : 1; ?>
    <p><label>Top Winner Rank:</label> <input type="number" name="winner" value="<?php echo $nextRank; ?>" readonly required /></p>
    <p><label>Prize Coins:</label> <input type="number" name="points" min="0" required /></p>
    <p><button type="submit">Add Prize Tier</button></p>
</form>

<p><a href="<?php echo base_url('league-prize-distribute/' . (int)$league_id); ?>">Distribute Prizes For This League</a></p>

<hr />
<h3>Configured Prize Tiers</h3>
<table border="1" cellpadding="6" cellspacing="0">
    <tr>
        <th>ID</th>
        <th>Rank</th>
        <th>Coins</th>
        <th>Actions</th>
    </tr>
    <?php if (!empty($prizes)): foreach ($prizes as $p): ?>
        <tr>
            <td><?php echo (int)$p->id; ?></td>
            <td><?php echo (int)$p->top_winner; ?></td>
            <td><?php echo (int)$p->points; ?></td>
            <td>
                <form method="post" action="<?php echo base_url('league-prize/' . (int)$league_id); ?>" style="display:inline;">
                    <input type="hidden" name="btnupdate" value="1" />
                    <input type="hidden" name="edit_id" value="<?php echo (int)$p->id; ?>" />
                    <input type="number" name="points" min="0" value="<?php echo (int)$p->points; ?>" required />
                    <button type="submit">Update</button>
                </form>
                <button type="button" onclick="deletePrize(<?php echo (int)$p->id; ?>)">Delete</button>
            </td>
        </tr>
    <?php endforeach; endif; ?>
</table>

<p><a href="<?php echo base_url('league'); ?>">Back to League List</a></p>

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
