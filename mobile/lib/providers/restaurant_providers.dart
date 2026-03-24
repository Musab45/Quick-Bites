import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/data/repositories/restaurant_repository.dart';
import 'package:mobile/providers/core_providers.dart';

final restaurantRepositoryProvider = Provider<RestaurantRepository>(
  (ref) => RestaurantRepository(ref.watch(apiServiceProvider)),
);

final restaurantsFutureProvider = FutureProvider.autoDispose((ref) async {
  return ref.watch(restaurantRepositoryProvider).fetchRestaurants();
});
