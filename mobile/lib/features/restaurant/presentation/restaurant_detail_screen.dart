import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/constants/app_radius.dart';
import 'package:mobile/core/constants/app_spacing.dart';
import 'package:mobile/data/models/menu_item.dart';
import 'package:mobile/providers/browse_providers.dart';

class RestaurantDetailScreen extends ConsumerWidget {
  const RestaurantDetailScreen({required this.restaurantId, super.key});

  final int restaurantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantAsync = ref.watch(restaurantByIdProvider(restaurantId));
    final menuAsync = ref.watch(menuByRestaurantProvider(restaurantId));
    final cart = ref.watch(cartProvider);
    final cartCount = ref.watch(cartCountProvider);
    final isFavorite = ref.watch(
      favoriteRestaurantsProvider.select((ids) => ids.contains(restaurantId)),
    );

    return restaurantAsync.when(
      data: (restaurant) {
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;
        final menuItems =
            menuAsync.valueOrNull?.values
                .expand((items) => items)
                .toList(growable: false) ??
            const <MenuItem>[];

        return Scaffold(
          body: Stack(
            children: [
              ListView(
                padding: EdgeInsets.zero,
                children: [
                  Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: restaurant.imageUrl,
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(
                          height: 220,
                          color: colorScheme.surfaceContainerHigh,
                          alignment: Alignment.center,
                          child: const Icon(Icons.broken_image_outlined),
                        ),
                      ),
                      Container(
                        height: 220,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              colorScheme.onSurface.withValues(alpha: 0.28),
                              colorScheme.surface.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 42,
                        left: 16,
                        child: CircleAvatar(
                          backgroundColor: colorScheme.surfaceContainerLowest.withValues(alpha: 0.92),
                          child: IconButton(
                            onPressed: () => context.pop(),
                            icon: const Icon(Icons.arrow_back),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 42,
                        right: 16,
                        child: CircleAvatar(
                          backgroundColor: colorScheme.surfaceContainerLowest.withValues(alpha: 0.92),
                          child: IconButton(
                            onPressed: () {
                              ref
                                  .read(favoriteRestaurantsProvider.notifier)
                                  .toggle(restaurantId);
                              final message = isFavorite
                                  ? 'Removed from favorites'
                                  : 'Saved to favorites';
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  SnackBar(
                                    content: Text(message),
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                            },
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite
                                  ? colorScheme.error
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Transform.translate(
                    offset: const Offset(0, -12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLowest,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.sm,
                              AppSpacing.sm,
                              AppSpacing.sm,
                              AppSpacing.sm,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  restaurant.name,
                                  style: textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Gap(8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 15,
                                      color: colorScheme.secondary,
                                    ),
                                    const Gap(4),
                                    Text(
                                      restaurant.rating.toStringAsFixed(1),
                                      style: textTheme.labelMedium?.copyWith(
                                        color: colorScheme.secondary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const Gap(8),
                                    Text(
                                      '•',
                                      style: textTheme.bodySmall?.copyWith(
                                        color: colorScheme.outline,
                                      ),
                                    ),
                                    const Gap(8),
                                    Text(
                                      '1.2k+ Reviews',
                                      style: textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const Gap(8),
                                    Text(
                                      '•',
                                      style: textTheme.bodySmall?.copyWith(
                                        color: colorScheme.outline,
                                      ),
                                    ),
                                    const Gap(8),
                                    Expanded(
                                      child: Text(
                                        restaurant.cuisineType,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Gap(12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _MetaChip(
                                      icon: Icons.schedule,
                                      label:
                                          '${restaurant.deliveryTimeMinutes - 5}-${restaurant.deliveryTimeMinutes + 5} min',
                                    ),
                                    _MetaChip(
                                      icon: Icons.delivery_dining,
                                      label: restaurant.deliveryFee == 0
                                          ? 'Free Delivery'
                                          : '\$${restaurant.deliveryFee.toStringAsFixed(2)} Delivery',
                                    ),
                                    const _MetaChip(
                                      icon: Icons.shopping_bag,
                                      label: '\$15.00 Min.',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 6,
                            color: colorScheme.surfaceContainerLow,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.sm,
                              AppSpacing.md,
                              AppSpacing.sm,
                              120,
                            ),
                            child: menuAsync.when(
                              data: (_) {
                                if (menuItems.isEmpty) {
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Menu preview unavailable',
                                          style: textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () => context.push('/restaurant/${restaurant.id}/menu'),
                                        child: const Text('View Full Menu'),
                                      ),
                                    ],
                                  );
                                }

                                final previewItems = menuItems.take(2).toList(growable: false);
                                final feature = previewItems.first;
                                final compact = previewItems.length > 1 ? previewItems[1] : null;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Popular Preview',
                                            style: textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () => context.push('/restaurant/${restaurant.id}/menu'),
                                          child: const Text('View Full Menu'),
                                        ),
                                      ],
                                    ),
                                    const Gap(AppSpacing.sm),
                                    _FeatureMenuCard(item: feature),
                                    if (compact != null) ...[
                                      const Gap(AppSpacing.sm),
                                      _CompactMenuRow(item: compact),
                                    ],
                                  ],
                                );
                              },
                              loading: () => const Padding(
                                padding: EdgeInsets.only(top: AppSpacing.sm),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              error: (error, stack) =>
                                  Text('Failed to load menu: $error'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (cartCount > 0)
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 16,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => context.push('/cart'),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.onPrimary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$cartCount',
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Gap(10),
                        Expanded(
                          child: Text(
                            'View Cart',
                            style: textTheme.labelLarge?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          '\$${cart.totalAmount.toStringAsFixed(2)}',
                          style: textTheme.labelLarge?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Restaurant')),
        body: Center(child: Text('Failed to load restaurant: $error')),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.primary),
          const Gap(4),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _FeatureMenuCard extends ConsumerWidget {
  const _FeatureMenuCard({required this.item});

  final MenuItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Gap(4),
                Text(
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const Gap(8),
                Text(
                  '\$${item.price.toStringAsFixed(2)}',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Gap(8),
                _ItemCartControl(item: item),
              ],
            ),
          ),
          const Gap(AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: item.imageUrl,
              width: 96,
              height: 96,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Container(
                width: 96,
                height: 96,
                color: colorScheme.surfaceContainerHigh,
                child: const Icon(Icons.fastfood_outlined),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactMenuRow extends ConsumerWidget {
  const _CompactMenuRow({required this.item});

  final MenuItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colorScheme.surfaceContainerHigh),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Gap(2),
                Text(
                  item.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const Gap(6),
                Text(
                  '\$${item.price.toStringAsFixed(2)}',
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          _ItemCartControl(item: item),
        ],
      ),
    );
  }
}

class _ItemCartControl extends ConsumerWidget {
  const _ItemCartControl({required this.item});

  final MenuItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final line = ref.watch(cartProvider.select((cart) => cart.lines[item.id]));

    if (!item.isAvailable) {
      return Text(
        'Unavailable',
        style: textTheme.labelSmall?.copyWith(color: colorScheme.outline),
      );
    }

    if (line == null) {
      return IconButton(
        onPressed: () => ref.read(cartProvider.notifier).addItem(item),
        icon: Icon(Icons.add, color: colorScheme.primary),
        style: IconButton.styleFrom(
          visualDensity: VisualDensity.compact,
          backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.25),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () => ref.read(cartProvider.notifier).decrease(item.id),
            icon: Icon(Icons.remove, color: colorScheme.primary, size: 16),
          ),
          Text(
            '${line.quantity}',
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () => ref.read(cartProvider.notifier).increase(item.id),
            icon: Icon(Icons.add, color: colorScheme.primary, size: 16),
          ),
        ],
      ),
    );
  }
}
