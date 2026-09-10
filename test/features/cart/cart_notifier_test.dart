import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shop_wave/features/cart/domain/entities/cart_entity.dart';
import 'package:shop_wave/features/cart/presentation/providers/cart_notifier.dart';
import 'package:shop_wave/features/products/domain/entities/product_entity.dart';

// ── Test Helpers ─────────────────────────────────────────────────────────────

ProductEntity _makeProduct({
  String id = 'prod-1',
  String name = 'Test Product',
  double price = 100.0,
}) =>
    ProductEntity(
      id: id,
      nameEn: name,
      nameAr: 'منتج اختبار',
      slug: 'test-product',
      basePrice: price,
      finalPrice: price,
      discountPercent: 0,
      avgRating: 4.5,
      reviewCount: 10,
      soldCount: 50,
    );

// ── Cart Notifier Tests ───────────────────────────────────────────────────────

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        // Override cartLocalDataSourceProvider to avoid Hive init in tests
        cartLocalDataSourceProvider.overrideWith(
          (ref) => _FakeCartLocalDataSource(),
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('CartNotifier - addItem', () {
    test('adds a new product to the cart', () {
      final product = _makeProduct();
      container.read(cartNotifierProvider.notifier).addItem(product: product);
      final state = container.read(cartNotifierProvider);

      expect(state.items.length, 1);
      expect(state.items.first.product.id, 'prod-1');
      expect(state.items.first.quantity, 1);
    });

    test('increments quantity when same product added again', () {
      final product = _makeProduct();
      final notifier = container.read(cartNotifierProvider.notifier);

      notifier.addItem(product: product);
      notifier.addItem(product: product, quantity: 2);

      final state = container.read(cartNotifierProvider);
      expect(state.items.length, 1);
      expect(state.items.first.quantity, 3);
    });

    test('adds separate items for different variants of same product', () {
      final product = _makeProduct();
      final notifier = container.read(cartNotifierProvider.notifier);

      notifier.addItem(product: product, color: 'Red', size: 'M');
      notifier.addItem(product: product, color: 'Blue', size: 'L');

      final state = container.read(cartNotifierProvider);
      expect(state.items.length, 2);
    });

    test('adds multiple different products separately', () {
      final notifier = container.read(cartNotifierProvider.notifier);
      notifier.addItem(product: _makeProduct(id: 'prod-1'));
      notifier.addItem(product: _makeProduct(id: 'prod-2'));

      final state = container.read(cartNotifierProvider);
      expect(state.items.length, 2);
    });
  });

  group('CartNotifier - removeItem', () {
    test('removes an item from the cart', () {
      final product = _makeProduct();
      final notifier = container.read(cartNotifierProvider.notifier);

      notifier.addItem(product: product);
      notifier.removeItem(product.id);

      final state = container.read(cartNotifierProvider);
      expect(state.items, isEmpty);
    });

    test('only removes matching product, leaves others', () {
      final notifier = container.read(cartNotifierProvider.notifier);
      notifier.addItem(product: _makeProduct(id: 'prod-1'));
      notifier.addItem(product: _makeProduct(id: 'prod-2'));
      notifier.removeItem('prod-1');

      final state = container.read(cartNotifierProvider);
      expect(state.items.length, 1);
      expect(state.items.first.product.id, 'prod-2');
    });
  });

  group('CartNotifier - updateQuantity', () {
    test('updates item quantity correctly', () {
      final product = _makeProduct();
      final notifier = container.read(cartNotifierProvider.notifier);

      notifier.addItem(product: product);
      notifier.updateQuantity(product.id, 5);

      final state = container.read(cartNotifierProvider);
      expect(state.items.first.quantity, 5);
    });

    test('removes item when quantity set to 0', () {
      final product = _makeProduct();
      final notifier = container.read(cartNotifierProvider.notifier);

      notifier.addItem(product: product);
      notifier.updateQuantity(product.id, 0);

      final state = container.read(cartNotifierProvider);
      expect(state.items, isEmpty);
    });
  });

  group('CartNotifier - increment / decrement', () {
    test('increments product quantity by 1', () {
      final product = _makeProduct();
      final notifier = container.read(cartNotifierProvider.notifier);

      notifier.addItem(product: product, quantity: 2);
      notifier.increment(product.id);

      expect(container.read(cartNotifierProvider).items.first.quantity, 3);
    });

    test('decrements product quantity by 1', () {
      final product = _makeProduct();
      final notifier = container.read(cartNotifierProvider.notifier);

      notifier.addItem(product: product, quantity: 3);
      notifier.decrement(product.id);

      expect(container.read(cartNotifierProvider).items.first.quantity, 2);
    });

    test('removes item when decremented from quantity 1', () {
      final product = _makeProduct();
      final notifier = container.read(cartNotifierProvider.notifier);

      notifier.addItem(product: product, quantity: 1);
      notifier.decrement(product.id);

      expect(container.read(cartNotifierProvider).items, isEmpty);
    });
  });

  group('CartNotifier - clearCart', () {
    test('empties the cart completely', () {
      final notifier = container.read(cartNotifierProvider.notifier);
      notifier.addItem(product: _makeProduct(id: 'prod-1'));
      notifier.addItem(product: _makeProduct(id: 'prod-2'));
      notifier.clearCart();

      final state = container.read(cartNotifierProvider);
      expect(state.items, isEmpty);
    });
  });

  group('CartEntity - computed properties', () {
    test('totalItems sums all quantities', () {
      final product1 = _makeProduct(id: 'p1', price: 50);
      final product2 = _makeProduct(id: 'p2', price: 150);
      const cart = CartEntity(
        items: [
          CartItemEntity(product: ProductEntity(
            id: 'p1', nameEn: 'P1', nameAr: 'م1', slug: 's1',
            basePrice: 50, finalPrice: 50, discountPercent: 0,
            avgRating: 4, reviewCount: 0, soldCount: 0,
          ), quantity: 2),
          CartItemEntity(product: ProductEntity(
            id: 'p2', nameEn: 'P2', nameAr: 'م2', slug: 's2',
            basePrice: 150, finalPrice: 150, discountPercent: 0,
            avgRating: 4, reviewCount: 0, soldCount: 0,
          ), quantity: 3),
        ],
      );

      expect(cart.totalItems, 5);
      expect(cart.subtotal, closeTo(550, 0.01)); // 2×50 + 3×150
    });

    test('free shipping when subtotal >= 100', () {
      final item = CartItemEntity(
        product: _makeProduct(price: 200),
        quantity: 1,
      );
      final cart = CartEntity(items: [item]);

      expect(cart.shippingCost, 0.0);
    });

    test('shipping cost applied when subtotal < 100', () {
      final item = CartItemEntity(
        product: _makeProduct(price: 30),
        quantity: 1,
      );
      final cart = CartEntity(items: [item]);

      expect(cart.shippingCost, 9.99);
    });

    test('isEmpty returns true for empty cart', () {
      const cart = CartEntity();
      expect(cart.isEmpty, isTrue);
    });
  });
}

// ── Fake Cart Data Source ────────────────────────────────────────────────────

class _FakeCartLocalDataSource implements CartLocalDataSource {
  final _items = <CartItemEntity>[];

  @override
  List<CartItemEntity> getCartItems() => List.unmodifiable(_items);

  @override
  Future<void> saveCartItems(List<CartItemEntity> items) async {
    _items
      ..clear()
      ..addAll(items);
  }

  @override
  Future<void> clearCart() async => _items.clear();
}
