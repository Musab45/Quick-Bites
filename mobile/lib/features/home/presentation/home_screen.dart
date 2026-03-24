import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/constants/app_radius.dart';
import 'package:mobile/core/constants/app_spacing.dart';
import 'package:mobile/core/widgets/loading_card_shimmer.dart';
import 'package:mobile/providers/browse_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const categories = [
    'All',
    'Burgers',
    'Pizza',
    'Sushi',
    'Chinese',
    'Desserts',
    'Drinks',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantsAsync = ref.watch(restaurantsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final cartCount = ref.watch(cartCountProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on, size: 18, color: colorScheme.primary),
            const Gap(4),
            Text('San Francisco', style: textTheme.titleMedium),
            const Gap(2),
            Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
        actions: [
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
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const Gap(8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: ListView(
          children: [
            InkWell(
              onTap: () => context.go('/search'),
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: colorScheme.outline),
                    const Gap(10),
                    Expanded(
                      child: Text(
                        'Search restaurants or dishes',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                    ),
                    Icon(Icons.mic_none_rounded, color: colorScheme.primary),
                  ],
                ),
              ),
            ),
            const Gap(AppSpacing.sm),
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (context, index) => const Gap(8),
                itemBuilder: (context, index) {
                  final label = categories[index];
                  final isSelected = label == selectedCategory;
                  return ChoiceChip(
                    label: Text(label.toUpperCase()),
                    selected: isSelected,
                    side: BorderSide.none,
                    labelStyle: textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurfaceVariant,
                    ),
                    backgroundColor: colorScheme.surfaceContainerHigh,
                    selectedColor: colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.chip),
                    ),
                    onSelected: (_) {
                      ref.read(selectedCategoryProvider.notifier).state = label;
                    },
                  );
                },
              ),
            ),
            const Gap(AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: SizedBox(
                height: 192,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl:
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuDTp90NJgx44UCArpdj5ayAiOPcidIaJIEeblKP8ap_QW7BZFDKnxhIvv2KC70xfzNcB-d_dkzatlhqzhWbDZuDxn9mPfIUOgYz9FLeCS6NMEfDTVzQHkBdgt4ahVpPg14MZrIS2H1mMN4mhFHEGQK9wImUchwZg-MjT4xtSgncNp_gxIEd1H3v725LFEY_pn7s_AprukZ4xZcxW4YOgOu_RV0JDoKToJZgeVlNNBwg_OXVF-Ih9mkF1SE1MPo6dKqzM-pxJs9RjQ',
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Container(
                        color: colorScheme.surfaceContainerHigh,
                        child: const Icon(Icons.broken_image_outlined),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            colorScheme.onSurface.withValues(alpha: 0.72),
                            colorScheme.onSurface.withValues(alpha: 0.12),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      top: 20,
                      child: Text(
                        'Exclusive Deal',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.secondaryContainer,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      top: 42,
                      child: Text(
                        '30% Off Your\nFirst Order',
                        style: textTheme.headlineSmall?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      bottom: 16,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          textStyle: textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                          ),
                        ),
                        onPressed: () {},
                        child: const Text('Order Now'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Gap(AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nearby Restaurants',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(onPressed: () {}, child: const Text('View All')),
              ],
            ),
            const Gap(AppSpacing.sm),
            restaurantsAsync.when(
              data: (restaurants) {
                final filtered = selectedCategory == 'All'
                    ? restaurants
                    : restaurants
                          .where(
                            (restaurant) => restaurant.cuisineType
                                .toLowerCase()
                                .contains(selectedCategory.toLowerCase()),
                          )
                          .toList(growable: false);

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text('No restaurants found in this category.'),
                  );
                }

                return Column(
                  children: filtered
                      .map(
                        (restaurant) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: InkWell(
                            onTap: () =>
                                context.push('/restaurant/${restaurant.id}'),
                            borderRadius: BorderRadius.circular(AppRadius.card),
                            child: Container(
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.card,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.onSurface.withValues(alpha: 0.08),
                                    blurRadius: 8,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(
                                                AppRadius.card,
                                              ),
                                            ),
                                        child: CachedNetworkImage(
                                          imageUrl: restaurant.imageUrl,
                                          height: 140,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorWidget: (context, url, error) =>
                                              Container(
                                                height: 140,
                                                color: colorScheme.surfaceContainerLow,
                                                child: const Icon(
                                                  Icons.broken_image_outlined,
                                                ),
                                              ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 10,
                                        right: 10,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: colorScheme
                                                .surfaceContainerLowest
                                                .withValues(alpha: 0.9),
                                            borderRadius: BorderRadius.circular(
                                              AppRadius.chip,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.star,
                                                size: 13,
                                                color: colorScheme.secondary,
                                              ),
                                              const Gap(2),
                                              Text(
                                                restaurant.rating
                                                    .toStringAsFixed(1),
                                                style: textTheme.labelSmall
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (restaurant.rating >= 4.8)
                                        Positioned(
                                          bottom: 10,
                                          left: 10,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: colorScheme
                                                  .secondaryContainer,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              'POPULAR',
                                              style: textTheme.labelSmall
                                                  ?.copyWith(
                                                    color: colorScheme
                                                        .onSecondaryContainer,
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: 0.9,
                                                  ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(
                                      AppSpacing.sm,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          restaurant.name,
                                          style: textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        const Gap(6),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                restaurant.cuisineType,
                                                style: textTheme.bodySmall
                                                    ?.copyWith(
                                                      color: colorScheme
                                                          .onSurfaceVariant,
                                                    ),
                                              ),
                                            ),
                                            Text(
                                              restaurant.deliveryFee == 0
                                                  ? 'Free Delivery'
                                                  : '\$${restaurant.deliveryFee.toStringAsFixed(2)} Delivery',
                                              style: textTheme.labelSmall
                                                  ?.copyWith(
                                                    color: colorScheme.outline,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        const Gap(8),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.schedule,
                                              size: 14,
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                            const Gap(4),
                                            Text(
                                              '${restaurant.deliveryTimeMinutes} min',
                                              style: textTheme.labelSmall
                                                  ?.copyWith(
                                                    color: colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                            ),
                                            const Gap(10),
                                            Container(
                                              width: 4,
                                              height: 4,
                                              decoration: BoxDecoration(
                                                color:
                                                    colorScheme.outlineVariant,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const Gap(10),
                                            Icon(
                                              restaurant.deliveryFee == 0
                                                  ? Icons.delivery_dining
                                                  : Icons.local_fire_department,
                                              size: 14,
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                            const Gap(4),
                                            Text(
                                              restaurant.deliveryFee == 0
                                                  ? '\$0.00 fee'
                                                  : 'Hot Delivery',
                                              style: textTheme.labelSmall
                                                  ?.copyWith(
                                                    color: colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(growable: false),
                );
              },
              loading: () => const Column(
                children: [
                  LoadingCardShimmer(),
                  Gap(AppSpacing.sm),
                  LoadingCardShimmer(),
                ],
              ),
              error: (error, stack) =>
                  Text('Failed to load restaurants: $error'),
            ),
          ],
        ),
      ),
    );
  }
}
