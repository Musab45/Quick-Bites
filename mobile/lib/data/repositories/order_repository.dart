import 'package:dio/dio.dart';
import 'package:mobile/data/models/order.dart';
import 'package:mobile/data/services/api_service.dart';

class OrderRepository {
  OrderRepository(this._apiService);

  final ApiService _apiService;

  Future<OrderModel> createOrder({
    required String token,
    required int restaurantId,
    required String address,
    required String paymentMethod,
    required List<Map<String, dynamic>> items,
  }) async {
    final response = await _apiService.client.post(
      '/orders',
      data: {
        'restaurant_id': restaurantId,
        'address': address,
        'payment_method': paymentMethod,
        'items': items,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<OrderModel> getOrderById({required String token, required int orderId}) async {
    final response = await _apiService.client.get(
      '/orders/$orderId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<OrderModel>> listOrders({required String token}) async {
    final response = await _apiService.client.get(
      '/orders',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    final data = response.data as List<dynamic>;
    return data
        .map((item) => OrderModel.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }
}
