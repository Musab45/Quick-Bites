import 'package:dio/dio.dart';
import 'package:mobile/data/models/menu_item.dart';
import 'package:mobile/data/services/api_service.dart';

class MenuRepository {
  MenuRepository(this._apiService);

  final ApiService _apiService;

  Future<Map<String, List<MenuItem>>> fetchMenuByRestaurant(int restaurantId) async {
    final Response<dynamic> response = await _apiService.client.get('/menu/$restaurantId');
    final raw = response.data as Map<String, dynamic>;

    final Map<String, List<MenuItem>> grouped = {};
    for (final entry in raw.entries) {
      final items = (entry.value as List<dynamic>)
          .map((json) => MenuItem.fromJson(json as Map<String, dynamic>))
          .toList(growable: false);
      grouped[entry.key] = items;
    }
    return grouped;
  }
}
