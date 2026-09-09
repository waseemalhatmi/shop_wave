import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../data/datasources/coupons_remote_datasource.dart';
import '../../data/repositories/coupons_repository_impl.dart';
import '../../domain/repositories/coupons_repository.dart';

final couponsRemoteDataSourceProvider =
    Provider<CouponsRemoteDataSource>((ref) {
  return CouponsRemoteDataSource(ref.watch(supabaseClientProvider));
});

final couponsRepositoryProvider = Provider<CouponsRepository>((ref) {
  return CouponsRepositoryImpl(ref.watch(couponsRemoteDataSourceProvider));
});
