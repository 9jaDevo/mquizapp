<?php
$databases = ['afomo', 'afomo_dev', 'test', 'mpos', 'db', 'mquiz_app'];

foreach ($databases as $db) {
    $mysqli = new mysqli('localhost', 'root', '', $db);

    if (!$mysqli->connect_error) {
        echo "\n[Database: $db]\n";
        $result = $mysqli->query("SHOW TABLES LIKE 'tbl_%';");

        if ($result && $result->num_rows > 0) {
            echo "Found " . $result->num_rows . " tables\n";
            echo "First 5 tables:\n";
            $count = 0;
            while ($row = $result->fetch_row() && $count < 5) {
                echo "  - " . $row[0] . "\n";
                $count++;
            }
        } else {
            echo "No tbl_* tables found\n";
        }

        $mysqli->close();
    }
}
