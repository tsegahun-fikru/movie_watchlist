import 'package:movie_watchlist/core/auth/auth_repository.dart';
import 'package:movie_watchlist/core/error/exceptions.dart';
import 'package:movie_watchlist/core/error/failures.dart';
import 'package:movie_watchlist/core/result/result.dart';
import 'package:movie_watchlist/features/profile/domain/repositories/user_data_repository.dart';

class DeleteAccountParams {
  const DeleteAccountParams({required this.uid, this.email, this.password});

  final String uid;
  final String? email;
  final String? password;
}

class DeleteAccountUseCase {
  DeleteAccountUseCase({
    required AuthRepository authRepository,
    required UserDataRepository userDataRepository,
  }) : _authRepository = authRepository,
       _userDataRepository = userDataRepository;

  final AuthRepository _authRepository;
  final UserDataRepository _userDataRepository;

  Future<Result<Unit>> call(DeleteAccountParams params) async {
    final email = params.email?.trim();
    final password = params.password?.trim();

    if (email != null && email.isNotEmpty) {
      if (password == null || password.isEmpty) {
        return const Error<Unit>(
          ValidationFailure('Password confirmation is required.'),
        );
      }

      try {
        await _authRepository.reauthenticateWithPassword(email, password);
      } on AuthenticationException catch (error) {
        return Error<Unit>(AuthenticationFailure(error.message));
      } catch (error) {
        return Error<Unit>(UnknownFailure('$error'));
      }
    }

    final dataResult = await _userDataRepository.deleteUserData(params.uid);
    if (dataResult is Error<Unit>) {
      return dataResult;
    }

    try {
      await _authRepository.deleteCurrentUser();
      return const Success<Unit>(Unit());
    } on AuthenticationException catch (error) {
      return Error<Unit>(AuthenticationFailure(error.message));
    } catch (error) {
      return Error<Unit>(UnknownFailure('$error'));
    }
  }
}
