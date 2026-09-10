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
  String get general_confirm => 'تأكيد';

  @override
  String get general_close => 'إغلاق';

  @override
  String get general_clear => 'مسح';

  @override
  String get general_apply => 'تطبيق';

  @override
  String get general_copy => 'نسخ';

  @override
  String get general_copied => 'تم النسخ!';

  @override
  String get general_share => 'مشاركة';

  @override
  String get general_add => 'إضافة';

  @override
  String get general_remove => 'إزالة';

  @override
  String get general_update => 'تحديث';

  @override
  String get general_success => 'تمت العملية بنجاح';

  @override
  String get general_view_all => 'عرض الكل';

  @override
  String get general_go_home => 'العودة للرئيسية';

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
  String get auth_logout_confirm => 'هل أنت متأكد من تسجيل الخروج؟';

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
  String get auth_password_new => 'كلمة المرور الجديدة';

  @override
  String get auth_password_new_hint => 'أدخل كلمة المرور الجديدة';

  @override
  String get auth_password_current => 'كلمة المرور الحالية';

  @override
  String get auth_password_current_hint => 'أدخل كلمة المرور الحالية';

  @override
  String get auth_password_updated => 'تم تحديث كلمة المرور بنجاح';

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
  String get home_greeting_morning => 'صباح الخير';

  @override
  String get home_greeting_afternoon => 'مساء الخير';

  @override
  String get home_greeting_evening => 'مساء النور';

  @override
  String get home_no_products => 'لا توجد منتجات في هذه الفئة';

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
  String product_items_left(int count) {
    return 'تبقى $count فقط';
  }

  @override
  String product_discount_badge(int percent) {
    return 'خصم $percent%';
  }

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
  String get cart_remove_item => 'إزالة العنصر';

  @override
  String get cart_remove_confirm => 'هل تريد إزالة هذا العنصر من السلة؟';

  @override
  String get cart_coupon_remove => 'إزالة الكوبون';

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
  String get checkout_no_address => 'يرجى اختيار عنوان التوصيل';

  @override
  String get checkout_processing => 'جارٍ معالجة طلبك...';

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
  String get orders_empty_desc => 'لم تقم بأي طلب بعد. ابدأ التسوق الآن!';

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
  String get order_cancel => 'إلغاء الطلب';

  @override
  String get order_cancel_confirm => 'هل تريد إلغاء هذا الطلب؟';

  @override
  String get order_cancel_reason => 'سبب الإلغاء';

  @override
  String get order_cancel_success => 'تم إلغاء الطلب بنجاح';

  @override
  String get order_reorder => 'إعادة الطلب';

  @override
  String get order_reorder_success => 'تمت إضافة المنتجات إلى السلة!';

  @override
  String get order_live_tracking => 'تتبع مباشر';

  @override
  String get order_filter_all => 'الكل';

  @override
  String get order_filter_active => 'نشط';

  @override
  String get order_filter_completed => 'مكتمل';

  @override
  String get order_filter_cancelled => 'ملغي';

  @override
  String get order_number => 'رقم الطلب';

  @override
  String get order_date => 'تاريخ الطلب';

  @override
  String order_items_count(int count) {
    return '$count منتجات';
  }

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
  String get profile_security => 'الأمان وكلمة المرور';

  @override
  String get profile_stat_orders => 'الطلبات';

  @override
  String get profile_stat_wishlist => 'المفضلة';

  @override
  String get profile_stat_reviews => 'التقييمات';

  @override
  String get profile_my_reviews => 'تقييماتي ومراجعاتي';

  @override
  String profile_reviews_desc(int count) {
    return 'لقد قمت بكتابة $count تقييم للمنتجات حتى الآن.';
  }

  @override
  String get profile_verified_email => 'بريد إلكتروني موثق';

  @override
  String get profile_change_password => 'تغيير كلمة المرور';

  @override
  String get profile_update_password => 'تحديث كلمة المرور';

  @override
  String get profile_password_weak => 'ضعيف';

  @override
  String get profile_password_medium => 'متوسط';

  @override
  String get profile_password_strong => 'قوي';

  @override
  String get profile_two_factor => 'التحقق بخطوتين';

  @override
  String get profile_two_factor_enabled => 'مُفعّل';

  @override
  String get profile_two_factor_disabled => 'غير مُفعّل';

  @override
  String get profile_active_sessions => 'الجلسات النشطة';

  @override
  String get profile_email_verified => 'موثق';

  @override
  String get profile_email_not_verified => 'غير موثق';

  @override
  String get security_title => 'الأمان وكلمة المرور';

  @override
  String get security_password_section => 'تغيير كلمة المرور';

  @override
  String get security_strength_title => 'مستوى القوة';

  @override
  String get security_req_length => '8 أحرف على الأقل';

  @override
  String get security_req_case => 'أحرف كبيرة وصغيرة';

  @override
  String get security_req_number => 'رقم واحد على الأقل';

  @override
  String get security_req_special => 'رمز خاص واحد (!@#...).';

  @override
  String get support_title => 'المساعدة والدعم';

  @override
  String get support_faq => 'الأسئلة الشائعة';

  @override
  String get support_contact => 'تواصل معنا';

  @override
  String get support_whatsapp => 'واتساب';

  @override
  String get support_email => 'البريد الإلكتروني';

  @override
  String get support_hotline => 'الخط الساخن';

  @override
  String get support_copy_success => 'تم النسخ';

  @override
  String get support_faq_q1 => 'كيف أتتبع طلبي؟';

  @override
  String get support_faq_a1 =>
      'يمكنك متابعة حالة طلبك من قسم \"طلباتي\" في حسابك.';

  @override
  String get support_faq_q2 => 'ما هي سياسة الإرجاع؟';

  @override
  String get support_faq_a2 =>
      'يمكنك إرجاع أي منتج خلال 14 يوماً من تاريخ الاستلام.';

  @override
  String get support_faq_q3 => 'هل الدفع الإلكتروني آمن؟';

  @override
  String get support_faq_a3 => 'نعم، جميع المعاملات مشفرة بتقنية SSL 256 بت.';

  @override
  String get support_faq_q4 => 'متى يصل طلبي؟';

  @override
  String get support_faq_a4 => 'عادةً خلال 2-5 أيام عمل داخل المملكة.';

  @override
  String get support_faq_q5 => 'كيف أستخدم كوبون الخصم؟';

  @override
  String get support_faq_a5 =>
      'أدخل رمز الكوبون في صفحة الدفع قبل تأكيد الطلب.';

  @override
  String get privacy_title => 'سياسة الخصوصية';

  @override
  String get privacy_data_section => 'جمع البيانات واستخدامها';

  @override
  String get privacy_payment_section => 'أمان المدفوعات';

  @override
  String get privacy_rights_section => 'حقوقك';

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
  String get address_empty => 'لا يوجد عناوين محفوظة';

  @override
  String get address_empty_desc => 'أضف عنواناً لتسريع عملية الطلب.';

  @override
  String get address_delete_confirm => 'هل تريد حذف هذا العنوان؟';

  @override
  String get notifications_title => 'الإشعارات';

  @override
  String get notifications_empty => 'لا يوجد إشعارات';

  @override
  String get notifications_mark_read => 'تعليم الكل كمقروء';

  @override
  String get notifications_order_update => 'تحديث الطلب';

  @override
  String get notifications_promo => 'عروض خاصة';

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
  String get settings_currency => 'العملة';

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
  String get search_recent => 'عمليات البحث الأخيرة';

  @override
  String get search_clear_history => 'مسح السجل';

  @override
  String get search_no_history => 'لا يوجد سجل بحث';

  @override
  String get search_categories => 'الفئات';

  @override
  String search_all_results(String query) {
    return 'جميع النتائج لـ \"$query\"';
  }

  @override
  String get search_filter_price_range => 'نطاق السعر';

  @override
  String get search_filter_min_rating => 'أدنى تقييم';

  @override
  String get search_filter_category => 'الفئة';

  @override
  String get search_filter_reset => 'إعادة التعيين';

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

  @override
  String get review_submitted => 'تم إرسال تقييمك بنجاح';

  @override
  String get review_helpful => 'هل كان هذا مفيداً؟';

  @override
  String get coupon_title => 'الكوبونات والعروض';

  @override
  String get coupon_invalid => 'رمز الكوبون غير صالح';

  @override
  String get coupon_expired => 'انتهت صلاحية هذا الكوبون';

  @override
  String coupon_min_order(double amount) {
    return 'الحد الأدنى للطلب $amount ر.س';
  }

  @override
  String coupon_applied(String code) {
    return 'تم تطبيق كوبون $code';
  }

  @override
  String get coupon_removed => 'تم إزالة الكوبون';

  @override
  String get admin_dashboard => 'لوحة التحكم';

  @override
  String get admin_products => 'المنتجات';

  @override
  String get admin_orders => 'الطلبات';

  @override
  String get admin_users => 'المستخدمون';

  @override
  String get admin_analytics => 'التحليلات';
}
