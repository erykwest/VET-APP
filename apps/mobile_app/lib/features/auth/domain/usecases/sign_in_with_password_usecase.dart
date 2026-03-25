import '../../../../shared/auth/auth.dart';
import '../../../../shared/types/result.dart';
import '../auth_repository.dart';

class SignInWithPasswordUseCase {
  const SignInWithPasswordUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthContext>> call(AuthEmailPasswordCredentials credentials) {
    return _repository.signInWithPassword(credentials);
  }
}
