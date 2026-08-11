/// All route paths in the application — single source of truth.
abstract final class AppRoutes {
  // ── Auth ───────────────────────────────────────────────────────
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String otp = '/otp';

  // ── Main Shell (Bottom Nav) ────────────────────────────────────
  static const String home = '/home';
  static const String categories = '/categories';
  static const String cart = '/cart';
  static const String favorites = '/favorites';
  static const String profile = '/profile';

  // ── Products ───────────────────────────────────────────────────
  static const String productDetail = '/product/:productId';
  static const String productList = '/products';
  static const String search = '/search';
  static const String offers = '/offers';

  // ── Checkout ───────────────────────────────────────────────────
  static const String checkout = '/checkout';
  static const String orderConfirmed = '/order-confirmed/:orderId';

  // ── Orders ─────────────────────────────────────────────────────
  static const String orders = '/orders';
  static const String orderDetail = '/order/:orderId';

  // ── Profile Sub-screens ────────────────────────────────────────
  static const String editProfile = '/profile/edit';
  static const String addresses = '/addresses';
  static const String addAddress = '/addresses/add';
  static const String editAddress = '/addresses/:addressId/edit';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String reviews = '/product/:productId/reviews';
  static const String writeReview = '/product/:productId/review/write';

  // ── Admin Panel ────────────────────────────────────────────────
  static const String adminDashboard = '/admin';
  static const String adminProducts = '/admin/products';
  static const String adminProductForm = '/admin/products/form';
  static const String adminCategories = '/admin/categories';
  static const String adminOrders = '/admin/orders';
  static const String adminOrderDetail = '/admin/orders/detail';
  static const String adminUsers = '/admin/users';
  static const String adminBanners = '/admin/banners';
  static const String adminCoupons = '/admin/coupons';
  static const String adminReviews = '/admin/reviews';

  // ── Helpers ────────────────────────────────────────────────────
  static String productDetailPath(String productId) => '/product/$productId';
  static String orderDetailPath(String orderId) => '/order/$orderId';
  static String orderConfirmedPath(String orderId) => '/order-confirmed/$orderId';
  static String editAddressPath(String addressId) => '/addresses/$addressId/edit';
  static String reviewsPath(String productId) => '/product/$productId/reviews';
  static String writeReviewPath(String productId) => '/product/$productId/review/write';
}
