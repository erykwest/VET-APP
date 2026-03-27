import 'app_session.dart';
import 'app_user.dart';

class AuthContext {
  const AuthContext({
    this.user,
    this.session,
    this.onboardingCompleted = false,
    this.emailConfirmationRequired = false,
  });

  final AppUser? user;
  final AppSession? session;
  final bool onboardingCompleted;
  final bool emailConfirmationRequired;

  bool get isSignedIn => user != null && session != null;

  AuthContext copyWith({
    AppUser? user,
    AppSession? session,
    bool? onboardingCompleted,
    bool? emailConfirmationRequired,
  }) {
    return AuthContext(
      user: user ?? this.user,
      session: session ?? this.session,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      emailConfirmationRequired:
          emailConfirmationRequired ?? this.emailConfirmationRequired,
    );
  }
}
