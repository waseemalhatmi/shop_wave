import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_constants.dart';
import '../../../../core/di/providers.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../products/domain/repositories/products_repository.dart';
import 'products_providers.dart';

// ─── Recent Searches Notifier ─────────────────────────────────────────────────

class RecentSearchesNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    final prefs = ref.read(sharedPreferencesProvider);
    return prefs.getStringList(AppConstants.keyRecentSearches) ?? [];
  }

  Future<void> addQuery(String rawQuery) async {
    final query = rawQuery.trim();
    if (query.isEmpty) return;

    final current = List<String>.from(state);
    current.removeWhere((item) => item.toLowerCase() == query.toLowerCase());
    current.insert(0, query);

    // Keep up to 10 recent searches
    final updated = current.take(10).toList();
    state = updated;

    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setStringList(AppConstants.keyRecentSearches, updated);
  }

  Future<void> removeQuery(String query) async {
    final updated = state.where((item) => item != query).toList();
    state = updated;

    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setStringList(AppConstants.keyRecentSearches, updated);
  }

  Future<void> clearAll() async {
    state = [];
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(AppConstants.keyRecentSearches);
  }
}

final recentSearchesProvider =
    NotifierProvider<RecentSearchesNotifier, List<String>>(
  RecentSearchesNotifier.new,
);

// ─── Search Filter & Control Providers ────────────────────────────────────────

final searchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

final searchSelectedCategoryProvider =
    StateProvider.autoDispose<String?>((ref) => null);

final searchSortOptionProvider =
    StateProvider.autoDispose<ProductSortOption>(
  (ref) => ProductSortOption.newest,
);

// ─── Search Results Provider ──────────────────────────────────────────────────

final searchResultsProvider =
    FutureProvider.autoDispose<List<ProductEntity>>((ref) async {
  final query = ref.watch(searchQueryProvider).trim();
  if (query.isEmpty) {
    return [];
  }

  final categoryId = ref.watch(searchSelectedCategoryProvider);
  final sortBy = ref.watch(searchSortOptionProvider);
  final repository = ref.watch(productsRepositoryProvider);

  final params = ProductFilterParams(
    searchQuery: query,
    categoryId: categoryId,
    sortBy: sortBy,
    limit: 50,
  );

  final result = await repository.getFilteredProducts(params);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (products) => products,
  );
});
