import 'package:equatable/equatable.dart';

/// Domain entity representing a promotional discount coupon.
class CouponEntity extends Equatable {
  const CouponEntity({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    this.minOrderAmount = 0.0,
    this.maxUses,
    this.usedCount = 0,
    this.isActive = true,
    this.expiresAt,
  });

  final String id;
  final String code;
  final String discountType; // 'percentage' or 'fixed'
  final double discountValue;
  final double minOrderAmount;
  final int? maxUses;
  final int usedCount;
  final bool isActive;
  final DateTime? expiresAt;

  bool get isPercentage => discountType == 'percentage';
  bool get isFixed => discountType == 'fixed';

  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);

  bool get isExhausted => maxUses != null && usedCount >= maxUses!;

  /// Formatted discount label, e.g. "20% OFF" or "50 SAR OFF"
  String formattedDiscount(String currency) =>
      isPercentage ? '${discountValue.round()}%' : '${discountValue.toStringAsFixed(2)} $currency';

  /// Validates whether this coupon can be applied to the given subtotal.
  /// Returns null if valid, or an error message code/string if invalid.
  String? validate(double subtotal, {bool isAr = false}) {
    if (!isActive) {
      return isAr ? 'هذا الكوبون غير فعال حالياً' : 'This coupon is currently inactive';
    }
    if (isExpired) {
      return isAr ? 'عذراً، هذا الكوبون منتهي الصلاحية' : 'Sorry, this coupon has expired';
    }
    if (isExhausted) {
      return isAr
          ? 'تم استنفاذ الحد الأقصى لاستخدام هذا الكوبون'
          : 'This coupon usage limit has been reached';
    }
    if (subtotal < minOrderAmount) {
      return isAr
          ? 'الحد الأدنى للطلب لتفعيل هذا الكوبون هو ${minOrderAmount.toStringAsFixed(2)}'
          : 'Minimum order amount for this coupon is ${minOrderAmount.toStringAsFixed(2)}';
    }
    return null;
  }

  /// Calculates the discount deduction for the given subtotal.
  double calculateDiscount(double subtotal) {
    if (validate(subtotal) != null) return 0.0;

    if (isPercentage) {
      final discount = subtotal * (discountValue / 100.0);
      return discount > subtotal ? subtotal : discount;
    } else {
      return discountValue > subtotal ? subtotal : discountValue;
    }
  }

  factory CouponEntity.fromJson(Map<String, dynamic> json) {
    return CouponEntity(
      id: json['id'] as String,
      code: (json['code'] as String).toUpperCase(),
      discountType: (json['discount_type'] as String?) ?? 'percentage',
      discountValue: (json['discount_value'] as num).toDouble(),
      minOrderAmount: (json['min_order_amount'] as num?)?.toDouble() ?? 0.0,
      maxUses: json['max_uses'] as int?,
      usedCount: (json['used_count'] as int?) ?? 0,
      isActive: (json['is_active'] as bool?) ?? true,
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'discount_type': discountType,
        'discount_value': discountValue,
        'min_order_amount': minOrderAmount,
        'max_uses': maxUses,
        'used_count': usedCount,
        'is_active': isActive,
        'expires_at': expiresAt?.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        id,
        code,
        discountType,
        discountValue,
        minOrderAmount,
        maxUses,
        usedCount,
        isActive,
        expiresAt,
      ];
}
