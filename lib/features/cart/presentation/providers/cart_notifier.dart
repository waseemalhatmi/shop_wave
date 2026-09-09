import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/config/app_constants.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../coupons/domain/entities/coupon_entity.dart';
import '../../../coupons/presentation/providers/coupons_providers.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../data/datasources/cart_local_data_source.dart';
import '../../domain/entities/cart_entity.dart';

final cartLocalDataSourceProvider = Provider<CartLocalDataSource>((ref) {
  final box = Hive.box<dynamic>(AppConstants.cartBox);
  return CartLocalDataSourceImpl(box);
});

final cartNotifierProvider = NotifierProvider<CartNotifier, CartEntity>(() {
  return CartNotifier();
});

/// Cart state notifier — manages the shopping cart in memory and locally.
class CartNotifier extends Notifier<CartEntity> {
  @override
  CartEntity build() {
    final localDataSource = ref.watch(cartLocalDataSourceProvider);
    final savedItems = localDataSource.getCartItems();
    return CartEntity(items: savedItems);
  }

  // ── Add ──────────────────────────────────────────────────────────────────

  void addItem({
    required ProductEntity product,
    int quantity = 1,
    String? variantId,
    String? variantLabel,
    double? unitPrice,
  }) {
    final existing = _findItem(product.id, variantId);

    if (existing != null) {
      // Increment quantity if already in cart
      _updateItem(
        existing.copyWith(quantity: existing.quantity + quantity),
      );
      AppLogger.i('Cart: increased qty for ${product.nameEn}');
    } else {
      final newItem = CartItemEntity(
        product: product,
        quantity: quantity,
        variantId: variantId,
        variantLabel: variantLabel,
        unitPrice: unitPrice,
      );
      state = state.copyWith(items: [...state.items, newItem]);
      AppLogger.i('Cart: added ${product.nameEn} x$quantity');
    }
    _saveToLocalStorage();
  }

  // ── Remove ───────────────────────────────────────────────────────────────

  void removeItem(String productId, {String? variantId}) {
    state = state.copyWith(
      items: state.items
          .where((i) => !(i.product.id == productId && i.variantId == variantId))
          .toList(),
    );
    AppLogger.i('Cart: removed product $productId');
    _saveToLocalStorage();
  }

  // ── Update Quantity ──────────────────────────────────────────────────────

  void updateQuantity(String productId, int quantity, {String? variantId}) {
    if (quantity <= 0) {
      removeItem(productId, variantId: variantId);
      return;
    }
    final existing = _findItem(productId, variantId);
    if (existing == null) return;
    _updateItem(existing.copyWith(quantity: quantity));
  }

  // ── Increment / Decrement ────────────────────────────────────────────────

  void increment(String productId, {String? variantId}) {
    final existing = _findItem(productId, variantId);
    if (existing == null) return;
    _updateItem(existing.copyWith(quantity: existing.quantity + 1));
  }

  void decrement(String productId, {String? variantId}) {
    final existing = _findItem(productId, variantId);
    if (existing == null) return;
    if (existing.quantity <= 1) {
      removeItem(productId, variantId: variantId);
      return;
    }
    _updateItem(existing.copyWith(quantity: existing.quantity - 1));
  }

  // ── Coupon Management ──────────────────────────────────────────────────

  Future<Either<String, CouponEntity>> applyCoupon(String code, {bool isAr = false}) async {
    if (state.isEmpty) {
      return Left(isAr ? 'السلة فارغة' : 'Your cart is empty');
    }

    final repository = ref.read(couponsRepositoryProvider);
    final result = await repository.validateCoupon(
      code: code,
      subtotal: state.subtotal,
      isAr: isAr,
    );

    return result.fold(
      (failure) => Left(failure.message),
      (coupon) {
        state = state.copyWith(appliedCoupon: coupon);
        AppLogger.i('Cart: applied coupon ${coupon.code}');
        return Right(coupon);
      },
    );
  }

  void removeCoupon() {
    state = state.copyWith(clearCoupon: true);
    AppLogger.i('Cart: removed coupon');
  }

  // ── Clear ────────────────────────────────────────────────────────────────

  void clearCart() {
    state = const CartEntity();
    AppLogger.i('Cart: cleared');
    _saveToLocalStorage();
  }

  // ── Private Helpers ──────────────────────────────────────────────────────

  CartItemEntity? _findItem(String productId, String? variantId) =>
      state.items.where(
        (i) => i.product.id == productId && i.variantId == variantId,
      ).firstOrNull;

  void _updateItem(CartItemEntity updated) {
    state = state.copyWith(
      items: state.items.map((i) {
        final matches = i.product.id == updated.product.id &&
            i.variantId == updated.variantId;
        return matches ? updated : i;
      }).toList(),
    );
    _saveToLocalStorage();
  }

  void _saveToLocalStorage() {
    ref.read(cartLocalDataSourceProvider).saveCartItems(state.items);
  }
}

// ── Derived providers ────────────────────────────────────────────────────────

final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartNotifierProvider).totalItems;
});

final isInCartProvider = Provider.family<bool, String>((ref, productId) {
  return ref.watch(cartNotifierProvider).containsProduct(productId);
});

final cartProductQuantityProvider = Provider.family<int, String>((ref, productId) {
  return ref.watch(cartNotifierProvider).quantityOf(productId);
});
