import '../../../../shared/auth/auth.dart';
import '../../../../shared/types/result.dart';
import '../auth_repository.dart';

class RestoreAuthSessionUseCase {
  const RestoreAuthSessionUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthContext>> call() {
    return _repository.restoreSession();
  }
}
