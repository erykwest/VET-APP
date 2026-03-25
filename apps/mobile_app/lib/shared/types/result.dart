import '../errors/app_error.dart';

sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(AppError error) onFailure,
  }) {
    return switch (this) {
      Success<T>(value: final value) => onSuccess(value),
      Failure<T>(error: final error) => onFailure(error),
    };
  }

  Result<R> map<R>(R Function(T value) transform) {
    return switch (this) {
      Success<T>(value: final value) => Success<R>(transform(value)),
      Failure<T>(error: final error) => Failure<R>(error),
    };
  }

  static Result<T> success<T>(T value) => Success<T>(value);
  static Result<T> failure<T>(AppError error) => Failure<T>(error);
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

final class Failure<T> extends Result<T> {
  const Failure(this.error);

  final AppError error;
}
