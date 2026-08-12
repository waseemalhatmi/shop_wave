import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/admin_remote_datasource.dart';
import 'admin_providers.dart';

class AdminProductsState {
  final List<Map<String, dynamic>> products;
  final bool hasMore;
  final int page;
  final String search;
  final bool? isActive;
  final bool isLoadingMore;

  // New Fields for Bulk Actions & Advanced Filters
  final Set<String> selectedIds;
  final String? categoryId;
  final double? minPrice;
  final double? maxPrice;
  final bool? isFeatured;
  final bool? isNewArrival;
  final bool? isOnSale;

  AdminProductsState({
    required this.products,
    required this.hasMore,
    required this.page,
    required this.search,
    this.isActive,
    required this.isLoadingMore,
    this.selectedIds = const {},
    this.categoryId,
    this.minPrice,
    this.maxPrice,
    this.isFeatured,
    this.isNewArrival,
    this.isOnSale,
  });

  AdminProductsState copyWith({
    List<Map<String, dynamic>>? products,
    bool? hasMore,
    int? page,
    String? search,
    bool? isActive,
    bool? isLoadingMore,
    bool forceIsActive = false,
    Set<String>? selectedIds,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    bool? isFeatured,
    bool? isNewArrival,
    bool? isOnSale,
    bool forceFilters = false,
  }) {
    return AdminProductsState(
      products: products ?? this.products,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      search: search ?? this.search,
      isActive: forceIsActive ? isActive : (isActive ?? this.isActive),
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      selectedIds: selectedIds ?? this.selectedIds,
      categoryId: forceFilters ? categoryId : (categoryId ?? this.categoryId),
      minPrice: forceFilters ? minPrice : (minPrice ?? this.minPrice),
      maxPrice: forceFilters ? maxPrice : (maxPrice ?? this.maxPrice),
      isFeatured: forceFilters ? isFeatured : (isFeatured ?? this.isFeatured),
      isNewArrival: forceFilters ? isNewArrival : (isNewArrival ?? this.isNewArrival),
      isOnSale: forceFilters ? isOnSale : (isOnSale ?? this.isOnSale),
    );
  }
}

class AdminProductsNotifier extends AsyncNotifier<AdminProductsState> {
  static const int _pageSize = 20;
  Timer? _debounce;

  @override
  Future<AdminProductsState> build() async {
    ref.onDispose(() => _debounce?.cancel());
    final initialProducts = await _fetchPage(0, '', null, null, null, null, null, null, null);
    return AdminProductsState(
      products: initialProducts,
      hasMore: initialProducts.length == _pageSize,
      page: 0,
      search: '',
      isActive: null,
      isLoadingMore: false,
    );
  }

  Future<List<Map<String, dynamic>>> _fetchPage(
    int page, String search, bool? isActive, String? categoryId,
    double? minPrice, double? maxPrice, bool? isFeatured, bool? isNewArrival, bool? isOnSale
  ) async {
    final ds = ref.read(adminDataSourceProvider);
    return ds.getAllProducts(
      search: search,
      isActive: isActive,
      categoryId: categoryId,
      minPrice: minPrice,
      maxPrice: maxPrice,
      isFeatured: isFeatured,
      isNewArrival: isNewArrival,
      isOnSale: isOnSale,
      page: page,
      pageSize: _pageSize,
    );
  }

  void setSearch(String search) {
    if (state.value?.search == search) return;
    
    // Debounce to prevent API spam
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      state = const AsyncLoading();
      try {
        final st = state.value ?? AdminProductsState(products: [], hasMore: false, page: 0, search: search, isLoadingMore: false);
        final newProducts = await _fetchPage(0, search, st.isActive, st.categoryId, st.minPrice, st.maxPrice, st.isFeatured, st.isNewArrival, st.isOnSale);
        state = AsyncData(st.copyWith(
          products: newProducts,
          hasMore: newProducts.length == _pageSize,
          page: 0,
          search: search,
        ));
      } catch (e, st) {
        state = AsyncError(e, st);
      }
    });
  }

  void setFilter(bool? isActive) async {
    if (state.value?.isActive == isActive) return;
    
    state = const AsyncLoading();
    try {
      final st = state.value ?? AdminProductsState(products: [], hasMore: false, page: 0, search: '', isLoadingMore: false);
      final newProducts = await _fetchPage(0, st.search, isActive, st.categoryId, st.minPrice, st.maxPrice, st.isFeatured, st.isNewArrival, st.isOnSale);
      state = AsyncData(st.copyWith(
        products: newProducts,
        hasMore: newProducts.length == _pageSize,
        page: 0,
        isActive: isActive,
        forceIsActive: true,
      ));
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  void applyAdvancedFilters({String? categoryId, double? minPrice, double? maxPrice, bool? isFeatured, bool? isNewArrival, bool? isOnSale}) async {
    state = const AsyncLoading();
    try {
      final st = state.value ?? AdminProductsState(products: [], hasMore: false, page: 0, search: '', isLoadingMore: false);
      final newProducts = await _fetchPage(0, st.search, st.isActive, categoryId, minPrice, maxPrice, isFeatured, isNewArrival, isOnSale);
      state = AsyncData(st.copyWith(
        products: newProducts,
        hasMore: newProducts.length == _pageSize,
        page: 0,
        categoryId: categoryId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        isFeatured: isFeatured,
        isNewArrival: isNewArrival,
        isOnSale: isOnSale,
        forceFilters: true,
      ));
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  Future<void> loadMore() async {
    final val = state.value;
    if (val == null || !val.hasMore || val.isLoadingMore || state.isLoading) return;

    // Set loading more without losing existing data
    state = AsyncData(val.copyWith(isLoadingMore: true));

    try {
      final nextPage = val.page + 1;
      final newProducts = await _fetchPage(nextPage, val.search, val.isActive, val.categoryId, val.minPrice, val.maxPrice, val.isFeatured, val.isNewArrival, val.isOnSale);
      
      state = AsyncData(val.copyWith(
        products: [...val.products, ...newProducts],
        hasMore: newProducts.length == _pageSize,
        page: nextPage,
        isLoadingMore: false,
      ));
    } catch (e) {
      // Revert loading state on error, keep existing data
      state = AsyncData(val.copyWith(isLoadingMore: false));
    }
  }

  Future<void> toggleActive(String id, bool isActive) async {
    final val = state.value;
    if (val == null) return;

    // Optimistic Update
    final index = val.products.indexWhere((p) => p['id'] == id);
    if (index == -1) return;

    final oldProduct = val.products[index];
    final updatedProduct = Map<String, dynamic>.from(oldProduct)..[ 'is_active' ] = isActive;
    
    final newProducts = List<Map<String, dynamic>>.from(val.products)..[index] = updatedProduct;
    state = AsyncData(val.copyWith(products: newProducts));

    try {
      await ref.read(adminDataSourceProvider).toggleProductActive(id, isActive);
    } catch (e) {
      // Revert if failed
      final revertedProducts = List<Map<String, dynamic>>.from(val.products)..[index] = oldProduct;
      state = AsyncData(val.copyWith(products: revertedProducts));
      throw Exception('Failed to toggle active status');
    }
  }

  Future<void> deleteProduct(String id) async {
    final val = state.value;
    if (val == null) return;

    // Optimistic Update
    final index = val.products.indexWhere((p) => p['id'] == id);
    if (index == -1) return;
    
    final oldProduct = val.products[index];
    final newProducts = List<Map<String, dynamic>>.from(val.products)..removeAt(index);
    state = AsyncData(val.copyWith(products: newProducts));

    try {
      await ref.read(adminDataSourceProvider).softDeleteProduct(id);
    } catch (e) {
      // Revert if failed
      final revertedProducts = List<Map<String, dynamic>>.from(val.products)..insert(index, oldProduct);
      state = AsyncData(val.copyWith(products: revertedProducts));
      throw Exception('Failed to delete product');
    }
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    final val = state.value;
    if (val == null) return;

    // Optimistic Update
    final index = val.products.indexWhere((p) => p['id'] == id);
    if (index == -1) return;

    final oldProduct = val.products[index];
    final updatedProduct = Map<String, dynamic>.from(oldProduct)..addAll(data);
    
    final newProducts = List<Map<String, dynamic>>.from(val.products)..[index] = updatedProduct;
    state = AsyncData(val.copyWith(products: newProducts));

    try {
      await ref.read(adminDataSourceProvider).updateProduct(id, data);
    } catch (e) {
      // Revert if failed
      final revertedProducts = List<Map<String, dynamic>>.from(val.products)..[index] = oldProduct;
      state = AsyncData(val.copyWith(products: revertedProducts));
      throw Exception('Failed to update product');
    }
  }

  // ── Bulk Actions ────────────────────────────────────────────────────────

  void toggleSelection(String id) {
    final val = state.value;
    if (val == null) return;
    final newSelection = Set<String>.from(val.selectedIds);
    if (newSelection.contains(id)) {
      newSelection.remove(id);
    } else {
      newSelection.add(id);
    }
    state = AsyncData(val.copyWith(selectedIds: newSelection));
  }

  void selectAll() {
    final val = state.value;
    if (val == null) return;
    final newSelection = val.products.map((p) => p['id'] as String).toSet();
    state = AsyncData(val.copyWith(selectedIds: newSelection));
  }

  void clearSelection() {
    final val = state.value;
    if (val == null) return;
    state = AsyncData(val.copyWith(selectedIds: {}));
  }

  Future<void> bulkDelete() async {
    final val = state.value;
    if (val == null || val.selectedIds.isEmpty) return;

    final idsToDelete = val.selectedIds.toList();
    
    // Optimistic Update
    final originalProducts = val.products;
    final newProducts = val.products.where((p) => !idsToDelete.contains(p['id'])).toList();
    state = AsyncData(val.copyWith(products: newProducts, selectedIds: {}));

    try {
      await ref.read(adminDataSourceProvider).bulkDeleteProducts(idsToDelete);
    } catch (e) {
      // Revert if failed
      state = AsyncData(val.copyWith(products: originalProducts, selectedIds: val.selectedIds));
      throw Exception('Failed to bulk delete');
    }
  }

  Future<void> bulkToggleActive(bool isActive) async {
    final val = state.value;
    if (val == null || val.selectedIds.isEmpty) return;

    final idsToUpdate = val.selectedIds.toList();
    
    // Optimistic Update
    final originalProducts = val.products;
    final newProducts = val.products.map((p) {
      if (idsToUpdate.contains(p['id'])) {
        return Map<String, dynamic>.from(p)..[ 'is_active' ] = isActive;
      }
      return p;
    }).toList();
    
    state = AsyncData(val.copyWith(products: newProducts, selectedIds: {}));

    try {
      await ref.read(adminDataSourceProvider).bulkUpdateProductsActive(idsToUpdate, isActive);
    } catch (e) {
      // Revert if failed
      state = AsyncData(val.copyWith(products: originalProducts, selectedIds: val.selectedIds));
      throw Exception('Failed to bulk update status');
    }
  }
}

final adminProductsNotifierProvider = AsyncNotifierProvider.autoDispose<AdminProductsNotifier, AdminProductsState>(() {
  return AdminProductsNotifier();
});

