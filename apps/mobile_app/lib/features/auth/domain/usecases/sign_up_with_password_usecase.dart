import '../../../../shared/auth/auth.dart';
import '../../../../shared/types/result.dart';
import '../auth_repository.dart';

class SignUpWithPasswordUseCase {
  const SignUpWithPasswordUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthContext>> call(AuthSignUpRequest request) {
    return _repository.signUpWithPassword(request);
  }
}
