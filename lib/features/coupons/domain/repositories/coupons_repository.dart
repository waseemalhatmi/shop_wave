import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/coupon_entity.dart';

abstract class CouponsRepository {
  /// Validates a coupon code against Supabase and the order subtotal.
  Future<Either<Failure, CouponEntity>> validateCoupon({
    required String code,
    required double subtotal,
    bool isAr = false,
  });

  /// Increments the used count of a coupon after successful order placement.
  Future<Either<Failure, void>> recordCouponUsage(String couponId);
}
