<?php
require_once 'config.php';

$method = $_SERVER['REQUEST_METHOD'];
$conn = getDBConnection();

// Get user ID from request (for demo, use session or request parameter)
function getUserId() {
    // Option 1: From session (if user is logged in)
    if (session_status() === PHP_SESSION_NONE) {
        session_start();
    }
    
    if (isset($_SESSION['user_id'])) {
        return $_SESSION['user_id'];
    }
    
    // Option 2: From request parameter (for demo purposes)
    if (isset($_GET['userId']) || isset($_POST['userId'])) {
        return $_GET['userId'] ?? $_POST['userId'];
    }
    
    // Option 3: Generate demo user ID
    if (!isset($_SESSION['demo_user_id'])) {
        $_SESSION['demo_user_id'] = 'demo_user_' . time();
    }
    return $_SESSION['demo_user_id'];
}

switch ($method) {
    case 'GET':
        $userId = $_GET['userId'] ?? getUserId();
        $action = $_GET['action'] ?? '';
        
        if ($action === 'count') {
            // Get cart item count
            $stmt = $conn->prepare("SELECT SUM(quantity) as total FROM cart WHERE user_id = :user_id");
            $stmt->execute([':user_id' => $userId]);
            $row = $stmt->fetch(PDO::FETCH_ASSOC);
            
            sendJSON(['count' => $row['total'] ?? 0]);
        } else {
            // Get user's cart with product details
            $stmt = $conn->prepare("
                SELECT c.*, p.name, p.price, p.image 
                FROM cart c 
                JOIN products p ON c.product_id = p.id 
                WHERE c.user_id = :user_id
            ");
            $stmt->execute([':user_id' => $userId]);
            
            $cartItems = [];
            while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
                $cartItems[] = $row;
            }
            
            sendJSON($cartItems);
        }
        break;
        
    case 'POST':
        // Add item to cart
        $data = getJSONInput();
        $userId = $data['userId'] ?? getUserId();
        $productId = intval($data['productId']);
        $quantity = intval($data['quantity'] ?? 1);
        
        // Check if item already exists in cart
        $stmt = $conn->prepare("SELECT * FROM cart WHERE user_id = :user_id AND product_id = :product_id");
        $stmt->execute([':user_id' => $userId, ':product_id' => $productId]);
        
        if ($stmt->fetch(PDO::FETCH_ASSOC)) {
            // Update quantity
            $stmt = $conn->prepare("UPDATE cart SET quantity = quantity + :quantity WHERE user_id = :user_id AND product_id = :product_id");
            $stmt->execute([':quantity' => $quantity, ':user_id' => $userId, ':product_id' => $productId]);
        } else {
            // Add new item
            $stmt = $conn->prepare("INSERT INTO cart (user_id, product_id, quantity) VALUES (:user_id, :product_id, :quantity)");
            $stmt->execute([':user_id' => $userId, ':product_id' => $productId, ':quantity' => $quantity]);
        }
        
        sendJSON(['success' => true, 'message' => 'Item added to cart']);
        break;
        
    case 'PUT':
        // Update cart item quantity
        $data = getJSONInput();
        $userId = $data['userId'] ?? getUserId();
        $productId = intval($data['productId']);
        $quantity = intval($data['quantity']);
        
        if ($quantity <= 0) {
            // Remove item if quantity is 0
            $stmt = $conn->prepare("DELETE FROM cart WHERE user_id = :user_id AND product_id = :product_id");
            $stmt->execute([':user_id' => $userId, ':product_id' => $productId]);
        } else {
            // Update quantity
            $stmt = $conn->prepare("UPDATE cart SET quantity = :quantity WHERE user_id = :user_id AND product_id = :product_id");
            $stmt->execute([':quantity' => $quantity, ':user_id' => $userId, ':product_id' => $productId]);
        }
        
        sendJSON(['success' => true]);
        break;
        
    case 'DELETE':
        // Remove item from cart
        $data = getJSONInput();
        $userId = $data['userId'] ?? getUserId();
        $productId = intval($data['productId']);
        
        $stmt = $conn->prepare("DELETE FROM cart WHERE user_id = :user_id AND product_id = :product_id");
        $stmt->execute([':user_id' => $userId, ':product_id' => $productId]);
        
        sendJSON(['success' => true]);
        break;
        
    default:
        sendJSON(['error' => 'Method not allowed'], 405);
        break;
}

$conn->close();
?>

