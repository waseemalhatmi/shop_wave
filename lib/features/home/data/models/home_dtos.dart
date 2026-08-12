import '../../../categories/domain/entities/category_entity.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../domain/entities/banner_entity.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Banner DTO
// ─────────────────────────────────────────────────────────────────────────────

class BannerDto {
  const BannerDto({
    required this.id,
    required this.imageUrl,
    this.titleEn,
    this.titleAr,
    this.actionType,
    this.actionValue,
    this.sortOrder = 0,
  });

  final String id;
  final String imageUrl;
  final String? titleEn;
  final String? titleAr;
  final String? actionType;
  final String? actionValue;
  final int sortOrder;

  factory BannerDto.fromJson(Map<String, dynamic> json) => BannerDto(
        id: json['id'] as String,
        imageUrl: json['image_url'] as String,
        titleEn: json['title_en'] as String?,
        titleAr: json['title_ar'] as String?,
        actionType: json['action_type'] as String?,
        actionValue: json['action_value'] as String?,
        sortOrder: (json['sort_order'] as int?) ?? 0,
      );

  BannerEntity toEntity() => BannerEntity(
        id: id,
        imageUrl: imageUrl,
        titleEn: titleEn,
        titleAr: titleAr,
        actionType: actionType,
        actionValue: actionValue,
        sortOrder: sortOrder,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Category DTO
// ─────────────────────────────────────────────────────────────────────────────

class CategoryDto {
  const CategoryDto({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.slug,
    this.imageUrl,
    this.parentId,
    this.sortOrder = 0,
    this.isActive = true,
  });

  final String id;
  final String nameEn;
  final String nameAr;
  final String slug;
  final String? imageUrl;
  final String? parentId;
  final int sortOrder;
  final bool isActive;

  factory CategoryDto.fromJson(Map<String, dynamic> json) => CategoryDto(
        id: json['id'] as String,
        nameEn: json['name_en'] as String,
        nameAr: json['name_ar'] as String,
        slug: json['slug'] as String,
        imageUrl: json['image_url'] as String?,
        parentId: json['parent_id'] as String?,
        sortOrder: (json['sort_order'] as int?) ?? 0,
        isActive: (json['is_active'] as bool?) ?? true,
      );

  CategoryEntity toEntity() => CategoryEntity(
        id: id,
        nameEn: nameEn,
        nameAr: nameAr,
        slug: slug,
        imageUrl: imageUrl,
        parentId: parentId,
        sortOrder: sortOrder,
        isActive: isActive,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Product DTO
// ─────────────────────────────────────────────────────────────────────────────

class ProductDto {
  const ProductDto({
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

  factory ProductDto.fromJson(Map<String, dynamic> json) {
    // Extract images from product_images join or top-level field
    final rawImages = json['product_images'] as List<dynamic>?;
    final imageUrls = rawImages
            ?.map((e) => e['url'] as String)
            .where((url) => url.isNotEmpty)
            .toList() ??
        <String>[];

    final primaryImage = rawImages
            ?.where((e) => (e['is_primary'] as bool?) == true)
            .map((e) => e['url'] as String)
            .firstOrNull ??
        imageUrls.firstOrNull;

      final double base = (json['base_price'] as num).toDouble();
      final double discount = (json['discount_percent'] as num?)?.toDouble() ?? 0;
      final double calculatedFinalPrice = base * (1 - (discount / 100));

      return ProductDto(
        id: json['id'] as String,
        nameEn: json['name_en'] as String,
        nameAr: json['name_ar'] as String,
        slug: json['slug'] as String,
        descriptionEn: json['description_en'] as String?,
        descriptionAr: json['description_ar'] as String?,
        categoryId: json['category_id'] as String?,
        brandId: json['brand_id'] as String?,
        basePrice: base,
        finalPrice: calculatedFinalPrice,
        discountPercent: discount,
      avgRating: (json['avg_rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['review_count'] as int?) ?? 0,
      soldCount: (json['sold_count'] as int?) ?? 0,
      primaryImageUrl: primaryImage,
      images: imageUrls,
      isFeatured: (json['is_featured'] as bool?) ?? false,
      isNewArrival: (json['is_new_arrival'] as bool?) ?? false,
      isOnSale: (json['is_on_sale'] as bool?) ?? false,
      isActive: (json['is_active'] as bool?) ?? true,
      sku: json['sku'] as String?,
    );
  }

  ProductEntity toEntity() => ProductEntity(
        id: id,
        nameEn: nameEn,
        nameAr: nameAr,
        descriptionEn: descriptionEn,
        descriptionAr: descriptionAr,
        slug: slug,
        categoryId: categoryId,
        brandId: brandId,
        basePrice: basePrice,
        finalPrice: finalPrice,
        discountPercent: discountPercent,
        avgRating: avgRating,
        reviewCount: reviewCount,
        soldCount: soldCount,
        primaryImageUrl: primaryImageUrl,
        images: images,
        isFeatured: isFeatured,
        isNewArrival: isNewArrival,
        isOnSale: isOnSale,
        isActive: isActive,
        sku: sku,
      );
}
