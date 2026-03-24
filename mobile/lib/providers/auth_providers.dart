import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile/data/models/auth_user.dart';
import 'package:mobile/data/repositories/auth_repository.dart';
import 'package:mobile/providers/core_providers.dart';

class AuthState {
  const AuthState({
    required this.initialized,
    required this.isLoading,
    required this.token,
    required this.user,
    required this.error,
  });

  final bool initialized;
  final bool isLoading;
  final String? token;
  final AuthUser? user;
  final String? error;

  bool get isAuthenticated => token != null && token!.isNotEmpty && user != null;

  AuthState copyWith({
    bool? initialized,
    bool? isLoading,
    String? token,
    bool clearToken = false,
    AuthUser? user,
    bool clearUser = false,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      initialized: initialized ?? this.initialized,
      isLoading: isLoading ?? this.isLoading,
      token: clearToken ? null : (token ?? this.token),
      user: clearUser ? null : (user ?? this.user),
      error: clearError ? null : (error ?? this.error),
    );
  }

  static const initial = AuthState(
    initialized: false,
    isLoading: false,
    token: null,
    user: null,
    error: null,
  );
}

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(apiServiceProvider));
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._ref) : super(AuthState.initial) {
    hydrate();
  }

  final Ref _ref;

  FlutterSecureStorage get _storage => _ref.read(secureStorageProvider);
  AuthRepository get _authRepository => _ref.read(authRepositoryProvider);

  Future<void> hydrate() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final userJson = await _storage.read(key: 'auth_user');

      if (token == null || userJson == null) {
        state = state.copyWith(initialized: true, clearToken: true, clearUser: true);
        return;
      }

      final decoded = jsonDecode(userJson) as Map<String, dynamic>;
      state = state.copyWith(
        initialized: true,
        token: token,
        user: AuthUser.fromJson(decoded),
        clearError: true,
      );
    } catch (_) {
      state = state.copyWith(
        initialized: true,
        clearToken: true,
        clearUser: true,
        clearError: true,
      );
    }
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final session = await _authRepository.login(email: email, password: password);
      await _persistSession(session);
      state = state.copyWith(
        isLoading: false,
        initialized: true,
        token: session.token,
        user: session.user,
        clearError: true,
      );
      return true;
    } on DioException catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.response?.data['detail']?.toString() ?? 'Login failed',
      );
      return false;
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Login failed');
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final session = await _authRepository.register(
        fullName: fullName,
        email: email,
        password: password,
      );
      await _persistSession(session);
      state = state.copyWith(
        isLoading: false,
        initialized: true,
        token: session.token,
        user: session.user,
        clearError: true,
      );
      return true;
    } on DioException catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.response?.data['detail']?.toString() ?? 'Registration failed',
      );
      return false;
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Registration failed');
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'auth_user');
    state = state.copyWith(
      initialized: true,
      isLoading: false,
      clearToken: true,
      clearUser: true,
      clearError: true,
    );
  }

  Future<void> expireSession() async {
    await logout();
    state = state.copyWith(error: 'Session expired. Please login again.');
  }

  Future<void> _persistSession(AuthSession session) async {
    await _storage.write(key: 'auth_token', value: session.token);
    await _storage.write(
      key: 'auth_user',
      value: jsonEncode(
        {
          'id': session.user.id,
          'email': session.user.email,
          'full_name': session.user.fullName,
        },
      ),
    );
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

final authTokenProvider = Provider<String?>((ref) {
  return ref.watch(authNotifierProvider).token;
});
