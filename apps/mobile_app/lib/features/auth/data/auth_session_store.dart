import '../../../shared/auth/auth.dart';

abstract interface class AuthSessionStore {
  Stream<AuthContext> watch();

  AuthContext read();

  Future<void> write(AuthContext context);

  Future<void> clear();
}
