import 'package:movie_watchlist/core/result/result.dart';

abstract class UserDataRepository {
  Future<Result<Unit>> deleteUserData(String uid);
}
