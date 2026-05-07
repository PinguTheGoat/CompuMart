<?php
/**
 * PHP Test File for CompuMart
 * Access this file to verify PHP is working: http://localhost/Website/api/test.php
 */

header('Content-Type: application/json');

$testResults = [
    'php_version' => phpversion(),
    'php_working' => true,
    'pdo_available' => extension_loaded('PDO'),
    'pgsql_available' => extension_loaded('pdo_pgsql'),
    'server_time' => date('Y-m-d H:i:s'),
    'database_type' => 'PostgreSQL',
    'next_steps' => [
        '1. Make sure PostgreSQL is running on localhost:5432',
        '2. Update credentials in api/config.php',
        '3. Run database setup: http://localhost/Website/api/database_setup.php',
        '4. Test products API: http://localhost/Website/api/products.php'
    ]
];

// Try to connect to PostgreSQL
try {
    $dsn = 'pgsql:host=localhost;port=5432';
    $conn = @new PDO($dsn, 'postgres', 'your_password');
    $testResults['postgresql_connection'] = 'Success!';
    $testResults['postgresql_status'] = 'PostgreSQL is running and accessible';
    $conn = null;
} catch (PDOException $e) {
    $testResults['postgresql_connection'] = 'Failed: ' . $e->getMessage();
    $testResults['postgresql_status'] = 'Make sure PostgreSQL is running on localhost:5432 and credentials are correct';
}

echo json_encode($testResults, JSON_PRETTY_PRINT);
?>

