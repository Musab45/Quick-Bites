import 'package:mobile/data/models/restaurant.dart';

class RestaurantSearchPage {
  const RestaurantSearchPage({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
  });

  final List<Restaurant> items;
  final int page;
  final int pageSize;
  final int totalItems;
  final int totalPages;

  factory RestaurantSearchPage.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(Restaurant.fromJson)
        .toList(growable: false);

    return RestaurantSearchPage(
      items: rawItems,
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['page_size'] as num?)?.toInt() ?? rawItems.length,
      totalItems: (json['total_items'] as num?)?.toInt() ?? rawItems.length,
      totalPages: (json['total_pages'] as num?)?.toInt() ?? 1,
    );
  }
}
