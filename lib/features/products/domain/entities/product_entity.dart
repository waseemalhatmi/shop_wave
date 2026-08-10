/// Domain entity for a product — the core commerce object.
class ProductEntity {
  const ProductEntity({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.slug,
    required this.basePrice,
    required this.finalPrice,
    required this.discountPercent,
    required this.avgRating,
    required this.reviewCount,
    required this.soldCount,
    this.descriptionEn,
    this.descriptionAr,
    this.categoryId,
    this.brandId,
    this.primaryImageUrl,
    this.images = const [],
    this.isFeatured = false,
    this.isNewArrival = false,
    this.isOnSale = false,
    this.isActive = true,
    this.sku,
  });

  final String id;
  final String nameEn;
  final String nameAr;
  final String? descriptionEn;
  final String? descriptionAr;
  final String slug;
  final String? categoryId;
  final String? brandId;
  final double basePrice;
  final double finalPrice;
  final double discountPercent;
  final double avgRating;
  final int reviewCount;
  final int soldCount;
  final String? primaryImageUrl;
  final List<String> images;
  final bool isFeatured;
  final bool isNewArrival;
  final bool isOnSale;
  final bool isActive;
  final String? sku;

  bool get hasDiscount => discountPercent > 0;
  bool get isInStock => true; // determined by variant stock — simplified here

  String localizedName(String langCode) =>
      langCode == 'ar' ? nameAr : nameEn;

  String? localizedDescription(String langCode) =>
      langCode == 'ar' ? descriptionAr : descriptionEn;

  int get discountPercenti => discountPercent.round();
}
