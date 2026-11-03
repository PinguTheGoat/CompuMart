import '../models/product.dart';

class ProductService {
  // Supabase Configuration (Optional: fill these with your Supabase credentials)
  static const String supabaseUrl = 'https://your-project-id.supabase.co';
  static const String supabaseAnonKey = 'your-anon-key';

  // CompuMart Warehouse Catalog (Stock direct from warehouse)
  static final List<Product> defaultProducts = [
    const Product(
      id: 1,
      name: 'AMD Ryzen 7 5700X3D Processor',
      price: 138.20,
      image: 'assets/images/category-1.png',
      category: 'CPU',
      description: 'High-performance processor with 3D V-Cache technology for exceptional gaming performance. Warehouse deal.',
      stock: 50,
      rating: 4.9,
    ),
    const Product(
      id: 2,
      name: 'Palit RTX 5090 GameRock OC 32GB',
      price: 5300.00,
      image: 'assets/images/category-2.png',
      category: 'GPU',
      description: 'Top-of-the-line graphics card with 32GB VRAM, perfect for 4K ray tracing and professional workloads.',
      stock: 25,
      rating: 5.0,
    ),
    const Product(
      id: 3,
      name: 'Corsair Dominator Titanium DDR5 96GB',
      price: 320.00,
      image: 'assets/images/category-3.png',
      category: 'RAM',
      description: 'Premium DDR5 memory kit with 96GB capacity and titanium heat spreaders for ultimate multitasking.',
      stock: 40,
      rating: 4.8,
    ),
    const Product(
      id: 4,
      name: 'SAMSUNG 980 M.2 PCIe NVMe 1TB SSD',
      price: 215.00,
      image: 'assets/images/category-4.png',
      category: 'SSD',
      description: 'Lightning-fast NVMe SSD with 1TB capacity for rapid load times and instantaneous file transfers.',
      stock: 60,
      rating: 4.9,
    ),
    const Product(
      id: 5,
      name: 'Lian Li Edge Series-1000W Modular PSU',
      price: 279.00,
      image: 'assets/images/category-5.png',
      category: 'Power Supply',
      description: '80 Plus Gold certified fully modular power supply unit with 1000W clean wattage headroom.',
      stock: 35,
      rating: 4.7,
    ),
    const Product(
      id: 6,
      name: 'GIGABYTE AORUS RTX 5080 Master ICE 16G',
      price: 1790.00,
      image: 'assets/images/category-6.png',
      category: 'GPU',
      description: 'Premium RTX 5080 graphics card with 16GB VRAM and advanced ICE triple-fan cooling solution.',
      stock: 30,
      rating: 4.9,
    ),
    const Product(
      id: 7,
      name: 'Hyte Y70 Touch Dual Chamber ATX Case',
      price: 501.00,
      image: 'assets/images/category-7.png',
      category: 'Case',
      description: 'Panoramic chassis featuring an integrated 4K multi-touch LCD display and dual-chamber airflow.',
      stock: 20,
      rating: 5.0,
    ),
    const Product(
      id: 8,
      name: 'ASUS ROG Astral RTX 5090 Dhahab OC',
      price: 5500.00,
      image: 'assets/images/product-1.png',
      category: 'GPU',
      description: 'Limited edition flagship graphics card with custom gold vapor cooling and extreme overclocking support.',
      stock: 15,
      rating: 5.0,
    ),
    const Product(
      id: 9,
      name: 'Asus ROG Crosshair X870E Extreme',
      price: 939.00,
      image: 'assets/images/product-2.png',
      category: 'Motherboard',
      description: 'High-end enthusiast motherboard with PCIe 5.0, robust VRM power stages, and WiFi 7 onboard.',
      stock: 45,
      rating: 4.8,
    ),
    const Product(
      id: 10,
      name: 'AMD Ryzen 9 9950X3D 16-Core Processor',
      price: 533.00,
      image: 'assets/images/product-3.png',
      category: 'CPU',
      description: '16-core flagship CPU with 2nd generation 3D V-Cache delivering unparalleled gaming and creator output.',
      stock: 40,
      rating: 5.0,
    ),
  ];

  static List<Product> getProducts({String category = 'All', String searchQuery = ''}) {
    return defaultProducts.where((product) {
      final matchesCategory = category == 'All' || product.category.toLowerCase() == category.toLowerCase();
      final matchesSearch = searchQuery.isEmpty ||
          product.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          product.category.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }
}
