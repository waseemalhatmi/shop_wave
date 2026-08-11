// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'ShopWave';

  @override
  String get general_ok => 'OK';

  @override
  String get general_cancel => 'Cancel';

  @override
  String get general_retry => 'Try Again';

  @override
  String get general_save => 'Save';

  @override
  String get general_delete => 'Delete';

  @override
  String get general_edit => 'Edit';

  @override
  String get general_done => 'Done';

  @override
  String get general_back => 'Back';

  @override
  String get general_next => 'Next';

  @override
  String get general_search => 'Search';

  @override
  String get general_loading => 'Loading...';

  @override
  String get general_error => 'Something went wrong';

  @override
  String get general_no_internet => 'No internet connection';

  @override
  String get general_no_internet_desc =>
      'Please check your connection and try again.';

  @override
  String get general_server_error => 'Server error. Please try again.';

  @override
  String get general_empty => 'Nothing here yet';

  @override
  String get general_required => 'This field is required';

  @override
  String get general_see_all => 'See All';

  @override
  String get general_sar => 'SAR';

  @override
  String get general_free => 'Free';

  @override
  String get onboarding_skip => 'Skip';

  @override
  String get onboarding_get_started => 'Get Started';

  @override
  String get onboarding_slide1_title => 'Discover Amazing Products';

  @override
  String get onboarding_slide1_desc =>
      'Browse thousands of products from top brands, all in one place.';

  @override
  String get onboarding_slide2_title => 'Fast & Secure Checkout';

  @override
  String get onboarding_slide2_desc =>
      'Shop with confidence. Secure payments and hassle-free returns.';

  @override
  String get onboarding_slide3_title => 'Track Your Orders';

  @override
  String get onboarding_slide3_desc =>
      'Real-time updates on every order, right to your door.';

  @override
  String get auth_login => 'Log In';

  @override
  String get auth_register => 'Sign Up';

  @override
  String get auth_logout => 'Log Out';

  @override
  String get auth_email => 'Email Address';

  @override
  String get auth_email_hint => 'Enter your email';

  @override
  String get auth_email_invalid => 'Please enter a valid email address';

  @override
  String get auth_password => 'Password';

  @override
  String get auth_password_hint => 'Enter your password';

  @override
  String get auth_password_min => 'Password must be at least 8 characters';

  @override
  String get auth_password_confirm => 'Confirm Password';

  @override
  String get auth_password_mismatch => 'Passwords do not match';

  @override
  String get auth_full_name => 'Full Name';

  @override
  String get auth_full_name_hint => 'Enter your full name';

  @override
  String get auth_full_name_min => 'Name must be at least 2 characters';

  @override
  String get auth_phone => 'Phone Number';

  @override
  String get auth_forgot_password => 'Forgot Password?';

  @override
  String get auth_reset_password => 'Reset Password';

  @override
  String get auth_reset_sent => 'Reset link sent to your email';

  @override
  String get auth_no_account => 'Don\'t have an account?';

  @override
  String get auth_have_account => 'Already have an account?';

  @override
  String get auth_or => 'or';

  @override
  String get auth_continue_google => 'Continue with Google';

  @override
  String get auth_otp_title => 'Enter OTP';

  @override
  String auth_otp_desc(String email) {
    return 'We sent a 6-digit code to $email';
  }

  @override
  String get auth_otp_resend => 'Resend Code';

  @override
  String auth_otp_resend_in(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get nav_home => 'Home';

  @override
  String get nav_categories => 'Categories';

  @override
  String get nav_cart => 'Cart';

  @override
  String get nav_favorites => 'Favorites';

  @override
  String get nav_profile => 'Profile';

  @override
  String get home_search_hint => 'Search products...';

  @override
  String get home_banners => 'Featured';

  @override
  String get home_categories => 'Categories';

  @override
  String get home_flash_deals => 'Flash Deals';

  @override
  String get home_featured => 'Featured Products';

  @override
  String get home_new_arrivals => 'New Arrivals';

  @override
  String get home_best_sellers => 'Best Sellers';

  @override
  String get product_add_to_cart => 'Add to Cart';

  @override
  String get product_buy_now => 'Buy Now';

  @override
  String get product_out_of_stock => 'Out of Stock';

  @override
  String get product_in_stock => 'In Stock';

  @override
  String get product_description => 'Description';

  @override
  String get product_reviews => 'Reviews';

  @override
  String get product_related => 'You May Also Like';

  @override
  String get product_select_variant => 'Select Options';

  @override
  String get product_size => 'Size';

  @override
  String get product_color => 'Color';

  @override
  String get product_quantity => 'Quantity';

  @override
  String get product_share => 'Share';

  @override
  String get product_added_to_cart => 'Added to cart!';

  @override
  String get product_added_to_favorites => 'Added to favorites';

  @override
  String get product_removed_from_favorites => 'Removed from favorites';

  @override
  String get cart_title => 'My Cart';

  @override
  String get cart_empty => 'Your cart is empty';

  @override
  String get cart_empty_desc => 'Looks like you haven\'t added anything yet.';

  @override
  String get cart_shop_now => 'Shop Now';

  @override
  String get cart_subtotal => 'Subtotal';

  @override
  String get cart_shipping => 'Shipping';

  @override
  String get cart_discount => 'Discount';

  @override
  String get cart_total => 'Total';

  @override
  String get cart_checkout => 'Proceed to Checkout';

  @override
  String cart_items(int count) {
    return '$count Items';
  }

  @override
  String get checkout_title => 'Checkout';

  @override
  String get checkout_delivery_address => 'Delivery Address';

  @override
  String get checkout_payment_method => 'Payment Method';

  @override
  String get checkout_order_summary => 'Order Summary';

  @override
  String get checkout_coupon => 'Apply Coupon';

  @override
  String get checkout_coupon_hint => 'Enter coupon code';

  @override
  String get checkout_coupon_applied => 'Coupon applied!';

  @override
  String get checkout_coupon_invalid => 'Invalid or expired coupon';

  @override
  String get checkout_place_order => 'Place Order';

  @override
  String get checkout_cash_on_delivery => 'Cash on Delivery';

  @override
  String get checkout_card => 'Credit / Debit Card';

  @override
  String get order_confirmed_title => 'Order Confirmed!';

  @override
  String order_confirmed_desc(String orderId) {
    return 'Your order #$orderId has been placed successfully.';
  }

  @override
  String get order_track => 'Track Order';

  @override
  String get order_continue_shopping => 'Continue Shopping';

  @override
  String get orders_title => 'My Orders';

  @override
  String get orders_empty => 'No orders yet';

  @override
  String get order_detail_title => 'Order Details';

  @override
  String get order_status_pending => 'Pending';

  @override
  String get order_status_confirmed => 'Confirmed';

  @override
  String get order_status_processing => 'Processing';

  @override
  String get order_status_shipped => 'Shipped';

  @override
  String get order_status_delivered => 'Delivered';

  @override
  String get order_status_cancelled => 'Cancelled';

  @override
  String get order_status_refunded => 'Refunded';

  @override
  String get favorites_title => 'My Favorites';

  @override
  String get favorites_empty => 'No favorites yet';

  @override
  String get favorites_empty_desc =>
      'Tap the heart on any product to save it here.';

  @override
  String get profile_title => 'My Profile';

  @override
  String get profile_edit => 'Edit Profile';

  @override
  String get profile_orders => 'My Orders';

  @override
  String get profile_addresses => 'Addresses';

  @override
  String get profile_notifications => 'Notifications';

  @override
  String get profile_settings => 'Settings';

  @override
  String get profile_help => 'Help & Support';

  @override
  String get profile_about => 'About ShopWave';

  @override
  String get profile_account => 'Account';

  @override
  String get profile_preferences => 'Preferences';

  @override
  String get profile_privacy => 'Privacy Policy';

  @override
  String get address_title => 'Addresses';

  @override
  String get address_add => 'Add Address';

  @override
  String get address_edit => 'Edit Address';

  @override
  String get address_delete => 'Delete Address';

  @override
  String get address_set_default => 'Set as Default';

  @override
  String get address_default => 'Default';

  @override
  String get address_home => 'Home';

  @override
  String get address_work => 'Work';

  @override
  String get address_full_name => 'Full Name';

  @override
  String get address_phone => 'Phone';

  @override
  String get address_city => 'City';

  @override
  String get address_street => 'Street Address';

  @override
  String get address_postal => 'Postal Code';

  @override
  String get address_building => 'Building / Apartment';

  @override
  String get address_saved => 'Address saved';

  @override
  String get notifications_title => 'Notifications';

  @override
  String get notifications_empty => 'No notifications';

  @override
  String get notifications_mark_read => 'Mark All as Read';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_theme => 'Theme';

  @override
  String get settings_theme_light => 'Light';

  @override
  String get settings_theme_dark => 'Dark';

  @override
  String get settings_theme_system => 'System Default';

  @override
  String get settings_language => 'Language';

  @override
  String get settings_language_en => 'English';

  @override
  String get settings_language_ar => 'Arabic';

  @override
  String get settings_notifications => 'Notifications';

  @override
  String get settings_version => 'App Version';

  @override
  String get search_hint => 'What are you looking for?';

  @override
  String search_empty(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get search_filters => 'Filters';

  @override
  String get search_sort => 'Sort By';

  @override
  String get search_sort_newest => 'Newest';

  @override
  String get search_sort_price_asc => 'Price: Low to High';

  @override
  String get search_sort_price_desc => 'Price: High to Low';

  @override
  String get search_sort_rating => 'Top Rated';

  @override
  String get search_sort_popular => 'Most Popular';

  @override
  String get review_write => 'Write a Review';

  @override
  String get review_title => 'Review Title';

  @override
  String get review_body => 'Your Review';

  @override
  String get review_submit => 'Submit Review';

  @override
  String get review_no_reviews => 'No reviews yet. Be the first!';

  @override
  String review_rating_label(int count) {
    return '$count ratings';
  }
}
