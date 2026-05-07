<?php
/**
 * Authentication API for CompuMart
 * Handles user registration and login
 */

require_once 'config.php';

$method = $_SERVER['REQUEST_METHOD'];
$conn = getDBConnection();

// Ensure users table has role column (for admin)
try {
    $stmt = $conn->prepare("SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'role'");
    $stmt->execute();
    if ($stmt->rowCount() == 0) {
        $conn->exec("ALTER TABLE users ADD COLUMN role VARCHAR(20) DEFAULT 'user'");
    }
} catch (PDOException $e) {
    // Column may already exist
}

// Ensure admin account exists
$stmt = $conn->prepare("SELECT * FROM users WHERE email = :email");
$stmt->execute([':email' => 'admin@compumart.local']);
$adminCheck = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$adminCheck) {
    $hashedPassword = password_hash('admin123', PASSWORD_DEFAULT);
    $stmt = $conn->prepare("INSERT INTO users (email, password, name, role) VALUES (:email, :password, :name, :role)");
    $stmt->execute([
        ':email' => 'admin@compumart.local',
        ':password' => $hashedPassword,
        ':name' => 'Admin',
        ':role' => 'admin'
    ]);
}

if ($method === 'POST') {
    $data = getJSONInput();
    $action = $data['action'] ?? '';
    
    if ($action === 'register') {
        // User Registration
        $name = trim($data['name'] ?? '');
        $email = trim($data['email'] ?? '');
        $password = $data['password'] ?? '';
        
        if (empty($name) || empty($email) || empty($password)) {
            sendJSON(['success' => false, 'message' => 'All fields are required.'], 400);
        }
        
        // Check if email already exists
        $stmt = $conn->prepare("SELECT id FROM users WHERE email = :email");
        $stmt->execute([':email' => $email]);
        
        if ($stmt->fetch(PDO::FETCH_ASSOC)) {
            sendJSON(['success' => false, 'message' => 'An account with this email already exists.'], 400);
        }
        
        // Hash password and insert user
        $hashedPassword = password_hash($password, PASSWORD_DEFAULT);
        $role = 'user';
        
        $stmt = $conn->prepare("INSERT INTO users (name, email, password, role) VALUES (:name, :email, :password, :role)");
        
        if ($stmt->execute([':name' => $name, ':email' => $email, ':password' => $hashedPassword, ':role' => $role])) {
            // Get the newly inserted user's ID
            $lastId = $conn->lastInsertId();
            sendJSON([
                'success' => true,
                'message' => 'Account created successfully.',
                'user' => [
                    'id' => $lastId,
                    'name' => $name,
                    'email' => $email,
                    'role' => $role
                ]
            ]);
        } else {
            sendJSON(['success' => false, 'message' => 'Failed to create account'], 500);
        }
        
    } elseif ($action === 'login') {
        // User Login
        $email = trim($data['email'] ?? '');
        $password = $data['password'] ?? '';
        
        if (empty($email) || empty($password)) {
            sendJSON(['success' => false, 'message' => 'Email and password are required.'], 400);
        }
        
        // Find user by email
        $stmt = $conn->prepare("SELECT id, name, email, password, role FROM users WHERE email = :email");
        $stmt->execute([':email' => $email]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$user) {
            sendJSON(['success' => false, 'message' => 'Invalid email or password.'], 401);
        }
        
        // Verify password (handle both hashed and plain text for migration)
        $passwordValid = false;
        if (password_verify($password, $user['password'])) {
            $passwordValid = true;
        } elseif ($user['password'] === $password) {
            // Legacy plain text password - rehash it
            $hashedPassword = password_hash($password, PASSWORD_DEFAULT);
            $updateStmt = $conn->prepare("UPDATE users SET password = :password WHERE id = :id");
            $updateStmt->execute([':password' => $hashedPassword, ':id' => $user['id']]);
            $passwordValid = true;
        }
        
        if (!$passwordValid) {
            sendJSON(['success' => false, 'message' => 'Invalid email or password.'], 401);
        }
        
        sendJSON([
            'success' => true,
            'message' => 'Login successful.',
            'user' => [
                'id' => $user['id'],
                'name' => $user['name'],
                'email' => $user['email'],
                'role' => $user['role'] ?? 'user'
            ]
        ]);
        
    } else {
        sendJSON(['success' => false, 'message' => 'Invalid action.'], 400);
    }
    
} elseif ($method === 'GET') {
    // Get current user (if session exists - for future use)
    sendJSON(['success' => false, 'message' => 'GET method not implemented. Use POST for login/register.'], 405);
    
} else {
    sendJSON(['success' => false, 'message' => 'Method not allowed.'], 405);
}

$conn->close();
?>

