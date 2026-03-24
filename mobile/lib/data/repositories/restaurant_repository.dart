import 'package:dio/dio.dart';
import 'package:mobile/data/models/restaurant.dart';
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
}
