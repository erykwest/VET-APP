import '../../shared/types/result.dart';
import '../models/app_session.dart';

abstract class AuthRepository {
  Future<Result<AppSession>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Result<AppSession>> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  });

  Future<Result<void>> signOut();

  Future<Result<AppSession?>> restoreSession();
}
