import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/providers/auth_providers.dart';

class ProfileSettingsState {
  const ProfileSettingsState({
    required this.initialized,
    required this.defaultAddress,
    required this.preferredPaymentMethod,
    required this.notificationsEnabled,
  });

  final bool initialized;
  final String defaultAddress;
  final String preferredPaymentMethod;
  final bool notificationsEnabled;

  static const initial = ProfileSettingsState(
    initialized: false,
    defaultAddress: '123 Test Street',
    preferredPaymentMethod: 'card',
    notificationsEnabled: true,
  );

  ProfileSettingsState copyWith({
    bool? initialized,
    String? defaultAddress,
    String? preferredPaymentMethod,
    bool? notificationsEnabled,
  }) {
    return ProfileSettingsState(
      initialized: initialized ?? this.initialized,
      defaultAddress: defaultAddress ?? this.defaultAddress,
      preferredPaymentMethod: preferredPaymentMethod ?? this.preferredPaymentMethod,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

class ProfileSettingsNotifier extends StateNotifier<ProfileSettingsState> {
  ProfileSettingsNotifier(this._ref) : super(ProfileSettingsState.initial) {
    hydrate();
  }

  static const _storageKey = 'profile_settings';
  final Ref _ref;

  Future<void> hydrate() async {
    try {
      final raw = await _ref.read(secureStorageProvider).read(key: _storageKey);
      if (raw == null || raw.isEmpty) {
        state = state.copyWith(initialized: true);
        return;
      }

      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      state = state.copyWith(
        initialized: true,
        defaultAddress: (decoded['default_address'] as String?)?.trim().isNotEmpty == true
            ? (decoded['default_address'] as String)
            : state.defaultAddress,
        preferredPaymentMethod:
            (decoded['preferred_payment_method'] as String?) ?? state.preferredPaymentMethod,
        notificationsEnabled:
            (decoded['notifications_enabled'] as bool?) ?? state.notificationsEnabled,
      );
    } catch (_) {
      state = state.copyWith(initialized: true);
    }
  }

  Future<void> updateAddress(String value) async {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return;
    }
    state = state.copyWith(defaultAddress: normalized);
    await _persist();
  }

  Future<void> updatePreferredPaymentMethod(String value) async {
    state = state.copyWith(preferredPaymentMethod: value);
    await _persist();
  }

  Future<void> toggleNotifications() async {
    state = state.copyWith(notificationsEnabled: !state.notificationsEnabled);
    await _persist();
  }

  Future<void> _persist() async {
    await _ref.read(secureStorageProvider).write(
      key: _storageKey,
      value: jsonEncode({
        'default_address': state.defaultAddress,
        'preferred_payment_method': state.preferredPaymentMethod,
        'notifications_enabled': state.notificationsEnabled,
      }),
    );
  }
}

final profileSettingsProvider =
    StateNotifierProvider<ProfileSettingsNotifier, ProfileSettingsState>((ref) {
      return ProfileSettingsNotifier(ref);
    });
