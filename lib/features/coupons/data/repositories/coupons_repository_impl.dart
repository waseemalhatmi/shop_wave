import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/coupon_entity.dart';
import '../../domain/repositories/coupons_repository.dart';
import '../datasources/coupons_remote_datasource.dart';

class CouponsRepositoryImpl implements CouponsRepository {
  const CouponsRepositoryImpl(this._dataSource);

  final CouponsRemoteDataSource _dataSource;

  @override
  Future<Either<Failure, CouponEntity>> validateCoupon({
    required String code,
    required double subtotal,
    bool isAr = false,
  }) async {
    try {
      final coupon = await _dataSource.validateCoupon(
        code: code,
        subtotal: subtotal,
        isAr: isAr,
      );
      return Right(coupon);
    } on NotFoundAppException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerAppException catch (e) {
      return Left(ValidationFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> recordCouponUsage(String couponId) async {
    try {
      await _dataSource.recordCouponUsage(couponId);
      return const Right(null);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
