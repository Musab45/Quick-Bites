import 'package:dio/dio.dart';
import 'package:mobile/core/utils/env.dart';

class ApiService {
  ApiService()
      : client = Dio(
          BaseOptions(
            baseUrl: Env.apiBaseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        );

  final Dio client;
}
