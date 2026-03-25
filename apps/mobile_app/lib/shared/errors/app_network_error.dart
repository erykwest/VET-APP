import 'app_error.dart';

final class AppNetworkError extends AppError {
  const AppNetworkError({
    super.code = 'network_error',
    super.message = 'Network error',
    super.details,
  });
}
