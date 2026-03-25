import 'app_user.dart';

class AppSession {
  const AppSession({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.createdAt,
    this.expiresAt,
  });

  final AppUser user;
  final String accessToken;
  final String refreshToken;
  final DateTime createdAt;
  final DateTime? expiresAt;

  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);

  AppSession copyWith({
    AppUser? user,
    String? accessToken,
    String? refreshToken,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return AppSession(
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user': user.toMap(),
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
    };
  }

  factory AppSession.fromMap(Map<String, dynamic> map) {
    return AppSession(
      user: AppUser.fromMap(Map<String, dynamic>.from(map['user'] as Map? ?? {})),
      accessToken: map['access_token'] as String? ?? '',
      refreshToken: map['refresh_token'] as String? ?? '',
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      expiresAt: DateTime.tryParse(map['expires_at'] as String? ?? ''),
    );
  }
}
