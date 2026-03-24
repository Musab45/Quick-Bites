class Restaurant {
  const Restaurant({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.deliveryTimeMinutes,
    required this.deliveryFee,
    required this.cuisineType,
    required this.isOpen,
  });

  final int id;
  final String name;
  final String imageUrl;
  final double rating;
  final int deliveryTimeMinutes;
  final double deliveryFee;
  final String cuisineType;
  final bool isOpen;

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] as int,
      name: (json['name'] ?? '') as String,
      imageUrl: (json['image_url'] ?? '') as String,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      deliveryTimeMinutes: (json['delivery_time_minutes'] as num?)?.toInt() ?? 0,
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 0,
      cuisineType: (json['cuisine_type'] ?? '') as String,
      isOpen: (json['is_open'] as bool?) ?? false,
    );
  }
}
