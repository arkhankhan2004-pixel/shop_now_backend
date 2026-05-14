class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String category;
  final int discountPercent;
  final String? imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.imageUrl,
    this.discountPercent = 0,
  });

  double get discountedPrice {
    if (discountPercent > 0) {
      return price * (1 - (discountPercent / 100));
    }
    return price;
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      category: json['category'] ?? '',
      imageUrl: json['image_url'],
      discountPercent: int.tryParse(json['discount_percent']?.toString() ?? '0') ?? 0,
    );
  }
}
