import '../../../../shared/auth/auth.dart';
import '../../../../shared/types/result.dart';
import '../auth_repository.dart';

class SignOutUseCase {
  const SignOutUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthContext>> call() {
    return _repository.signOut();
  }
}
