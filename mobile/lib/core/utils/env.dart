import 'package:flutter/foundation.dart';

class Env {
  static String get apiBaseUrl {
    const configured = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (configured.isNotEmpty) {
      return configured;
    }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }

    return 'http://127.0.0.1:8000';
  }
  static const String demoEmail = String.fromEnvironment(
    'DEMO_EMAIL',
    defaultValue: 'demo@quickbite.dev',
  );
  static const String demoPassword = String.fromEnvironment(
    'DEMO_PASSWORD',
    defaultValue: 'DemoPass123',
  );

  const Env._();
}
