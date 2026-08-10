import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case: Sign in with email and password.
///
/// Why a separate class per use case?
/// - Single Responsibility: each class does exactly one thing
/// - Testable independently from UI and data layer
/// - Discoverable: new developers can read use cases to understand
///   what the feature does without reading implementation details
///
/// This is the "application business rule" layer.
class SignInWithEmailUseCase {
  const SignInWithEmailUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
  }) =>
      _repository.signInWithEmail(
        email: email.trim().toLowerCase(),
        password: password,
      );
}
