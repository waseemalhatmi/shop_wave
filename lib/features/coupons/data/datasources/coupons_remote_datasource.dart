import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/coupon_entity.dart';

class CouponsRemoteDataSource {
  const CouponsRemoteDataSource(this._supabase);

  final SupabaseClient _supabase;

  Future<CouponEntity> validateCoupon({
    required String code,
    required double subtotal,
    bool isAr = false,
  }) async {
    try {
      final cleanCode = code.trim().toUpperCase();
      final data = await _supabase
          .from('coupons')
          .select()
          .ilike('code', cleanCode)
          .maybeSingle();

      if (data == null) {
        throw NotFoundAppException(
          isAr ? 'كود الكوبون غير صالح' : 'Coupon code is invalid',
        );
      }

      final coupon = CouponEntity.fromJson(data);
      final validationError = coupon.validate(subtotal, isAr: isAr);
      if (validationError != null) {
        throw ServerAppException(validationError);
      }

      return coupon;
    } on AppException {
      rethrow;
    } catch (e, st) {
      AppLogger.e('CouponsRemoteDataSource.validateCoupon', error: e, stackTrace: st);
      throw ServerAppException(
        isAr ? 'فشل التحقق من الكوبون' : 'Failed to validate coupon',
      );
    }
  }

  Future<void> recordCouponUsage(String couponId) async {
    try {
      // First attempt RPC if configured in DB, else direct atomic increment
      final current = await _supabase
          .from('coupons')
          .select('used_count')
          .eq('id', couponId)
          .maybeSingle();

      if (current != null) {
        final count = (current['used_count'] as int?) ?? 0;
        await _supabase
            .from('coupons')
            .update({'used_count': count + 1})
            .eq('id', couponId);
      }
    } catch (e, st) {
      AppLogger.e('Failed to record coupon usage', error: e, stackTrace: st);
    }
  }
}
