abstract class AppError implements Exception {
  const AppError({
    required this.code,
    required this.message,
    this.details,
  });

  final String code;
  final String message;
  final Object? details;

  @override
  String toString() => '$code: $message';
}

final class AppUnexpectedError extends AppError {
  const AppUnexpectedError({
    super.code = 'unexpected_error',
    super.message = 'Unexpected error',
    super.details,
  });
}
