import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/guest_auth_prompt.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../providers/profile_providers.dart';

/// Profile screen — user account overview and navigation hub.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final user = authState is AuthAuthenticated ? authState.user : null;
    final statsAsync = ref.watch(profileStatsProvider);
    final stats = statsAsync.value;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // ── Profile Header ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.paddingOf(context).top + AppSpacing.md,
                bottom: AppSpacing.xl,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.secondary],
                ),
              ),
              child: Column(
                children: [
                  if (user != null) ...[
                    // Avatar
                    Stack(
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.white.withValues(alpha: 0.5),
                              width: 3,
                            ),
                          ),
                          child: user.avatarUrl != null
                              ? ClipOval(
                                  child: Image.network(
                                    user.avatarUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        _InitialsAvatar(initials: user.initials),
                                  ),
                                )
                              : _InitialsAvatar(
                                  initials: user.initials,
                                ),
                        ),
                        // Edit button
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => context.push(AppRoutes.editProfile),
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: const BoxDecoration(
                                color: AppColors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit_rounded,
                                size: 14,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      user.displayName,
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 14,
                        color: AppColors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ] else ...[
                    // Guest Header
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.white.withValues(alpha: 0.5),
                          width: 3,
                        ),
                      ),
                      child: const Icon(
                        Icons.person_outline_rounded,
                        size: 44,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      isAr ? 'مرحباً بك في ShopWave 👋' : 'Welcome to ShopWave 👋',
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        isAr
                            ? 'سجّل دخولك للوصول إلى طلباتك وعناوينك وإعدادات حسابك'
                            : 'Sign in to access your orders, addresses, and account settings',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 13,
                          color: AppColors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ElevatedButton.icon(
                      onPressed: () => context.push(AppRoutes.login),
                      icon: const Icon(Icons.login_rounded, size: 18),
                      label: Text(
                        isAr ? 'تسجيل الدخول / إنشاء حساب' : 'Sign In / Register',
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.primary,
                        elevation: 3,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ── Stats Row ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
              child: Row(
                children: [
                  _StatCard(
                    label: isAr ? 'الطلبات' : 'Orders',
                    value: user != null && stats != null ? '${stats.ordersCount}' : '0',
                    icon: Icons.shopping_bag_outlined,
                    onTap: () {
                      if (user == null) {
                        GuestAuthPrompt.show(
                          context,
                          title: isAr ? 'سجل الطلبات' : 'Order History',
                          message: isAr
                              ? 'سجّل دخولك لتتبع مشترياتك السابقة والحالية ومعرفة حالة الشحن.'
                              : 'Sign in to view your past and active orders and track shipping.',
                          icon: Icons.receipt_long_outlined,
                        );
                      } else {
                        context.push(AppRoutes.orders);
                      }
                    },
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _StatCard(
                    label: isAr ? 'المفضلة' : 'Wishlist',
                    value: user != null && stats != null ? '${stats.wishlistCount}' : '0',
                    icon: Icons.favorite_outline_rounded,
                    onTap: () => context.push(AppRoutes.favorites),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _StatCard(
                    label: isAr ? 'التقييمات' : 'Reviews',
                    value: user != null && stats != null ? '${stats.reviewsCount}' : '0',
                    icon: Icons.star_outline_rounded,
                    onTap: () {
                      if (user == null) {
                        GuestAuthPrompt.show(
                          context,
                          title: isAr ? 'التقييمات والمراجعات' : 'Reviews',
                          message: isAr
                              ? 'سجّل دخولك لإضافة ومراجعة تقييمات المنتجات ومساعدة المتسوقين.'
                              : 'Sign in to write product reviews and view your review history.',
                          icon: Icons.star_outline_rounded,
                        );
                      } else {
                        _showReviewsInfo(
                          context,
                          isAr,
                          stats?.reviewsCount ?? 0,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          // ── Menu Items ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
              ),
              child: Column(
                children: [
                  _ProfileSection(
                    title: context.l10n.profile_account,
                    items: [
                      _ProfileMenuItem(
                        icon: Icons.person_outline_rounded,
                        label: context.l10n.profile_edit,
                        onTap: () {
                          if (user == null) {
                            GuestAuthPrompt.show(
                              context,
                              title: isAr ? 'تعديل الملف الشخصي' : 'Edit Profile',
                              message: isAr
                                  ? 'سجّل دخولك لتعديل بياناتك الشخصية وصورة الحساب.'
                                  : 'Sign in to update your personal information and profile picture.',
                              icon: Icons.person_outline_rounded,
                            );
                          } else {
                            context.push(AppRoutes.editProfile);
                          }
                        },
                      ),
                      _ProfileMenuItem(
                        icon: Icons.shield_outlined,
                        label: isAr
                            ? 'الأمان وكلمة المرور'
                            : 'Security & Password',
                        onTap: () {
                          if (user == null) {
                            GuestAuthPrompt.show(
                              context,
                              title: isAr ? 'الأمان وكلمة المرور' : 'Security & Password',
                              message: isAr
                                  ? 'سجّل دخولك لإدارة أمان حسابك وكلمة المرور.'
                                  : 'Sign in to manage your account security and password.',
                              icon: Icons.shield_outlined,
                            );
                          } else {
                            context.push(AppRoutes.security);
                          }
                        },
                      ),
                      _ProfileMenuItem(
                        icon: Icons.location_on_outlined,
                        label: context.l10n.profile_addresses,
                        onTap: () {
                          if (user == null) {
                            GuestAuthPrompt.show(
                              context,
                              title: isAr ? 'العناوين المحفوظة' : 'Saved Addresses',
                              message: isAr
                                  ? 'سجّل دخولك لإدارة عناوين الشحن والتوصيل الخاصة بك.'
                                  : 'Sign in to manage your saved delivery addresses.',
                              icon: Icons.location_on_outlined,
                            );
                          } else {
                            context.push(AppRoutes.addresses);
                          }
                        },
                      ),
                      _ProfileMenuItem(
                        icon: Icons.receipt_long_outlined,
                        label: context.l10n.profile_orders,
                        onTap: () {
                          if (user == null) {
                            GuestAuthPrompt.show(
                              context,
                              title: isAr ? 'سجل الطلبات' : 'My Orders',
                              message: isAr
                                  ? 'سجّل دخولك للاطلاع على طلباتك وتتبع شحناتك.'
                                  : 'Sign in to view your orders and track shipments.',
                              icon: Icons.receipt_long_outlined,
                            );
                          } else {
                            context.push(AppRoutes.orders);
                          }
                        },
                      ),
                      _ProfileMenuItem(
                        icon: Icons.notifications_outlined,
                        label: context.l10n.profile_notifications,
                        onTap: () {
                          if (user == null) {
                            GuestAuthPrompt.show(
                              context,
                              title: isAr ? 'الإشعارات' : 'Notifications',
                              message: isAr
                                  ? 'سجّل دخولك لتلقي تنبيهات العروض والطلبات الخاصة بك.'
                                  : 'Sign in to view your personalized notifications and deal alerts.',
                              icon: Icons.notifications_outlined,
                            );
                          } else {
                            context.push(AppRoutes.notifications);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _ProfileSection(
                    title: context.l10n.profile_preferences,
                    items: [
                      _ProfileMenuItem(
                        icon: Icons.settings_outlined,
                        label: context.l10n.profile_settings,
                        onTap: () => context.push(AppRoutes.settings),
                      ),
                      _ProfileMenuItem(
                        icon: Icons.help_outline_rounded,
                        label: context.l10n.profile_help,
                        onTap: () => context.push(AppRoutes.helpSupport),
                      ),
                      _ProfileMenuItem(
                        icon: Icons.privacy_tip_outlined,
                        label: context.l10n.profile_privacy,
                        onTap: () => context.push(AppRoutes.privacyPolicy),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // ── Admin Panel button (only for admins) ───────────
                  if (user != null && user.isAdmin) ...[
                    _AdminPanelButton(user: user),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  // Sign Out (only for logged-in users)
                  if (user != null) ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await ref
                              .read(authNotifierProvider.notifier)
                              .signOut();
                        },
                        icon: const Icon(
                          Icons.logout_rounded,
                          color: AppColors.badge,
                        ),
                        label: Text(
                          context.l10n.auth_logout,
                          style: const TextStyle(color: AppColors.badge),
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize:
                              const Size.fromHeight(AppSpacing.buttonHeight),
                          side: const BorderSide(color: AppColors.badge),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showReviewsInfo(BuildContext context, bool isAr, int count) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.star_rounded, color: Colors.amber, size: 28),
            const SizedBox(width: 8),
            Text(
              isAr ? 'تقييماتي ومراجعاتي' : 'My Reviews',
              style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Text(
          isAr
              ? 'لقد قمت بكتابة $count تقييم للمنتجات حتى الآن. تظهر تقييماتك للمتسوقين لمساعدتهم في اتخاذ قرارات الشراء.'
              : 'You have submitted $count product review(s) so far. Your feedback helps other shoppers make informed choices.',
          style: const TextStyle(fontFamily: 'Outfit', height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(isAr ? 'حسناً' : 'OK'),
          ),
        ],
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({required this.initials});
  final String initials;

  @override
  Widget build(BuildContext context) => Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
      );
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : AppColors.primary.withValues(alpha: 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? AppColors.shadowDark : AppColors.shadowLight,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: AppColors.primary),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.title, required this.items});
  final String title;
  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.shadowDark : AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...items,
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, size: 20),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );
}

/// Admin panel button — only shown to admin/super_admin users.
class _AdminPanelButton extends StatelessWidget {
  const _AdminPanelButton({required this.user});
  final dynamic user;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(AppRoutes.adminDashboard),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFFFF6584)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: const Color(0xFF6C63FF).withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Admin Panel', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white)),
            Text('Manage your store', style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: Colors.white70)),
          ])),
          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
        ]),
      ),
    );
  }
}

