/// Domain entity for a promotional banner.
class BannerEntity {
  const BannerEntity({
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
  // 'product' | 'category' | 'brand' | 'url'
  final String? actionType;
  final String? actionValue;
  final int sortOrder;

  String? localizedTitle(String langCode) =>
      langCode == 'ar' ? titleAr : titleEn;
}
