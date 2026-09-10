import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// The application name
  ///
  /// In en, this message translates to:
  /// **'ShopWave'**
  String get appName;

  /// No description provided for @general_ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get general_ok;

  /// No description provided for @general_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get general_cancel;

  /// No description provided for @general_retry.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get general_retry;

  /// No description provided for @general_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get general_save;

  /// No description provided for @general_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get general_delete;

  /// No description provided for @general_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get general_edit;

  /// No description provided for @general_done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get general_done;

  /// No description provided for @general_back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get general_back;

  /// No description provided for @general_next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get general_next;

  /// No description provided for @general_search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get general_search;

  /// No description provided for @general_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get general_loading;

  /// No description provided for @general_error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get general_error;

  /// No description provided for @general_no_internet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get general_no_internet;

  /// No description provided for @general_no_internet_desc.
  ///
  /// In en, this message translates to:
  /// **'Please check your connection and try again.'**
  String get general_no_internet_desc;

  /// No description provided for @general_server_error.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again.'**
  String get general_server_error;

  /// No description provided for @general_empty.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get general_empty;

  /// No description provided for @general_required.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get general_required;

  /// No description provided for @general_see_all.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get general_see_all;

  /// No description provided for @general_sar.
  ///
  /// In en, this message translates to:
  /// **'SAR'**
  String get general_sar;

  /// No description provided for @general_free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get general_free;

  /// No description provided for @general_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get general_confirm;

  /// No description provided for @general_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get general_close;

  /// No description provided for @general_clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get general_clear;

  /// No description provided for @general_apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get general_apply;

  /// No description provided for @general_copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get general_copy;

  /// No description provided for @general_copied.
  ///
  /// In en, this message translates to:
  /// **'Copied!'**
  String get general_copied;

  /// No description provided for @general_share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get general_share;

  /// No description provided for @general_add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get general_add;

  /// No description provided for @general_remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get general_remove;

  /// No description provided for @general_update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get general_update;

  /// No description provided for @general_success.
  ///
  /// In en, this message translates to:
  /// **'Operation successful'**
  String get general_success;

  /// No description provided for @general_view_all.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get general_view_all;

  /// No description provided for @general_go_home.
  ///
  /// In en, this message translates to:
  /// **'Go to Home'**
  String get general_go_home;

  /// No description provided for @onboarding_skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboarding_skip;

  /// No description provided for @onboarding_get_started.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboarding_get_started;

  /// No description provided for @onboarding_slide1_title.
  ///
  /// In en, this message translates to:
  /// **'Discover Amazing Products'**
  String get onboarding_slide1_title;

  /// No description provided for @onboarding_slide1_desc.
  ///
  /// In en, this message translates to:
  /// **'Browse thousands of products from top brands, all in one place.'**
  String get onboarding_slide1_desc;

  /// No description provided for @onboarding_slide2_title.
  ///
  /// In en, this message translates to:
  /// **'Fast & Secure Checkout'**
  String get onboarding_slide2_title;

  /// No description provided for @onboarding_slide2_desc.
  ///
  /// In en, this message translates to:
  /// **'Shop with confidence. Secure payments and hassle-free returns.'**
  String get onboarding_slide2_desc;

  /// No description provided for @onboarding_slide3_title.
  ///
  /// In en, this message translates to:
  /// **'Track Your Orders'**
  String get onboarding_slide3_title;

  /// No description provided for @onboarding_slide3_desc.
  ///
  /// In en, this message translates to:
  /// **'Real-time updates on every order, right to your door.'**
  String get onboarding_slide3_desc;

  /// No description provided for @auth_login.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get auth_login;

  /// No description provided for @auth_register.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get auth_register;

  /// No description provided for @auth_logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get auth_logout;

  /// No description provided for @auth_logout_confirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get auth_logout_confirm;

  /// No description provided for @auth_email.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get auth_email;

  /// No description provided for @auth_email_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get auth_email_hint;

  /// No description provided for @auth_email_invalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get auth_email_invalid;

  /// No description provided for @auth_password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get auth_password;

  /// No description provided for @auth_password_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get auth_password_hint;

  /// No description provided for @auth_password_min.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get auth_password_min;

  /// No description provided for @auth_password_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get auth_password_confirm;

  /// No description provided for @auth_password_mismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get auth_password_mismatch;

  /// No description provided for @auth_password_new.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get auth_password_new;

  /// No description provided for @auth_password_new_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your new password'**
  String get auth_password_new_hint;

  /// No description provided for @auth_password_current.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get auth_password_current;

  /// No description provided for @auth_password_current_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password'**
  String get auth_password_current_hint;

  /// No description provided for @auth_password_updated.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully'**
  String get auth_password_updated;

  /// No description provided for @auth_full_name.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get auth_full_name;

  /// No description provided for @auth_full_name_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get auth_full_name_hint;

  /// No description provided for @auth_full_name_min.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get auth_full_name_min;

  /// No description provided for @auth_phone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get auth_phone;

  /// No description provided for @auth_forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get auth_forgot_password;

  /// No description provided for @auth_reset_password.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get auth_reset_password;

  /// No description provided for @auth_reset_sent.
  ///
  /// In en, this message translates to:
  /// **'Reset link sent to your email'**
  String get auth_reset_sent;

  /// No description provided for @auth_no_account.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get auth_no_account;

  /// No description provided for @auth_have_account.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get auth_have_account;

  /// No description provided for @auth_or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get auth_or;

  /// No description provided for @auth_continue_google.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get auth_continue_google;

  /// No description provided for @auth_otp_title.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get auth_otp_title;

  /// No description provided for @auth_otp_desc.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to {email}'**
  String auth_otp_desc(String email);

  /// No description provided for @auth_otp_resend.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get auth_otp_resend;

  /// No description provided for @auth_otp_resend_in.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String auth_otp_resend_in(int seconds);

  /// No description provided for @nav_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get nav_home;

  /// No description provided for @nav_categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get nav_categories;

  /// No description provided for @nav_cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get nav_cart;

  /// No description provided for @nav_favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get nav_favorites;

  /// No description provided for @nav_profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get nav_profile;

  /// No description provided for @home_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get home_search_hint;

  /// No description provided for @home_banners.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get home_banners;

  /// No description provided for @home_categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get home_categories;

  /// No description provided for @home_flash_deals.
  ///
  /// In en, this message translates to:
  /// **'Flash Deals'**
  String get home_flash_deals;

  /// No description provided for @home_featured.
  ///
  /// In en, this message translates to:
  /// **'Featured Products'**
  String get home_featured;

  /// No description provided for @home_new_arrivals.
  ///
  /// In en, this message translates to:
  /// **'New Arrivals'**
  String get home_new_arrivals;

  /// No description provided for @home_best_sellers.
  ///
  /// In en, this message translates to:
  /// **'Best Sellers'**
  String get home_best_sellers;

  /// No description provided for @home_greeting_morning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get home_greeting_morning;

  /// No description provided for @home_greeting_afternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get home_greeting_afternoon;

  /// No description provided for @home_greeting_evening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get home_greeting_evening;

  /// No description provided for @home_no_products.
  ///
  /// In en, this message translates to:
  /// **'No products in this category'**
  String get home_no_products;

  /// No description provided for @product_add_to_cart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get product_add_to_cart;

  /// No description provided for @product_buy_now.
  ///
  /// In en, this message translates to:
  /// **'Buy Now'**
  String get product_buy_now;

  /// No description provided for @product_out_of_stock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get product_out_of_stock;

  /// No description provided for @product_in_stock.
  ///
  /// In en, this message translates to:
  /// **'In Stock'**
  String get product_in_stock;

  /// No description provided for @product_description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get product_description;

  /// No description provided for @product_reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get product_reviews;

  /// No description provided for @product_related.
  ///
  /// In en, this message translates to:
  /// **'You May Also Like'**
  String get product_related;

  /// No description provided for @product_select_variant.
  ///
  /// In en, this message translates to:
  /// **'Select Options'**
  String get product_select_variant;

  /// No description provided for @product_size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get product_size;

  /// No description provided for @product_color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get product_color;

  /// No description provided for @product_quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get product_quantity;

  /// No description provided for @product_share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get product_share;

  /// No description provided for @product_added_to_cart.
  ///
  /// In en, this message translates to:
  /// **'Added to cart!'**
  String get product_added_to_cart;

  /// No description provided for @product_added_to_favorites.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites'**
  String get product_added_to_favorites;

  /// No description provided for @product_removed_from_favorites.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get product_removed_from_favorites;

  /// No description provided for @product_items_left.
  ///
  /// In en, this message translates to:
  /// **'Only {count} left'**
  String product_items_left(int count);

  /// No description provided for @product_discount_badge.
  ///
  /// In en, this message translates to:
  /// **'{percent}% OFF'**
  String product_discount_badge(int percent);

  /// No description provided for @cart_title.
  ///
  /// In en, this message translates to:
  /// **'My Cart'**
  String get cart_title;

  /// No description provided for @cart_empty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cart_empty;

  /// No description provided for @cart_empty_desc.
  ///
  /// In en, this message translates to:
  /// **'Looks like you haven\'t added anything yet.'**
  String get cart_empty_desc;

  /// No description provided for @cart_shop_now.
  ///
  /// In en, this message translates to:
  /// **'Shop Now'**
  String get cart_shop_now;

  /// No description provided for @cart_subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get cart_subtotal;

  /// No description provided for @cart_shipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get cart_shipping;

  /// No description provided for @cart_discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get cart_discount;

  /// No description provided for @cart_total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get cart_total;

  /// No description provided for @cart_checkout.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Checkout'**
  String get cart_checkout;

  /// No description provided for @cart_items.
  ///
  /// In en, this message translates to:
  /// **'{count} Items'**
  String cart_items(int count);

  /// No description provided for @cart_remove_item.
  ///
  /// In en, this message translates to:
  /// **'Remove Item'**
  String get cart_remove_item;

  /// No description provided for @cart_remove_confirm.
  ///
  /// In en, this message translates to:
  /// **'Remove this item from your cart?'**
  String get cart_remove_confirm;

  /// No description provided for @cart_coupon_remove.
  ///
  /// In en, this message translates to:
  /// **'Remove Coupon'**
  String get cart_coupon_remove;

  /// No description provided for @checkout_title.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout_title;

  /// No description provided for @checkout_delivery_address.
  ///
  /// In en, this message translates to:
  /// **'Delivery Address'**
  String get checkout_delivery_address;

  /// No description provided for @checkout_payment_method.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get checkout_payment_method;

  /// No description provided for @checkout_order_summary.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get checkout_order_summary;

  /// No description provided for @checkout_coupon.
  ///
  /// In en, this message translates to:
  /// **'Apply Coupon'**
  String get checkout_coupon;

  /// No description provided for @checkout_coupon_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter coupon code'**
  String get checkout_coupon_hint;

  /// No description provided for @checkout_coupon_applied.
  ///
  /// In en, this message translates to:
  /// **'Coupon applied!'**
  String get checkout_coupon_applied;

  /// No description provided for @checkout_coupon_invalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired coupon'**
  String get checkout_coupon_invalid;

  /// No description provided for @checkout_place_order.
  ///
  /// In en, this message translates to:
  /// **'Place Order'**
  String get checkout_place_order;

  /// No description provided for @checkout_cash_on_delivery.
  ///
  /// In en, this message translates to:
  /// **'Cash on Delivery'**
  String get checkout_cash_on_delivery;

  /// No description provided for @checkout_card.
  ///
  /// In en, this message translates to:
  /// **'Credit / Debit Card'**
  String get checkout_card;

  /// No description provided for @checkout_no_address.
  ///
  /// In en, this message translates to:
  /// **'Please select a delivery address'**
  String get checkout_no_address;

  /// No description provided for @checkout_processing.
  ///
  /// In en, this message translates to:
  /// **'Processing your order...'**
  String get checkout_processing;

  /// No description provided for @order_confirmed_title.
  ///
  /// In en, this message translates to:
  /// **'Order Confirmed!'**
  String get order_confirmed_title;

  /// No description provided for @order_confirmed_desc.
  ///
  /// In en, this message translates to:
  /// **'Your order #{orderId} has been placed successfully.'**
  String order_confirmed_desc(String orderId);

  /// No description provided for @order_track.
  ///
  /// In en, this message translates to:
  /// **'Track Order'**
  String get order_track;

  /// No description provided for @order_continue_shopping.
  ///
  /// In en, this message translates to:
  /// **'Continue Shopping'**
  String get order_continue_shopping;

  /// No description provided for @orders_title.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get orders_title;

  /// No description provided for @orders_empty.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get orders_empty;

  /// No description provided for @orders_empty_desc.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t placed any orders yet. Start shopping now!'**
  String get orders_empty_desc;

  /// No description provided for @order_detail_title.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get order_detail_title;

  /// No description provided for @order_status_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get order_status_pending;

  /// No description provided for @order_status_confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get order_status_confirmed;

  /// No description provided for @order_status_processing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get order_status_processing;

  /// No description provided for @order_status_shipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get order_status_shipped;

  /// No description provided for @order_status_delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get order_status_delivered;

  /// No description provided for @order_status_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get order_status_cancelled;

  /// No description provided for @order_status_refunded.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get order_status_refunded;

  /// No description provided for @order_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel Order'**
  String get order_cancel;

  /// No description provided for @order_cancel_confirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this order?'**
  String get order_cancel_confirm;

  /// No description provided for @order_cancel_reason.
  ///
  /// In en, this message translates to:
  /// **'Cancellation Reason'**
  String get order_cancel_reason;

  /// No description provided for @order_cancel_success.
  ///
  /// In en, this message translates to:
  /// **'Order cancelled successfully'**
  String get order_cancel_success;

  /// No description provided for @order_reorder.
  ///
  /// In en, this message translates to:
  /// **'Re-order'**
  String get order_reorder;

  /// No description provided for @order_reorder_success.
  ///
  /// In en, this message translates to:
  /// **'Items added to your cart!'**
  String get order_reorder_success;

  /// No description provided for @order_live_tracking.
  ///
  /// In en, this message translates to:
  /// **'Live Tracking'**
  String get order_live_tracking;

  /// No description provided for @order_filter_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get order_filter_all;

  /// No description provided for @order_filter_active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get order_filter_active;

  /// No description provided for @order_filter_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get order_filter_completed;

  /// No description provided for @order_filter_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get order_filter_cancelled;

  /// No description provided for @order_number.
  ///
  /// In en, this message translates to:
  /// **'Order Number'**
  String get order_number;

  /// No description provided for @order_date.
  ///
  /// In en, this message translates to:
  /// **'Order Date'**
  String get order_date;

  /// No description provided for @order_items_count.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String order_items_count(int count);

  /// No description provided for @favorites_title.
  ///
  /// In en, this message translates to:
  /// **'My Favorites'**
  String get favorites_title;

  /// No description provided for @favorites_empty.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get favorites_empty;

  /// No description provided for @favorites_empty_desc.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on any product to save it here.'**
  String get favorites_empty_desc;

  /// No description provided for @profile_title.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get profile_title;

  /// No description provided for @profile_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profile_edit;

  /// No description provided for @profile_orders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get profile_orders;

  /// No description provided for @profile_addresses.
  ///
  /// In en, this message translates to:
  /// **'Addresses'**
  String get profile_addresses;

  /// No description provided for @profile_notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profile_notifications;

  /// No description provided for @profile_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profile_settings;

  /// No description provided for @profile_help.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get profile_help;

  /// No description provided for @profile_about.
  ///
  /// In en, this message translates to:
  /// **'About ShopWave'**
  String get profile_about;

  /// No description provided for @profile_account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profile_account;

  /// No description provided for @profile_preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get profile_preferences;

  /// No description provided for @profile_privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get profile_privacy;

  /// No description provided for @profile_security.
  ///
  /// In en, this message translates to:
  /// **'Security & Password'**
  String get profile_security;

  /// No description provided for @profile_stat_orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get profile_stat_orders;

  /// No description provided for @profile_stat_wishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get profile_stat_wishlist;

  /// No description provided for @profile_stat_reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get profile_stat_reviews;

  /// No description provided for @profile_my_reviews.
  ///
  /// In en, this message translates to:
  /// **'My Reviews'**
  String get profile_my_reviews;

  /// No description provided for @profile_reviews_desc.
  ///
  /// In en, this message translates to:
  /// **'You have submitted {count} product review(s) so far.'**
  String profile_reviews_desc(int count);

  /// No description provided for @profile_verified_email.
  ///
  /// In en, this message translates to:
  /// **'Verified Email'**
  String get profile_verified_email;

  /// No description provided for @profile_change_password.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get profile_change_password;

  /// No description provided for @profile_update_password.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get profile_update_password;

  /// No description provided for @profile_password_weak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get profile_password_weak;

  /// No description provided for @profile_password_medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get profile_password_medium;

  /// No description provided for @profile_password_strong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get profile_password_strong;

  /// No description provided for @profile_two_factor.
  ///
  /// In en, this message translates to:
  /// **'Two-Factor Authentication'**
  String get profile_two_factor;

  /// No description provided for @profile_two_factor_enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get profile_two_factor_enabled;

  /// No description provided for @profile_two_factor_disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get profile_two_factor_disabled;

  /// No description provided for @profile_active_sessions.
  ///
  /// In en, this message translates to:
  /// **'Active Sessions'**
  String get profile_active_sessions;

  /// No description provided for @profile_email_verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get profile_email_verified;

  /// No description provided for @profile_email_not_verified.
  ///
  /// In en, this message translates to:
  /// **'Not Verified'**
  String get profile_email_not_verified;

  /// No description provided for @security_title.
  ///
  /// In en, this message translates to:
  /// **'Security & Password'**
  String get security_title;

  /// No description provided for @security_password_section.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get security_password_section;

  /// No description provided for @security_strength_title.
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get security_strength_title;

  /// No description provided for @security_req_length.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get security_req_length;

  /// No description provided for @security_req_case.
  ///
  /// In en, this message translates to:
  /// **'Upper & lowercase letters'**
  String get security_req_case;

  /// No description provided for @security_req_number.
  ///
  /// In en, this message translates to:
  /// **'At least one number'**
  String get security_req_number;

  /// No description provided for @security_req_special.
  ///
  /// In en, this message translates to:
  /// **'One special character (!@#...).'**
  String get security_req_special;

  /// No description provided for @support_title.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get support_title;

  /// No description provided for @support_faq.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get support_faq;

  /// No description provided for @support_contact.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get support_contact;

  /// No description provided for @support_whatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get support_whatsapp;

  /// No description provided for @support_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get support_email;

  /// No description provided for @support_hotline.
  ///
  /// In en, this message translates to:
  /// **'Toll-Free Hotline'**
  String get support_hotline;

  /// No description provided for @support_copy_success.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get support_copy_success;

  /// No description provided for @support_faq_q1.
  ///
  /// In en, this message translates to:
  /// **'How do I track my order?'**
  String get support_faq_q1;

  /// No description provided for @support_faq_a1.
  ///
  /// In en, this message translates to:
  /// **'You can track your order from the \'My Orders\' section in your profile.'**
  String get support_faq_a1;

  /// No description provided for @support_faq_q2.
  ///
  /// In en, this message translates to:
  /// **'What is your return policy?'**
  String get support_faq_q2;

  /// No description provided for @support_faq_a2.
  ///
  /// In en, this message translates to:
  /// **'You can return any product within 14 days of receiving it.'**
  String get support_faq_a2;

  /// No description provided for @support_faq_q3.
  ///
  /// In en, this message translates to:
  /// **'Is online payment secure?'**
  String get support_faq_q3;

  /// No description provided for @support_faq_a3.
  ///
  /// In en, this message translates to:
  /// **'Yes, all transactions are encrypted with 256-bit SSL technology.'**
  String get support_faq_a3;

  /// No description provided for @support_faq_q4.
  ///
  /// In en, this message translates to:
  /// **'When will my order arrive?'**
  String get support_faq_q4;

  /// No description provided for @support_faq_a4.
  ///
  /// In en, this message translates to:
  /// **'Usually within 2-5 business days within the Kingdom.'**
  String get support_faq_a4;

  /// No description provided for @support_faq_q5.
  ///
  /// In en, this message translates to:
  /// **'How do I use a discount coupon?'**
  String get support_faq_q5;

  /// No description provided for @support_faq_a5.
  ///
  /// In en, this message translates to:
  /// **'Enter the coupon code at checkout before confirming your order.'**
  String get support_faq_a5;

  /// No description provided for @privacy_title.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy_title;

  /// No description provided for @privacy_data_section.
  ///
  /// In en, this message translates to:
  /// **'Data Collection & Use'**
  String get privacy_data_section;

  /// No description provided for @privacy_payment_section.
  ///
  /// In en, this message translates to:
  /// **'Payment Security'**
  String get privacy_payment_section;

  /// No description provided for @privacy_rights_section.
  ///
  /// In en, this message translates to:
  /// **'Your Rights'**
  String get privacy_rights_section;

  /// No description provided for @address_title.
  ///
  /// In en, this message translates to:
  /// **'Addresses'**
  String get address_title;

  /// No description provided for @address_add.
  ///
  /// In en, this message translates to:
  /// **'Add Address'**
  String get address_add;

  /// No description provided for @address_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit Address'**
  String get address_edit;

  /// No description provided for @address_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete Address'**
  String get address_delete;

  /// No description provided for @address_set_default.
  ///
  /// In en, this message translates to:
  /// **'Set as Default'**
  String get address_set_default;

  /// No description provided for @address_default.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get address_default;

  /// No description provided for @address_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get address_home;

  /// No description provided for @address_work.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get address_work;

  /// No description provided for @address_full_name.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get address_full_name;

  /// No description provided for @address_phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get address_phone;

  /// No description provided for @address_city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get address_city;

  /// No description provided for @address_street.
  ///
  /// In en, this message translates to:
  /// **'Street Address'**
  String get address_street;

  /// No description provided for @address_postal.
  ///
  /// In en, this message translates to:
  /// **'Postal Code'**
  String get address_postal;

  /// No description provided for @address_building.
  ///
  /// In en, this message translates to:
  /// **'Building / Apartment'**
  String get address_building;

  /// No description provided for @address_saved.
  ///
  /// In en, this message translates to:
  /// **'Address saved'**
  String get address_saved;

  /// No description provided for @address_empty.
  ///
  /// In en, this message translates to:
  /// **'No saved addresses'**
  String get address_empty;

  /// No description provided for @address_empty_desc.
  ///
  /// In en, this message translates to:
  /// **'Add an address to speed up checkout.'**
  String get address_empty_desc;

  /// No description provided for @address_delete_confirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this address?'**
  String get address_delete_confirm;

  /// No description provided for @notifications_title.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications_title;

  /// No description provided for @notifications_empty.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get notifications_empty;

  /// No description provided for @notifications_mark_read.
  ///
  /// In en, this message translates to:
  /// **'Mark All as Read'**
  String get notifications_mark_read;

  /// No description provided for @notifications_order_update.
  ///
  /// In en, this message translates to:
  /// **'Order Update'**
  String get notifications_order_update;

  /// No description provided for @notifications_promo.
  ///
  /// In en, this message translates to:
  /// **'Special Offers'**
  String get notifications_promo;

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @settings_theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settings_theme;

  /// No description provided for @settings_theme_light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settings_theme_light;

  /// No description provided for @settings_theme_dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settings_theme_dark;

  /// No description provided for @settings_theme_system.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get settings_theme_system;

  /// No description provided for @settings_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_language;

  /// No description provided for @settings_language_en.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settings_language_en;

  /// No description provided for @settings_language_ar.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get settings_language_ar;

  /// No description provided for @settings_notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settings_notifications;

  /// No description provided for @settings_version.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get settings_version;

  /// No description provided for @settings_currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get settings_currency;

  /// No description provided for @search_hint.
  ///
  /// In en, this message translates to:
  /// **'What are you looking for?'**
  String get search_hint;

  /// No description provided for @search_empty.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String search_empty(String query);

  /// No description provided for @search_filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get search_filters;

  /// No description provided for @search_sort.
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get search_sort;

  /// No description provided for @search_sort_newest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get search_sort_newest;

  /// No description provided for @search_sort_price_asc.
  ///
  /// In en, this message translates to:
  /// **'Price: Low to High'**
  String get search_sort_price_asc;

  /// No description provided for @search_sort_price_desc.
  ///
  /// In en, this message translates to:
  /// **'Price: High to Low'**
  String get search_sort_price_desc;

  /// No description provided for @search_sort_rating.
  ///
  /// In en, this message translates to:
  /// **'Top Rated'**
  String get search_sort_rating;

  /// No description provided for @search_sort_popular.
  ///
  /// In en, this message translates to:
  /// **'Most Popular'**
  String get search_sort_popular;

  /// No description provided for @search_recent.
  ///
  /// In en, this message translates to:
  /// **'Recent Searches'**
  String get search_recent;

  /// No description provided for @search_clear_history.
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get search_clear_history;

  /// No description provided for @search_no_history.
  ///
  /// In en, this message translates to:
  /// **'No search history'**
  String get search_no_history;

  /// No description provided for @search_categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get search_categories;

  /// No description provided for @search_all_results.
  ///
  /// In en, this message translates to:
  /// **'All results for \"{query}\"'**
  String search_all_results(String query);

  /// No description provided for @search_filter_price_range.
  ///
  /// In en, this message translates to:
  /// **'Price Range'**
  String get search_filter_price_range;

  /// No description provided for @search_filter_min_rating.
  ///
  /// In en, this message translates to:
  /// **'Minimum Rating'**
  String get search_filter_min_rating;

  /// No description provided for @search_filter_category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get search_filter_category;

  /// No description provided for @search_filter_reset.
  ///
  /// In en, this message translates to:
  /// **'Reset Filters'**
  String get search_filter_reset;

  /// No description provided for @review_write.
  ///
  /// In en, this message translates to:
  /// **'Write a Review'**
  String get review_write;

  /// No description provided for @review_title.
  ///
  /// In en, this message translates to:
  /// **'Review Title'**
  String get review_title;

  /// No description provided for @review_body.
  ///
  /// In en, this message translates to:
  /// **'Your Review'**
  String get review_body;

  /// No description provided for @review_submit.
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get review_submit;

  /// No description provided for @review_no_reviews.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet. Be the first!'**
  String get review_no_reviews;

  /// No description provided for @review_rating_label.
  ///
  /// In en, this message translates to:
  /// **'{count} ratings'**
  String review_rating_label(int count);

  /// No description provided for @review_submitted.
  ///
  /// In en, this message translates to:
  /// **'Your review was submitted successfully'**
  String get review_submitted;

  /// No description provided for @review_helpful.
  ///
  /// In en, this message translates to:
  /// **'Was this helpful?'**
  String get review_helpful;

  /// No description provided for @coupon_title.
  ///
  /// In en, this message translates to:
  /// **'Coupons & Offers'**
  String get coupon_title;

  /// No description provided for @coupon_invalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid coupon code'**
  String get coupon_invalid;

  /// No description provided for @coupon_expired.
  ///
  /// In en, this message translates to:
  /// **'This coupon has expired'**
  String get coupon_expired;

  /// No description provided for @coupon_min_order.
  ///
  /// In en, this message translates to:
  /// **'Minimum order {amount} SAR'**
  String coupon_min_order(double amount);

  /// No description provided for @coupon_applied.
  ///
  /// In en, this message translates to:
  /// **'Coupon {code} applied'**
  String coupon_applied(String code);

  /// No description provided for @coupon_removed.
  ///
  /// In en, this message translates to:
  /// **'Coupon removed'**
  String get coupon_removed;

  /// No description provided for @admin_dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get admin_dashboard;

  /// No description provided for @admin_products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get admin_products;

  /// No description provided for @admin_orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get admin_orders;

  /// No description provided for @admin_users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get admin_users;

  /// No description provided for @admin_analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get admin_analytics;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
