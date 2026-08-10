/// Domain entity for a product category.
class CategoryEntity {
  const CategoryEntity({
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
  final String? imageUrl;
  final String? parentId;
  final String slug;
  final int sortOrder;
  final bool isActive;

  bool get isTopLevel => parentId == null;

  /// Returns the localized name based on language code.
  String localizedName(String langCode) =>
      langCode == 'ar' ? nameAr : nameEn;
}
