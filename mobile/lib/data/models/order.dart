class OrderItemModel {
  const OrderItemModel({
    required this.id,
    required this.menuItemId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  final int id;
  final int menuItemId;
  final String name;
  final int quantity;
  final double unitPrice;
  final double lineTotal;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as int,
      menuItemId: json['menu_item_id'] as int,
      name: (json['name'] ?? '') as String,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0,
      lineTotal: (json['line_total'] as num?)?.toDouble() ?? 0,
    );
  }
}

class OrderModel {
  const OrderModel({
    required this.id,
    required this.userId,
    required this.restaurantId,
    required this.address,
    required this.paymentMethod,
    required this.status,
    required this.totalAmount,
    required this.estimatedDeliveryMinutes,
    required this.createdAt,
    required this.items,
  });

  final int id;
  final int userId;
  final int restaurantId;
  final String address;
  final String paymentMethod;
  final String status;
  final double totalAmount;
  final int estimatedDeliveryMinutes;
  final DateTime createdAt;
  final List<OrderItemModel> items;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List<dynamic>? ?? const []);
    return OrderModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      restaurantId: json['restaurant_id'] as int,
      address: (json['address'] ?? '') as String,
      paymentMethod: (json['payment_method'] ?? '') as String,
      status: (json['status'] ?? 'pending') as String,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0,
      estimatedDeliveryMinutes: (json['estimated_delivery_minutes'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse((json['created_at'] ?? '') as String) ?? DateTime.now(),
      items: rawItems
          .map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}
