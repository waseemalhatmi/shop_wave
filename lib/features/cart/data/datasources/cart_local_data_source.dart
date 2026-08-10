import 'package:hive_flutter/hive_flutter.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../domain/entities/cart_entity.dart';

abstract class CartLocalDataSource {
  List<CartItemEntity> getCartItems();
  Future<void> saveCartItems(List<CartItemEntity> items);
  Future<void> clearCart();
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  const CartLocalDataSourceImpl(this.box);

  final Box<dynamic> box;

  static const _cartKey = 'cart_items';

  @override
  List<CartItemEntity> getCartItems() {
    try {
      final data = box.get(_cartKey);
      if (data == null) return [];

      final list = data as List<dynamic>;
      return list.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        return _cartItemFromMap(map);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveCartItems(List<CartItemEntity> items) async {
    final maps = items.map((i) => _cartItemToMap(i)).toList();
    await box.put(_cartKey, maps);
  }

  @override
  Future<void> clearCart() async {
    await box.delete(_cartKey);
  }

  // ── Serialization Helpers ─────────────────────────────────────────

  CartItemEntity _cartItemFromMap(Map<String, dynamic> map) {
    return CartItemEntity(
      product: _productFromMap(Map<String, dynamic>.from(map['product'] as Map)),
      quantity: map['quantity'] as int,
      variantId: map['variant_id'] as String?,
      variantLabel: map['variant_label'] as String?,
      unitPrice: (map['unit_price'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> _cartItemToMap(CartItemEntity item) {
    return {
      'product': _productToMap(item.product),
      'quantity': item.quantity,
      'variant_id': item.variantId,
      'variant_label': item.variantLabel,
      'unit_price': item.unitPrice,
    };
  }

  ProductEntity _productFromMap(Map<String, dynamic> map) {
    return ProductEntity(
      id: map['id'] as String,
      nameEn: map['name_en'] as String,
      nameAr: map['name_ar'] as String,
      descriptionEn: map['description_en'] as String?,
      descriptionAr: map['description_ar'] as String?,
      slug: map['slug'] as String,
      categoryId: map['category_id'] as String?,
      brandId: map['brand_id'] as String?,
      basePrice: (map['base_price'] as num).toDouble(),
      finalPrice: (map['final_price'] as num).toDouble(),
      discountPercent: (map['discount_percent'] as num).toDouble(),
      avgRating: (map['avg_rating'] as num).toDouble(),
      reviewCount: map['review_count'] as int,
      soldCount: map['sold_count'] as int,
      primaryImageUrl: map['primary_image_url'] as String?,
      images: List<String>.from(map['images'] as List? ?? []),
      isFeatured: map['is_featured'] as bool? ?? false,
      isNewArrival: map['is_new_arrival'] as bool? ?? false,
      isOnSale: map['is_on_sale'] as bool? ?? false,
      isActive: map['is_active'] as bool? ?? true,
      sku: map['sku'] as String?,
    );
  }

  Map<String, dynamic> _productToMap(ProductEntity p) {
    return {
      'id': p.id,
      'name_en': p.nameEn,
      'name_ar': p.nameAr,
      'description_en': p.descriptionEn,
      'description_ar': p.descriptionAr,
      'slug': p.slug,
      'category_id': p.categoryId,
      'brand_id': p.brandId,
      'base_price': p.basePrice,
      'final_price': p.finalPrice,
      'discount_percent': p.discountPercent,
      'avg_rating': p.avgRating,
      'review_count': p.reviewCount,
      'sold_count': p.soldCount,
      'primary_image_url': p.primaryImageUrl,
      'images': p.images,
      'is_featured': p.isFeatured,
      'is_new_arrival': p.isNewArrival,
      'is_on_sale': p.isOnSale,
      'is_active': p.isActive,
      'sku': p.sku,
    };
  }
}
