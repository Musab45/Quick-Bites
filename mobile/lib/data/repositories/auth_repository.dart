import 'package:mobile/data/models/auth_user.dart';
import 'package:mobile/data/services/api_service.dart';

class AuthRepository {
  AuthRepository(this._apiService);

  final ApiService _apiService;

  Future<AuthSession> login({required String email, required String password}) async {
    final response = await _apiService.client.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    return AuthSession(
      token: response.data['access_token'] as String,
      user: AuthUser.fromJson(response.data['user'] as Map<String, dynamic>),
    );
  }

  Future<AuthSession> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    await _apiService.client.post(
      '/auth/register',
      data: {
        'full_name': fullName,
        'email': email,
        'password': password,
      },
    );

    return login(email: email, password: password);
  }
}
