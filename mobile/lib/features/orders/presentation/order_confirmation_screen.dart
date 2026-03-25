import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/constants/app_colors.dart';
import 'package:mobile/core/constants/app_spacing.dart';
import 'package:mobile/core/widgets/app_bar_system.dart';
import 'package:mobile/providers/browse_providers.dart';

class OrderConfirmationScreen extends ConsumerWidget {
  const OrderConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(latestOrderProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (order == null) {
      return Scaffold(
        appBar: QuickBiteAppBars.checkout(
          title: 'Checkout',
          stepLabel: 'STEP 3 OF 3: CONFIRMED',
          progress: 1,
          onClose: () => context.go('/home'),
        ),
        body: const Center(child: Text('No recent order found.')),
      );
    }

    return Scaffold(
      appBar: QuickBiteAppBars.checkout(
        title: 'Checkout',
        stepLabel: 'STEP 3 OF 3: CONFIRMED',
        progress: 1,
        onClose: () => context.go('/home'),
      ),
      body: Center(
        child: Stack(
          children: [
            Positioned(
              top: -120,
              right: -120,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -120,
              left: -120,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.lg,
              ),
              children: [
                const Gap(12),
                Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 128,
                        height: 128,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.success.withValues(alpha: 0.3),
                              blurRadius: 36,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.check,
                          color: colorScheme.onPrimary,
                          size: 64,
                        ),
                      ),
                      Positioned(
                        top: -8,
                        right: -8,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(28),
                Text(
                  'Order Placed!',
                  textAlign: TextAlign.center,
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Gap(6),
                Text(
                  'Your food is being prepared',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const Gap(16),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      'ORDER ID: #QB-${order.id.toString().padLeft(5, '0')}',
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                const Gap(24),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest.withValues(
                      alpha: 0.88,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.onSurface.withValues(alpha: 0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer.withValues(
                            alpha: 0.12,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.schedule,
                          color: colorScheme.secondary,
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Estimated Arrival',
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.secondary,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const Gap(2),
                            Text(
                              '${order.estimatedDeliveryMinutes - 5} - ${order.estimatedDeliveryMinutes + 5} mins',
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.restaurant, color: colorScheme.outline),
                    ],
                  ),
                ),
                const Gap(28),
                FilledButton.icon(
                  onPressed: () => context.go('/order-tracking/${order.id}'),
                  icon: const Icon(Icons.near_me),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  label: const Text('Track Order'),
                ),
                const Gap(AppSpacing.sm),
                OutlinedButton(
                  onPressed: () => context.go('/home'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Back to Home'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
