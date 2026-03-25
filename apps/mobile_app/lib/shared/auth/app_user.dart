class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.createdAt,
    this.displayName,
    this.onboardingCompleted = false,
  });

  final String id;
  final String email;
  final String? displayName;
  final DateTime createdAt;
  final bool onboardingCompleted;

  AppUser copyWith({
    String? id,
    String? email,
    String? displayName,
    DateTime? createdAt,
    bool? onboardingCompleted,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'created_at': createdAt.toIso8601String(),
      'onboarding_completed': onboardingCompleted,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String? ?? '',
      email: map['email'] as String? ?? '',
      displayName: map['display_name'] as String?,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      onboardingCompleted: map['onboarding_completed'] as bool? ?? false,
    );
  }
}
