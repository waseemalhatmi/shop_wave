import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../router/app_routes.dart';
import '../theme/app_colors.dart';
import '../../features/cart/presentation/providers/cart_notifier.dart';

/// The main scaffold wrapping the bottom-navigation tab screens.
///
/// Used by [ShellRoute] in [AppRouter] so the bottom navigation bar
/// persists across tab switches without rebuilding.
///
/// Cart badge is driven by [cartItemCountProvider] — live reactive count.
class MainScaffold extends ConsumerWidget {
  const MainScaffold({
    super.key,
    required this.location,
    required this.child,
  });

  final String location;
  final Widget child;

  static const List<_NavItem> _navItems = [
    _NavItem(
      label: 'Home',
      labelAr: 'الرئيسية',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      route: AppRoutes.home,
    ),
    _NavItem(
      label: 'Categories',
      labelAr: 'الفئات',
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view_rounded,
      route: AppRoutes.categories,
    ),
    _NavItem(
      label: 'Cart',
      labelAr: 'السلة',
      icon: Icons.shopping_bag_outlined,
      activeIcon: Icons.shopping_bag_rounded,
      route: AppRoutes.cart,
    ),
    _NavItem(
      label: 'Favorites',
      labelAr: 'المفضلة',
      icon: Icons.favorite_border_rounded,
      activeIcon: Icons.favorite_rounded,
      route: AppRoutes.favorites,
    ),
    _NavItem(
      label: 'Profile',
      labelAr: 'حسابي',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      route: AppRoutes.profile,
    ),
  ];

  int _currentIndex() {
    final routes = _navItems.map((e) => e.route).toList();
    for (var i = 0; i < routes.length; i++) {
      if (location.startsWith(routes[i])) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final currentIndex = _currentIndex();
    final theme = Theme.of(context);

    // Live cart count for badge
    final cartCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      body: child,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: theme.brightness == Brightness.light
                  ? AppColors.borderLight
                  : AppColors.borderDark,
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => context.go(_navItems[index].route),
          items: _navItems.mapIndexed((index, item) {
            // Cart item (index 2) gets a badge
            final isCart = item.route == AppRoutes.cart;
            final showBadge = isCart && cartCount > 0;

            final iconWidget = showBadge
                ? Badge(
                    label: Text(
                      cartCount > 99 ? '99+' : '$cartCount',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    backgroundColor: AppColors.badge,
                    child: Icon(
                      index == currentIndex ? item.activeIcon : item.icon,
                    ),
                  )
                : Icon(
                    index == currentIndex ? item.activeIcon : item.icon,
                  );

            return BottomNavigationBarItem(
              icon: iconWidget,
              activeIcon: iconWidget,
              label: isRtl ? item.labelAr : item.label,
              tooltip: isRtl ? item.labelAr : item.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─── Extension ────────────────────────────────────────────────────────────────

extension _IndexedMap<T> on List<T> {
  List<R> mapIndexed<R>(R Function(int index, T element) f) {
    var index = 0;
    return map((e) => f(index++, e)).toList();
  }
}

/// Data class representing a single bottom navigation tab.
class _NavItem {
  const _NavItem({
    required this.label,
    required this.labelAr,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });

  final String label;
  final String labelAr;
  final IconData icon;
  final IconData activeIcon;
  final String route;
}
