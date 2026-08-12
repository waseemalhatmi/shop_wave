import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/admin_remote_datasource.dart';
import 'admin_providers.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class AdminReviewsState {
  final List<Map<String, dynamic>> reviews;
  final bool hasMore;
  final int page;
  final int? ratingFilter; // null = all, 1-5 = specific rating (min)
  final bool isLoadingMore;

  const AdminReviewsState({
    required this.reviews,
    required this.hasMore,
    required this.page,
    required this.ratingFilter,
    required this.isLoadingMore,
  });

  AdminReviewsState copyWith({
    List<Map<String, dynamic>>? reviews,
    bool? hasMore,
    int? page,
    int? ratingFilter,
    bool clearRatingFilter = false,
    bool? isLoadingMore,
  }) {
    return AdminReviewsState(
      reviews: reviews ?? this.reviews,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      ratingFilter: clearRatingFilter ? null : (ratingFilter ?? this.ratingFilter),
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class AdminReviewsNotifier extends AsyncNotifier<AdminReviewsState> {
  static const int _pageSize = 20;

  @override
  Future<AdminReviewsState> build() async {
    final initial = await _fetchPage(0, null);
    return AdminReviewsState(
      reviews: initial,
      hasMore: initial.length == _pageSize,
      page: 0,
      ratingFilter: null,
      isLoadingMore: false,
    );
  }

  Future<List<Map<String, dynamic>>> _fetchPage(int page, int? ratingFilter) async {
    final ds = ref.read(adminDataSourceProvider);
    // Filter by specific rating: show reviews with exactly that rating
    return ds.getAllReviews(
      page: page,
      pageSize: _pageSize,
      minRating: ratingFilter,
      maxRating: ratingFilter,
    );
  }

  // ── Rating Filter ────────────────────────────────────────────────────────

  Future<void> setRatingFilter(int? rating) async {
    final current = state.value;
    if (current?.ratingFilter == rating) return;
    state = const AsyncLoading();
    try {
      final result = await _fetchPage(0, rating);
      state = AsyncData(AdminReviewsState(
        reviews: result,
        hasMore: result.length == _pageSize,
        page: 0,
        ratingFilter: rating,
        isLoadingMore: false,
      ));
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  // ── Infinite Scroll ──────────────────────────────────────────────────────

  Future<void> loadMore() async {
    final val = state.value;
    if (val == null || !val.hasMore || val.isLoadingMore || state.isLoading) return;
    state = AsyncData(val.copyWith(isLoadingMore: true));
    try {
      final nextPage = val.page + 1;
      final more = await _fetchPage(nextPage, val.ratingFilter);
      state = AsyncData(val.copyWith(
        reviews: [...val.reviews, ...more],
        hasMore: more.length == _pageSize,
        page: nextPage,
        isLoadingMore: false,
      ));
    } catch (_) {
      state = AsyncData(val.copyWith(isLoadingMore: false));
    }
  }

  // ── Optimistic Delete ────────────────────────────────────────────────────

  Future<void> deleteReview(String id) async {
    final val = state.value;
    if (val == null) return;

    final index = val.reviews.indexWhere((r) => r['id'] == id);
    if (index == -1) return;

    final oldReview = val.reviews[index];
    state = AsyncData(val.copyWith(
      reviews: List<Map<String, dynamic>>.from(val.reviews)..removeAt(index),
    ));

    try {
      await ref.read(adminDataSourceProvider).deleteReview(id);
    } catch (e) {
      // Revert on failure
      state = AsyncData(val.copyWith(
        reviews: List<Map<String, dynamic>>.from(val.reviews)..insert(index, oldReview),
      ));
      throw Exception('Failed to delete review');
    }
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final adminReviewsNotifierProvider =
    AsyncNotifierProvider<AdminReviewsNotifier, AdminReviewsState>(AdminReviewsNotifier.new, isAutoDispose: true,);

