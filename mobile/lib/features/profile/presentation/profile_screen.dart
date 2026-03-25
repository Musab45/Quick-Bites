import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/providers/auth_providers.dart';
import 'package:mobile/providers/browse_providers.dart';
import 'package:mobile/core/constants/app_radius.dart';
import 'package:mobile/core/constants/app_spacing.dart';
import 'package:mobile/core/widgets/app_bar_system.dart';
import 'package:mobile/core/widgets/state_widgets.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final auth = ref.watch(authNotifierProvider);
    final ordersAsync = ref.watch(orderHistoryProvider);
    final fullName = auth.user?.fullName ?? 'Guest';
    final email = auth.user?.email ?? '-';
    final initials = fullName
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    return Scaffold(
      appBar: QuickBiteAppBars.profile(
        title: 'My Profile',
        onSettings: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Settings panel is coming soon.')),
          );
        },
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.lg,
        ),
        children: [
          Column(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.primaryContainer,
                    width: 4,
                  ),
                  color: colorScheme.surfaceContainerLowest,
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        initials.isEmpty ? 'U' : initials,
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.photo_camera,
                          size: 14,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                fullName,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile editing is coming soon.')),
                  );
                },
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'EDIT PROFILE',
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadius.card),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.onSurface.withValues(alpha: 0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ProfileStat(
                    value: ordersAsync.maybeWhen(
                      data: (orders) => orders.length.toString(),
                      orElse: () => '-',
                    ),
                    label: 'Orders',
                  ),
                ),
                const SizedBox(height: 34, child: VerticalDivider()),
                const Expanded(
                  child: _ProfileStat(value: '12', label: 'Saved Restaurants'),
                ),
                const SizedBox(height: 34, child: VerticalDivider()),
                const Expanded(
                  child: _ProfileStat(value: '4', label: 'Reviews'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('My Orders', style: Theme.of(context).textTheme.titleMedium),
              TextButton(
                onPressed: () => context.go('/orders'),
                child: const Text('View All'),
              ),
            ],
          ),
          ordersAsync.when(
            data: (orders) {
              if (orders.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                  ),
                  child: AppEmptyState(
                    message: 'No orders yet.',
                    actionLabel: 'Browse Restaurants',
                    icon: Icons.receipt_long_outlined,
                    onAction: () => context.go('/home'),
                  ),
                );
              }

              final preview = orders.take(4).toList(growable: false);
              return SizedBox(
                height: 152,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: preview.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final order = preview[index];
                    return _OrderCard(order: order);
                  },
                ),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: SizedBox(height: 152, child: AppListShimmer(itemCount: 2)),
            ),
            error: (error, stack) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!context.mounted) {
                  return;
                }
                showErrorSnackBar(
                  context: context,
                  message: 'Unable to load order history.',
                  onRetry: () => ref.invalidate(orderHistoryProvider),
                );
              });
              return AppEmptyState(
                message: 'Unable to load order history.',
                actionLabel: 'Retry',
                icon: Icons.error_outline,
                onAction: () => ref.invalidate(orderHistoryProvider),
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('Settings', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadius.card),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.onSurface.withValues(alpha: 0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                ListTile(
                  leading: _SettingIcon(icon: Icons.location_on),
                  title: const Text('My Addresses'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: _SettingIcon(icon: Icons.payments),
                  title: const Text('Payment Methods'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: _SettingIcon(icon: Icons.notifications),
                  title: const Text('Notifications'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: _SettingIcon(
                    icon: Icons.logout,
                    isDestructive: true,
                  ),
                  title: Text(
                    'Logout',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    await ref.read(authNotifierProvider.notifier).logout();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 11),
        ),
      ],
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final dynamic order;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () => context.push('/order-tracking/${order.id}'),
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.22),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface.withValues(alpha: 0.05),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.fastfood, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Restaurant #${order.restaurantId}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${order.items.length} Items • \$${order.totalAmount.toStringAsFixed(2)}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                _ProfileOrderStatus(status: order.status),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.createdAt.toLocal().toString().split(' ').first,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Text(
                  order.status.toLowerCase() == 'on_the_way'
                      ? 'Track'
                      : 'Reorder',
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingIcon extends StatelessWidget {
  const _SettingIcon({required this.icon, this.isDestructive = false});

  final IconData icon;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isDestructive
            ? colorScheme.errorContainer.withValues(alpha: 0.3)
            : colorScheme.primary.withValues(alpha: 0.08),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 18,
        color: isDestructive ? colorScheme.error : colorScheme.primary,
      ),
    );
  }
}

class _ProfileOrderStatus extends StatelessWidget {
  const _ProfileOrderStatus({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final normalized = status.toLowerCase();
    Color background;
    Color foreground;
    String label;

    if (normalized == 'delivered') {
      background = colorScheme.primaryContainer.withValues(alpha: 0.18);
      foreground = colorScheme.primary;
      label = 'Delivered';
    } else if (normalized == 'on_the_way') {
      background = colorScheme.secondaryContainer.withValues(alpha: 0.35);
      foreground = colorScheme.onSecondaryContainer;
      label = 'In Transit';
    } else if (normalized == 'cancelled') {
      background = colorScheme.errorContainer.withValues(alpha: 0.65);
      foreground = colorScheme.error;
      label = 'Cancelled';
    } else {
      background = colorScheme.primaryContainer.withValues(alpha: 0.22);
      foreground = colorScheme.primary;
      label = 'Preparing';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
