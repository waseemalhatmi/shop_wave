import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case: Register a new account with email, password, and full name.
class SignUpWithEmailUseCase {
  const SignUpWithEmailUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
    required String fullName,
  }) =>
      _repository.signUpWithEmail(
        email: email.trim().toLowerCase(),
        password: password,
        fullName: fullName.trim(),
      );
}
