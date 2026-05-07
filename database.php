<?php
    // PostgreSQL Configuration
    $db_server = "localhost";
    $db_port = "5432";
    $db_user = "postgres";
    $db_pass = "050806"; // Set your PostgreSQL password
    $db_name = "compumart";
    $conn = "";

    try {
        $dsn = "pgsql:host=$db_server;port=$db_port;dbname=$db_name";
        $conn = new PDO($dsn, $db_user, $db_pass);
        $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        echo "You are connected";
    } catch(PDOException $e) {
        echo "Could not connect: " . $e->getMessage();
    }
?>