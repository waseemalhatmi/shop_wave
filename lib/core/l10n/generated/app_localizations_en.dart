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
  String get general_confirm => 'Confirm';

  @override
  String get general_close => 'Close';

  @override
  String get general_clear => 'Clear';

  @override
  String get general_apply => 'Apply';

  @override
  String get general_copy => 'Copy';

  @override
  String get general_copied => 'Copied!';

  @override
  String get general_share => 'Share';

  @override
  String get general_add => 'Add';

  @override
  String get general_remove => 'Remove';

  @override
  String get general_update => 'Update';

  @override
  String get general_success => 'Operation successful';

  @override
  String get general_view_all => 'View All';

  @override
  String get general_go_home => 'Go to Home';

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
  String get auth_logout_confirm => 'Are you sure you want to log out?';

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
  String get auth_password_new => 'New Password';

  @override
  String get auth_password_new_hint => 'Enter your new password';

  @override
  String get auth_password_current => 'Current Password';

  @override
  String get auth_password_current_hint => 'Enter your current password';

  @override
  String get auth_password_updated => 'Password updated successfully';

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
  String get home_greeting_morning => 'Good morning';

  @override
  String get home_greeting_afternoon => 'Good afternoon';

  @override
  String get home_greeting_evening => 'Good evening';

  @override
  String get home_no_products => 'No products in this category';

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
  String product_items_left(int count) {
    return 'Only $count left';
  }

  @override
  String product_discount_badge(int percent) {
    return '$percent% OFF';
  }

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
  String get cart_remove_item => 'Remove Item';

  @override
  String get cart_remove_confirm => 'Remove this item from your cart?';

  @override
  String get cart_coupon_remove => 'Remove Coupon';

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
  String get checkout_no_address => 'Please select a delivery address';

  @override
  String get checkout_processing => 'Processing your order...';

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
  String get orders_empty_desc =>
      'You haven\'t placed any orders yet. Start shopping now!';

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
  String get order_cancel => 'Cancel Order';

  @override
  String get order_cancel_confirm =>
      'Are you sure you want to cancel this order?';

  @override
  String get order_cancel_reason => 'Cancellation Reason';

  @override
  String get order_cancel_success => 'Order cancelled successfully';

  @override
  String get order_reorder => 'Re-order';

  @override
  String get order_reorder_success => 'Items added to your cart!';

  @override
  String get order_live_tracking => 'Live Tracking';

  @override
  String get order_filter_all => 'All';

  @override
  String get order_filter_active => 'Active';

  @override
  String get order_filter_completed => 'Completed';

  @override
  String get order_filter_cancelled => 'Cancelled';

  @override
  String get order_number => 'Order Number';

  @override
  String get order_date => 'Order Date';

  @override
  String order_items_count(int count) {
    return '$count items';
  }

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
  String get profile_security => 'Security & Password';

  @override
  String get profile_stat_orders => 'Orders';

  @override
  String get profile_stat_wishlist => 'Wishlist';

  @override
  String get profile_stat_reviews => 'Reviews';

  @override
  String get profile_my_reviews => 'My Reviews';

  @override
  String profile_reviews_desc(int count) {
    return 'You have submitted $count product review(s) so far.';
  }

  @override
  String get profile_verified_email => 'Verified Email';

  @override
  String get profile_change_password => 'Change Password';

  @override
  String get profile_update_password => 'Update Password';

  @override
  String get profile_password_weak => 'Weak';

  @override
  String get profile_password_medium => 'Medium';

  @override
  String get profile_password_strong => 'Strong';

  @override
  String get profile_two_factor => 'Two-Factor Authentication';

  @override
  String get profile_two_factor_enabled => 'Enabled';

  @override
  String get profile_two_factor_disabled => 'Disabled';

  @override
  String get profile_active_sessions => 'Active Sessions';

  @override
  String get profile_email_verified => 'Verified';

  @override
  String get profile_email_not_verified => 'Not Verified';

  @override
  String get security_title => 'Security & Password';

  @override
  String get security_password_section => 'Change Password';

  @override
  String get security_strength_title => 'Strength';

  @override
  String get security_req_length => 'At least 8 characters';

  @override
  String get security_req_case => 'Upper & lowercase letters';

  @override
  String get security_req_number => 'At least one number';

  @override
  String get security_req_special => 'One special character (!@#...).';

  @override
  String get support_title => 'Help & Support';

  @override
  String get support_faq => 'Frequently Asked Questions';

  @override
  String get support_contact => 'Contact Us';

  @override
  String get support_whatsapp => 'WhatsApp';

  @override
  String get support_email => 'Email';

  @override
  String get support_hotline => 'Toll-Free Hotline';

  @override
  String get support_copy_success => 'Copied';

  @override
  String get support_faq_q1 => 'How do I track my order?';

  @override
  String get support_faq_a1 =>
      'You can track your order from the \'My Orders\' section in your profile.';

  @override
  String get support_faq_q2 => 'What is your return policy?';

  @override
  String get support_faq_a2 =>
      'You can return any product within 14 days of receiving it.';

  @override
  String get support_faq_q3 => 'Is online payment secure?';

  @override
  String get support_faq_a3 =>
      'Yes, all transactions are encrypted with 256-bit SSL technology.';

  @override
  String get support_faq_q4 => 'When will my order arrive?';

  @override
  String get support_faq_a4 =>
      'Usually within 2-5 business days within the Kingdom.';

  @override
  String get support_faq_q5 => 'How do I use a discount coupon?';

  @override
  String get support_faq_a5 =>
      'Enter the coupon code at checkout before confirming your order.';

  @override
  String get privacy_title => 'Privacy Policy';

  @override
  String get privacy_data_section => 'Data Collection & Use';

  @override
  String get privacy_payment_section => 'Payment Security';

  @override
  String get privacy_rights_section => 'Your Rights';

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
  String get address_empty => 'No saved addresses';

  @override
  String get address_empty_desc => 'Add an address to speed up checkout.';

  @override
  String get address_delete_confirm => 'Delete this address?';

  @override
  String get notifications_title => 'Notifications';

  @override
  String get notifications_empty => 'No notifications';

  @override
  String get notifications_mark_read => 'Mark All as Read';

  @override
  String get notifications_order_update => 'Order Update';

  @override
  String get notifications_promo => 'Special Offers';

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
  String get settings_currency => 'Currency';

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
  String get search_recent => 'Recent Searches';

  @override
  String get search_clear_history => 'Clear History';

  @override
  String get search_no_history => 'No search history';

  @override
  String get search_categories => 'Categories';

  @override
  String search_all_results(String query) {
    return 'All results for \"$query\"';
  }

  @override
  String get search_filter_price_range => 'Price Range';

  @override
  String get search_filter_min_rating => 'Minimum Rating';

  @override
  String get search_filter_category => 'Category';

  @override
  String get search_filter_reset => 'Reset Filters';

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

  @override
  String get review_submitted => 'Your review was submitted successfully';

  @override
  String get review_helpful => 'Was this helpful?';

  @override
  String get coupon_title => 'Coupons & Offers';

  @override
  String get coupon_invalid => 'Invalid coupon code';

  @override
  String get coupon_expired => 'This coupon has expired';

  @override
  String coupon_min_order(double amount) {
    return 'Minimum order $amount SAR';
  }

  @override
  String coupon_applied(String code) {
    return 'Coupon $code applied';
  }

  @override
  String get coupon_removed => 'Coupon removed';

  @override
  String get admin_dashboard => 'Dashboard';

  @override
  String get admin_products => 'Products';

  @override
  String get admin_orders => 'Orders';

  @override
  String get admin_users => 'Users';

  @override
  String get admin_analytics => 'Analytics';
}
