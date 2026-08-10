import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/addresses/domain/entities/address_entity.dart';
import '../../features/addresses/presentation/screens/add_address_screen.dart';
import '../../features/addresses/presentation/screens/addresses_screen.dart';
import '../../features/auth/presentation/providers/auth_notifier.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/categories/presentation/screens/categories_screen.dart';
import '../../features/checkout/presentation/screens/checkout_screen.dart';
import '../../features/favorites/presentation/screens/favorites_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/orders/presentation/screens/order_confirmed_screen.dart';
import '../../features/orders/presentation/screens/order_detail_screen.dart';
import '../../features/orders/presentation/screens/orders_screen.dart';
import '../../features/products/presentation/screens/product_detail_screen.dart';
import '../../features/products/presentation/screens/product_list_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/reviews/presentation/screens/add_review_screen.dart';
import '../../features/reviews/presentation/screens/reviews_screen.dart';
import '../../features/products/presentation/screens/search_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../widgets/main_scaffold.dart';
import 'app_routes.dart';

/// A [ChangeNotifier] that re-notifies GoRouter whenever the auth state
/// changes, so the redirect guard is re-evaluated automatically.
class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(ProviderContainer container) {
    _subscription = container.listen<AuthState>(
      authNotifierProvider,
      (_, __) => notifyListeners(),
    );
  }

  late final ProviderSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}

/// Application router using GoRouter.
///
/// Architecture decisions:
/// - [ShellRoute] wraps the main tab bar screens so the bottom navigation
///   persists across navigation (like WhatsApp tabs).
/// - Auth guard redirects unauthenticated users to login.
/// - All route paths are defined in [AppRoutes] — never magic strings here.
final class AppRouter {
  AppRouter._();

  static GoRouter createRouter(ProviderContainer container) => GoRouter(
    debugLogDiagnostics: true,
    initialLocation: AppRoutes.splash,
    refreshListenable: _RouterRefreshNotifier(container),
    redirect: _authGuard,
    routes: [
      // ── Auth routes (no bottom nav) ──────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.otp,
        name: 'otp',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return OtpScreen(email: email);
        },
      ),

      // ── Main Shell — Bottom Navigation ───────────────────────
      ShellRoute(
        builder: (_, state, child) => MainScaffold(
          location: state.uri.path,
          child: child,
        ),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            builder: (_, __) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.categories,
            name: 'categories',
            builder: (_, __) => const CategoriesScreen(),
          ),
          GoRoute(
            path: AppRoutes.cart,
            name: 'cart',
            builder: (_, __) => const CartScreen(),
          ),
          GoRoute(
            path: AppRoutes.favorites,
            name: 'favorites',
            builder: (_, __) => const FavoritesScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            builder: (_, __) => const ProfileScreen(),
          ),
        ],
      ),

      // ── Product routes ────────────────────────────────────────
      GoRoute(
        path: AppRoutes.productDetail,
        name: 'productDetail',
        builder: (_, state) {
          final productId = state.pathParameters['productId']!;
          return ProductDetailScreen(productId: productId);
        },
      ),
      GoRoute(
        path: AppRoutes.reviews,
        name: 'reviews',
        builder: (_, state) {
          final productId = state.pathParameters['productId']!;
          return ReviewsScreen(productId: productId);
        },
      ),
      GoRoute(
        path: AppRoutes.writeReview,
        name: 'writeReview',
        builder: (_, state) {
          final productId = state.pathParameters['productId']!;
          return AddReviewScreen(productId: productId);
        },
      ),
      GoRoute(
        path: AppRoutes.productList,
        name: 'productList',
        builder: (_, state) {
          final categoryId = state.uri.queryParameters['categoryId'];
          final title = state.uri.queryParameters['title'] ?? 'Products';
          return ProductListScreen(
            categoryId: categoryId,
            title: title,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.search,
        name: 'search',
        builder: (_, __) => const SearchScreen(),
      ),

      // ── Checkout & Orders ─────────────────────────────────────
      GoRoute(
        path: AppRoutes.checkout,
        name: 'checkout',
        builder: (_, __) => const CheckoutScreen(),
      ),
      GoRoute(
        path: AppRoutes.orderConfirmed,
        name: 'orderConfirmed',
        builder: (_, state) {
          final orderId = state.pathParameters['orderId']!;
          return OrderConfirmedScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: AppRoutes.orders,
        name: 'orders',
        builder: (_, __) => const OrdersScreen(),
      ),
      GoRoute(
        path: AppRoutes.orderDetail,
        name: 'orderDetail',
        builder: (_, state) {
          final orderId = state.pathParameters['orderId']!;
          return OrderDetailScreen(orderId: orderId);
        },
      ),

      // ── Profile sub-screens ───────────────────────────────────
      GoRoute(
        path: AppRoutes.editProfile,
        name: 'editProfile',
        builder: (_, __) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.addresses,
        name: 'addresses',
        builder: (_, __) => const AddressesScreen(),
      ),
      GoRoute(
        path: AppRoutes.addAddress,
        name: 'addAddress',
        builder: (_, __) => const AddAddressScreen(),
      ),
      GoRoute(
        path: AppRoutes.editAddress,
        name: 'editAddress',
        builder: (_, state) {
          final address = state.extra as AddressEntity?;
          return AddAddressScreen(addressToEdit: address);
        },
      ),
      GoRoute(
        path: AppRoutes.notifications,
        name: 'notifications',
        builder: (_, __) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (_, __) => const SettingsScreen(),
      ),
    ],

    errorBuilder: (context, state) => _ErrorScreen(error: state.error),
  );

  /// Auth guard — runs before every navigation.
  /// Returns null to allow navigation, or a redirect path.
  static String? _authGuard(BuildContext context, GoRouterState state) {
    const publicRoutes = {
      AppRoutes.splash,
      AppRoutes.onboarding,
      AppRoutes.login,
      AppRoutes.register,
      AppRoutes.forgotPassword,
      AppRoutes.otp,
    };

    final isPublicRoute = publicRoutes.contains(state.uri.path) ||
        (state.uri.path != AppRoutes.splash &&
            publicRoutes.any((r) => r != AppRoutes.splash && state.uri.path.startsWith(r)));

    // Read auth state synchronously via ProviderScope container
    final container = ProviderScope.containerOf(context, listen: false);
    final authState = container.read(authNotifierProvider);

    if (authState is AuthAuthenticated && isPublicRoute) {
      return AppRoutes.home;
    }
    if (authState is AuthUnauthenticated && !isPublicRoute) {
      return AppRoutes.login;
    }
    // AuthInitial (loading) — stay on splash
    return null;
  }
}

/// Fallback error screen shown when router encounters an unknown route.
class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({required this.error});
  final Exception? error;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Page not found',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(error?.toString() ?? 'Unknown route'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      );
}
