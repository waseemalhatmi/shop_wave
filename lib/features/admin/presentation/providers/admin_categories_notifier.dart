import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/admin_remote_datasource.dart';
import 'admin_providers.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class AdminCategoriesState {
  final List<Map<String, dynamic>> categories;
  final String search;

  const AdminCategoriesState({required this.categories, required this.search});

  AdminCategoriesState copyWith({
    List<Map<String, dynamic>>? categories,
    String? search,
  }) {
    return AdminCategoriesState(
      categories: categories ?? this.categories,
      search: search ?? this.search,
    );
  }

  /// Returns client-side filtered categories by search
  List<Map<String, dynamic>> get filteredCategories {
    if (search.isEmpty) return categories;
    final q = search.toLowerCase();
    return categories.where((c) {
      final nameEn = (c['name_en'] as String? ?? '').toLowerCase();
      final nameAr = (c['name_ar'] as String? ?? '').toLowerCase();
      return nameEn.contains(q) || nameAr.contains(q);
    }).toList();
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class AdminCategoriesNotifier extends AsyncNotifier<AdminCategoriesState> {
  @override
  Future<AdminCategoriesState> build() async {
    final cats = await ref.read(adminDataSourceProvider).getAllCategories();
    return AdminCategoriesState(categories: cats, search: '');
  }

  // ── Search (client-side, instant) ────────────────────────────────────────

  void setSearch(String search) {
    final val = state.value;
    if (val == null) return;
    state = AsyncData(val.copyWith(search: search));
  }

  // ── Create ────────────────────────────────────────────────────────────────

  Future<void> createCategory(Map<String, dynamic> data) async {
    // Full refresh after create to get correct sort_order + product_count
    await ref.read(adminDataSourceProvider).createCategory(data);
    await _refresh();
  }

  // ── Optimistic Update ─────────────────────────────────────────────────────

  Future<void> updateCategory(String id, Map<String, dynamic> data) async {
    final val = state.value;
    if (val == null) return;

    final index = val.categories.indexWhere((c) => c['id'] == id);
    if (index == -1) return;

    final oldCat = val.categories[index];
    final updated = Map<String, dynamic>.from(oldCat)..addAll(data);

    state = AsyncData(val.copyWith(
      categories: List<Map<String, dynamic>>.from(val.categories)..[index] = updated,
    ));

    try {
      await ref.read(adminDataSourceProvider).updateCategory(id, data);
    } catch (e) {
      // Revert
      state = AsyncData(val.copyWith(
        categories: List<Map<String, dynamic>>.from(val.categories)..[index] = oldCat,
      ));
      throw Exception('Failed to update category');
    }
  }

  // ── Optimistic Toggle Active ──────────────────────────────────────────────

  Future<void> toggleActive(String id, bool isActive) async {
    await updateCategory(id, {'is_active': isActive});
  }

  // ── Optimistic Delete ─────────────────────────────────────────────────────

  Future<void> deleteCategory(String id) async {
    final val = state.value;
    if (val == null) return;

    final index = val.categories.indexWhere((c) => c['id'] == id);
    if (index == -1) return;

    final oldCat = val.categories[index];
    state = AsyncData(val.copyWith(
      categories: List<Map<String, dynamic>>.from(val.categories)..removeAt(index),
    ));

    try {
      await ref.read(adminDataSourceProvider).deleteCategory(id);
    } catch (e) {
      state = AsyncData(val.copyWith(
        categories: List<Map<String, dynamic>>.from(val.categories)..insert(index, oldCat),
      ));
      throw Exception('Failed to delete category');
    }
  }

  // ── Reorder (Drag & Drop) ─────────────────────────────────────────────────

  Future<void> reorder(int oldIndex, int newIndex) async {
    final val = state.value;
    if (val == null) return;

    // Apply locally first (optimistic)
    final reordered = List<Map<String, dynamic>>.from(val.categories);
    final item = reordered.removeAt(oldIndex);
    if (newIndex > oldIndex) newIndex -= 1;
    reordered.insert(newIndex, item);

    // Assign new sort_order values
    final withOrder = List.generate(reordered.length, (i) {
      return Map<String, dynamic>.from(reordered[i])..['sort_order'] = i;
    });

    state = AsyncData(val.copyWith(categories: withOrder));

    try {
      await ref.read(adminDataSourceProvider).updateCategorySortOrder(
        withOrder.map((c) => {'id': c['id'], 'sort_order': c['sort_order']}).toList(),
      );
    } catch (e) {
      // Revert
      state = AsyncData(val.copyWith(categories: val.categories));
      throw Exception('Failed to reorder categories');
    }
  }

  // ── Refresh ───────────────────────────────────────────────────────────────

  Future<void> _refresh() async {
    final val = state.value;
    final cats = await ref.read(adminDataSourceProvider).getAllCategories();
    state = AsyncData(AdminCategoriesState(
      categories: cats,
      search: val?.search ?? '',
    ));
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final adminCategoriesNotifierProvider =
    AsyncNotifierProvider<AdminCategoriesNotifier, AdminCategoriesState>(AdminCategoriesNotifier.new, isAutoDispose: true,);

