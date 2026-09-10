import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final sections = [
      (
        Icons.verified_user_outlined,
        isAr ? 'حماية وأمان البيانات' : 'Data Protection & Privacy',
        isAr
            ? 'نلتزم في ShopWave بحماية بياناتك الشخصية ومعلوماتك الحساسة وفقاً لأعلى المعايير والأنظمة المعتمدة في المملكة العربية السعودية. لا نقوم بمشاركة أي معلومات شخصية مع أطراف ثالثة لأغراض دعائية إطلاقاً.'
            : 'At ShopWave, we strictly protect your personal information and sensitive data in full compliance with recognized privacy laws. We never share or sell personal data to third parties for marketing purposes.',
      ),
      (
        Icons.lock_outline_rounded,
        isAr ? 'تشفير المدفوعات والبطاقات' : 'Encrypted Payments',
        isAr
            ? 'تتم جميع المعاملات المالية عبر بوابات دفع آمنة ومشفرة بتقنية SSL 256-bit ومتوافقة مع معايير PCI-DSS العالمية. لا يقوم التطبيق بتخزين أرقام بطاقاتك الائتمانية أو رموز CVV.'
            : 'All payment transactions are processed through highly secure 256-bit SSL encrypted gateways complying with global PCI-DSS standards. We never store credit card numbers or CVV codes.',
      ),
      (
        Icons.local_shipping_outlined,
        isAr ? 'عناوين التوصيل وسجل الشحنات' : 'Delivery & Addresses',
        isAr
            ? 'تُستخدم بيانات الموقع والعناوين المحفوظة فقط لتسهيل وصول الشحنات وضمان دقة مواعيد التسليم بواسطة شركات الشحن المعتمدة لدينا.'
            : 'Saved delivery addresses and contact information are strictly utilized to ensure accurate order delivery and courier fulfillment.',
      ),
      (
        Icons.delete_outline_rounded,
        isAr ? 'حقوق المستخدم وحذف الحساب' : 'User Rights & Data Deletion',
        isAr
            ? 'يحق لك في أي وقت تعديل بياناتك الشخصية أو طلب إغلاق وحذف حسابك وسجلك من خلال التواصل المباشر مع فريق الدعم الفني عبر البريد الإلكتروني.'
            : 'You hold the right to modify, export, or permanently delete your account and profile data at any time by contacting our support team.',
      ),
    ];

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          isAr ? 'سياسة الخصوصية والشروط' : 'Privacy & Terms',
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
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.gavel_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        isAr
                            ? 'آخر تحديث: سبتمبر 2026 • تضمن شروط الخصوصية حماية كاملة لتجربة تسوقك.'
                            : 'Last updated: September 2026 • Your rights and safety are our top priority.',
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ...sections.map(
                (sec) => Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceDark
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(sec.$1, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            sec.$2,
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        sec.$3,
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 13,
                          height: 1.5,
                          color: theme.colorScheme.onSurfaceVariant,
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
