<?php
// Database configuration for CompuMart
// XAMPP default settings

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// PostgreSQL credentials
define('DB_HOST', 'localhost');
define('DB_PORT', '5432'); // PostgreSQL default port
define('DB_USER', 'postgres');
define('DB_PASS', '050806'); // Set your PostgreSQL password
define('DB_NAME', 'compumart');

// Create database connection
function getDBConnection() {
    try {
        $dsn = 'pgsql:host=' . DB_HOST . ';port=' . DB_PORT . ';dbname=' . DB_NAME;
        $conn = new PDO($dsn, DB_USER, DB_PASS);
        $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        
        // Auto-initialize tables if they don't exist
        ensureTables($conn);
        
        return $conn;
    } catch (PDOException $e) {
        error_log("Database connection error: " . $e->getMessage());
        http_response_code(500);
        echo json_encode(['error' => 'Database connection failed', 'success' => false]);
        exit();
    }
}

// Ensure database tables are created
function ensureTables($conn) {
    // Create products table (PostgreSQL syntax)
    $sql = "CREATE TABLE IF NOT EXISTS products (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        price DECIMAL(10, 2) NOT NULL,
        image VARCHAR(500) NOT NULL,
        category VARCHAR(50) NOT NULL,
        description TEXT,
        stock INT DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )";
    $conn->exec($sql);
    
    // Create index for category and name
    $conn->exec("CREATE INDEX IF NOT EXISTS idx_category ON products(category)");
    $conn->exec("CREATE INDEX IF NOT EXISTS idx_name ON products(name)");
    
    // Create users table
    $sql = "CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        email VARCHAR(255) NOT NULL UNIQUE,
        password VARCHAR(255) NOT NULL,
        name VARCHAR(255) NOT NULL,
        phone VARCHAR(50),
        address TEXT,
        role VARCHAR(20) DEFAULT 'user',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )";
    $conn->exec($sql);
    $conn->exec("ALTER TABLE users ADD COLUMN IF NOT EXISTS phone VARCHAR(50)");
    $conn->exec("ALTER TABLE users ADD COLUMN IF NOT EXISTS address TEXT");
    
    // Create cart table
    $sql = "CREATE TABLE IF NOT EXISTS cart (
        id SERIAL PRIMARY KEY,
        user_id VARCHAR(255) NOT NULL,
        product_id INT REFERENCES products(id) ON DELETE CASCADE,
        quantity INT DEFAULT 1,
        added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )";
    $conn->exec($sql);

    // Keep the product sequence aligned if rows were manually reset
    try {
        $conn->exec("SELECT setval(pg_get_serial_sequence('products', 'id'), GREATEST((SELECT COALESCE(MAX(id), 1) FROM products), 1), true)");
    } catch (Exception $e) {
        // Ignore sequence alignment failures; inserts will still work if sequence exists
    }
    
    // Create orders table
    $sql = "CREATE TABLE IF NOT EXISTS orders (
        id SERIAL PRIMARY KEY,
        user_id VARCHAR(255) NOT NULL,
        total DECIMAL(10, 2) NOT NULL,
        status VARCHAR(50) DEFAULT 'pending',
        customer_name VARCHAR(255),
        customer_phone VARCHAR(50),
        customer_email VARCHAR(255),
        delivery_address TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )";
    $conn->exec($sql);
    
    // Create order_items table
    $sql = "CREATE TABLE IF NOT EXISTS order_items (
        id SERIAL PRIMARY KEY,
        order_id INT REFERENCES orders(id) ON DELETE CASCADE,
        product_id INT REFERENCES products(id) ON DELETE SET NULL,
        quantity INT NOT NULL,
        price DECIMAL(10, 2) NOT NULL
    )";
    $conn->exec($sql);
    
    // Seed ONLY the 11 default products
    $result = $conn->query("SELECT COUNT(*) as count FROM products");
    $row = $result->fetch(PDO::FETCH_ASSOC);
    
    if ($row['count'] == 0) {
        $products = [
            ['AMD Ryzen 7 5700X3D Processor', 138.20, 'public/img/category-1.png', 'cpu', 'High-performance processor with 3D V-Cache technology for exceptional gaming performance.', 50],
            ['Palit RTX 5090 GameRock OC 32GB', 5300.00, 'public/img/category-2.png', 'gpu', 'Top-of-the-line graphics card with 32GB VRAM, perfect for 4K gaming and professional work.', 25],
            ['Corsair Dominator Titanium DDR5 96GB', 320.00, 'public/img/category-3.png', 'ram', 'Premium DDR5 memory kit with 96GB capacity and titanium heat spreaders.', 40],
            ['SAMSUNG 980 M.2 PCIe NVMe 1TB SSD', 215.00, 'public/img/category-4.png', 'ssd', 'Fast NVMe SSD with 1TB storage capacity for lightning-fast boot times and file transfers.', 60],
            ['Lian Li Edge Series-1000W Full Modular Power', 279.00, 'public/img/category-5.png', 'powersupply', '80 Plus Gold certified fully modular power supply with 1000W capacity.', 35],
            ['GIGABYTE AORUS GeForce RTX 5080 Master ICE 16G Graphics Card', 1790.00, 'public/img/category-6.png', 'gpu', 'Premium RTX 5080 graphics card with 16GB VRAM and advanced cooling solution.', 30],
            ['Hyte Y70 Touch Infinite Dual Chamber ATX PC Case', 501.00, 'public/img/category-7.png', 'case', 'Premium PC case with touch screen display and dual chamber design for optimal airflow.', 20],
            ['ASUS ROG Astral GeForce RTX5090 Dhahab OC Edition Graphic card', 5500.00, 'public/img/product-1.png', 'gpu', 'Ultimate flagship graphics card with premium design and extreme overclocking capabilities.', 15],
            ['Asus Rog Crosshair X870e Extreme Motherboard', 939.00, 'public/img/product-2.png', 'motherboard', 'High-end motherboard with advanced features for extreme performance and overclocking.', 45],
            ['AMD Ryzen 9 9950X3D Processor', 533.00, 'public/img/product-3.png', 'cpu', 'Flagship processor with 3D V-Cache for unparalleled gaming and productivity performance.', 40],
            ['Benq Zowie Xl2586x+ 24 Full Hd Tn Led 600hz Gaming Monitor', 1300.00, 'public/img/product-4.png', 'monitor', 'Ultra-high refresh rate gaming monitor with 600Hz for competitive gaming.', 25]
        ];
        
        $stmt = $conn->prepare("INSERT INTO products (name, price, image, category, description, stock) VALUES (:name, :price, :image, :category, :description, :stock)");
        
        foreach ($products as $product) {
            $stmt->execute([
                ':name' => $product[0],
                ':price' => $product[1],
                ':image' => $product[2],
                ':category' => $product[3],
                ':description' => $product[4],
                ':stock' => $product[5]
            ]);
        }
    }
    
    // Seed default admin user if doesn't exist
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
}

// Hard reset the database back to the 11 default products.
function resetProductsDatabase($conn) {
    $conn->exec("DROP TABLE IF EXISTS cart CASCADE");
    $conn->exec("DROP TABLE IF EXISTS orders CASCADE");
    $conn->exec("DROP TABLE IF EXISTS order_items CASCADE");
    $conn->exec("DROP TABLE IF EXISTS products CASCADE");
    ensureTables($conn);
}

// Helper function to send JSON response
function sendJSON($data, $statusCode = 200) {
    http_response_code($statusCode);
    echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
    exit();
}

// Helper function to get JSON input
function getJSONInput() {
    $json = file_get_contents('php://input');
    return json_decode($json, true);
}

?>

