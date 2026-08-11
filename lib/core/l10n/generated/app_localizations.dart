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
