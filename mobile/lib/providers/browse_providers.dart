import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:mobile/providers/auth_providers.dart';
import 'package:mobile/data/models/menu_item.dart';
import 'package:mobile/data/models/order.dart';
import 'package:mobile/data/models/restaurant.dart';
import 'package:mobile/data/repositories/menu_repository.dart';
import 'package:mobile/data/repositories/order_repository.dart';
import 'package:mobile/data/repositories/restaurant_repository.dart';
import 'package:mobile/providers/core_providers.dart';

final restaurantRepositoryProvider = Provider<RestaurantRepository>(
  (ref) => RestaurantRepository(ref.watch(apiServiceProvider)),
);

final menuRepositoryProvider = Provider<MenuRepository>(
  (ref) => MenuRepository(ref.watch(apiServiceProvider)),
);

final orderRepositoryProvider = Provider<OrderRepository>(
  (ref) => OrderRepository(ref.watch(apiServiceProvider)),
);

final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

class FavoriteRestaurantsNotifier extends StateNotifier<Set<int>> {
  FavoriteRestaurantsNotifier(this._ref) : super(const <int>{}) {
    _hydrate();
  }

  static const _storageKey = 'favorite_restaurant_ids';
  final Ref _ref;

  Future<void> _hydrate() async {
    try {
      final raw = await _ref.read(secureStorageProvider).read(key: _storageKey);
      if (raw == null || raw.isEmpty) {
        return;
      }

      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return;
      }

      state = decoded.whereType<num>().map((id) => id.toInt()).toSet();
    } catch (_) {}
  }

  Future<void> toggle(int restaurantId) async {
    final updated = Set<int>.from(state);
    if (updated.contains(restaurantId)) {
      updated.remove(restaurantId);
    } else {
      updated.add(restaurantId);
    }

    state = updated;
    await _ref
        .read(secureStorageProvider)
        .write(
          key: _storageKey,
          value: jsonEncode(updated.toList(growable: false)),
        );
  }
}

final favoriteRestaurantsProvider =
    StateNotifierProvider<FavoriteRestaurantsNotifier, Set<int>>(
      (ref) => FavoriteRestaurantsNotifier(ref),
    );

final restaurantsProvider = FutureProvider<List<Restaurant>>((ref) async {
  return ref.watch(restaurantRepositoryProvider).fetchRestaurants();
});

final restaurantByIdProvider = FutureProvider.family<Restaurant, int>((
  ref,
  restaurantId,
) async {
  return ref
      .watch(restaurantRepositoryProvider)
      .fetchRestaurantById(restaurantId);
});

final menuByRestaurantProvider =
    FutureProvider.family<Map<String, List<MenuItem>>, int>((
      ref,
      restaurantId,
    ) async {
      return ref
          .watch(menuRepositoryProvider)
          .fetchMenuByRestaurant(restaurantId);
    });

class CartLine {
  const CartLine({required this.item, required this.quantity});

  final MenuItem item;
  final int quantity;

  CartLine copyWith({int? quantity}) {
    return CartLine(item: item, quantity: quantity ?? this.quantity);
  }
}

class CartState {
  const CartState({required this.restaurantId, required this.lines});

  final int? restaurantId;
  final Map<int, CartLine> lines;

  bool get isEmpty => lines.isEmpty;
  int get totalItems =>
      lines.values.fold<int>(0, (sum, line) => sum + line.quantity);
  double get totalAmount => lines.values.fold<double>(
    0,
    (sum, line) => sum + (line.item.price * line.quantity),
  );
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState(restaurantId: null, lines: {}));

  void addItem(MenuItem menuItem) {
    final hasDifferentRestaurant =
        state.restaurantId != null &&
        state.restaurantId != menuItem.restaurantId;

    final baseLines = hasDifferentRestaurant
        ? <int, CartLine>{}
        : {...state.lines};
    final existing = baseLines[menuItem.id];
    baseLines[menuItem.id] = existing == null
        ? CartLine(item: menuItem, quantity: 1)
        : existing.copyWith(quantity: existing.quantity + 1);

    state = CartState(restaurantId: menuItem.restaurantId, lines: baseLines);
  }

  void increase(int menuItemId) {
    final line = state.lines[menuItemId];
    if (line == null) {
      return;
    }
    final updated = {
      ...state.lines,
      menuItemId: line.copyWith(quantity: line.quantity + 1),
    };
    state = CartState(restaurantId: state.restaurantId, lines: updated);
  }

  void decrease(int menuItemId) {
    final line = state.lines[menuItemId];
    if (line == null) {
      return;
    }

    final updated = {...state.lines};
    if (line.quantity <= 1) {
      updated.remove(menuItemId);
    } else {
      updated[menuItemId] = line.copyWith(quantity: line.quantity - 1);
    }

    state = CartState(
      restaurantId: updated.isEmpty ? null : state.restaurantId,
      lines: updated,
    );
  }

  void remove(int menuItemId) {
    final updated = {...state.lines};
    updated.remove(menuItemId);
    state = CartState(
      restaurantId: updated.isEmpty ? null : state.restaurantId,
      lines: updated,
    );
  }

  void clear() {
    state = const CartState(restaurantId: null, lines: {});
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>(
  (ref) => CartNotifier(),
);

final cartCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.totalItems;
});

final latestOrderProvider = StateProvider<OrderModel?>((ref) => null);

final orderHistoryProvider = FutureProvider<List<OrderModel>>((ref) async {
  final token = ref.read(authTokenProvider);
  if (token == null || token.isEmpty) {
    throw Exception('Authentication required');
  }

  try {
    return ref.watch(orderRepositoryProvider).listOrders(token: token);
  } on DioException catch (error) {
    if (error.response?.statusCode == 401) {
      await ref.read(authNotifierProvider.notifier).expireSession();
    }
    rethrow;
  }
});

final orderTrackingProvider = FutureProvider.family<OrderModel, int>((
  ref,
  orderId,
) async {
  final token = ref.read(authTokenProvider);
  if (token == null || token.isEmpty) {
    throw Exception('Authentication required');
  }

  try {
    return ref
        .watch(orderRepositoryProvider)
        .getOrderById(token: token, orderId: orderId);
  } on DioException catch (error) {
    if (error.response?.statusCode == 401) {
      await ref.read(authNotifierProvider.notifier).expireSession();
    }
    rethrow;
  }
});
