import '../../../shared/auth/auth.dart';

class AuthSignUpResult {
  const AuthSignUpResult({
    required this.user,
    this.session,
    this.requiresEmailConfirmation = false,
  });

  final AppUser user;
  final AppSession? session;
  final bool requiresEmailConfirmation;

  bool get hasActiveSession => session != null;
}
