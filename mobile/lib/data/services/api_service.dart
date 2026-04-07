import 'package:dio/dio.dart';
import 'package:mobile/core/utils/env.dart';

class ApiService {
  ApiService()
      : client = Dio(
          BaseOptions(
            baseUrl: Env.apiBaseUrl.replaceFirst(RegExp(r'/+$'), ''),
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: const {
              // Avoid ngrok browser interstitial responses on free domains.
              'ngrok-skip-browser-warning': '1',
              'accept': 'application/json',
            },
          ),
        );

  final Dio client;
}
