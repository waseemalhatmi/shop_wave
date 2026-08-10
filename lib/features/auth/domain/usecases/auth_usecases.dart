import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

/// Use case: Send a password reset email.
class SendPasswordResetEmailUseCase {
  const SendPasswordResetEmailUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, void>> call({required String email}) =>
      _repository.sendPasswordResetEmail(
        email: email.trim().toLowerCase(),
      );
}

/// Use case: Sign out the current user.
class SignOutUseCase {
  const SignOutUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, void>> call() => _repository.signOut();
}
