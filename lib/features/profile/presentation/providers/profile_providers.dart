import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_watchlist/core/providers/core_providers.dart';
import 'package:movie_watchlist/features/auth/presentation/providers/auth_providers.dart';
import 'package:movie_watchlist/features/profile/data/datasources/firestore_user_data_source.dart';
import 'package:movie_watchlist/features/profile/data/repositories/firestore_user_data_repository.dart';
import 'package:movie_watchlist/features/profile/domain/repositories/user_data_repository.dart';
import 'package:movie_watchlist/features/profile/domain/usecases/delete_account_use_case.dart';

final firestoreUserDataSourceProvider = Provider<FirestoreUserDataSource>((
  ref,
) {
  return FirestoreUserDataSource(firestore: ref.watch(firestoreProvider));
});

final userDataRepositoryProvider = Provider<UserDataRepository>((ref) {
  return FirestoreUserDataRepository(
    dataSource: ref.watch(firestoreUserDataSourceProvider),
  );
});

final deleteAccountUseCaseProvider = Provider<DeleteAccountUseCase>((ref) {
  return DeleteAccountUseCase(
    authRepository: ref.watch(authRepositoryProvider),
    userDataRepository: ref.watch(userDataRepositoryProvider),
  );
});
