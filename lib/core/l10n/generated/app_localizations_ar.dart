// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'شوب ويف';

  @override
  String get general_ok => 'حسناً';

  @override
  String get general_cancel => 'إلغاء';

  @override
  String get general_retry => 'إعادة المحاولة';

  @override
  String get general_save => 'حفظ';

  @override
  String get general_delete => 'حذف';

  @override
  String get general_edit => 'تعديل';

  @override
  String get general_done => 'تم';

  @override
  String get general_back => 'رجوع';

  @override
  String get general_next => 'التالي';

  @override
  String get general_search => 'بحث';

  @override
  String get general_loading => 'جارٍ التحميل...';

  @override
  String get general_error => 'حدث خطأ ما';

  @override
  String get general_no_internet => 'لا يوجد اتصال بالإنترنت';

  @override
  String get general_no_internet_desc =>
      'يرجى التحقق من اتصالك والمحاولة مجدداً.';

  @override
  String get general_server_error => 'خطأ في الخادم. يرجى المحاولة مجدداً.';

  @override
  String get general_empty => 'لا يوجد شيء هنا بعد';

  @override
  String get general_required => 'هذا الحقل مطلوب';

  @override
  String get general_see_all => 'عرض الكل';

  @override
  String get general_sar => 'ر.س';

  @override
  String get general_free => 'مجاني';

  @override
  String get onboarding_skip => 'تخطي';

  @override
  String get onboarding_get_started => 'ابدأ الآن';

  @override
  String get onboarding_slide1_title => 'اكتشف منتجات رائعة';

  @override
  String get onboarding_slide1_desc =>
      'تصفح آلاف المنتجات من أفضل الماركات في مكان واحد.';

  @override
  String get onboarding_slide2_title => 'دفع سريع وآمن';

  @override
  String get onboarding_slide2_desc => 'تسوق بثقة. مدفوعات آمنة وإرجاع سهل.';

  @override
  String get onboarding_slide3_title => 'تتبع طلباتك';

  @override
  String get onboarding_slide3_desc =>
      'تحديثات فورية لكل طلب حتى يصل إلى بابك.';

  @override
  String get auth_login => 'تسجيل الدخول';

  @override
  String get auth_register => 'إنشاء حساب';

  @override
  String get auth_logout => 'تسجيل الخروج';

  @override
  String get auth_email => 'البريد الإلكتروني';

  @override
  String get auth_email_hint => 'أدخل بريدك الإلكتروني';

  @override
  String get auth_email_invalid => 'يرجى إدخال بريد إلكتروني صحيح';

  @override
  String get auth_password => 'كلمة المرور';

  @override
  String get auth_password_hint => 'أدخل كلمة المرور';

  @override
  String get auth_password_min => 'يجب أن تكون كلمة المرور 8 أحرف على الأقل';

  @override
  String get auth_password_confirm => 'تأكيد كلمة المرور';

  @override
  String get auth_password_mismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get auth_full_name => 'الاسم الكامل';

  @override
  String get auth_full_name_hint => 'أدخل اسمك الكامل';

  @override
  String get auth_full_name_min => 'يجب أن يكون الاسم حرفين على الأقل';

  @override
  String get auth_phone => 'رقم الهاتف';

  @override
  String get auth_forgot_password => 'نسيت كلمة المرور؟';

  @override
  String get auth_reset_password => 'إعادة تعيين كلمة المرور';

  @override
  String get auth_reset_sent => 'تم إرسال رابط الإعادة إلى بريدك الإلكتروني';

  @override
  String get auth_no_account => 'ليس لديك حساب؟';

  @override
  String get auth_have_account => 'لديك حساب بالفعل؟';

  @override
  String get auth_or => 'أو';

  @override
  String get auth_continue_google => 'المتابعة مع Google';

  @override
  String get auth_otp_title => 'إدخال رمز OTP';

  @override
  String auth_otp_desc(String email) {
    return 'أرسلنا رمزاً مكوناً من 6 أرقام إلى $email';
  }

  @override
  String get auth_otp_resend => 'إعادة إرسال الرمز';

  @override
  String auth_otp_resend_in(int seconds) {
    return 'إعادة الإرسال خلال $seconds ث';
  }

  @override
  String get nav_home => 'الرئيسية';

  @override
  String get nav_categories => 'الفئات';

  @override
  String get nav_cart => 'السلة';

  @override
  String get nav_favorites => 'المفضلة';

  @override
  String get nav_profile => 'حسابي';

  @override
  String get home_search_hint => 'ابحث عن منتجات...';

  @override
  String get home_banners => 'مميز';

  @override
  String get home_categories => 'الفئات';

  @override
  String get home_flash_deals => 'عروض سريعة';

  @override
  String get home_featured => 'منتجات مميزة';

  @override
  String get home_new_arrivals => 'وصل حديثاً';

  @override
  String get home_best_sellers => 'الأكثر مبيعاً';

  @override
  String get product_add_to_cart => 'أضف إلى السلة';

  @override
  String get product_buy_now => 'اشتري الآن';

  @override
  String get product_out_of_stock => 'نفد المخزون';

  @override
  String get product_in_stock => 'متوفر';

  @override
  String get product_description => 'الوصف';

  @override
  String get product_reviews => 'التقييمات';

  @override
  String get product_related => 'قد يعجبك أيضاً';

  @override
  String get product_select_variant => 'اختر الخيارات';

  @override
  String get product_size => 'المقاس';

  @override
  String get product_color => 'اللون';

  @override
  String get product_quantity => 'الكمية';

  @override
  String get product_share => 'مشاركة';

  @override
  String get product_added_to_cart => 'تمت الإضافة إلى السلة!';

  @override
  String get product_added_to_favorites => 'أضيف إلى المفضلة';

  @override
  String get product_removed_from_favorites => 'حُذف من المفضلة';

  @override
  String get cart_title => 'سلة التسوق';

  @override
  String get cart_empty => 'سلتك فارغة';

  @override
  String get cart_empty_desc => 'يبدو أنك لم تضف أي شيء بعد.';

  @override
  String get cart_shop_now => 'تسوق الآن';

  @override
  String get cart_subtotal => 'الإجمالي الجزئي';

  @override
  String get cart_shipping => 'الشحن';

  @override
  String get cart_discount => 'الخصم';

  @override
  String get cart_total => 'الإجمالي';

  @override
  String get cart_checkout => 'المتابعة للدفع';

  @override
  String cart_items(int count) {
    return '$count عناصر';
  }

  @override
  String get checkout_title => 'إتمام الطلب';

  @override
  String get checkout_delivery_address => 'عنوان التوصيل';

  @override
  String get checkout_payment_method => 'طريقة الدفع';

  @override
  String get checkout_order_summary => 'ملخص الطلب';

  @override
  String get checkout_coupon => 'تطبيق كوبون';

  @override
  String get checkout_coupon_hint => 'أدخل رمز الكوبون';

  @override
  String get checkout_coupon_applied => 'تم تطبيق الكوبون!';

  @override
  String get checkout_coupon_invalid => 'كوبون غير صالح أو منتهي الصلاحية';

  @override
  String get checkout_place_order => 'تأكيد الطلب';

  @override
  String get checkout_cash_on_delivery => 'الدفع عند الاستلام';

  @override
  String get checkout_card => 'بطاقة ائتمانية / مدى';

  @override
  String get order_confirmed_title => 'تم تأكيد طلبك!';

  @override
  String order_confirmed_desc(String orderId) {
    return 'تم وضع طلبك #$orderId بنجاح.';
  }

  @override
  String get order_track => 'تتبع الطلب';

  @override
  String get order_continue_shopping => 'مواصلة التسوق';

  @override
  String get orders_title => 'طلباتي';

  @override
  String get orders_empty => 'لا يوجد طلبات بعد';

  @override
  String get order_detail_title => 'تفاصيل الطلب';

  @override
  String get order_status_pending => 'قيد الانتظار';

  @override
  String get order_status_confirmed => 'مؤكد';

  @override
  String get order_status_processing => 'جارٍ المعالجة';

  @override
  String get order_status_shipped => 'تم الشحن';

  @override
  String get order_status_delivered => 'تم التسليم';

  @override
  String get order_status_cancelled => 'ملغي';

  @override
  String get order_status_refunded => 'مُسترد';

  @override
  String get favorites_title => 'المفضلة';

  @override
  String get favorites_empty => 'لا يوجد مفضلة بعد';

  @override
  String get favorites_empty_desc => 'اضغط على القلب في أي منتج لحفظه هنا.';

  @override
  String get profile_title => 'حسابي';

  @override
  String get profile_edit => 'تعديل الملف الشخصي';

  @override
  String get profile_orders => 'طلباتي';

  @override
  String get profile_addresses => 'العناوين';

  @override
  String get profile_notifications => 'الإشعارات';

  @override
  String get profile_settings => 'الإعدادات';

  @override
  String get profile_help => 'المساعدة والدعم';

  @override
  String get profile_about => 'عن شوب ويف';

  @override
  String get profile_account => 'الحساب';

  @override
  String get profile_preferences => 'التفضيلات';

  @override
  String get profile_privacy => 'سياسة الخصوصية';

  @override
  String get address_title => 'العناوين';

  @override
  String get address_add => 'إضافة عنوان';

  @override
  String get address_edit => 'تعديل العنوان';

  @override
  String get address_delete => 'حذف العنوان';

  @override
  String get address_set_default => 'تعيين كافتراضي';

  @override
  String get address_default => 'افتراضي';

  @override
  String get address_home => 'المنزل';

  @override
  String get address_work => 'العمل';

  @override
  String get address_full_name => 'الاسم الكامل';

  @override
  String get address_phone => 'الهاتف';

  @override
  String get address_city => 'المدينة';

  @override
  String get address_street => 'عنوان الشارع';

  @override
  String get address_postal => 'الرمز البريدي';

  @override
  String get address_building => 'المبنى / الشقة';

  @override
  String get address_saved => 'تم حفظ العنوان';

  @override
  String get notifications_title => 'الإشعارات';

  @override
  String get notifications_empty => 'لا يوجد إشعارات';

  @override
  String get notifications_mark_read => 'تعليم الكل كمقروء';

  @override
  String get settings_title => 'الإعدادات';

  @override
  String get settings_theme => 'المظهر';

  @override
  String get settings_theme_light => 'فاتح';

  @override
  String get settings_theme_dark => 'داكن';

  @override
  String get settings_theme_system => 'إعداد النظام';

  @override
  String get settings_language => 'اللغة';

  @override
  String get settings_language_en => 'الإنجليزية';

  @override
  String get settings_language_ar => 'العربية';

  @override
  String get settings_notifications => 'الإشعارات';

  @override
  String get settings_version => 'إصدار التطبيق';

  @override
  String get search_hint => 'عن ماذا تبحث؟';

  @override
  String search_empty(String query) {
    return 'لا نتائج لـ \"$query\"';
  }

  @override
  String get search_filters => 'تصفية';

  @override
  String get search_sort => 'ترتيب حسب';

  @override
  String get search_sort_newest => 'الأحدث';

  @override
  String get search_sort_price_asc => 'السعر: من الأقل للأعلى';

  @override
  String get search_sort_price_desc => 'السعر: من الأعلى للأقل';

  @override
  String get search_sort_rating => 'الأعلى تقييماً';

  @override
  String get search_sort_popular => 'الأكثر شعبية';

  @override
  String get review_write => 'كتابة تقييم';

  @override
  String get review_title => 'عنوان التقييم';

  @override
  String get review_body => 'تقييمك';

  @override
  String get review_submit => 'إرسال التقييم';

  @override
  String get review_no_reviews => 'لا يوجد تقييمات بعد. كن الأول!';

  @override
  String review_rating_label(int count) {
    return '$count تقييم';
  }
}
