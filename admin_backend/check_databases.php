<?php
try {
    // Try to connect with root
    $mysqli = new mysqli('localhost', 'root', '');

    if ($mysqli->connect_error) {
        die("Connection failed: " . $mysqli->connect_error);
    }

    echo "Connected successfully!\n\n";
    echo "Available databases:\n";
    echo "====================\n";

    $result = $mysqli->query("SHOW DATABASES;");

    if ($result) {
        while ($row = $result->fetch_row()) {
            echo "- " . $row[0] . "\n";
        }
    }

    $mysqli->close();
} catch (Exception $e) {
    die("Error: " . $e->getMessage());
}
