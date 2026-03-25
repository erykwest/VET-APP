import 'dart:math';

import '../../../shared/auth/auth.dart';
import '../../../shared/errors/app_auth_error.dart';
import '../../../shared/types/result.dart';
import 'auth_remote_data_source.dart';

class FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  FakeAuthRemoteDataSource({
    Map<String, FakeUserRecord>? seededUsers,
  }) : _users = {
          ...?seededUsers,
        };

  final Map<String, FakeUserRecord> _users;

  @override
  Future<Result<AppSession>> signInWithPassword(
    AuthEmailPasswordCredentials credentials,
  ) async {
    final normalizedEmail = credentials.email.trim().toLowerCase();
    final user = _users[normalizedEmail];
    if (user == null || user.password != credentials.password) {
      return Result.failure(
        const AppAuthError(
          code: 'invalid_credentials',
          message: 'Email or password is incorrect',
        ),
      );
    }

    return Result.success(_sessionFor(user.toAppUser()));
  }

  @override
  Future<Result<AppSession>> signUpWithPassword(
    AuthSignUpRequest request,
  ) async {
    final normalizedEmail = request.email.trim().toLowerCase();
    if (_users.containsKey(normalizedEmail)) {
      return Result.failure(
        const AppAuthError(
          code: 'email_already_used',
          message: 'This email is already registered',
        ),
      );
    }

    final user = FakeUserRecord(
      id: _id('user'),
      email: normalizedEmail,
      password: request.password,
      displayName: request.displayName?.trim().isEmpty ?? true
          ? null
          : request.displayName?.trim(),
      createdAt: DateTime.now().toUtc(),
      onboardingCompleted: false,
    );
    _users[normalizedEmail] = user;

    return Result.success(_sessionFor(user.toAppUser()));
  }

  @override
  Future<Result<void>> resetPasswordForEmail(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (!_users.containsKey(normalizedEmail)) {
      return Result.failure(
        const AppAuthError(
          code: 'email_not_found',
          message: 'No account found for this email',
        ),
      );
    }

    return Result.success(null);
  }

  @override
  Future<Result<void>> signOut() async {
    return Result.success(null);
  }

  AppSession _sessionFor(AppUser user) {
    final seed = Random().nextInt(1 << 32).toRadixString(16);
    return AppSession(
      user: user,
      accessToken: 'fake_access_$seed',
      refreshToken: 'fake_refresh_$seed',
      createdAt: DateTime.now().toUtc(),
      expiresAt: DateTime.now().toUtc().add(const Duration(hours: 2)),
    );
  }

  String _id(String prefix) {
    final seed = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
    return '${prefix}_$seed';
  }
}

class FakeUserRecord {
  const FakeUserRecord({
    required this.id,
    required this.email,
    required this.password,
    required this.createdAt,
    required this.onboardingCompleted,
    this.displayName,
  });

  final String id;
  final String email;
  final String password;
  final String? displayName;
  final DateTime createdAt;
  final bool onboardingCompleted;

  AppUser toAppUser() {
    return AppUser(
      id: id,
      email: email,
      displayName: displayName,
      createdAt: createdAt,
      onboardingCompleted: onboardingCompleted,
    );
  }
}
