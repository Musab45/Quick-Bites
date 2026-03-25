import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/constants/app_colors.dart';
import 'package:mobile/core/constants/app_radius.dart';
import 'package:mobile/core/constants/app_spacing.dart';
import 'package:mobile/core/widgets/app_bar_system.dart';
import 'package:mobile/providers/browse_providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  static const _recentSearches = ['Artisan Pizza', 'Vegan Bowls', 'Thai Tea'];
  static const _quickFilters = [
    ('Fastest', Icons.electric_bolt),
    ('Budget', Icons.payments),
    ('Top Rated', Icons.verified),
    ('Eco-friendly', Icons.eco),
  ];

  final _queryController = TextEditingController();

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature is coming soon.')),
    );
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = ref.watch(cartCountProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: QuickBiteAppBars.home(
        locationLabel: 'San Francisco',
        cartCount: cartCount,
        onCartTap: () => context.push('/cart'),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.xs,
            ),
            color: colorScheme.surface,
            child: TextField(
              controller: _queryController,
              decoration: InputDecoration(
                hintText: 'Search for sushi, burgers, or pizza...',
                prefixIcon: Icon(Icons.search, color: colorScheme.outline),
                suffixIcon: IconButton(
                  onPressed: () => _showComingSoon('Voice search'),
                  icon: Icon(Icons.mic_none, color: colorScheme.outline),
                ),
                fillColor: colorScheme.surfaceContainerLowest,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.sm,
              0,
            ),
            child: Text(
              'RECENT SEARCHES',
              style: textTheme.labelSmall?.copyWith(
                letterSpacing: 1.1,
                color: colorScheme.outline,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm,
              AppSpacing.xs,
              AppSpacing.sm,
              0,
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _recentSearches
                  .map(
                    (entry) => Chip(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.chip),
                      ),
                      side: BorderSide.none,
                      backgroundColor: colorScheme.surfaceContainerLowest,
                      avatar: Icon(
                        Icons.history,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      label: Text(
                        entry,
                        style: textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.xs,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Popular Categories',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Curated selections for your cravings',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => _showComingSoon('Category explorer'),
                  child: const Text('See All'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: SizedBox(
              height: 360,
              child: Row(
                children: [
                  Expanded(
                    child: _CategoryTile(
                      imageUrl:
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuDJlMObRapGj9UnuU7iNIkVkcIG3OIpOoUk_MHrN2dzrFDlzz4qaZPb8oYns_FF1D5Onk-q1Z-vx8JEk1-8VtNwcFcjRZW387o9h3_KquCe-TmVwLcYYLxsmqyZPxp7sgzLKgwyqIkeNQ5Wgw2EBk4ruomot30al1SoOocc8IGV2ie175AufGXeBlChX_jEGJ71s_xxKGnCkdyvHA-vJYCBpmvDEASLHGdkjIPW5Yp7K067HOhPqsW-TM5Z8je70SE5L9x3xMP_pQ',
                      title: 'Italian Classics',
                      subtitle: '240+ Restaurants',
                      badge: 'Trending',
                      large: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      children: const [
                        Expanded(
                          child: _CategoryTile(
                            imageUrl:
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuBe-VYx7q6iKqv6z16V9xjOBJ0iv1NyfhOs7e4u56zvpiUF7QNEX1GQl7a7ckrvT9nJpygioGtpG1vanWz_PbmkcOspinZrKehd_1QxqarYcYrNj0TMvNBdvUcHQOSDZ3TT41xSiyzV3ufp3gqN2pmVroP1uV9aP4Tih5h6nzvwBUJU3bglPsQCCPbv1nxMoXpG_bdnoyoh-6GQ94ItOs5Jtk8lt2CjU3pb96AboHGkrxBz3ThtYfyMo2le80HANczlrt12W4SpIg',
                            title: 'Healthy',
                          ),
                        ),
                        SizedBox(height: 12),
                        Expanded(
                          child: _CategoryTile(
                            imageUrl:
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuCON_IPPXjxqbCiYNhPWBzj9Nb71zjaGMD6OjHMdlMBt1TSZqPByxn-ATDAI2tKCjPBKzBdkqYRjaPzb6LhKMlgXblVnt9lb0P283eDe-3Qxp41TzjV42ObqtzVOjr-zLHFbCOrIYg6RGHxteTFoe51DbuMWsEAmzhZIVu-ndByiIHewNNCiyCxjhVKmz_pdzdxf60S6t4DExg67CpaMm3MewrDkKDe8zfSVPMnCNI8WOk9IX_jDJUhgysKJs9S1jSPgCEmF8VgmQ',
                            title: 'Sushi',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: SizedBox(
              height: 156,
              child: _CategoryTile(
                imageUrl:
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuAVGoSdAN05EJrzvuUa4EpdKyBR1-M0K4OUTCW7p3hWkgRdWBL-Id0EzGPobJ7vmGjuqB_DKM_EYIundHfEVL1hZkp5_wcPHMJuv8LVpfmyq-Ql1PVkF7XNFGaPO-VlCTw17JL1otoJ3bDFPDmAgeJAhBOKcNGDWb9MfoTNnj7INstiaNfG2KneCAQ67M2zcN7u__3qlmAkp_Md9dJfp0ar6vggzDwUwjpbkJPqqSa4D2sdw9NjFWib1plSfb3l_Z_j-VGMZS0h_A',
                title: 'Gourmet Burgers',
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            color: colorScheme.surfaceContainerLow,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Trending Now',
                              style: textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'Most ordered in your area today',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  height: 264,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                    ),
                    children: const [
                      _TrendingCard(
                        imageUrl:
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuDQuDUNVMRwt8zmVqFO1tBWBVegM0m3XXJD2CwpsEGWE1Z3I45rtPWhmIRsZH6tHxt0kUYIyXwMqCyg3K1BWFYBfz5lbv21cumfeW4m9iDMeGAvHWzVaEWZ39x59E308P4dcBTMBI0ZQNLdez-N-pDIkBOQtCf5kw0071wv9sJf12JI679OrHbZgoMboRDH7ddBKWCfBjvRIqBAOcjNvscmVQo6Us-Yd5ao9HlGTKM1qPe9UFjn9p1Yg_7eNt100myE_f9IKBFrFA',
                        title: 'The Golden Fork',
                        subtitle: 'French • Bistro',
                        eta: '25-35 min',
                        rating: '4.8',
                        deliveryText: 'Free Delivery',
                        freeDelivery: true,
                      ),
                      SizedBox(width: 12),
                      _TrendingCard(
                        imageUrl:
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuBr7HPFO9dS8Zfj1Fme9sitOFDiDtbNBDw5-ujnqomH9JVYCx37GC6e38t_Cf1V05qH5_fUdAHKrLobFlpmkgjiCL7LDz8adtsI5heNukhvMsMPuz0homEz7Ke5J8-eKsIXY79MiycTaILPDKwOPUC_6R8aFI7In5KZJWLmDTm_3u-xrK9N9KL7JCivnRc9OmN5xOcU--WwWdweDiYNxxqUZ605KBcVL8F3K5C0qOwV78ll6-ib0TaxN_pcUjjRidkPe9l32o4Lqg',
                        title: 'Neon Ramen',
                        subtitle: 'Japanese • Soul Food',
                        eta: '15-20 min',
                        rating: '4.9',
                        deliveryText: '\$2.99 Delivery',
                        freeDelivery: false,
                      ),
                      SizedBox(width: 12),
                      _TrendingCard(
                        imageUrl:
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuDNaluuLJtmCVp4a-aN3b78Y3SR8wPExzpULl9gNQgbKFbkdLSvQmykagOA4ZtowoYWiCl8mGTfyqwEyUGHVPvGfVeEVn-sAmAw8Bqc9IFWzH-onxXdHEJqWg0c_DODdMUAlhRUEAeEQ2DV66Qo6pIO9xrEjgYzoF6GmTGtTzjE1iZPJzNGxsza7DdD9zDzv3r_-8tUXZvAEEib3clOzCCx0nhjlVfsWGf51LPQSDNKKFZnj3nbUJOd7yU2YG5CFa0RQL9G3UTwzw',
                        title: 'Green Garden',
                        subtitle: 'Vegan • Organic',
                        eta: '20-30 min',
                        rating: '4.6',
                        deliveryText: 'Free Delivery',
                        freeDelivery: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.sm,
            ),
            child: Text(
              'QUICK FILTERS',
              style: textTheme.labelSmall?.copyWith(
                letterSpacing: 1.1,
                color: colorScheme.outline,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _quickFilters.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.8,
              ),
              itemBuilder: (context, index) {
                final filter = _quickFilters[index];
                return Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        filter.$2,
                        color: colorScheme.onSurfaceVariant,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        filter.$1,
                        style: textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.imageUrl,
    required this.title,
    this.subtitle,
    this.badge,
    this.large = false,
  });

  final String imageUrl;
  final String title;
  final String? subtitle;
  final String? badge;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: colorScheme.surfaceContainerHigh,
              alignment: Alignment.center,
              child: Icon(Icons.fastfood, color: colorScheme.outline),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colorScheme.surface.withValues(alpha: 0),
                  AppColors.darkText.withValues(alpha: 0.72),
                ],
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (badge != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      badge!.toUpperCase(),
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                Text(
                  title,
                  style:
                      (large ? textTheme.headlineSmall : textTheme.titleMedium)
                          ?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimary.withValues(alpha: 0.8),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendingCard extends StatelessWidget {
  const _TrendingCard({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.eta,
    required this.rating,
    required this.deliveryText,
    required this.freeDelivery,
  });

  final String imageUrl;
  final String title;
  final String subtitle;
  final String eta;
  final String rating;
  final String deliveryText;
  final bool freeDelivery;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: 272,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Stack(
              children: [
                Image.network(
                  imageUrl,
                  width: 272,
                  height: 140,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 272,
                    height: 140,
                    color: colorScheme.surfaceContainerHigh,
                    alignment: Alignment.center,
                    child: Icon(Icons.storefront, color: colorScheme.outline),
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
                      color: colorScheme.surfaceContainerLowest.withValues(
                        alpha: 0.9,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 14,
                          color: colorScheme.secondary,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          rating,
                          style: textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$subtitle • $eta',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        deliveryText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelMedium?.copyWith(
                          color: freeDelivery
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                          fontWeight: freeDelivery
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
