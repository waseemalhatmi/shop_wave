import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/repositories/addresses_repository.dart';
import '../datasources/addresses_remote_data_source.dart';
import '../models/address_model.dart';

class AddressesRepositoryImpl implements AddressesRepository {
  const AddressesRepositoryImpl(this.remoteDataSource);

  final AddressesRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, List<AddressEntity>>> getAddresses() async {
    try {
      final models = await remoteDataSource.getAddresses();
      final entities = models.map((m) => m.toDomain()).toList();
      return Right(entities);
    } on ServerAppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AddressEntity>> addAddress(AddressEntity address) async {
    try {
      final model = await remoteDataSource.addAddress(
        AddressModelX.fromDomain(address),
      );
      return Right(model.toDomain());
    } on ServerAppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AddressEntity>> updateAddress(AddressEntity address) async {
    try {
      final model = await remoteDataSource.updateAddress(
        AddressModelX.fromDomain(address),
      );
      return Right(model.toDomain());
    } on ServerAppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAddress(String id) async {
    try {
      await remoteDataSource.deleteAddress(id);
      return const Right(null);
    } on ServerAppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setDefaultAddress(String id) async {
    try {
      await remoteDataSource.setDefaultAddress(id);
      return const Right(null);
    } on ServerAppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
