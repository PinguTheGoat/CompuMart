class Product {
  final int id;
  final String name;
  final double price;
  final String image;
  final String category;
  final String description;
  final int stock;
  final double rating;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.category,
    required this.description,
    required this.stock,
    this.rating = 4.8,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      image: json['image'] as String? ?? 'assets/images/category-1.png',
      category: json['category'] as String? ?? 'General',
      description: json['description'] as String? ?? '',
      stock: json['stock'] as int? ?? 10,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image': image,
      'category': category,
      'description': description,
      'stock': stock,
      'rating': rating,
    };
  }
}
