import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/admin_providers.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});
  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  String _search = '';
  final _ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(adminUsersProvider(_search));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(isAr ? 'إدارة المستخدمين' : 'Users Management', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, fontFamily: 'Outfit', color: isDark ? AppColors.white : AppColors.onSurfaceLight)),
          const SizedBox(height: 16),
          TextField(controller: _ctrl, onChanged: (v) => setState(() => _search = v),
            decoration: InputDecoration(hintText: isAr ? 'البحث عن مستخدمين...' : 'Search users...', hintStyle: const TextStyle(fontFamily: 'Outfit'),
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
              filled: true, fillColor: isDark ? AppColors.surfaceDark : AppColors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(vertical: 12))),
        ])),
        Expanded(child: usersAsync.when(
          data: (users) => ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            itemCount: users.length,
            itemBuilder: (ctx, i) {
              final u = users[i];
              final role = u['role'] as String? ?? 'customer';
              final isAdmin = role != 'customer';
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: isDark ? AppColors.surfaceDark : AppColors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 4)]),
                child: Row(children: [
                  CircleAvatar(
                    backgroundColor: isAdmin ? AppColors.primary : AppColors.primaryLight,
                    child: u['avatar_url'] != null ? ClipOval(child: Image.network(u['avatar_url']!, fit: BoxFit.cover)) : Text((u['full_name'] as String? ?? '?')[0].toUpperCase(), style: TextStyle(color: isAdmin ? Colors.white : AppColors.primary, fontWeight: FontWeight.w700, fontFamily: 'Outfit')),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(u['full_name'] as String? ?? (isAr ? 'غير معروف' : 'Unknown'), style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700)),
                    Text('${isAr ? 'المعرف' : 'ID'}: ${(u['id'] as String).substring(0, 8)}...', style: TextStyle(fontFamily: 'Outfit', fontSize: 11, color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight)),
                  ])),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: isAdmin ? AppColors.primary : AppColors.primaryLight, borderRadius: BorderRadius.circular(20)),
                    child: Text(role.toUpperCase(), style: TextStyle(color: isAdmin ? Colors.white : AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700, fontFamily: 'Outfit'))),
                  PopupMenuButton<String>(
                    onSelected: (val) async {
                      await ref.read(adminDataSourceProvider).updateUserRole(u['id'] as String, val);
                      ref.invalidate(adminUsersProvider(_search));
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(value: 'customer', child: Text(isAr ? 'تعيين كمستخدم عادي' : 'Set Customer')),
                      PopupMenuItem(value: 'admin', child: Text(isAr ? 'تعيين كمسؤول' : 'Set Admin')),
                    ],
                    child: const Icon(Icons.more_vert_rounded, color: AppColors.primary),
                  ),
                ]),
              );
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          error: (e, _) => Center(child: Text('$e', style: const TextStyle(color: AppColors.error))),
        )),
      ]),
    );
  }
}
