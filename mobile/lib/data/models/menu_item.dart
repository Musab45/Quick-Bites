class MenuItem {
  const MenuItem({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.isAvailable,
  });

  final int id;
  final int restaurantId;
  final String name;
  final String description;
  final String category;
  final double price;
  final String imageUrl;
  final bool isAvailable;

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] as int,
      restaurantId: json['restaurant_id'] as int,
      name: (json['name'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      category: (json['category'] ?? '') as String,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      imageUrl: (json['image_url'] ?? '') as String,
      isAvailable: (json['is_available'] as bool?) ?? false,
    );
  }
}
