<?php
/**
 * Orders API for CompuMart
 * Handles order creation and retrieval
 */

require_once 'config.php';

$method = $_SERVER['REQUEST_METHOD'];
$conn = getDBConnection();

// Ensure order tables exist
try {
    $conn->exec("CREATE TABLE IF NOT EXISTS orders (
        id SERIAL PRIMARY KEY,
        user_id VARCHAR(255) NOT NULL,
        total DECIMAL(10, 2) NOT NULL,
        status VARCHAR(50) DEFAULT 'pending',
        customer_name VARCHAR(255),
        customer_phone VARCHAR(50),
        customer_email VARCHAR(255),
        delivery_address TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )");
    
    $conn->exec("CREATE TABLE IF NOT EXISTS order_items (
        id SERIAL PRIMARY KEY,
        order_id INT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
        product_id INT NOT NULL REFERENCES products(id),
        quantity INT NOT NULL,
        price DECIMAL(10, 2) NOT NULL
    )");
} catch (PDOException $e) {
    // Tables may already exist
}

if ($method === 'POST') {
    // Create new order
    $data = getJSONInput();
    
    $userId = $data['user_id'] ?? 'guest';
    $items = $data['items'] ?? [];
    $total = floatval($data['total'] ?? 0);
    $customerName = trim($data['customer_name'] ?? '');
    $customerPhone = trim($data['customer_phone'] ?? '');
    $customerEmail = trim($data['customer_email'] ?? '');
    $deliveryAddress = trim($data['delivery_address'] ?? '');
    
    if (empty($items) || $total <= 0 || empty($customerName) || empty($customerPhone) || empty($deliveryAddress)) {
        sendJSON(['success' => false, 'message' => 'Invalid order data. Please fill all required fields.'], 400);
    }
    
    // Start transaction
    $conn->beginTransaction();
    
    try {
        // Insert order
        $status = 'pending';
        $stmt = $conn->prepare("INSERT INTO orders (user_id, total, status, customer_name, customer_phone, customer_email, delivery_address) VALUES (:user_id, :total, :status, :customer_name, :customer_phone, :customer_email, :delivery_address)");
        
        if (!$stmt->execute([
            ':user_id' => $userId,
            ':total' => $total,
            ':status' => $status,
            ':customer_name' => $customerName,
            ':customer_phone' => $customerPhone,
            ':customer_email' => $customerEmail,
            ':delivery_address' => $deliveryAddress
        ])) {
            throw new Exception("Failed to create order");
        }
        
        $orderId = $conn->lastInsertId();
        
        // Insert order items
        $itemStmt = $conn->prepare("INSERT INTO order_items (order_id, product_id, quantity, price) VALUES (:order_id, :product_id, :quantity, :price)");
        
        foreach ($items as $item) {
            $productId = intval($item['product_id'] ?? $item['id']);
            $quantity = intval($item['quantity'] ?? 1);
            $price = floatval($item['price'] ?? 0);
            
            if (!$itemStmt->execute([
                ':order_id' => $orderId,
                ':product_id' => $productId,
                ':quantity' => $quantity,
                ':price' => $price
            ])) {
                throw new Exception("Failed to insert order item");
            }
        }
        
        // Commit transaction
        $conn->commit();
        
        sendJSON([
            'success' => true,
            'message' => 'Order created successfully.',
            'order_id' => $orderId
        ]);
        
    } catch (Exception $e) {
        // Rollback on error
        $conn->rollBack();
        sendJSON(['success' => false, 'message' => $e->getMessage()], 500);
    }
    
} elseif ($method === 'GET') {
    // Get orders (for a specific user or all orders)
    $userId = $_GET['user_id'] ?? '';
    
    if (!empty($userId)) {
        // Get orders for specific user
        $stmt = $conn->prepare("SELECT * FROM orders WHERE user_id = :user_id ORDER BY created_at DESC");
        $stmt->execute([':user_id' => $userId]);
        
        $orders = [];
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            // Get order items
            $itemStmt = $conn->prepare("SELECT oi.*, p.name as product_name FROM order_items oi LEFT JOIN products p ON oi.product_id = p.id WHERE oi.order_id = :order_id");
            $itemStmt->execute([':order_id' => $row['id']]);
            
            $items = [];
            while ($item = $itemStmt->fetch(PDO::FETCH_ASSOC)) {
                $items[] = $item;
            }
            
            $row['items'] = $items;
            $orders[] = $row;
        }
        
        sendJSON(['success' => true, 'orders' => $orders]);
    } else {
        // Get all orders (admin view)
        $result = $conn->query("SELECT * FROM orders ORDER BY created_at DESC");
        $orders = [];
        while ($row = $result->fetch(PDO::FETCH_ASSOC)) {
            $orders[] = $row;
        }
        sendJSON(['success' => true, 'orders' => $orders]);
    }
    
} else {
    sendJSON(['success' => false, 'message' => 'Method not allowed.'], 405);
}
?>

