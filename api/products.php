<?php
require_once 'config.php';

$method = $_SERVER['REQUEST_METHOD'];
$conn = getDBConnection();

switch ($method) {
    case 'GET':
        // Get all products or filter by category
        $category = isset($_GET['category']) ? $_GET['category'] : null;
        $productId = isset($_GET['id']) ? intval($_GET['id']) : null;
        
        if ($productId) {
            // Get single product by ID
            $stmt = $conn->prepare("SELECT * FROM products WHERE id = :id");
            $stmt->execute([':id' => $productId]);
            $product = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$product) {
                sendJSON(['error' => 'Product not found'], 404);
            }
            
            sendJSON($product);
        } else if ($category) {
            // Get products by category
            $stmt = $conn->prepare("SELECT * FROM products WHERE category = :category ORDER BY id ASC");
            $stmt->execute([':category' => $category]);
            
            $products = [];
            while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
                $products[] = $row;
            }
            
            sendJSON($products);
        } else {
            // Get all products
            $result = $conn->query("SELECT * FROM products ORDER BY id ASC");
            
            $products = [];
            while ($row = $result->fetch(PDO::FETCH_ASSOC)) {
                $products[] = $row;
            }
            
            sendJSON($products);
        }
        break;
        
    case 'POST':
        // Add new product (admin function)
        $data = getJSONInput();
        
        $name = $data['name'] ?? '';
        $price = $data['price'] ?? 0;
        $image = $data['image'] ?? '';
        $category = $data['category'] ?? '';
        $description = $data['description'] ?? '';
        $stock = $data['stock'] ?? 0;
        
        try {
            $stmt = $conn->prepare("INSERT INTO products (name, price, image, category, description, stock) VALUES (:name, :price, :image, :category, :description, :stock) RETURNING id");
            
            $result = $stmt->execute([
                ':name' => $name,
                ':price' => $price,
                ':image' => $image,
                ':category' => $category,
                ':description' => $description,
                ':stock' => $stock
            ]);
            
            if ($result) {
                $idRow = $stmt->fetch(PDO::FETCH_ASSOC);
                $lastId = $idRow['id'] ?? null;
                
                if ($lastId) {
                    sendJSON(['success' => true, 'id' => (int)$lastId], 201);
                } else {
                    sendJSON(['error' => 'Failed to retrieve product ID'], 500);
                }
            } else {
                sendJSON(['error' => 'Failed to execute insert'], 500);
            }
        } catch (PDOException $e) {
            error_log("Product insert error: " . $e->getMessage());
            sendJSON(['error' => 'Database error: ' . $e->getMessage()], 500);
        }
        break;
        
    case 'DELETE':
        // Delete product (admin function)
        $data = getJSONInput();
        $productId = intval($data['id'] ?? null);
        
        if (!$productId) {
            sendJSON(['error' => 'Product ID required'], 400);
            break;
        }
        
        try {
            // First, remove from any carts (in case CASCADE isn't working)
            $stmt = $conn->prepare("DELETE FROM cart WHERE product_id = :id");
            $stmt->execute([':id' => $productId]);
            
            // Then delete the product
            $stmt = $conn->prepare("DELETE FROM products WHERE id = :id");
            $result = $stmt->execute([':id' => $productId]);
            
            if (!$result) {
                sendJSON(['error' => 'Failed to execute delete query', 'success' => false], 500);
                break;
            }
            
            if ($stmt->rowCount() > 0) {
                sendJSON(['success' => true, 'message' => 'Product deleted']);
            } else {
                sendJSON(['error' => 'Product not found', 'success' => false], 404);
            }
        } catch (PDOException $e) {
            sendJSON(['error' => 'Database error: ' . $e->getMessage(), 'success' => false], 500);
        }
        break;
        
    default:
        sendJSON(['error' => 'Method not allowed'], 405);
        break;
}
?>

