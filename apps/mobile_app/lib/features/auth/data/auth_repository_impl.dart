import 'dart:async';

import '../../../shared/auth/auth.dart';
import '../../../shared/types/result.dart';
import '../domain/auth_repository.dart';
import 'auth_remote_data_source.dart';
import 'auth_session_store.dart';
import 'auth_sign_up_result.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthSessionStore sessionStore,
  })  : _remoteDataSource = remoteDataSource,
        _sessionStore = sessionStore {
    _contextController.add(_sessionStore.read());
    _storeSubscription = _sessionStore.watch().listen(_contextController.add);
  }

  final AuthRemoteDataSource _remoteDataSource;
  final AuthSessionStore _sessionStore;
  final StreamController<AuthContext> _contextController =
      StreamController<AuthContext>.broadcast();
  late final StreamSubscription<AuthContext> _storeSubscription;

  @override
  Stream<AuthContext> watchContext() => _contextController.stream;

  @override
  Future<Result<AuthContext>> restoreSession() async {
    final context = await _sessionStore.restore();
    _contextController.add(context);
    return Result.success(context);
  }

  @override
  Future<Result<AuthContext>> signInWithPassword(
    AuthEmailPasswordCredentials credentials,
  ) async {
    final result = await _remoteDataSource.signInWithPassword(credentials);
    return await result.fold(
      onSuccess: (session) async {
        final context = AuthContext(
          user: session.user,
          session: session,
          onboardingCompleted: session.user.onboardingCompleted,
        );
        await _sessionStore.write(context);
        _contextController.add(context);
        return Result.success(context);
      },
      onFailure: (error) async => Result.failure(error),
    );
  }

  @override
  Future<Result<AuthContext>> signUpWithPassword(
    AuthSignUpRequest request,
  ) async {
    final result = await _remoteDataSource.signUpWithPassword(request);
    return await result.fold(
      onSuccess: (signupResult) async {
        if (signupResult.requiresEmailConfirmation ||
            signupResult.session == null) {
          final context = AuthContext(
            user: signupResult.user,
            session: null,
            onboardingCompleted: false,
            emailConfirmationRequired: true,
          );
          await _sessionStore.clear();
          _contextController.add(context);
          return Result.success(context);
        }

        final user = signupResult.user.copyWith(onboardingCompleted: false);
        final updatedSession = signupResult.session!.copyWith(user: user);
        final context = AuthContext(
          user: user,
          session: updatedSession,
          onboardingCompleted: false,
        );
        await _sessionStore.write(context);
        _contextController.add(context);
        return Result.success(context);
      },
      onFailure: (error) async => Result.failure(error),
    );
  }

  @override
  Future<Result<void>> resetPasswordForEmail(String email) {
    return _remoteDataSource.resetPasswordForEmail(email);
  }

  @override
  Future<Result<AuthContext>> signOut() async {
    final result = await _remoteDataSource.signOut();
    return await result.fold(
      onSuccess: (_) async {
        const context = AuthContext();
        await _sessionStore.clear();
        _contextController.add(context);
        return Result.success(context);
      },
      onFailure: (error) async => Result.failure(error),
    );
  }

  Future<void> dispose() async {
    await _storeSubscription.cancel();
    await _contextController.close();
    await _sessionStore.dispose();
  }
}
