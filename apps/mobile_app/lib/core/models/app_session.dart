import 'app_user.dart';

class AppSession {
  const AppSession({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    this.expiresAt,
  });

  final String accessToken;
  final String refreshToken;
  final AppUser user;
  final DateTime? expiresAt;

  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);
}
