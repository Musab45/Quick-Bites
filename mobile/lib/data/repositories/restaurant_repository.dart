import 'package:dio/dio.dart';
import 'package:mobile/data/models/restaurant.dart';
import 'package:mobile/data/models/restaurant_search_page.dart';
import 'package:mobile/data/services/api_service.dart';

class RestaurantRepository {
  RestaurantRepository(this._apiService);

  final ApiService _apiService;

  Future<List<Restaurant>> fetchRestaurants() async {
    final Response<dynamic> response = await _apiService.client.get('/restaurants');
    final data = response.data as List<dynamic>;
    return data
        .map((json) => Restaurant.fromJson(json as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<Restaurant> fetchRestaurantById(int id) async {
    final Response<dynamic> response = await _apiService.client.get('/restaurants/$id');
    return Restaurant.fromJson(response.data as Map<String, dynamic>);
  }

  Future<RestaurantSearchPage> searchRestaurants({
    String query = '',
    String? cuisine,
    bool? openNow,
    double? maxDeliveryFee,
    int? maxDeliveryTime,
    double? minRating,
    int page = 1,
    int pageSize = 20,
    String sort = 'rating_desc',
  }) async {
    final Map<String, dynamic> params = {
      'q': query,
      'page': page,
      'page_size': pageSize,
      'sort': sort,
    };

    if (cuisine != null && cuisine.trim().isNotEmpty) {
      params['cuisine'] = cuisine.trim();
    }
    if (openNow != null) {
      params['open_now'] = openNow;
    }
    if (maxDeliveryFee != null) {
      params['max_delivery_fee'] = maxDeliveryFee;
    }
    if (maxDeliveryTime != null) {
      params['max_delivery_time'] = maxDeliveryTime;
    }
    if (minRating != null) {
      params['min_rating'] = minRating;
    }

    final Response<dynamic> response = await _apiService.client.get(
      '/restaurants/search',
      queryParameters: params,
    );
    return RestaurantSearchPage.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<String>> fetchSearchSuggestions({
    required String query,
    int limit = 8,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const <String>[];
    }

    final Response<dynamic> response = await _apiService.client.get(
      '/restaurants/suggestions',
      queryParameters: {'q': trimmed, 'limit': limit},
    );

    final data = response.data as Map<String, dynamic>;
    return (data['suggestions'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<String>()
        .toList(growable: false);
  }
}
