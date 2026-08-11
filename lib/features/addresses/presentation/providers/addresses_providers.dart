import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/repositories/addresses_repository.dart';
import '../../data/datasources/addresses_remote_data_source.dart';
import '../../data/repositories/addresses_repository_impl.dart';
import 'dart:async';

final addressesRepositoryProvider = Provider<AddressesRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final remoteDataSource = AddressesRemoteDataSourceImpl(supabase);
  return AddressesRepositoryImpl(remoteDataSource);
});

class UserAddresses extends AsyncNotifier<List<AddressEntity>> {
  @override
  Future<List<AddressEntity>> build() async {
    final repository = ref.watch(addressesRepositoryProvider);
    final result = await repository.getAddresses();
    return result.fold<List<AddressEntity>>(
      (failure) => throw Exception(failure.message),
      (addresses) => addresses,
    );
  }

  Future<void> addAddress(AddressEntity address) async {
    state = const AsyncLoading();
    final repository = ref.read(addressesRepositoryProvider);
    final result = await repository.addAddress(address);
    state = await AsyncValue.guard(() async {
      result.fold(
        (failure) => throw Exception(failure.message),
        (addr) => addr,
      );
      final res = await repository.getAddresses();
      return res.fold<List<AddressEntity>>(
        (f) => throw Exception(f.message),
        (list) => list,
      );
    });
  }

  Future<void> updateAddress(AddressEntity address) async {
    state = const AsyncLoading();
    final repository = ref.read(addressesRepositoryProvider);
    final result = await repository.updateAddress(address);
    state = await AsyncValue.guard(() async {
      result.fold(
        (failure) => throw Exception(failure.message),
        (addr) => addr,
      );
      final res = await repository.getAddresses();
      return res.fold<List<AddressEntity>>(
        (f) => throw Exception(f.message),
        (list) => list,
      );
    });
  }

  Future<void> deleteAddress(String id) async {
    state = const AsyncLoading();
    final repository = ref.read(addressesRepositoryProvider);
    final result = await repository.deleteAddress(id);
    state = await AsyncValue.guard(() async {
      result.fold(
        (failure) => throw Exception(failure.message),
        (_) => null,
      );
      final res = await repository.getAddresses();
      return res.fold<List<AddressEntity>>(
        (f) => throw Exception(f.message),
        (list) => list,
      );
    });
  }

  Future<void> setDefaultAddress(String id) async {
    state = const AsyncLoading();
    final repository = ref.read(addressesRepositoryProvider);
    final result = await repository.setDefaultAddress(id);
    state = await AsyncValue.guard(() async {
      result.fold(
        (failure) => throw Exception(failure.message),
        (_) => null,
      );
      final res = await repository.getAddresses();
      return res.fold<List<AddressEntity>>(
        (f) => throw Exception(f.message),
        (list) => list,
      );
    });
  }
}

final userAddressesProvider = AsyncNotifierProvider<UserAddresses, List<AddressEntity>>(() {
  return UserAddresses();
});
