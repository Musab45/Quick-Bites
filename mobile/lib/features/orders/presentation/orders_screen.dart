import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/constants/app_radius.dart';
import 'package:mobile/core/constants/app_spacing.dart';
import 'package:mobile/core/widgets/app_bar_system.dart';
import 'package:mobile/core/widgets/state_widgets.dart';
import 'package:mobile/data/models/order.dart';
import 'package:mobile/providers/browse_providers.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedTab = 0;
  String _query = '';

  void _openFilterActions() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.bolt_rounded),
                title: const Text('Show Active Orders'),
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() => _selectedTab = 0);
                },
              ),
              ListTile(
                leading: const Icon(Icons.history_rounded),
                title: const Text('Show Past Orders'),
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() => _selectedTab = 1);
                },
              ),
              ListTile(
                leading: const Icon(Icons.clear_rounded),
                title: const Text('Clear Search Query'),
                onTap: () {
                  Navigator.of(context).pop();
                  _searchController.clear();
                  setState(() => _query = '');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(orderHistoryProvider);
    final cartCount = ref.watch(cartCountProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: QuickBiteAppBars.home(
        locationLabel: 'San Francisco',
        cartCount: cartCount,
        onCartTap: () => context.push('/cart'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm,
            AppSpacing.xs,
            AppSpacing.sm,
            AppSpacing.sm,
          ),
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

              final activeOrders = orders
                  .where((order) => !_isPastOrder(order.status))
                  .toList(growable: false);
              final pastOrders = orders
                  .where((order) => _isPastOrder(order.status))
                  .toList(growable: false);
              final selected = _selectedTab == 0 ? activeOrders : pastOrders;
              final filtered = _filterOrders(selected, _query);

              return Column(
                children: [
                  _SegmentedTabs(
                    selectedTab: _selectedTab,
                    onTabChanged: (value) =>
                        setState(() => _selectedTab = value),
                  ),
                  const Gap(AppSpacing.xs),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              setState(
                                () => _query = value.trim().toLowerCase(),
                              );
                            },
                            style: Theme.of(context).textTheme.bodyMedium,
                            decoration: InputDecoration(
                              hintText: 'Search orders...',
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                size: 20,
                              ),
                              border: InputBorder.none,
                              hintStyle: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                              contentPadding: const EdgeInsets.only(top: 10),
                            ),
                          ),
                        ),
                      ),
                      const Gap(10),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: _openFilterActions,
                          icon: Icon(
                            Icons.tune_rounded,
                            color: colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(AppSpacing.sm),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Text(
                              _selectedTab == 0
                                  ? 'No active orders match your search.'
                                  : 'No past orders match your search.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => const Gap(12),
                            itemBuilder: (context, index) {
                              final order = filtered[index];
                              return _OrderCard(
                                order: order,
                                isPast: _isPastOrder(order.status),
                              );
                            },
                          ),
                  ),
                ],
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
      ),
    );
  }

  List<OrderModel> _filterOrders(List<OrderModel> orders, String query) {
    if (query.isEmpty) {
      return orders;
    }

    return orders
        .where((order) {
          final itemSummary = order.items
              .map((item) => item.name.toLowerCase())
              .join(' ');
          final haystack = [
            'order #${order.id}',
            'restaurant #${order.restaurantId}',
            _statusLabel(order.status).toLowerCase(),
            itemSummary,
          ].join(' ');
          return haystack.contains(query);
        })
        .toList(growable: false);
  }

  bool _isPastOrder(String status) {
    final normalized = status.toLowerCase();
    return normalized == 'delivered' || normalized == 'cancelled';
  }
}

class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({required this.selectedTab, required this.onTabChanged});

  final int selectedTab;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _TabButton(
            label: 'Active',
            selected: selectedTab == 0,
            onTap: () => onTabChanged(0),
          ),
          _TabButton(
            label: 'Past',
            selected: selectedTab == 1,
            onTap: () => onTabChanged(1),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 44,
          decoration: BoxDecoration(
            color: selected ? colorScheme.surfaceContainerLowest : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? colorScheme.secondary : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.isPast});

  final OrderModel order;
  final bool isPast;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final itemSummary = order.items
        .take(2)
        .map((item) => '${item.quantity}x ${item.name}')
        .join(', ');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.restaurant_rounded,
                  color: colorScheme.secondary,
                  size: 20,
                ),
              ),
              const Gap(10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Restaurant #${order.restaurantId}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Order #${order.id}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: order.status),
            ],
          ),
          const Gap(10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  isPast ? Icons.check_circle_rounded : Icons.schedule_rounded,
                  size: 15,
                  color: colorScheme.secondary,
                ),
                const Gap(6),
                Expanded(
                  child: Text(
                    isPast
                        ? _formatShortDate(order.createdAt)
                        : 'ETA ${_formatEta(order)}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.secondary,
                    ),
                  ),
                ),
                Text(
                  '\$${order.totalAmount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
          const Gap(8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              itemSummary.isNotEmpty
                  ? itemSummary
                  : '${order.items.length} items',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const Gap(12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: isPast
                      ? OutlinedButton(
                          onPressed: () => context.go('/home'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: colorScheme.secondary.withValues(alpha: 0.25),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Reorder',
                            style: TextStyle(color: colorScheme.secondary),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: () =>
                              context.push('/order-tracking/${order.id}'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: colorScheme.onSecondary,
                            backgroundColor: colorScheme.secondary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Track Order',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                ),
              ),
              const Gap(8),
              TextButton(
                onPressed: () => context.push('/order-tracking/${order.id}'),
                child: const Text('Details'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatEta(OrderModel order) {
    final eta = order.createdAt.add(
      Duration(minutes: order.estimatedDeliveryMinutes),
    );
    final hour = eta.hour == 0
        ? 12
        : (eta.hour > 12 ? eta.hour - 12 : eta.hour);
    final suffix = eta.hour >= 12 ? 'PM' : 'AM';
    final minute = eta.minute.toString().padLeft(2, '0');
    return '$hour:$minute $suffix';
  }

  String _formatShortDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final normalized = status.toLowerCase();
    late Color background;
    late Color foreground;
    late IconData icon;

    if (normalized == 'delivered') {
      background = colorScheme.surfaceContainerHigh;
      foreground = colorScheme.onSurfaceVariant;
      icon = Icons.check_circle_rounded;
    } else if (normalized == 'cancelled') {
      background = colorScheme.errorContainer.withValues(alpha: 0.7);
      foreground = colorScheme.error;
      icon = Icons.cancel_rounded;
    } else {
      background = colorScheme.secondaryContainer.withValues(alpha: 0.28);
      foreground = colorScheme.secondary;
      icon = Icons.schedule_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: foreground),
          const Gap(4),
          Text(
            _statusLabel(normalized),
            style: TextStyle(
              color: foreground,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

String _statusLabel(String normalized) {
  if (normalized == 'on_the_way') {
    return 'On The Way';
  }
  if (normalized == 'delivered') {
    return 'Delivered';
  }
  if (normalized == 'cancelled') {
    return 'Cancelled';
  }
  return 'Preparing';
}
