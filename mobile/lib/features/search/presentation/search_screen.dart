import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/constants/app_radius.dart';
import 'package:mobile/core/constants/app_spacing.dart';
import 'package:mobile/core/widgets/app_bar_system.dart';
import 'package:mobile/data/models/restaurant.dart';
import 'package:mobile/data/models/restaurant_search_page.dart';
import 'package:mobile/providers/browse_providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  static const _seedRecentSearches = <String>[
    'Burger',
    'Sushi',
    'Free delivery',
    'Healthy',
  ];

  static const _quickFilters = <({String label, IconData icon})>[
    (label: 'Open Now', icon: Icons.access_time_filled),
    (label: 'Fastest', icon: Icons.electric_bolt),
    (label: 'Budget', icon: Icons.payments),
    (label: 'Top Rated', icon: Icons.verified),
  ];

  final _queryController = TextEditingController();
  final _scrollController = ScrollController();
  final Set<String> _activeFilters = <String>{};
  final List<String> _recentSearches = List<String>.from(_seedRecentSearches);

  Timer? _debounce;
  List<Restaurant> _results = const <Restaurant>[];
  int _page = 1;
  int _totalPages = 0;
  int _totalItems = 0;
  bool _isInitialLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  int _requestToken = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _refreshSearch();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = ref.watch(cartCountProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final query = _queryController.text.trim().toLowerCase();
    final suggestionsAsync = query.isEmpty
        ? const AsyncData<List<String>>(<String>[])
        : ref.watch(searchSuggestionsProvider(query));

    return Scaffold(
      appBar: QuickBiteAppBars.home(
        locationLabel: 'San Francisco',
        cartCount: cartCount,
        onCartTap: () => context.push('/cart'),
      ),
      body: ListView(
        controller: _scrollController,
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
                  onChanged: (_) {
                    setState(() {});
                    _scheduleRefresh();
                  },
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) {
                    _saveRecentSearch(value);
                    _refreshSearch();
                  },
                  decoration: InputDecoration(
                    hintText: 'Search restaurants, cuisine, or dishes...',
                    prefixIcon: Icon(Icons.search, color: colorScheme.outline),
                    suffixIcon: query.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _queryController.clear();
                              setState(() {
                                _page = 1;
                              });
                              _refreshSearch();
                            },
                            icon: Icon(
                              Icons.close,
                              color: colorScheme.onSurfaceVariant,
                            ),
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
                  'QUICK FILTERS',
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
                  children: _quickFilters.map((filter) {
                    final selected = _activeFilters.contains(filter.label);
                    return FilterChip(
                      selected: selected,
                      onSelected: (_) => _toggleFilter(filter.label),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.chip),
                      ),
                      side: BorderSide.none,
                      avatar: Icon(
                        filter.icon,
                        size: 16,
                        color: selected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurfaceVariant,
                      ),
                      selectedColor: colorScheme.primary,
                      backgroundColor: colorScheme.surfaceContainerLow,
                      label: Text(
                        filter.label,
                        style: textTheme.labelMedium?.copyWith(
                          color: selected
                              ? colorScheme.onPrimary
                              : colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  }).toList(growable: false),
                ),
              ),
              if (query.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.xs,
                  ),
                  child: Text(
                    'SUGGESTIONS',
                    style: textTheme.labelSmall?.copyWith(
                      letterSpacing: 1.1,
                      color: colorScheme.outline,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                ...suggestionsAsync.when(
                  loading: () => const [
                    ListTile(
                      dense: true,
                      leading: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      title: Text('Loading suggestions...'),
                    ),
                  ],
                  error: (error, stack) => [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                      child: Text(
                        'Suggestions unavailable right now.',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                  data: (suggestions) {
                    if (suggestions.isEmpty) {
                      return [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                          child: Text(
                            'No suggestions for "$query"',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ];
                    }
                    return suggestions
                        .map(
                          (entry) => ListTile(
                            dense: true,
                            leading: const Icon(Icons.search_rounded, size: 18),
                            title: Text(entry),
                            onTap: () {
                              _queryController.text = entry;
                              _queryController.selection = TextSelection.fromPosition(
                                TextPosition(offset: entry.length),
                              );
                              _saveRecentSearch(entry);
                              _refreshSearch();
                            },
                          ),
                        )
                        .toList(growable: false);
                  },
                ),
              ] else ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.xs,
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
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _recentSearches.map((entry) {
                      return ActionChip(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.chip),
                        ),
                        avatar: const Icon(Icons.history, size: 16),
                        label: Text(entry),
                        onPressed: () {
                          _queryController.text = entry;
                          _queryController.selection = TextSelection.fromPosition(
                            TextPosition(offset: entry.length),
                          );
                          _refreshSearch();
                        },
                      );
                    }).toList(growable: false),
                  ),
                ),
              ],
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Results ($_totalItems)',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (_activeFilters.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          setState(_activeFilters.clear);
                          _refreshSearch();
                        },
                        child: const Text('Clear Filters'),
                      ),
                  ],
                ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  child: Text(
                    _error!,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                )
              else if (_isInitialLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_results.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  child: Text(
                    'No restaurants match your query and filters.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                ..._results.map(
                  (restaurant) => Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.sm,
                      0,
                      AppSpacing.sm,
                      AppSpacing.sm,
                    ),
                    child: _SearchResultCard(
                      restaurant: restaurant,
                      onTapRestaurant: () {
                        _saveRecentSearch(restaurant.name);
                        context.push('/restaurant/${restaurant.id}');
                      },
                      onTapMenu: () {
                        _saveRecentSearch(restaurant.name);
                        context.push('/restaurant/${restaurant.id}/menu');
                      },
                    ),
                  ),
                ),
              if (_isLoadingMore)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.sm,
                    AppSpacing.sm,
                    AppSpacing.sm,
                    AppSpacing.sm,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 10),
                      Text('Loading more...'),
                    ],
                  ),
                ),
              if (!_isInitialLoading && !_isLoadingMore && _page < _totalPages)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.sm,
                    AppSpacing.sm,
                    AppSpacing.sm,
                    AppSpacing.sm,
                  ),
                  child: Text(
                    'Scroll for more (${_results.length}/$_totalItems)',
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  void _toggleFilter(String label) {
    setState(() {
      if (_activeFilters.contains(label)) {
        _activeFilters.remove(label);
      } else {
        _activeFilters.add(label);
      }
    });
    _refreshSearch();
  }

  void _saveRecentSearch(String rawQuery) {
    final normalized = rawQuery.trim();
    if (normalized.isEmpty) {
      return;
    }
    setState(() {
      _recentSearches.removeWhere(
        (entry) => entry.toLowerCase() == normalized.toLowerCase(),
      );
      _recentSearches.insert(0, normalized);
      if (_recentSearches.length > 8) {
        _recentSearches.removeRange(8, _recentSearches.length);
      }
    });
  }

  void _scheduleRefresh() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _refreshSearch);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      _loadMore();
    }
  }

  Future<void> _refreshSearch() async {
    final token = ++_requestToken;
    setState(() {
      _isInitialLoading = true;
      _isLoadingMore = false;
      _error = null;
      _page = 1;
      _totalPages = 0;
      _totalItems = 0;
      _results = const <Restaurant>[];
    });

    try {
      final response = await _fetchPage(page: 1);
      if (!mounted || token != _requestToken) {
        return;
      }
      setState(() {
        _results = response.items;
        _totalItems = response.totalItems;
        _totalPages = response.totalPages;
        _page = response.page;
        _isInitialLoading = false;
      });
    } catch (error) {
      if (!mounted || token != _requestToken) {
        return;
      }
      setState(() {
        _error = 'Unable to load search data: $error';
        _isInitialLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isInitialLoading || _isLoadingMore || _page >= _totalPages) {
      return;
    }

    final token = _requestToken;
    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _page + 1;
      final response = await _fetchPage(page: nextPage);
      if (!mounted || token != _requestToken) {
        return;
      }

      final seenIds = _results.map((item) => item.id).toSet();
      final merged = <Restaurant>[..._results];
      for (final item in response.items) {
        if (seenIds.add(item.id)) {
          merged.add(item);
        }
      }

      setState(() {
        _results = merged;
        _totalItems = response.totalItems;
        _totalPages = response.totalPages;
        _page = response.page;
        _isLoadingMore = false;
      });
    } catch (_) {
      if (!mounted || token != _requestToken) {
        return;
      }
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<RestaurantSearchPage> _fetchPage({required int page}) {
    final query = _queryController.text.trim().toLowerCase();
    final sort = _activeFilters.contains('Fastest')
        ? 'delivery_time_asc'
        : (_activeFilters.contains('Budget')
              ? 'delivery_fee_asc'
              : 'rating_desc');

    return ref.read(restaurantRepositoryProvider).searchRestaurants(
      query: query,
      page: page,
      pageSize: 12,
      openNow: _activeFilters.contains('Open Now') ? true : null,
      maxDeliveryFee: _activeFilters.contains('Budget') ? 2.0 : null,
      minRating: _activeFilters.contains('Top Rated') ? 4.7 : null,
      sort: sort,
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({
    required this.restaurant,
    required this.onTapRestaurant,
    required this.onTapMenu,
  });

  final Restaurant restaurant;
  final VoidCallback onTapRestaurant;
  final VoidCallback onTapMenu;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTapRestaurant,
      borderRadius: BorderRadius.circular(20),
      child: Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.network(
              restaurant.imageUrl,
              height: 138,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 138,
                color: colorScheme.surfaceContainerHigh,
                alignment: Alignment.center,
                child: Icon(Icons.storefront, color: colorScheme.outline),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurant.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${restaurant.cuisineType} • ${restaurant.deliveryTimeMinutes} min',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.star, size: 14, color: colorScheme.secondary),
                          const SizedBox(width: 4),
                          Text(
                            restaurant.rating.toStringAsFixed(1),
                            style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        restaurant.deliveryFee == 0
                            ? 'Free delivery'
                            : '\$${restaurant.deliveryFee.toStringAsFixed(2)} delivery',
                        style: textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    FilledButton.tonal(
                      onPressed: onTapMenu,
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        minimumSize: const Size(0, 32),
                      ),
                      child: const Text('Menu'),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      restaurant.isOpen ? Icons.circle : Icons.circle_outlined,
                      size: 10,
                      color: restaurant.isOpen
                          ? Colors.green
                          : colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      restaurant.isOpen ? 'Open' : 'Closed',
                      style: textTheme.labelSmall?.copyWith(
                        color: restaurant.isOpen
                            ? Colors.green
                            : colorScheme.onSurfaceVariant,
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
    );
  }
}
