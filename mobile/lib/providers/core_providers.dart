import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/widgets/main_nav_scaffold.dart';
import 'package:mobile/data/services/api_service.dart';
import 'package:mobile/features/auth/presentation/login_screen.dart';
import 'package:mobile/features/auth/presentation/register_screen.dart';
import 'package:mobile/features/cart/presentation/cart_screen.dart';
import 'package:mobile/features/checkout/presentation/checkout_screen.dart';
import 'package:mobile/features/home/presentation/home_screen.dart';
import 'package:mobile/features/menu/presentation/menu_screen.dart';
import 'package:mobile/features/onboarding/presentation/onboarding_screen.dart';
import 'package:mobile/features/orders/presentation/order_confirmation_screen.dart';
import 'package:mobile/features/orders/presentation/orders_screen.dart';
import 'package:mobile/features/orders/presentation/order_tracking_screen.dart';
import 'package:mobile/features/profile/presentation/profile_screen.dart';
import 'package:mobile/features/restaurant/presentation/restaurant_detail_screen.dart';
import 'package:mobile/features/search/presentation/search_screen.dart';
import 'package:mobile/features/splash/presentation/splash_screen.dart';
import 'package:mobile/providers/auth_providers.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final appRouterProvider = Provider<GoRouter>(
  (ref) {
    final auth = ref.watch(authNotifierProvider);
    final protectedPaths = <String>{
      '/checkout',
      '/order-confirmation',
      '/profile',
      '/orders',
    };

    return GoRouter(
      initialLocation: '/splash',
      redirect: (context, state) {
        if (!auth.initialized) {
          return state.matchedLocation == '/splash' ? null : '/splash';
        }

        final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';
        final isProtected =
            protectedPaths.contains(state.matchedLocation) || state.matchedLocation.startsWith('/order-tracking/');

        if (!auth.isAuthenticated && isProtected) {
          return '/login?from=${Uri.encodeComponent(state.matchedLocation)}';
        }

        if (auth.isAuthenticated && isAuthRoute) {
          return '/home';
        }

        return null;
      },
      routes: [
        GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
        GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
        GoRoute(
          path: '/login',
          builder: (context, state) {
            final from = state.uri.queryParameters['from'];
            return LoginScreen(fromPath: from);
          },
        ),
        GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
        ShellRoute(
          builder: (context, state, child) {
            return MainNavScaffold(location: state.matchedLocation, child: child);
          },
          routes: [
            GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
            GoRoute(path: '/search', builder: (context, state) => const SearchScreen()),
            GoRoute(path: '/orders', builder: (context, state) => const OrdersScreen()),
            GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
          ],
        ),
        GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),
        GoRoute(path: '/checkout', builder: (context, state) => const CheckoutScreen()),
        GoRoute(
          path: '/order-confirmation',
          builder: (context, state) => const OrderConfirmationScreen(),
        ),
        GoRoute(
          path: '/order-tracking/:id',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
            return OrderTrackingScreen(orderId: id);
          },
        ),
        GoRoute(
          path: '/restaurant/:id',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
            return RestaurantDetailScreen(restaurantId: id);
          },
        ),
        GoRoute(
          path: '/restaurant/:id/menu',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
            return MenuScreen(restaurantId: id);
          },
        ),
      ],
    );
  },
);
