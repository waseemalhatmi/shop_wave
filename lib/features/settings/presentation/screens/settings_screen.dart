import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/extensions/context_ext.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    
    final themeMode = ref.watch(themeModeNotifierProvider);
    final locale = ref.watch(localeNotifierProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          context.l10n.settings_title,
          style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
        children: [
          _buildSectionHeader(isAr ? 'المظهر' : 'Appearance'),
          const SizedBox(height: AppSpacing.sm),
          _buildThemeCard(context, ref, themeMode, isDark),
          const SizedBox(height: AppSpacing.lg),
          
          _buildSectionHeader(isAr ? 'اللغة والمنطقة' : 'Language & Region'),
          const SizedBox(height: AppSpacing.sm),
          _buildLanguageCard(context, ref, locale, isDark),
          const SizedBox(height: AppSpacing.lg),

          _buildSectionHeader(isAr ? 'حول' : 'About'),
          const SizedBox(height: AppSpacing.sm),
          _buildAboutCard(context, isDark),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Outfit',
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildThemeCard(
    BuildContext context,
    WidgetRef ref,
    ThemeMode themeMode,
    bool isDark,
  ) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        children: [
          _buildRadioListTile<ThemeMode>(
            title: isAr ? 'الوضع الفاتح' : 'Light Mode',
            value: ThemeMode.light,
            groupValue: themeMode,
            icon: Icons.light_mode_outlined,
            onChanged: (val) {
              if (val != null) {
                ref.read(themeModeNotifierProvider.notifier).setThemeMode(val);
              }
            },
          ),
          const Divider(height: 1, indent: 56),
          _buildRadioListTile<ThemeMode>(
            title: isAr ? 'الوضع الداكن' : 'Dark Mode',
            value: ThemeMode.dark,
            groupValue: themeMode,
            icon: Icons.dark_mode_outlined,
            onChanged: (val) {
              if (val != null) {
                ref.read(themeModeNotifierProvider.notifier).setThemeMode(val);
              }
            },
          ),
          const Divider(height: 1, indent: 56),
          _buildRadioListTile<ThemeMode>(
            title: context.l10n.settings_theme_system,
            value: ThemeMode.system,
            groupValue: themeMode,
            icon: Icons.settings_brightness_outlined,
            onChanged: (val) {
              if (val != null) {
                ref.read(themeModeNotifierProvider.notifier).setThemeMode(val);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageCard(
    BuildContext context,
    WidgetRef ref,
    Locale locale,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        children: [
          _buildRadioListTile<String>(
            title: context.l10n.settings_language_en,
            value: 'en',
            groupValue: locale.languageCode,
            icon: Icons.language_outlined,
            onChanged: (val) {
              if (val != null) {
                ref.read(localeNotifierProvider.notifier).setLocale(val);
              }
            },
          ),
          const Divider(height: 1, indent: 56),
          _buildRadioListTile<String>(
            title: context.l10n.settings_language_ar,
            value: 'ar',
            groupValue: locale.languageCode,
            icon: Icons.language_outlined,
            onChanged: (val) {
              if (val != null) {
                ref.read(localeNotifierProvider.notifier).setLocale(val);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context, bool isDark) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: Text(
              isAr ? 'إصدار التطبيق' : 'App Version',
              style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600),
            ),
            trailing: const Text(
              '1.0.0',
              style: TextStyle(fontFamily: 'Outfit', color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioListTile<T>({
    required String title,
    required T value,
    required T groupValue,
    required IconData icon,
    required ValueChanged<T?> onChanged,
  }) {
    return RadioListTile<T>(
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Outfit',
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      secondary: Icon(icon),
      value: value,
      // ignore: deprecated_member_use
      groupValue: groupValue,
      // ignore: deprecated_member_use
      onChanged: onChanged,
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.primary
            : null,
      ),
    );
  }
}
