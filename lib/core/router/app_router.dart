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
import '../../features/profile/presentation/screens/account_security_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/help_support_screen.dart';
import '../../features/profile/presentation/screens/privacy_policy_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/reviews/presentation/screens/add_review_screen.dart';
import '../../features/reviews/presentation/screens/reviews_screen.dart';
import '../../features/products/presentation/screens/search_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
// Admin imports
import '../../features/admin/presentation/screens/admin_main_scaffold.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/presentation/screens/admin_products_screen.dart';
import '../../features/admin/presentation/screens/admin_product_form_screen.dart';
import '../../features/admin/presentation/screens/admin_categories_screen.dart';
import '../../features/admin/presentation/screens/admin_orders_screen.dart';
import '../../features/admin/presentation/screens/admin_order_detail_screen.dart';
import '../../features/admin/presentation/screens/admin_users_screen.dart';
import '../../features/admin/presentation/screens/admin_banners_screen.dart';
import '../../features/admin/presentation/screens/admin_coupons_screen.dart';
import '../../features/admin/presentation/screens/admin_reviews_screen.dart';
import '../widgets/main_scaffold.dart';
import 'app_routes.dart';

/// Re-notifies GoRouter whenever auth state changes.
class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(ProviderContainer container) {
    _subscription = container.listen<AuthState>(
      authNotifierProvider,
      (_, __) => notifyListeners(),
    );
  }
  late final ProviderSubscription<AuthState> _subscription;
  @override
  void dispose() { _subscription.close(); super.dispose(); }
}

final class AppRouter {
  AppRouter._();

  static GoRouter createRouter(ProviderContainer container) => GoRouter(
    debugLogDiagnostics: true,
    initialLocation: AppRoutes.splash,
    refreshListenable: _RouterRefreshNotifier(container),
    redirect: (context, state) => _authGuard(context, state, container),
    routes: [
      // ── Auth routes ──────────────────────────────────────────
      GoRoute(path: AppRoutes.splash, name: 'splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: AppRoutes.onboarding, name: 'onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: AppRoutes.login, name: 'login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: AppRoutes.register, name: 'register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: AppRoutes.forgotPassword, name: 'forgotPassword', builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(path: AppRoutes.otp, name: 'otp', builder: (context, state) {
        final email = state.uri.queryParameters['email'] ?? '';
        return OtpScreen(email: email);
      }),

      // ── Main Shell — Bottom Navigation ───────────────────────
      ShellRoute(
        builder: (_, state, child) => MainScaffold(location: state.uri.path, child: child),
        routes: [
          GoRoute(path: AppRoutes.home, name: 'home', builder: (_, __) => const HomeScreen()),
          GoRoute(path: AppRoutes.categories, name: 'categories', builder: (_, __) => const CategoriesScreen()),
          GoRoute(path: AppRoutes.cart, name: 'cart', builder: (_, __) => const CartScreen()),
          GoRoute(path: AppRoutes.favorites, name: 'favorites', builder: (_, __) => const FavoritesScreen()),
          GoRoute(path: AppRoutes.profile, name: 'profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),

      // ── Product routes ────────────────────────────────────────
      GoRoute(path: AppRoutes.productDetail, name: 'productDetail', builder: (_, state) => ProductDetailScreen(productId: state.pathParameters['productId']!)),
      GoRoute(path: AppRoutes.reviews, name: 'reviews', builder: (_, state) => ReviewsScreen(productId: state.pathParameters['productId']!)),
      GoRoute(path: AppRoutes.writeReview, name: 'writeReview', builder: (_, state) => AddReviewScreen(productId: state.pathParameters['productId']!)),
      GoRoute(path: AppRoutes.productList, name: 'productList', builder: (_, state) {
        final extraMap = state.extra is Map<String, dynamic> ? state.extra as Map<String, dynamic> : null;
        final categoryId = extraMap?['categoryId'] as String? ?? state.uri.queryParameters['categoryId'];
        final filter = extraMap?['filter'] as String? ?? state.uri.queryParameters['filter'];
        final title = extraMap?['title'] as String? ?? state.uri.queryParameters['title'] ?? 'Products';
        return ProductListScreen(
          categoryId: categoryId,
          filter: filter,
          title: title,
        );
      }),
      GoRoute(path: AppRoutes.search, name: 'search', builder: (_, __) => const SearchScreen()),

      // ── Checkout & Orders ─────────────────────────────────────
      GoRoute(path: AppRoutes.checkout, name: 'checkout', builder: (_, __) => const CheckoutScreen()),
      GoRoute(path: AppRoutes.orderConfirmed, name: 'orderConfirmed', builder: (_, state) => OrderConfirmedScreen(orderId: state.pathParameters['orderId']!)),
      GoRoute(path: AppRoutes.orders, name: 'orders', builder: (_, __) => const OrdersScreen()),
      GoRoute(path: AppRoutes.orderDetail, name: 'orderDetail', builder: (_, state) => OrderDetailScreen(orderId: state.pathParameters['orderId']!)),

      // ── Profile sub-screens ───────────────────────────────────
      GoRoute(path: AppRoutes.editProfile, name: 'editProfile', builder: (_, __) => const EditProfileScreen()),
      GoRoute(path: AppRoutes.security, name: 'security', builder: (_, __) => const AccountSecurityScreen()),
      GoRoute(path: AppRoutes.helpSupport, name: 'helpSupport', builder: (_, __) => const HelpSupportScreen()),
      GoRoute(path: AppRoutes.privacyPolicy, name: 'privacyPolicy', builder: (_, __) => const PrivacyPolicyScreen()),
      GoRoute(path: AppRoutes.addresses, name: 'addresses', builder: (_, __) => const AddressesScreen()),
      GoRoute(path: AppRoutes.addAddress, name: 'addAddress', builder: (_, __) => const AddAddressScreen()),
      GoRoute(path: AppRoutes.editAddress, name: 'editAddress', builder: (_, state) => AddAddressScreen(addressToEdit: state.extra as AddressEntity?)),
      GoRoute(path: AppRoutes.notifications, name: 'notifications', builder: (_, __) => const NotificationsScreen()),
      GoRoute(path: AppRoutes.settings, name: 'settings', builder: (_, __) => const SettingsScreen()),

      // ── Admin Panel (ShellRoute with side navigation) ─────────
      ShellRoute(
        builder: (_, state, child) => AdminMainScaffold(location: state.uri.path, child: child),
        routes: [
          GoRoute(path: AppRoutes.adminDashboard, name: 'adminDashboard', builder: (_, __) => const AdminDashboardScreen()),
          GoRoute(path: AppRoutes.adminProducts, name: 'adminProducts', builder: (_, __) => const AdminProductsScreen()),
          GoRoute(path: AppRoutes.adminCategories, name: 'adminCategories', builder: (_, __) => const AdminCategoriesScreen()),
          GoRoute(path: AppRoutes.adminOrders, name: 'adminOrders', builder: (_, __) => const AdminOrdersScreen()),
          GoRoute(path: AppRoutes.adminUsers, name: 'adminUsers', builder: (_, __) => const AdminUsersScreen()),
          GoRoute(path: AppRoutes.adminBanners, name: 'adminBanners', builder: (_, __) => const AdminBannersScreen()),
          GoRoute(path: AppRoutes.adminCoupons, name: 'adminCoupons', builder: (_, __) => const AdminCouponsScreen()),
          GoRoute(path: AppRoutes.adminReviews, name: 'adminReviews', builder: (_, __) => const AdminReviewsScreen()),
        ],
      ),
      // Admin routes outside shell (full-screen pages)
      GoRoute(
        path: AppRoutes.adminProductForm,
        name: 'adminProductForm',
        builder: (_, state) => AdminProductFormScreen(product: state.extra as Map<String, dynamic>?),
      ),
      GoRoute(
        path: AppRoutes.adminOrderDetail,
        name: 'adminOrderDetail',
        builder: (_, state) => AdminOrderDetailScreen(order: state.extra as Map<String, dynamic>),
      ),
    ],

    errorBuilder: (context, state) => _ErrorScreen(error: state.error),
  );

  /// Auth + Admin guard — runs before every navigation.
  static String? _authGuard(BuildContext context, GoRouterState state, ProviderContainer container) {
    const authEntryRoutes = {
      AppRoutes.login,
      AppRoutes.register,
      AppRoutes.forgotPassword,
      AppRoutes.otp,
      AppRoutes.onboarding,
    };

    const protectedRoutes = {
      AppRoutes.checkout,
      AppRoutes.orderConfirmed,
      AppRoutes.orders,
      AppRoutes.orderDetail,
      AppRoutes.editProfile,
      AppRoutes.security,
      AppRoutes.addresses,
      AppRoutes.addAddress,
      AppRoutes.editAddress,
      AppRoutes.writeReview,
    };

    final path = state.uri.path;
    final isAuthEntryRoute = authEntryRoutes.contains(path) ||
        authEntryRoutes.any((r) => path.startsWith(r));
    final isProtectedRoute = protectedRoutes.contains(path) ||
        protectedRoutes.any((r) => path.startsWith(r));
    final isAdminRoute = path.startsWith('/admin');

    final authState = container.read(authNotifierProvider);

    // Redirect authenticated users away from login/register/onboarding to home
    if (authState is AuthAuthenticated && isAuthEntryRoute) return AppRoutes.home;

    // Protect routes that strictly require authentication
    if (authState is! AuthAuthenticated && (isProtectedRoute || isAdminRoute)) {
      return AppRoutes.login;
    }

    // Protect admin routes — only admin/super_admin can access
    if (isAdminRoute && authState is AuthAuthenticated) {
      final user = authState.user;
      if (!user.isAdmin) return AppRoutes.home;
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
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, size: 64, color: Colors.red),
        const SizedBox(height: 16),
        Text('Page not found', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(error?.toString() ?? 'Unknown route'),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: () => context.go(AppRoutes.home), child: const Text('Go Home')),
      ]),
    ),
  );
}

