import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/constants/app_spacing.dart';
import 'package:mobile/core/widgets/app_bar_system.dart';
import 'package:mobile/core/widgets/state_widgets.dart';
import 'package:mobile/providers/browse_providers.dart';

class OrderTrackingScreen extends ConsumerWidget {
  const OrderTrackingScreen({required this.orderId, super.key});

  final int orderId;

  static const statuses = <String>[
    'pending',
    'preparing',
    'on_the_way',
    'delivered',
  ];

  static const statusLabels = <String>[
    'Order Placed',
    'Preparing',
    'On the Way',
    'Delivered',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final orderAsync = ref.watch(orderTrackingProvider(orderId));

    return Scaffold(
      appBar: QuickBiteAppBars.contextual(
        title: 'Track Order',
        subtitle: 'LIVE STATUS',
        onBack: () => context.go('/orders'),
        trailing: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Center(
            child: Text(
              'QuickBite',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
      body: orderAsync.when(
        data: (order) {
          final currentIndex = _indexForStatus(order.status);
          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm,
                  AppSpacing.sm,
                  AppSpacing.sm,
                  110,
                ),
                children: [
                  Container(
                    height: 220,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuDTp90NJgx44UCArpdj5ayAiOPcidIaJIEeblKP8ap_QW7BZFDKnxhIvv2KC70xfzNcB-d_dkzatlhqzhWbDZuDxn9mPfIUOgYz9FLeCS6NMEfDTVzQHkBdgt4ahVpPg14MZrIS2H1mMN4mhFHEGQK9wImUchwZg-MjT4xtSgncNp_gxIEd1H3v725LFEY_pn7s_AprukZ4xZcxW4YOgOu_RV0JDoKToJZgeVlNNBwg_OXVF-Ih9mkF1SE1MPo6dKqzM-pxJs9RjQ',
                            width: double.infinity,
                            height: 220,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: colorScheme.surfaceContainerHigh,
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.map,
                                    color: colorScheme.outline,
                                    size: 56,
                                  ),
                                ),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerLowest
                                  .withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const Gap(6),
                                Text(
                                  'LIVE TRACKING',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(AppSpacing.md),
                  Text(
                    'Order Timeline',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap(AppSpacing.sm),
                  ...List.generate(statuses.length, (index) {
                    final isCompleted = index <= currentIndex;
                    final isActive = index == currentIndex;
                    final isLast = index == statuses.length - 1;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 24,
                            child: Column(
                              children: [
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: isCompleted
                                        ? colorScheme.primary
                                        : colorScheme.surfaceContainerHigh,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _iconForStep(index),
                                    size: 14,
                                    color: isCompleted
                                        ? colorScheme.onPrimary
                                        : colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                if (!isLast)
                                  Container(
                                    width: 2,
                                    height: 48,
                                    color: index < currentIndex
                                        ? colorScheme.primary
                                        : colorScheme.outlineVariant,
                                  ),
                              ],
                            ),
                          ),
                          const Gap(10),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 1),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          statusLabels[index],
                                          style: textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: isActive
                                                ? colorScheme.primary
                                                : colorScheme.onSurface,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        isActive
                                            ? 'Live'
                                            : _timestampForStep(
                                                order.createdAt,
                                                index,
                                              ),
                                        style: textTheme.bodySmall?.copyWith(
                                          color: isActive
                                              ? colorScheme.primary
                                              : colorScheme.onSurfaceVariant,
                                          fontWeight: isActive
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Gap(2),
                                  Text(
                                    _descriptionForStep(index),
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      fontWeight: isActive
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const Gap(AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
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
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: colorScheme.surfaceContainerLow,
                              ),
                              child: const Icon(Icons.person, size: 30),
                            ),
                            Positioned(
                              right: -4,
                              bottom: -4,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: colorScheme.secondaryContainer,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: colorScheme.surfaceContainerLowest,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.star,
                                  size: 12,
                                  color: colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Gap(12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your Courier',
                                style: textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  letterSpacing: 0.8,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Gap(2),
                              Text(
                                'Marcus Rodriguez',
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Gold Tier • 1.2k Deliveries',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _ActionIcon(icon: Icons.chat),
                        const Gap(8),
                        _ActionIcon(icon: Icons.call, isPrimary: true),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                left: AppSpacing.sm,
                right: AppSpacing.sm,
                bottom: AppSpacing.sm,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.secondary.withValues(alpha: 0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colorScheme.onSecondaryContainer.withValues(
                            alpha: 0.2,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.schedule,
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ),
                      const Gap(10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ESTIMATED ARRIVAL',
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSecondaryContainer
                                    .withValues(alpha: 0.8),
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Arriving in ${order.estimatedDeliveryMinutes} minutes',
                              style: textTheme.titleSmall?.copyWith(
                                color: colorScheme.onSecondaryContainer,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Courier details are coming soon.',
                              ),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: colorScheme.onSecondaryContainer,
                          backgroundColor: colorScheme.onSecondaryContainer
                              .withValues(alpha: 0.12),
                        ),
                        child: const Text('Details'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSpacing.sm),
          child: AppListShimmer(itemCount: 2),
        ),
        error: (error, stack) => AppEmptyState(
          message: 'Unable to track this order right now.',
          icon: Icons.error_outline,
          actionLabel: 'Retry',
          onAction: () => ref.invalidate(orderTrackingProvider(orderId)),
        ),
      ),
    );
  }

  int _indexForStatus(String status) {
    if (status == 'confirmed') {
      return 0;
    }
    final index = statuses.indexOf(status);
    return index == -1 ? 0 : index;
  }

  String _timestampForStep(DateTime base, int step) {
    final offsets = [0, 8, 18, 35];
    final date = base.add(Duration(minutes: offsets[step]));
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _descriptionForStep(int step) {
    switch (step) {
      case 0:
        return 'We have received your order';
      case 1:
        return 'The kitchen is working its magic';
      case 2:
        return 'Driver is on the way to your location';
      case 3:
        return 'Safe delivery to your doorstep';
      default:
        return '';
    }
  }

  IconData _iconForStep(int step) {
    switch (step) {
      case 0:
        return Icons.check;
      case 1:
        return Icons.restaurant;
      case 2:
        return Icons.delivery_dining;
      case 3:
        return Icons.home;
      default:
        return Icons.radio_button_unchecked;
    }
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({required this.icon, this.isPrimary = false});

  final IconData icon;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isPrimary
            ? colorScheme.primary
            : colorScheme.surfaceContainerLow,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 20,
        color: isPrimary ? colorScheme.onPrimary : colorScheme.primary,
      ),
    );
  }
}
