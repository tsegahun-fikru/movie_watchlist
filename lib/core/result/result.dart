import 'package:movie_watchlist/core/error/failures.dart';

sealed class Result<T> {
  const Result();

  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) {
    final value = this;
    if (value is Success<T>) {
      return success(value.data);
    }

    return failure((value as Error<T>).failure);
  }
}

class Unit {
  const Unit();
}

class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;
}

class Error<T> extends Result<T> {
  const Error(this.failure);

  final Failure failure;
}
