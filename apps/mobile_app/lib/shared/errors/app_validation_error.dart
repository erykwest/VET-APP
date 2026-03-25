import 'app_error.dart';

final class AppValidationError extends AppError {
  const AppValidationError({
    super.code = 'validation_error',
    super.message = 'Validation error',
    super.details,
  });
}
