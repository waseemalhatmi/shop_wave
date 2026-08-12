import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/admin_users_notifier.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 250) {
      ref.read(adminUsersNotifierProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(adminUsersNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final currentFilter = stateAsync.value?.roleFilter ?? UserRoleFilter.all;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + Count
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        isAr ? 'إدارة المستخدمين' : 'Users Management',
                        style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w800, fontFamily: 'Outfit',
                          color: isDark ? AppColors.white : AppColors.onSurfaceLight,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (stateAsync.value != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${stateAsync.value!.users.length}+',
                          style: const TextStyle(
                            fontFamily: 'Outfit', fontWeight: FontWeight.w700,
                            fontSize: 12, color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),

                // Search Field
                TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => ref.read(adminUsersNotifierProvider.notifier).setSearch(v),
                  decoration: InputDecoration(
                    hintText: isAr ? 'البحث عن مستخدمين...' : 'Search users...',
                    hintStyle: const TextStyle(fontFamily: 'Outfit'),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchCtrl.clear();
                              ref.read(adminUsersNotifierProvider.notifier).setSearch('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: isDark ? AppColors.surfaceDark : AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 10),

                // Role Filter Chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _RoleChip(
                      label: isAr ? 'الكل' : 'All',
                      isSelected: currentFilter == UserRoleFilter.all,
                      color: AppColors.primary,
                      onTap: () => ref.read(adminUsersNotifierProvider.notifier).setRoleFilter(UserRoleFilter.all),
                    ),
                    _RoleChip(
                      label: isAr ? 'عملاء' : 'Customers',
                      isSelected: currentFilter == UserRoleFilter.customer,
                      color: AppColors.info,
                      onTap: () => ref.read(adminUsersNotifierProvider.notifier).setRoleFilter(UserRoleFilter.customer),
                    ),
                    _RoleChip(
                      label: isAr ? 'مسؤولون' : 'Admins',
                      isSelected: currentFilter == UserRoleFilter.admin,
                      color: AppColors.primary,
                      onTap: () => ref.read(adminUsersNotifierProvider.notifier).setRoleFilter(UserRoleFilter.admin),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Users List ──────────────────────────────────────────────────
          Expanded(
            child: stateAsync.when(
              data: (st) => st.users.isEmpty
                  ? _EmptyState(isAr: isAr)
                  : ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                      itemCount: st.users.length + (st.isLoadingMore ? 1 : 0),
                      itemBuilder: (ctx, i) {
                        if (i == st.users.length) {
                          return const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                          );
                        }
                        return _UserCard(
                          user: st.users[i],
                          isDark: isDark,
                          isAr: isAr,
                          onRoleChange: (userId, newRole) async {
                            try {
                              await ref.read(adminUsersNotifierProvider.notifier).updateUserRole(userId, newRole);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(isAr ? 'تم تحديث الدور بنجاح' : 'Role updated successfully', style: const TextStyle(fontFamily: 'Outfit')),
                                  backgroundColor: AppColors.success,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ));
                              }
                            } catch (_) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(isAr ? 'فشل تحديث الدور' : 'Failed to update role', style: const TextStyle(fontFamily: 'Outfit')),
                                  backgroundColor: AppColors.error,
                                  behavior: SnackBarBehavior.floating,
                                ));
                              }
                            }
                          },
                        );
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (e, _) => _ErrorState(
                isAr: isAr,
                onRetry: () => ref.invalidate(adminUsersNotifierProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Role Filter Chip ─────────────────────────────────────────────────────────

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.label, required this.isSelected, required this.color, required this.onTap});
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : Colors.grey.shade400),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Outfit', fontWeight: FontWeight.w600, fontSize: 12,
            color: isSelected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}

// ── User Card ────────────────────────────────────────────────────────────────

class _UserCard extends StatelessWidget {
  const _UserCard({required this.user, required this.isDark, required this.isAr, required this.onRoleChange});
  final Map<String, dynamic> user;
  final bool isDark, isAr;
  final void Function(String userId, String newRole) onRoleChange;

  @override
  Widget build(BuildContext context) {
    final role = user['role'] as String? ?? 'customer';
    final isAdmin = role == 'admin';
    final name = user['full_name'] as String? ?? (isAr ? 'مستخدم' : 'User');
    final avatarUrl = user['avatar_url'] as String?;
    final phone = user['phone'] as String? ?? '';
    final createdAt = user['created_at'];

    String joinDate = '';
    if (createdAt != null) {
      final dt = DateTime.tryParse(createdAt.toString())?.toLocal();
      if (dt != null) joinDate = '${dt.day}/${dt.month}/${dt.year}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 6, offset: const Offset(0, 2))],
        border: isAdmin ? Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1) : null,
      ),
      child: Row(
        children: [
          // ── Avatar ────────────────────────────────────────────────────
          Stack(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: isAdmin ? AppColors.primary : AppColors.primaryLight,
                child: avatarUrl != null
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: avatarUrl,
                          width: 52, height: 52, fit: BoxFit.cover,
                          memCacheWidth: 100,
                          errorWidget: (_, __, ___) => Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: TextStyle(color: isAdmin ? Colors.white : AppColors.primary, fontWeight: FontWeight.w800, fontSize: 18, fontFamily: 'Outfit'),
                          ),
                        ),
                      )
                    : Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: TextStyle(color: isAdmin ? Colors.white : AppColors.primary, fontWeight: FontWeight.w800, fontSize: 18, fontFamily: 'Outfit'),
                      ),
              ),
              // Admin badge
              if (isAdmin)
                Positioned(
                  right: 0, bottom: 0,
                  child: Container(
                    width: 16, height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.primary, shape: BoxShape.circle,
                      border: Border.all(color: isDark ? AppColors.surfaceDark : AppColors.white, width: 1.5),
                    ),
                    child: const Icon(Icons.shield_rounded, size: 10, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),

          // ── Info ──────────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontFamily: 'Outfit', fontWeight: FontWeight.w700, fontSize: 14,
                    color: isDark ? AppColors.white : AppColors.onSurfaceLight,
                  ),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                if (phone.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(phone, style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight)),
                ],
                const SizedBox(height: 4),
                Row(children: [
                  // Role Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isAdmin ? AppColors.primary : AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isAdmin ? (isAr ? 'مسؤول' : 'Admin') : (isAr ? 'عميل' : 'Customer'),
                      style: TextStyle(
                        color: isAdmin ? Colors.white : AppColors.primary,
                        fontSize: 10, fontWeight: FontWeight.w700, fontFamily: 'Outfit',
                      ),
                    ),
                  ),
                  if (joinDate.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Text(
                      '${isAr ? 'انضم' : 'Joined'}: $joinDate',
                      style: TextStyle(fontSize: 10, fontFamily: 'Outfit', color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight),
                    ),
                  ],
                ]),
              ],
            ),
          ),

          // ── Actions ───────────────────────────────────────────────────
          PopupMenuButton<String>(
            onSelected: (val) => onRoleChange(user['id'] as String, val),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'customer',
                child: Row(children: [
                  const Icon(Icons.person_rounded, size: 18, color: AppColors.info),
                  const SizedBox(width: 8),
                  Text(isAr ? 'تعيين كعميل' : 'Set as Customer', style: const TextStyle(fontFamily: 'Outfit')),
                ]),
              ),
              PopupMenuItem(
                value: 'admin',
                child: Row(children: [
                  const Icon(Icons.shield_rounded, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(isAr ? 'تعيين كمسؤول' : 'Set as Admin', style: const TextStyle(fontFamily: 'Outfit')),
                ]),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.more_vert_rounded, color: AppColors.primary, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty & Error States ─────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isAr});
  final bool isAr;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.people_outline_rounded, size: 72, color: Colors.grey.shade400),
        const SizedBox(height: 16),
        Text(
          isAr ? 'لا توجد مستخدمون' : 'No users found',
          style: TextStyle(fontFamily: 'Outfit', fontSize: 18, fontWeight: FontWeight.w700, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 8),
        Text(
          isAr ? 'جرّب تغيير البحث أو الفلتر' : 'Try adjusting your search or filter',
          style: TextStyle(fontFamily: 'Outfit', fontSize: 13, color: Colors.grey.shade500),
        ),
      ]),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.isAr, required this.onRetry});
  final bool isAr;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.cloud_off_rounded, color: AppColors.error, size: 64),
        const SizedBox(height: 16),
        Text(
          isAr ? 'فشل تحميل المستخدمين' : 'Failed to load users',
          style: const TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.error),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: Text(isAr ? 'إعادة المحاولة' : 'Retry', style: const TextStyle(fontFamily: 'Outfit')),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
        ),
      ]),
    );
  }
}
