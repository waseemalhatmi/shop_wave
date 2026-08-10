import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Concrete implementation of [AuthRepository].
///
/// This is the "translator" between the data layer (DTOs, exceptions)
/// and the domain layer (entities, failures).
///
/// Pattern: try/catch AppException → return Left(Failure)
/// This is the ONLY class that converts exceptions to failures.
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final dto = await _remoteDataSource.getCurrentUser();
      return dto?.toEntity();
    } catch (e, st) {
      AppLogger.e('AuthRepository.getCurrentUser', error: e, stackTrace: st);
      return null;
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final dto = await _remoteDataSource.signInWithEmail(
        email: email,
        password: password,
      );
      return Right(dto.toEntity());
    } on AuthAppException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkAppException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerAppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e, st) {
      AppLogger.e('AuthRepository.signInWithEmail', error: e, stackTrace: st);
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final dto = await _remoteDataSource.signUpWithEmail(
        email: email,
        password: password,
        fullName: fullName,
      );
      return Right(dto.toEntity());
    } on AuthAppException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkAppException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerAppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e, st) {
      AppLogger.e('AuthRepository.signUpWithEmail', error: e, stackTrace: st);
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await _remoteDataSource.sendPasswordResetEmail(email: email);
      return const Right(null);
    } on AuthAppException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkAppException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e, st) {
      AppLogger.e(
        'AuthRepository.sendPasswordResetEmail',
        error: e,
        stackTrace: st,
      );
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      return const Right(null);
    } on AuthAppException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e, st) {
      AppLogger.e('AuthRepository.signOut', error: e, stackTrace: st);
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges =>
      _remoteDataSource.authStateChanges.map((dto) => dto?.toEntity());
}
