import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final faqs = [
      (
        isAr ? 'كيف أتتبع طلبي بالوقت الفعلي؟' : 'How do I track my order live?',
        isAr
            ? 'يمكنك الانتقال إلى شاشة "طلباتي" والضغط على زر "تتبع"، حيث ستشاهد تحديثات فورية ومباشرة لحالة شحنتك ومراحل التوصيل من خلال تقنية Supabase Realtime.'
            : 'Navigate to "My Orders" and tap "Track". You will see real-time live updates on your package status and delivery stages powered by Supabase Realtime.',
      ),
      (
        isAr
            ? 'هل يمكنني إلغاء الطلب بعد تأكيده؟'
            : 'Can I cancel my order after placing it?',
        isAr
            ? 'نعم، يمكنك إلغاء الطلب طالما كانت حالته "تم الطلب" أو "قيد التجهيز". فقط افتح تفاصيل الطلب واضغط على "إلغاء الطلب" في أسفل الشاشة.'
            : 'Yes, you can cancel your order while it is still "Placed" or "Processing". Simply open the Order Details and tap "Cancel Order" at the bottom.',
      ),
      (
        isAr
            ? 'كيف تعمل ميزة إعادة الطلب بنقرة واحدة؟'
            : 'How does 1-tap re-ordering work?',
        isAr
            ? 'من شاشة الطلبات أو تفاصيل الطلب، اضغط على زر "إعادة الطلب"، وستتم إضافة كافة المنتجات بمقاساتها وألوانها الأصلية مباشرة إلى سلة التسوق الخاصة بك.'
            : 'From the Orders or Order Details screen, tap "Re-order", and all items with their exact variant sizes, colors, and prices will be added to your cart instantly.',
      ),
      (
        isAr ? 'ما هي طرق الدفع المتاحة؟' : 'What payment methods are supported?',
        isAr
            ? 'ندعم بطاقات مدى (Mada)، فيزا وماستركارد، آبل باي (Apple Pay)، تمارا وتابي للدفع الآجل، بالإضافة إلى الدفع عند الاستلام.'
            : 'We support Mada cards, Visa & MasterCard, Apple Pay, Tamara & Tabby installments, as well as Cash on Delivery.',
      ),
      (
        isAr
            ? 'كيف استخدم كوبونات وأكواد الخصم؟'
            : 'How do coupons and promo codes work?',
        isAr
            ? 'في شاشة السلة أو مرحلة الدفع، أدخل رمز الكوبون الترويجي في الحقل المخصص واضغط "تطبيق"، وسيتم احتساب الخصم فورياً ومزامنته مع السيرفر.'
            : 'In your Cart or Checkout screen, type your promo code into the coupon field and tap "Apply". The discount will calculate instantly with Supabase sync.',
      ),
    ];

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          isAr ? 'المساعدة والدعم الفني' : 'Help & Support',
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Contact Channels Banner ──────────────────────────────────
              Text(
                isAr ? 'قنوات التواصل المباشر' : 'Direct Support Channels',
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _ContactCard(
                      icon: Icons.chat_rounded,
                      iconColor: Colors.green,
                      title: isAr ? 'واتساب' : 'WhatsApp',
                      subtitle: '+966 50 123 4567',
                      onTap: () {
                        Clipboard.setData(
                          const ClipboardData(text: '+966501234567'),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isAr
                                  ? 'تم نسخ رقم الواتساب'
                                  : 'WhatsApp number copied!',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _ContactCard(
                      icon: Icons.email_rounded,
                      iconColor: AppColors.primary,
                      title: isAr ? 'البريد' : 'Email',
                      subtitle: 'support@shop.sa',
                      onTap: () {
                        Clipboard.setData(
                          const ClipboardData(text: 'support@shop.sa'),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isAr
                                  ? 'تم نسخ البريد الإلكتروني'
                                  : 'Email copied!',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              _ContactCard(
                icon: Icons.phone_in_talk_rounded,
                iconColor: Colors.purple,
                title: isAr
                    ? 'الرقم المجاني الموحد (خدمة العملاء)'
                    : 'Customer Care Toll-Free',
                subtitle:
                    '800-123-SHOP (السبت - الخميس 8:00 ص إلى 10:00 م)',
                onTap: () {
                  Clipboard.setData(const ClipboardData(text: '8001237467'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isAr ? 'تم نسخ الرقم المجاني' : 'Toll-free number copied!',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── FAQ Accordion ─────────────────────────────────────────────
              Text(
                isAr ? 'الأسئلة الشائعة (FAQ)' : 'Frequently Asked Questions',
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...faqs.map(
                (faq) => Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceDark
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                  ),
                  child: ExpansionTile(
                    shape: const Border(),
                    title: Text(
                      faq.$1,
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Text(
                          faq.$2,
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 13,
                            height: 1.5,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 11,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
