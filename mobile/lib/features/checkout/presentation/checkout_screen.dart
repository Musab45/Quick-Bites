import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/providers/auth_providers.dart';
import 'package:mobile/core/constants/app_radius.dart';
import 'package:mobile/core/constants/app_spacing.dart';
import 'package:mobile/providers/browse_providers.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _addressController = TextEditingController(text: '123 Test Street');
  String _paymentMethod = 'card';
  bool _isSubmitting = false;

  String get _paymentMethodForApi {
    return _paymentMethod == 'wallet' ? 'card' : _paymentMethod;
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submitOrder() async {
    final cart = ref.read(cartProvider);
    final token = ref.read(authTokenProvider);
    if (cart.restaurantId == null || cart.lines.isEmpty) {
      return;
    }
    if (token == null || token.isEmpty) {
      if (mounted) {
        context.go('/login?from=/checkout');
      }
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final itemsPayload = cart.lines.values
          .map(
            (line) => {'menu_item_id': line.item.id, 'quantity': line.quantity},
          )
          .toList(growable: false);

      final order = await ref
          .read(orderRepositoryProvider)
          .createOrder(
            token: token,
            restaurantId: cart.restaurantId!,
            address: _addressController.text.trim(),
            paymentMethod: _paymentMethodForApi,
            items: itemsPayload,
          );

      ref.read(latestOrderProvider.notifier).state = order;
      ref.read(cartProvider.notifier).clear();

      if (mounted) {
        context.go('/order-confirmation');
      }
    } catch (error) {
      final message = '$error';
      if (message.contains('401')) {
        await ref.read(authNotifierProvider.notifier).expireSession();
        if (mounted) {
          context.go('/login?from=/checkout');
        }
        return;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not place order. $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final cart = ref.watch(cartProvider);
    final subtotal = cart.totalAmount;
    final lines = cart.lines.values.toList(growable: false);
    final deliveryFee = 2.0;
    final serviceFee = 1.5;
    final total = subtotal + deliveryFee + serviceFee;

    return Scaffold(
      appBar: AppBar(centerTitle: false, title: const Text('Checkout')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.sm,
          140,
        ),
        children: [
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                    const Gap(6),
                    Text(
                      'DELIVER TO',
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.9,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    TextButton(onPressed: () {}, child: const Text('Change')),
                  ],
                ),
                const Gap(8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Home — Orchard Towers',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Gap(4),
                      TextField(
                        controller: _addressController,
                        style: textTheme.bodySmall,
                        decoration: InputDecoration(
                          hintText: 'Enter delivery address',
                          hintStyle: textTheme.bodySmall?.copyWith(
                            color: colorScheme.outline,
                          ),
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Gap(AppSpacing.sm),
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PAYMENT METHOD',
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.9,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const Gap(10),
                Row(
                  children: [
                    Expanded(
                      child: _PaymentOption(
                        icon: Icons.credit_card,
                        title: '**** 8842',
                        selected: _paymentMethod == 'card',
                        onTap: () => setState(() => _paymentMethod = 'card'),
                      ),
                    ),
                    const Gap(8),
                    Expanded(
                      child: _PaymentOption(
                        icon: Icons.account_balance_wallet,
                        title: 'Wallet',
                        selected: _paymentMethod == 'wallet',
                        onTap: () => setState(() => _paymentMethod = 'wallet'),
                      ),
                    ),
                    const Gap(8),
                    Expanded(
                      child: _PaymentOption(
                        icon: Icons.payments,
                        title: 'Cash',
                        selected: _paymentMethod == 'cash',
                        onTap: () => setState(() => _paymentMethod = 'cash'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Gap(AppSpacing.sm),
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ORDER SUMMARY',
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.9,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const Gap(10),
                ...lines.map(
                  (line) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${line.quantity}x ${line.item.name}',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Text(
                          '\$${(line.item.price * line.quantity).toStringAsFixed(2)}',
                          style: textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _SummaryRow(label: 'Subtotal', amount: subtotal),
                _SummaryRow(label: 'Delivery Fee', amount: deliveryFee),
                _SummaryRow(label: 'Service Fee', amount: serviceFee),
                const Divider(height: 20),
                _SummaryRow(label: 'Total', amount: total, isBold: true),
              ],
            ),
          ),
          const Gap(AppSpacing.sm),
          _SectionCard(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer.withValues(
                      alpha: 0.2,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.schedule, color: colorScheme.secondary),
                ),
                const Gap(10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ESTIMATED TIME',
                        style: textTheme.labelSmall?.copyWith(
                          letterSpacing: 0.9,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        '30–45 min',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: colorScheme.outline),
              ],
            ),
          ),
          const Gap(90),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: FilledButton.icon(
              onPressed: _isSubmitting ? null : _submitOrder,
              icon: const Icon(Icons.arrow_forward),
              iconAlignment: IconAlignment.end,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              label: Text(
                _isSubmitting
                    ? 'Placing Order...'
                    : 'Place Order — \$${total.toStringAsFixed(2)}',
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.button),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.button),
          border: Border.all(
            width: selected ? 2 : 1,
            color: selected
                ? colorScheme.primary
                : colorScheme.outlineVariant.withValues(alpha: 0),
          ),
          color: selected
              ? colorScheme.surfaceContainerLowest
              : colorScheme.surfaceContainerLow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected
                  ? colorScheme.onSurface
                  : colorScheme.onSurfaceVariant,
            ),
            const Gap(6),
            Flexible(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? colorScheme.onSurface
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            if (selected) ...[
              const Gap(4),
              Icon(Icons.check_circle, color: colorScheme.primary, size: 16),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.amount,
    this.isBold = false,
  });

  final String label;
  final double amount;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final style = isBold
        ? Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: colorScheme.primary,
          )
        : Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text('\$${amount.toStringAsFixed(2)}', style: style),
        ],
      ),
    );
  }
}
