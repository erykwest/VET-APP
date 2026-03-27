import '../../../shared/auth/auth.dart';

abstract interface class AuthSessionStore {
  Stream<AuthContext> watch();

  AuthContext read();

  Future<AuthContext> restore();

  Future<void> write(AuthContext context);

  Future<void> clear();

  Future<void> dispose();
}
