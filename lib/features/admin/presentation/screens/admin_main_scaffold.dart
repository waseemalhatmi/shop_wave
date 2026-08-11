import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_routes.dart';

/// The main scaffold for the admin panel.
/// Uses a NavigationRail on the side for professional admin navigation.
class AdminMainScaffold extends StatefulWidget {
  const AdminMainScaffold({super.key, required this.child, required this.location});
  final Widget child;
  final String location;

  @override
  State<AdminMainScaffold> createState() => _AdminMainScaffoldState();
}

class _AdminMainScaffoldState extends State<AdminMainScaffold> {
  List<_NavItem> _getItems(bool isAr) => [
    _NavItem(icon: Icons.dashboard_rounded, label: isAr ? 'لوحة التحكم' : 'Dashboard', route: AppRoutes.adminDashboard),
    _NavItem(icon: Icons.inventory_2_rounded, label: isAr ? 'المنتجات' : 'Products', route: AppRoutes.adminProducts),
    _NavItem(icon: Icons.category_rounded, label: isAr ? 'الأقسام' : 'Categories', route: AppRoutes.adminCategories),
    _NavItem(icon: Icons.receipt_long_rounded, label: isAr ? 'الطلبات' : 'Orders', route: AppRoutes.adminOrders),
    _NavItem(icon: Icons.people_rounded, label: isAr ? 'المستخدمين' : 'Users', route: AppRoutes.adminUsers),
    _NavItem(icon: Icons.campaign_rounded, label: isAr ? 'اللافتات (البنرات)' : 'Banners', route: AppRoutes.adminBanners),
    _NavItem(icon: Icons.local_offer_rounded, label: isAr ? 'الكوبونات' : 'Coupons', route: AppRoutes.adminCoupons),
    _NavItem(icon: Icons.star_rounded, label: isAr ? 'التقييمات' : 'Reviews', route: AppRoutes.adminReviews),
  ];

  int get _selectedIndex {
    final items = _getItems(false); // just for routing check
    for (int i = 0; i < items.length; i++) {
      if (widget.location.startsWith(items[i].route)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final items = _getItems(isAr);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF0F2F5),
      appBar: isMobile
          ? AppBar(
              title: Text(
                items[_selectedIndex].label,
                style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700),
              ),
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              leading: Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  tooltip: isAr ? 'العودة للمتجر' : 'Back to Store',
                  onPressed: () => context.go(AppRoutes.home),
                ),
              ],
            )
          : null,
      drawer: isMobile ? _buildDrawer(context, isDark, items) : null,
      body: Row(
        children: [
          if (!isMobile) _buildSideRail(context, isDark, items),
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  Widget _buildSideRail(BuildContext context, bool isDark, List<_NavItem> items) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 8, offset: const Offset(2, 0))],
      ),
      child: Column(
        children: [
          // Logo/Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.secondary],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.admin_panel_settings_rounded, color: AppColors.white, size: 26),
                ),
                const SizedBox(height: 12),
                Text(isAr ? 'لوحة الإدارة' : 'Admin Panel', style: const TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Outfit')),
                const Text('ShopWave', style: TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Outfit')),
              ],
            ),
          ),
          // Nav Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              itemCount: items.length,
              itemBuilder: (ctx, i) {
                final item = items[i];
                final selected = _selectedIndex == i;
                return _SideNavTile(item: item, selected: selected, onTap: () => context.go(item.route));
              },
            ),
          ),
          // Back to store
          Padding(
            padding: const EdgeInsets.all(12),
            child: OutlinedButton.icon(
              onPressed: () => context.go(AppRoutes.home),
              icon: const Icon(Icons.storefront_rounded, size: 16),
              label: const Text('Back to Store', style: TextStyle(fontFamily: 'Outfit', fontSize: 13)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, bool isDark, List<_NavItem> items) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.admin_panel_settings_rounded, color: AppColors.white, size: 36),
                const SizedBox(height: 8),
                Text(isAr ? 'لوحة الإدارة' : 'Admin Panel', style: const TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.w700, fontFamily: 'Outfit')),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (ctx, i) {
                final item = items[i];
                final selected = _selectedIndex == i;
                return ListTile(
                  leading: Icon(item.icon, color: selected ? AppColors.primary : null),
                  title: Text(item.label, style: TextStyle(fontFamily: 'Outfit', fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: selected ? AppColors.primary : null)),
                  selected: selected,
                  onTap: () { Navigator.pop(context); context.go(item.route); },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SideNavTile extends StatelessWidget {
  const _SideNavTile({required this.item, required this.selected, required this.onTap});
  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: selected ? AppColors.primaryLight : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(item.icon, color: selected ? AppColors.primary : Colors.grey.shade600, size: 20),
        title: Text(item.label, style: TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: selected ? AppColors.primary : Colors.grey.shade700)),
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onTap: onTap,
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.label, required this.route});
  final IconData icon;
  final String label;
  final String route;
}
