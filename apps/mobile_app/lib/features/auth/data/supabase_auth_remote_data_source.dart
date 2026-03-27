import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/auth/auth.dart';
import '../../../shared/config/app_runtime_config.dart';
import '../../../shared/errors/app_auth_error.dart';
import '../../../shared/types/result.dart';
import 'auth_sign_up_result.dart';
import 'auth_remote_data_source.dart';

class SupabaseAuthRemoteDataSource implements AuthRemoteDataSource {
  const SupabaseAuthRemoteDataSource({
    required this.config,
    this.client,
  });

  final AppRuntimeConfig config;
  final GoTrueClient? client;

  bool get isConfigured => config.hasSupabaseCredentials && client != null;
  GoTrueClient get _client => client!;

  @override
  Future<Result<AppSession>> signInWithPassword(
    AuthEmailPasswordCredentials credentials,
  ) async {
    if (!isConfigured) {
      return _missingConfig();
    }

    try {
      final response = await _client.signInWithPassword(
        email: credentials.email.trim(),
        password: credentials.password,
      );
      final session = response.session;
      final user = response.user;
      if (session == null || user == null || user.email == null) {
        return Result.failure(
          const AppAuthError(
            code: 'sign_in_incomplete',
            message: 'Sign-in completed without a usable session',
          ),
        );
      }

      return Result.success(_mapSession(session, user));
    } on AuthException catch (error) {
      return Result.failure(
        AppAuthError(
          code: error.statusCode ?? 'auth_error',
          message: error.message,
        ),
      );
    } catch (error) {
      return Result.failure(
        AppAuthError(
          code: 'unexpected_sign_in_error',
          message: 'Unable to sign in right now',
          details: error,
        ),
      );
    }
  }

  @override
  Future<Result<AuthSignUpResult>> signUpWithPassword(
    AuthSignUpRequest request,
  ) async {
    if (!isConfigured) {
      return Result.failure(_missingConfigError());
    }

    try {
      final response = await _client.signUp(
        email: request.email.trim(),
        password: request.password,
        data: {
          if (request.displayName != null &&
              request.displayName!.trim().isNotEmpty)
            'display_name': request.displayName!.trim(),
          'onboarding_completed': false,
        },
      );
      final session = response.session;
      final user = response.user;
      final normalizedUser = _mapSignUpUser(
        request: request,
        sessionUser: user,
      );
      return Result.success(
        AuthSignUpResult(
          user: normalizedUser,
          session: session != null && user != null && user.email != null
              ? _mapSession(session, user)
              : null,
          requiresEmailConfirmation:
              session == null || user == null || user.email == null,
        ),
      );
    } on AuthException catch (error) {
      return Result.failure(
        AppAuthError(
          code: error.statusCode ?? 'auth_error',
          message: error.message,
        ),
      );
    } catch (error) {
      return Result.failure(
        AppAuthError(
          code: 'unexpected_sign_up_error',
          message: 'Unable to create the account right now',
          details: error,
        ),
      );
    }
  }

  @override
  Future<Result<void>> resetPasswordForEmail(String email) async {
    if (!isConfigured) {
      return Result.failure(_missingConfigError());
    }

    try {
      await _client.resetPasswordForEmail(email.trim());
      return Result.success(null);
    } on AuthException catch (error) {
      return Result.failure(
        AppAuthError(
          code: error.statusCode ?? 'auth_error',
          message: error.message,
        ),
      );
    } catch (error) {
      return Result.failure(
        AppAuthError(
          code: 'unexpected_reset_password_error',
          message: 'Unable to start password recovery right now',
          details: error,
        ),
      );
    }
  }

  @override
  Future<Result<void>> signOut() async {
    if (!isConfigured) {
      return Result.failure(_missingConfigError());
    }

    try {
      await _client.signOut();
      return Result.success(null);
    } on AuthException catch (error) {
      return Result.failure(
        AppAuthError(
          code: error.statusCode ?? 'auth_error',
          message: error.message,
        ),
      );
    } catch (error) {
      return Result.failure(
        AppAuthError(
          code: 'unexpected_sign_out_error',
          message: 'Unable to sign out right now',
          details: error,
        ),
      );
    }
  }

  Result<T> _missingConfig<T>() => Result.failure(_missingConfigError());

  AppAuthError _missingConfigError() {
    return AppAuthError(
      code: 'supabase_missing_config',
      message: 'Supabase credentials are missing from runtime config',
      details: {
        'hasSupabaseCredentials': isConfigured,
        'supabaseUrl': config.supabaseUrl,
      },
    );
  }

  AppUser _mapSignUpUser({
    required AuthSignUpRequest request,
    required User? sessionUser,
  }) {
    if (sessionUser != null && sessionUser.email != null) {
      return AppUser(
        id: sessionUser.id,
        email: sessionUser.email!,
        displayName: sessionUser.userMetadata?['display_name'] as String?,
        createdAt:
            DateTime.tryParse(sessionUser.createdAt) ?? DateTime.now().toUtc(),
        onboardingCompleted:
            sessionUser.userMetadata?['onboarding_completed'] as bool? ?? false,
      );
    }

    return AppUser(
      id: 'pending-${request.email.trim().toLowerCase()}',
      email: request.email.trim().toLowerCase(),
      displayName: request.displayName?.trim().isEmpty ?? true
          ? null
          : request.displayName!.trim(),
      createdAt: DateTime.now().toUtc(),
      onboardingCompleted: false,
    );
  }

  AppSession _mapSession(Session session, User user) {
    final appUser = AppUser(
      id: user.id,
      email: user.email ?? '',
      displayName: user.userMetadata?['display_name'] as String?,
      createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now().toUtc(),
      onboardingCompleted:
          user.userMetadata?['onboarding_completed'] as bool? ?? false,
    );

    return AppSession(
      user: appUser,
      accessToken: session.accessToken,
      refreshToken: session.refreshToken ?? '',
      createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now().toUtc(),
      expiresAt: session.expiresAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              session.expiresAt! * 1000,
              isUtc: true,
            ),
    );
  }
}
