import 'package:dartz/dartz.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shop_wave/core/error/failures.dart';
import 'package:shop_wave/features/auth/domain/entities/user_entity.dart';
import 'package:shop_wave/features/auth/domain/repositories/auth_repository.dart';
import 'package:shop_wave/features/auth/domain/usecases/auth_usecases.dart';
import 'package:shop_wave/features/auth/domain/usecases/sign_in_with_email_usecase.dart';
import 'package:shop_wave/features/auth/domain/usecases/sign_up_with_email_usecase.dart';

// ── Mocks ────────────────────────────────────────────────────────────────────

class MockAuthRepository extends Mock implements AuthRepository {}

// ── Test Data ────────────────────────────────────────────────────────────────

final _testUser = UserEntity(
  id: 'user-123',
  email: 'test@shopwave.com',
  fullName: 'Test User',
  role: 'customer',
  createdAt: DateTime(2026, 1, 1),
);

// ── Test Suite ────────────────────────────────────────────────────────────────

void main() {
  late MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = MockAuthRepository();
  });

  // ── SignInWithEmailUseCase ──────────────────────────────────────────────────

  group('SignInWithEmailUseCase', () {
    late SignInWithEmailUseCase useCase;

    setUp(() {
      useCase = SignInWithEmailUseCase(mockRepo);
    });

    test('returns UserEntity on successful sign-in', () async {
      // Arrange
      when(
        () => mockRepo.signInWithEmail(
          email: 'test@shopwave.com',
          password: 'Password123!',
        ),
      ).thenAnswer((_) async => Right(_testUser));

      // Act
      final result = await useCase(
        email: 'test@shopwave.com',
        password: 'Password123!',
      );

      // Assert
      expect(result, Right<Failure, UserEntity>(_testUser));
      verify(
        () => mockRepo.signInWithEmail(
          email: 'test@shopwave.com',
          password: 'Password123!',
        ),
      ).called(1);
    });

    test('returns AuthFailure when credentials are invalid', () async {
      // Arrange
      when(
        () => mockRepo.signInWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => const Left(AuthFailure('Invalid credentials')));

      // Act
      final result = await useCase(email: 'bad@email.com', password: 'wrong');

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f, isA<AuthFailure>()),
        (_) => fail('Expected failure'),
      );
    });

    test('trims and lowercases email before calling repository', () async {
      // Arrange
      when(
        () => mockRepo.signInWithEmail(
          email: 'test@shopwave.com',
          password: 'Password123!',
        ),
      ).thenAnswer((_) async => Right(_testUser));

      // Act — pass email with spaces and uppercase
      await useCase(email: '  TEST@ShopWave.COM  ', password: 'Password123!');

      // Assert the normalized email was passed
      verify(
        () => mockRepo.signInWithEmail(
          email: 'test@shopwave.com',
          password: 'Password123!',
        ),
      ).called(1);
    });

    test('returns NetworkFailure when device is offline', () async {
      // Arrange
      when(
        () => mockRepo.signInWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => const Left(NetworkFailure()));

      // Act
      final result = await useCase(email: 'a@b.com', password: 'pass');

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f, isA<NetworkFailure>()),
        (_) => fail('Expected failure'),
      );
    });
  });

  // ── SignUpWithEmailUseCase ──────────────────────────────────────────────────

  group('SignUpWithEmailUseCase', () {
    late SignUpWithEmailUseCase useCase;

    setUp(() {
      useCase = SignUpWithEmailUseCase(mockRepo);
    });

    test('returns UserEntity on successful sign-up', () async {
      // Arrange
      when(
        () => mockRepo.signUpWithEmail(
          email: 'new@shopwave.com',
          password: 'SecurePass1!',
          fullName: 'New User',
        ),
      ).thenAnswer((_) async => Right(_testUser.copyWith(email: 'new@shopwave.com')));

      // Act
      final result = await useCase(
        email: 'new@shopwave.com',
        password: 'SecurePass1!',
        fullName: 'New User',
      );

      // Assert
      expect(result.isRight(), true);
    });

    test('returns ServerFailure when email is already taken', () async {
      // Arrange
      when(
        () => mockRepo.signUpWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
          fullName: any(named: 'fullName'),
        ),
      ).thenAnswer((_) async => const Left(ServerFailure('Email already in use.')));

      // Act
      final result = await useCase(
        email: 'taken@shopwave.com',
        password: 'pass',
        fullName: 'User',
      );

      // Assert
      result.fold(
        (f) => expect(f.message, contains('Email')),
        (_) => fail('Expected failure'),
      );
    });

    test('trims email and fullName before calling repository', () async {
      // Arrange
      when(
        () => mockRepo.signUpWithEmail(
          email: 'user@shopwave.com',
          password: 'pass',
          fullName: 'New User',
        ),
      ).thenAnswer((_) async => Right(_testUser));

      // Act — pass untrimmed values
      await useCase(
        email: '  USER@ShopWave.COM  ',
        password: 'pass',
        fullName: '  New User  ',
      );

      // Assert normalized values were passed
      verify(
        () => mockRepo.signUpWithEmail(
          email: 'user@shopwave.com',
          password: 'pass',
          fullName: 'New User',
        ),
      ).called(1);
    });
  });

  // ── SignOutUseCase ──────────────────────────────────────────────────────────

  group('SignOutUseCase', () {
    late SignOutUseCase useCase;

    setUp(() {
      useCase = SignOutUseCase(mockRepo);
    });

    test('calls signOut on repository and returns Right(null)', () async {
      // Arrange
      when(() => mockRepo.signOut()).thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase();

      // Assert
      expect(result.isRight(), true);
      verify(() => mockRepo.signOut()).called(1);
    });

    test('returns AuthFailure when sign-out fails', () async {
      // Arrange
      when(() => mockRepo.signOut())
          .thenAnswer((_) async => const Left(AuthFailure('Session expired')));

      // Act
      final result = await useCase();

      // Assert
      result.fold(
        (f) => expect(f, isA<AuthFailure>()),
        (_) => fail('Expected failure'),
      );
    });
  });
}
