<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <title>League Daily Quiz Assignment</title>
</head>
<body>
<h2>League Daily Quiz Assignment</h2>

<?php if ($this->session->flashdata('success')): ?>
    <p style="color:green;"><?php echo $this->session->flashdata('success'); ?></p>
<?php endif; ?>

<form method="post" action="<?php echo base_url('league-daily-quiz'); ?>">
    <input type="hidden" name="btnadd" value="1" />
    <p>
        <label>League:</label>
        <select name="league_id" required>
            <?php if (!empty($league)): foreach ($league as $l): ?>
                <option value="<?php echo $l->id; ?>"><?php echo htmlspecialchars($l->name); ?></option>
            <?php endforeach; endif; ?>
        </select>
    </p>
    <p><label>Quiz Day:</label> <input type="number" name="quiz_day" min="1" required /></p>
    <p><label>Quiz Date:</label> <input type="date" name="quiz_date" required /></p>
    <p>
        <label>Questions (multi-select):</label><br />
        <select name="question_ids[]" multiple size="12" required>
            <?php if (!empty($questions)): foreach ($questions as $q): ?>
                <option value="<?php echo $q->id; ?>"><?php echo $q->id . ' - ' . htmlspecialchars(substr($q->question, 0, 80)); ?></option>
            <?php endforeach; endif; ?>
        </select>
    </p>
    <p><button type="submit">Assign Daily Quiz</button></p>
</form>
</body>
</html>
