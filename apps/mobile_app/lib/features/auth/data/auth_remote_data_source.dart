import '../../../shared/auth/auth.dart';
import '../../../shared/types/result.dart';

abstract interface class AuthRemoteDataSource {
  Future<Result<AppSession>> signInWithPassword(
    AuthEmailPasswordCredentials credentials,
  );

  Future<Result<AppSession>> signUpWithPassword(
    AuthSignUpRequest request,
  );

  Future<Result<void>> resetPasswordForEmail(String email);

  Future<Result<void>> signOut();
}
