import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/constants/app_colors.dart';
import 'package:mobile/core/constants/app_radius.dart';
import 'package:mobile/core/constants/app_spacing.dart';
import 'package:mobile/core/widgets/state_widgets.dart';
import 'package:mobile/providers/browse_providers.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(orderHistoryProvider);

    return Scaffold(
      appBar: AppBar(centerTitle: false, title: const Text('My Orders')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: ordersAsync.when(
          data: (orders) {
            if (orders.isEmpty) {
              return AppEmptyState(
                message: 'No orders yet. Place your first order now.',
                actionLabel: 'Browse Restaurants',
                icon: Icons.receipt_long_outlined,
                onAction: () => context.go('/home'),
              );
            }
            return ListView.separated(
              itemCount: orders.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final order = orders[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    title: Text('Order #${order.id}', style: Theme.of(context).textTheme.titleMedium),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${order.createdAt.toLocal().toString().split(' ').first} • ${order.items.length} items',
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('\$${order.totalAmount.toStringAsFixed(2)}'),
                        const Gap(4),
                        _StatusBadge(status: order.status),
                      ],
                    ),
                    onTap: () => context.push('/order-tracking/${order.id}'),
                  ),
                );
              },
            );
          },
          loading: () => const AppListShimmer(),
          error: (error, stack) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) {
                return;
              }
              showErrorSnackBar(
                context: context,
                message: 'Failed to load orders.',
                onRetry: () => ref.invalidate(orderHistoryProvider),
              );
            });
            return AppEmptyState(
              message: 'Unable to load your orders.',
              actionLabel: 'Retry',
              onAction: () => ref.invalidate(orderHistoryProvider),
              icon: Icons.error_outline,
            );
          },
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final normalized = status.toLowerCase();
    Color background;
    Color foreground;

    if (normalized == 'delivered') {
      background = colorScheme.primaryContainer.withValues(alpha: 0.18);
      foreground = AppColors.success;
    } else if (normalized == 'on_the_way') {
      background = colorScheme.secondaryContainer.withValues(alpha: 0.3);
      foreground = AppColors.accentOrange;
    } else {
      background = colorScheme.errorContainer.withValues(alpha: 0.65);
      foreground = colorScheme.error;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _labelForStatus(normalized),
        style: TextStyle(color: foreground, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }

  String _labelForStatus(String normalized) {
    if (normalized == 'on_the_way') {
      return 'On the Way';
    }
    if (normalized == 'delivered') {
      return 'Delivered';
    }
    return 'In Progress';
  }
}
