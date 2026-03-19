<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <title>League Management</title>
</head>
<body>
<h2>League Management</h2>

<?php if ($this->session->flashdata('success')): ?>
    <p style="color:green;"><?php echo $this->session->flashdata('success'); ?></p>
<?php endif; ?>
<?php if ($this->session->flashdata('error')): ?>
    <p style="color:red;"><?php echo $this->session->flashdata('error'); ?></p>
<?php endif; ?>

<form method="post" action="<?php echo base_url('league'); ?>">
    <input type="hidden" name="btnadd" value="1" />
    <p><input type="text" name="name" placeholder="League name" required /></p>
    <p><textarea name="description" placeholder="Description"></textarea></p>
    <p><input type="datetime-local" name="start_date" required /></p>
    <p><input type="datetime-local" name="end_date" required /></p>
    <p><input type="number" name="entry" placeholder="Entry coins" value="0" required /></p>
    <p>
        <select name="language_id">
            <option value="0">All Languages</option>
            <?php if (!empty($language)): foreach ($language as $l): ?>
                <option value="<?php echo $l->id; ?>"><?php echo $l->name; ?></option>
            <?php endforeach; endif; ?>
        </select>
    </p>
    <p><button type="submit">Create League</button></p>
</form>

<hr />
<h3>Existing Leagues</h3>
<table border="1" cellpadding="6" cellspacing="0">
    <tr>
        <th>ID</th>
        <th>Name</th>
        <th>Start</th>
        <th>End</th>
        <th>Entry</th>
        <th>Status</th>
        <th>Actions</th>
    </tr>
    <?php if (!empty($league)): foreach ($league as $row): ?>
        <tr>
            <td><?php echo $row->id; ?></td>
            <td><?php echo htmlspecialchars($row->name); ?></td>
            <td><?php echo $row->start_date; ?></td>
            <td><?php echo $row->end_date; ?></td>
            <td><?php echo $row->entry; ?></td>
            <td><?php echo $row->status; ?></td>
            <td>
                <a href="<?php echo base_url('league-prize/' . (int)$row->id); ?>">Prizes</a> |
                <a href="<?php echo base_url('league-prize-distribute/' . (int)$row->id); ?>">Distribute</a>
            </td>
        </tr>
    <?php endforeach; endif; ?>
</table>
</body>
</html>
