import 'package:mobile/domain/failures.dart';

/// Empty value for [Result] when an operation has no payload.
final class Unit {
  const Unit._();
  static const value = Unit._();
}

/// Domain success/failure wrapper. Data layer returns this from API calls.
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Err<T>;

  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) {
    return switch (this) {
      Success(:final data) => success(data),
      Err(failure: final f) => failure(f),
    };
  }

  R fold<R>(
    R Function(Failure failure) onFailure,
    R Function(T data) onSuccess,
  ) =>
      when(success: onSuccess, failure: onFailure);
}

final class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;
}
