import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/constants/app_radius.dart';
import 'package:mobile/core/constants/app_spacing.dart';
import 'package:mobile/data/models/menu_item.dart';
import 'package:mobile/data/models/restaurant.dart';
import 'package:mobile/providers/browse_providers.dart';

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({required this.restaurantId, super.key});

  final int restaurantId;

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final menuAsync = ref.watch(menuByRestaurantProvider(widget.restaurantId));
    final restaurantAsync = ref.watch(restaurantByIdProvider(widget.restaurantId));
    final cartCount = ref.watch(cartCountProvider);
    final cart = ref.watch(cartProvider);
    final restaurantName = restaurantAsync.valueOrNull?.name ?? 'QuickBite';

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(restaurantName, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(onPressed: () => context.go('/search'), icon: const Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined)),
          Stack(
            children: [
              IconButton(
                onPressed: () => context.push('/cart'),
                icon: const Icon(Icons.shopping_cart_outlined),
              ),
              if (cartCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: CircleAvatar(
                    radius: 9,
                    backgroundColor: colorScheme.secondaryContainer,
                    child: Text(
                      '$cartCount',
                      style: TextStyle(fontSize: 11, color: colorScheme.onSecondaryContainer),
                    ),
                  ),
                ),
            ],
          ),
          const Gap(6),
        ],
      ),
      body: menuAsync.when(
        data: (groupedMenu) {
          final categories = groupedMenu.keys.toList(growable: false);
          selectedCategory ??= categories.isEmpty ? null : categories.first;
          final visibleItems = groupedMenu[selectedCategory] ?? const <MenuItem>[];

          if (categories.isEmpty) {
            return const Center(child: Text('No menu available.'));
          }

          final headerRestaurant = restaurantAsync.valueOrNull;

          return Stack(
            children: [
              NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverToBoxAdapter(child: _RestaurantHeader(restaurant: headerRestaurant)),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _CategoryTabsDelegate(
                        minHeight: 56,
                        maxHeight: 56,
                        child: Container(
                          color: colorScheme.surfaceContainerLowest,
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: categories.length,
                            separatorBuilder: (context, index) => const SizedBox(width: 20),
                            itemBuilder: (context, index) {
                              final category = categories[index];
                              final isActive = category == selectedCategory;
                              return InkWell(
                                onTap: () => setState(() => selectedCategory = category),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        category,
                                        style: textTheme.labelLarge?.copyWith(
                                          color: isActive
                                              ? colorScheme.primary
                                              : colorScheme.onSurfaceVariant,
                                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                                        ),
                                      ),
                                      const Gap(3),
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        width: isActive ? 28 : 0,
                                        height: 2,
                                        decoration: BoxDecoration(
                                          color: colorScheme.primary,
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ];
                },
                body: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.sm,
                    AppSpacing.sm,
                    AppSpacing.sm,
                    120,
                  ),
                  itemCount: visibleItems.length + 1,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          'Popular $selectedCategory',
                          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      );
                    }
                    return _MenuItemCard(item: visibleItems[index - 1]);
                  },
                ),
              ),
              if (cartCount > 0)
                Positioned(
                  left: AppSpacing.sm,
                  right: AppSpacing.sm,
                  bottom: AppSpacing.md,
                  child: InkWell(
                    onTap: () => context.push('/cart'),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorScheme.onPrimary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$cartCount',
                              style: textTheme.labelMedium?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const Gap(10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'View Cart',
                                  style: textTheme.labelLarge?.copyWith(
                                    color: colorScheme.onPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  restaurantName,
                                  style: textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onPrimary.withValues(alpha: 0.88),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '\$${cart.totalAmount.toStringAsFixed(2)}',
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Failed to load menu: $error')),
      ),
    );
  }
}

class _RestaurantHeader extends StatelessWidget {
  const _RestaurantHeader({required this.restaurant});

  final Restaurant? restaurant;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (restaurant == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      color: colorScheme.surfaceContainerLowest,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant!.name,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      '${restaurant!.cuisineType} • \$\$',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, size: 16, color: colorScheme.secondary),
                    const Gap(3),
                    Text(
                      restaurant!.rating.toStringAsFixed(1),
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.secondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(10),
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: colorScheme.onSurfaceVariant),
              const Gap(4),
              Text(
                '${restaurant!.deliveryTimeMinutes - 5}-${restaurant!.deliveryTimeMinutes + 5} min',
                style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const Gap(16),
              Icon(Icons.delivery_dining, size: 16, color: colorScheme.onSurfaceVariant),
              const Gap(4),
              Text(
                restaurant!.deliveryFee == 0
                    ? 'Free Delivery'
                    : '\$${restaurant!.deliveryFee.toStringAsFixed(2)} Delivery',
                style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryTabsDelegate extends SliverPersistentHeaderDelegate {
  _CategoryTabsDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_CategoryTabsDelegate oldDelegate) {
    return oldDelegate.minHeight != minHeight ||
        oldDelegate.maxHeight != maxHeight ||
        oldDelegate.child != child;
  }
}

class _MenuItemCard extends ConsumerWidget {
  const _MenuItemCard({required this.item});

  final MenuItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final cart = ref.watch(cartProvider);
    final line = cart.lines[item.id];

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: item.imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Container(
                width: 80,
                height: 80,
                color: colorScheme.surfaceContainerLow,
                alignment: Alignment.center,
                child: const Icon(Icons.fastfood_outlined),
              ),
            ),
          ),
          const Gap(AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const Gap(4),
                Text(
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const Gap(8),
                Text(
                  '\$${item.price.toStringAsFixed(2)}',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.secondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (line == null)
            Material(
              color: colorScheme.primary,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: item.isAvailable
                    ? () => ref.read(cartProvider.notifier).addItem(item)
                    : null,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.add, color: colorScheme.onPrimary, size: 20),
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.14),
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
                    style: textTheme.labelLarge?.copyWith(
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
            ),
        ],
      ),
    );
  }
}
