<?php
/**
 * Authentication API for CompuMart
 * Handles user registration and login
 */

require_once 'config.php';

$method = $_SERVER['REQUEST_METHOD'];
$conn = getDBConnection();

function verifyPasswordCompat($plainPassword, $storedPassword) {
    if (password_verify($plainPassword, $storedPassword)) {
        return true;
    }

    return hash_equals((string)$storedPassword, (string)$plainPassword);
}

function formatUserRow($user) {
    return [
        'id' => $user['id'],
        'name' => $user['name'],
        'email' => $user['email'],
        'phone' => $user['phone'] ?? '',
        'address' => $user['address'] ?? '',
        'role' => $user['role'] ?? 'user'
    ];
}

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
        $phone = trim($data['phone'] ?? '');
        $address = trim($data['address'] ?? '');
        
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
                    'phone' => $phone,
                    'address' => $address,
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
        $stmt = $conn->prepare("SELECT id, name, email, password, role, phone, address FROM users WHERE email = :email");
        $stmt->execute([':email' => $email]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$user) {
            sendJSON(['success' => false, 'message' => 'Invalid email or password.'], 401);
        }
        
        // Verify password (handle both hashed and plain text for migration)
        $passwordValid = false;
        if (verifyPasswordCompat($password, $user['password'])) {
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
            'user' => formatUserRow($user)
        ]);

    } elseif ($action === 'get_profile') {
        $userId = intval($data['user_id'] ?? 0);

        if ($userId <= 0) {
            sendJSON(['success' => false, 'message' => 'Valid user ID is required.'], 400);
        }

        $stmt = $conn->prepare("SELECT id, name, email, role, phone, address, created_at FROM users WHERE id = :id");
        $stmt->execute([':id' => $userId]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$user) {
            sendJSON(['success' => false, 'message' => 'User not found.'], 404);
        }

        sendJSON([
            'success' => true,
            'user' => [
                'id' => $user['id'],
                'name' => $user['name'],
                'email' => $user['email'],
                'phone' => $user['phone'] ?? '',
                'address' => $user['address'] ?? '',
                'role' => $user['role'] ?? 'user',
                'created_at' => $user['created_at']
            ]
        ]);

    } elseif ($action === 'update_profile') {
        $userId = intval($data['user_id'] ?? 0);
        $name = trim($data['name'] ?? '');
        $email = trim($data['email'] ?? '');
        $phone = trim($data['phone'] ?? '');
        $address = trim($data['address'] ?? '');

        if ($userId <= 0 || empty($name) || empty($email)) {
            sendJSON(['success' => false, 'message' => 'Name, email, and user ID are required.'], 400);
        }

        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            sendJSON(['success' => false, 'message' => 'Please enter a valid email address.'], 400);
        }

        $stmt = $conn->prepare("SELECT id FROM users WHERE email = :email AND id <> :id");
        $stmt->execute([':email' => $email, ':id' => $userId]);

        if ($stmt->fetch(PDO::FETCH_ASSOC)) {
            sendJSON(['success' => false, 'message' => 'That email address is already in use.'], 400);
        }

        $updateStmt = $conn->prepare("UPDATE users SET name = :name, email = :email, phone = :phone, address = :address WHERE id = :id");
        $updateStmt->execute([
            ':name' => $name,
            ':email' => $email,
            ':phone' => $phone,
            ':address' => $address,
            ':id' => $userId
        ]);

        $stmt = $conn->prepare("SELECT id, name, email, role, phone, address, created_at FROM users WHERE id = :id");
        $stmt->execute([':id' => $userId]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        sendJSON([
            'success' => true,
            'message' => 'Profile updated successfully.',
            'user' => [
                'id' => $user['id'],
                'name' => $user['name'],
                'email' => $user['email'],
                'phone' => $user['phone'] ?? '',
                'address' => $user['address'] ?? '',
                'role' => $user['role'] ?? 'user',
                'created_at' => $user['created_at']
            ]
        ]);

    } elseif ($action === 'change_password') {
        $userId = intval($data['user_id'] ?? 0);
        $currentPassword = $data['current_password'] ?? '';
        $newPassword = $data['new_password'] ?? '';

        if ($userId <= 0 || empty($currentPassword) || empty($newPassword)) {
            sendJSON(['success' => false, 'message' => 'Current password and new password are required.'], 400);
        }

        if (strlen($newPassword) < 6) {
            sendJSON(['success' => false, 'message' => 'New password must be at least 6 characters long.'], 400);
        }

        $stmt = $conn->prepare("SELECT id, password FROM users WHERE id = :id");
        $stmt->execute([':id' => $userId]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$user) {
            sendJSON(['success' => false, 'message' => 'User not found.'], 404);
        }

        if (!verifyPasswordCompat($currentPassword, $user['password'])) {
            sendJSON(['success' => false, 'message' => 'Current password is incorrect.'], 401);
        }

        $hashedPassword = password_hash($newPassword, PASSWORD_DEFAULT);
        $updateStmt = $conn->prepare("UPDATE users SET password = :password WHERE id = :id");
        $updateStmt->execute([':password' => $hashedPassword, ':id' => $userId]);

        sendJSON([
            'success' => true,
            'message' => 'Password changed successfully.'
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

