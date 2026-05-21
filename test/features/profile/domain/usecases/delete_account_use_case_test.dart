import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_watchlist/core/auth/auth_repository.dart';
import 'package:movie_watchlist/core/error/exceptions.dart';
import 'package:movie_watchlist/core/error/failures.dart';
import 'package:movie_watchlist/core/result/result.dart';
import 'package:movie_watchlist/features/profile/domain/repositories/user_data_repository.dart';
import 'package:movie_watchlist/features/profile/domain/usecases/delete_account_use_case.dart';

void main() {
  late DeleteAccountUseCase useCase;
  late FakeAuthRepository authRepository;
  late FakeUserDataRepository userDataRepository;

  setUp(() {
    authRepository = FakeAuthRepository();
    userDataRepository = FakeUserDataRepository();
    useCase = DeleteAccountUseCase(
      authRepository: authRepository,
      userDataRepository: userDataRepository,
    );
  });

  test('reauthenticates before deleting data and auth account', () async {
    final result = await useCase(
      const DeleteAccountParams(
        uid: 'user-1',
        email: 'user@example.com',
        password: 'secret',
      ),
    );

    expect(result, isA<Success<Unit>>());
    expect(authRepository.calls, <String>[
      'reauthenticate:user@example.com',
      'deleteCurrentUser',
    ]);
    expect(userDataRepository.deletedUid, 'user-1');
  });

  test(
    'requires password before touching user data for email accounts',
    () async {
      final result = await useCase(
        const DeleteAccountParams(uid: 'user-1', email: 'user@example.com'),
      );

      expect(result, isA<Error<Unit>>());
      expect((result as Error<Unit>).failure, isA<ValidationFailure>());
      expect(userDataRepository.deletedUid, isNull);
      expect(authRepository.calls, isEmpty);
    },
  );

  test('returns data deletion failure without deleting auth account', () async {
    userDataRepository.result = const Error<Unit>(
      CacheFailure('delete failed'),
    );

    final result = await useCase(
      const DeleteAccountParams(
        uid: 'user-1',
        email: 'user@example.com',
        password: 'secret',
      ),
    );

    expect(result, isA<Error<Unit>>());
    expect((result as Error<Unit>).failure, isA<CacheFailure>());
    expect(authRepository.calls, <String>['reauthenticate:user@example.com']);
  });

  test('maps auth deletion errors to authentication failure', () async {
    authRepository.deleteError = const AuthenticationException('auth failed');

    final result = await useCase(
      const DeleteAccountParams(
        uid: 'user-1',
        email: 'user@example.com',
        password: 'secret',
      ),
    );

    expect(result, isA<Error<Unit>>());
    expect((result as Error<Unit>).failure, isA<AuthenticationFailure>());
    expect(userDataRepository.deletedUid, 'user-1');
  });
}

class FakeAuthRepository implements AuthRepository {
  final List<String> calls = <String>[];
  AuthenticationException? reauthError;
  AuthenticationException? deleteError;

  @override
  Stream<User?> get authStateChanges => const Stream<User?>.empty();

  @override
  Future<void> deleteCurrentUser() async {
    calls.add('deleteCurrentUser');
    if (deleteError != null) throw deleteError!;
  }

  @override
  Future<void> reauthenticateWithPassword(String email, String password) async {
    calls.add('reauthenticate:$email');
    if (reauthError != null) throw reauthError!;
  }

  @override
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<User?> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<void> updateDisplayName(String? displayName) async {}
}

class FakeUserDataRepository implements UserDataRepository {
  Result<Unit> result = const Success<Unit>(Unit());
  String? deletedUid;

  @override
  Future<Result<Unit>> deleteUserData(String uid) async {
    deletedUid = uid;
    return result;
  }
}
