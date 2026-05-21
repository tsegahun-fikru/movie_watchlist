import 'package:movie_watchlist/core/error/exceptions.dart';
import 'package:movie_watchlist/core/error/failures.dart';
import 'package:movie_watchlist/core/result/result.dart';
import 'package:movie_watchlist/features/profile/data/datasources/firestore_user_data_source.dart';
import 'package:movie_watchlist/features/profile/domain/repositories/user_data_repository.dart';

class FirestoreUserDataRepository implements UserDataRepository {
  FirestoreUserDataRepository({required FirestoreUserDataSource dataSource})
    : _dataSource = dataSource;

  final FirestoreUserDataSource _dataSource;

  @override
  Future<Result<Unit>> deleteUserData(String uid) async {
    try {
      await _dataSource.deleteUserData(uid);
      return const Success<Unit>(Unit());
    } on CacheException catch (error) {
      return Error<Unit>(CacheFailure(error.message));
    } catch (error) {
      return Error<Unit>(UnknownFailure('$error'));
    }
  }
}
