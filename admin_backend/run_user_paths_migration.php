<?php
/**
 * Migration Runner: User Paths System
 * Run this script to apply the hybrid positioning database changes
 * 
 * Usage: php run_user_paths_migration.php
 */

// Load CodeIgniter framework
define('BASEPATH', __DIR__ . '/system/');
require_once __DIR__ . '/index.php';

// Get database instance
$CI =& get_instance();
$CI->load->database();

echo "========================================\n";
echo "User Paths System Migration\n";
echo "========================================\n\n";

// Read migration file
$migration_file = __DIR__ . '/database/migrations/2026_02_13_create_user_paths_system.sql';

if (!file_exists($migration_file)) {
    die("ERROR: Migration file not found: $migration_file\n");
}

echo "Reading migration file...\n";
$sql = file_get_contents($migration_file);

if (empty($sql)) {
    die("ERROR: Migration file is empty\n");
}

// Split SQL by delimiter (semicolon)
$statements = array_filter(
    array_map('trim', explode(';', $sql)),
    function($stmt) {
        // Filter out comments and empty statements
        return !empty($stmt) && 
               !preg_match('/^--/', $stmt) &&
               !preg_match('/^\s*$/', $stmt);
    }
);

echo "Found " . count($statements) . " SQL statements to execute\n\n";

$success_count = 0;
$error_count = 0;
$errors = [];

foreach ($statements as $index => $statement) {
    // Skip comments and empty lines
    if (empty(trim($statement)) || strpos(trim($statement), '--') === 0) {
        continue;
    }
    
    echo "Executing statement " . ($index + 1) . "... ";
    
    try {
        // Execute the statement
        $result = $CI->db->query($statement . ';');
        
        if ($result) {
            echo "✓ SUCCESS\n";
            $success_count++;
        } else {
            echo "✗ FAILED\n";
            $error_count++;
            $errors[] = [
                'statement' => substr($statement, 0, 100) . '...',
                'error' => $CI->db->error()
            ];
        }
    } catch (Exception $e) {
        echo "✗ EXCEPTION\n";
        $error_count++;
        $errors[] = [
            'statement' => substr($statement, 0, 100) . '...',
            'error' => $e->getMessage()
        ];
    }
}

echo "\n========================================\n";
echo "Migration Summary\n";
echo "========================================\n";
echo "Success: $success_count\n";
echo "Errors: $error_count\n";

if (!empty($errors)) {
    echo "\nErrors encountered:\n";
    foreach ($errors as $error) {
        echo "- Statement: " . $error['statement'] . "\n";
        echo "  Error: " . print_r($error['error'], true) . "\n\n";
    }
}

if ($error_count === 0) {
    echo "\n✓ Migration completed successfully!\n";
    echo "\nNext steps:\n";
    echo "1. Verify tables created: tbl_user_paths, tbl_skill_assessments, tbl_user_assessments\n";
    echo "2. Check altered tables: tbl_category, tbl_question\n";
    echo "3. Implement backend API endpoints\n";
    echo "4. Update Flutter app models and repositories\n";
} else {
    echo "\n✗ Migration completed with errors. Please review and fix.\n";
}

echo "\n";
?>
