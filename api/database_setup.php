<?php
/**
 * Database Setup Script for CompuMart
 * Run this file once to create the database and tables
 * Access via browser: http://localhost/Website/api/database_setup.php
 */
?>
<!DOCTYPE html>
<html>
<head>
    <title>CompuMart Database Setup</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background: #f5f5f5;
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
            text-align: center;
        }
        p { line-height: 1.6; }
        .success { color: #27ae60; }
        .error { color: #e74c3c; }
        .info { color: #3498db; }
        hr { margin: 20px 0; }
        .button-group {
            text-align: center;
            margin-top: 30px;
        }
        a {
            display: inline-block;
            padding: 12px 24px;
            margin: 0 10px;
            background: #3498db;
            color: white;
            text-decoration: none;
            border-radius: 4px;
            transition: background 0.3s;
        }
        a:hover { background: #2980b9; }
        a.success { background: #27ae60; }
        a.success:hover { background: #229954; }
        ul { line-height: 1.8; }
    </style>
</head>
<body>
<div class="container">
    <h1>🖥️ CompuMart Database Setup</h1>
    
<?php
// PostgreSQL connection details
$host = 'localhost';
$port = '5432';
$user = 'postgres';
$pass = '050806'; // Set your PostgreSQL password
$dbname = 'compumart';

$isReset = isset($_GET['reset']) && $_GET['reset'] === '1';

function seedDefaultProducts(PDO $conn) {
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

function setupSchema(PDO $conn) {
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
    $conn->exec("CREATE INDEX IF NOT EXISTS idx_category ON products(category)");
    $conn->exec("CREATE INDEX IF NOT EXISTS idx_name ON products(name)");

    $sql = "CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        email VARCHAR(255) NOT NULL UNIQUE,
        password VARCHAR(255) NOT NULL,
        name VARCHAR(255) NOT NULL,
        role VARCHAR(20) DEFAULT 'user',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )";
    $conn->exec($sql);

    $sql = "CREATE TABLE IF NOT EXISTS cart (
        id SERIAL PRIMARY KEY,
        user_id VARCHAR(255) NOT NULL,
        product_id INT REFERENCES products(id) ON DELETE CASCADE,
        quantity INT DEFAULT 1,
        added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )";
    $conn->exec($sql);

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

    $sql = "CREATE TABLE IF NOT EXISTS order_items (
        id SERIAL PRIMARY KEY,
        order_id INT REFERENCES orders(id) ON DELETE CASCADE,
        product_id INT REFERENCES products(id) ON DELETE SET NULL,
        quantity INT NOT NULL,
        price DECIMAL(10, 2) NOT NULL
    )";
    $conn->exec($sql);
}

function resetProductsDatabase(PDO $conn) {
    $conn->exec("DROP TABLE IF EXISTS cart CASCADE");
    $conn->exec("DROP TABLE IF EXISTS orders CASCADE");
    $conn->exec("DROP TABLE IF EXISTS order_items CASCADE");
    $conn->exec("DROP TABLE IF EXISTS products CASCADE");

    setupSchema($conn);
    seedDefaultProducts($conn);
}

// Connect to PostgreSQL server
try {
    // First connect without database to create it
    $dsn = "pgsql:host=$host;port=$port";
    $conn = new PDO($dsn, $user, $pass);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    echo "<h2>Database Setup Progress</h2>";
    
    // Create database
    try {
        $conn->exec("CREATE DATABASE compumart");
        echo "<p>✅ Database 'compumart' created successfully</p>";
    } catch (PDOException $e) {
        echo "<p>ℹ️ Database 'compumart' already exists</p>";
    }
    
    // Now connect to the specific database
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $conn = new PDO($dsn, $user, $pass);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    if ($isReset) {
        resetProductsDatabase($conn);
        echo "<p>✅ Database reset to the default 11 products.</p>";
    } else {
        setupSchema($conn);
        echo "<p>✅ Tables checked/created successfully</p>";
    }
    
    // Seed default admin user if missing
    $stmt = $conn->prepare("SELECT COUNT(*) as count FROM users WHERE email = :email");
    $stmt->execute([':email' => 'admin@compumart.local']);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result['count'] == 0) {
        $hashedPassword = password_hash('admin123', PASSWORD_DEFAULT);
        $stmt = $conn->prepare("INSERT INTO users (email, password, name, role) VALUES (:email, :password, :name, :role)");
        $stmt->execute([
            ':email' => 'admin@compumart.local',
            ':password' => $hashedPassword,
            ':name' => 'Admin',
            ':role' => 'admin'
        ]);
        echo "<p>✅ Default admin user created (email: admin@compumart.local, password: admin123)</p>";
    } else {
        echo "<p>ℹ️ Admin user already exists</p>";
    }

    echo "<hr>";
    echo "<h3 class='success'>✅ Setup Complete!</h3>";
    echo "<p><strong>Your database is ready to use.</strong></p>";
    echo "<p><strong>Database:</strong> compumart</p>";
    echo "<p><strong>Tables created:</strong> users, products, cart, orders, order_items</p>";
    echo "<p><strong>Default Admin Account:</strong></p>";
    echo "<ul>";
    echo "<li><strong>Email:</strong> admin@compumart.local</li>";
    echo "<li><strong>Password:</strong> admin123</li>";
    echo "</ul>";

    echo "<hr>";
    echo "<div class='button-group'>";
    echo "<a class='success' href='?reset=1' onclick=\"return confirm('Reset the database to the default 11 products? This will remove custom products.');\">🔄 Reset Database</a>";
    echo "<a class='success' href='../pages/login.html'>🔐 Go to Login</a>";
    echo "<a href='../index.html'>🏠 Go to Website</a>";
    echo "</div>";

} catch (PDOException $e) {
    echo "<p class='error'>❌ Error: " . htmlspecialchars($e->getMessage()) . "</p>";
    echo "<p class='error'>Make sure PostgreSQL is installed and running on localhost:5432</p>";
    echo "<p class='info'>Update the password in database_setup.php line 31 if needed.</p>";
}
?>

</div>
</body>
</html>

