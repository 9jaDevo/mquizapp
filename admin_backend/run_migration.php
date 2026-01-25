<?php

/**
 * Database Migration Runner using CodeIgniter
 * Executes SQL migration files for blog system
 */

try {
    // Try multiple credential options
    $credentials = [
        ['localhost', 'root', '', 'mquiz_d5bueportal'],           // XAMPP default
        ['localhost', 'root', 'password', 'mquiz_d5bueportal'],   // Common password
        ['localhost', 'mquiz_ru2ndi4', 'yZ#r$N43NvXr', 'mquiz_d5bueportal'], // From config
        ['localhost', 'admin', 'admin', 'mquiz_d5bueportal'],     // Alternative
    ];

    $mysqli = null;
    $last_error = '';

    foreach ($credentials as $cred) {
        $mysqli = new mysqli($cred[0], $cred[1], $cred[2], $cred[3]);

        if (!$mysqli->connect_error) {
            echo "✓ Connected using: {$cred[1]}\n\n";
            break;
        } else {
            $last_error = $mysqli->connect_error;
            $mysqli = null;
        }
    }

    if (!$mysqli) {
        die("Failed to connect with any credentials. Last error: " . $last_error);
    }

    // Set charset to UTF8MB4
    $mysqli->set_charset("utf8mb4");

    // Read migration file
    $migration_file = __DIR__ . '/database/migrations/001_create_blog_tables.sql';

    if (!file_exists($migration_file)) {
        die("Migration file not found: " . $migration_file);
    }

    $sql_content = file_get_contents($migration_file);

    // Split SQL statements more carefully
    $queries = [];
    $current_query = '';

    $lines = explode("\n", $sql_content);

    foreach ($lines as $line) {
        $line = trim($line);

        // Skip comments and empty lines
        if (empty($line) || preg_match('/^--/', $line)) {
            continue;
        }

        $current_query .= ' ' . $line;

        // Check if query ends with semicolon
        if (substr(rtrim($current_query), -1) === ';') {
            $queries[] = rtrim(trim($current_query), ';');
            $current_query = '';
        }
    }

    // Add remaining query if any
    if (!empty(trim($current_query))) {
        $queries[] = rtrim(trim($current_query), ';');
    }

    $success_count = 0;
    $error_count = 0;

    echo "Starting database migration...\n";
    echo "==================================\n";
    echo "Database: mquiz_d5bueportal\n";
    echo "Total queries: " . count($queries) . "\n";
    echo "==================================\n\n";

    foreach ($queries as $query) {
        $query = trim($query);
        if (empty($query)) continue;

        // Execute query
        if ($mysqli->query($query)) {
            $success_count++;
            $short_query = substr($query, 0, 70);
            if (strlen($query) > 70) $short_query .= "...";
            echo "✓ " . $short_query . "\n";
        } else {
            $error_count++;
            $short_query = substr($query, 0, 70);
            if (strlen($query) > 70) $short_query .= "...";
            echo "✗ " . $short_query . "\n";
            echo "  Error: " . $mysqli->error . "\n";
        }
    }

    echo "\n==================================\n";
    echo "Migration Summary:\n";
    echo "Successful: {$success_count}\n";
    echo "Errors: {$error_count}\n\n";

    // Verify tables were created
    echo "Verifying tables...\n";
    $result = $mysqli->query("SHOW TABLES LIKE 'tbl_blog%'");

    if ($result && $result->num_rows > 0) {
        $tables = [];
        while ($row = $result->fetch_row()) {
            $tables[] = $row[0];
        }

        echo "✓ Created " . count($tables) . " tables:\n";
        foreach ($tables as $table) {
            echo "  - " . $table . "\n";
        }
    } else {
        echo "✗ No blog tables found in database\n";
    }

    $mysqli->close();

    echo "\n==================================\n";
    if ($error_count === 0 && $success_count > 0) {
        echo "✓ Database migration completed successfully!\n";
    } else {
        echo "✗ Database migration completed with errors.\n";
    }
} catch (Exception $e) {
    die("Error: " . $e->getMessage());
}
