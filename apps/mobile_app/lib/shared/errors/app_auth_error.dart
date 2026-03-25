import 'app_error.dart';

final class AppAuthError extends AppError {
  const AppAuthError({
    super.code = 'auth_error',
    super.message = 'Authentication error',
    super.details,
  });
}
