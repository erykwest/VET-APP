import '../../../shared/auth/auth.dart';
import '../../../shared/types/result.dart';
import 'auth_sign_up_result.dart';

abstract interface class AuthRemoteDataSource {
  Future<Result<AppSession>> signInWithPassword(
    AuthEmailPasswordCredentials credentials,
  );

  Future<Result<AuthSignUpResult>> signUpWithPassword(
    AuthSignUpRequest request,
  );

  Future<Result<void>> resetPasswordForEmail(String email);

  Future<Result<void>> signOut();
}
