class AuthEmailPasswordCredentials {
  const AuthEmailPasswordCredentials({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;
}

class AuthSignUpRequest {
  const AuthSignUpRequest({
    required this.email,
    required this.password,
    this.displayName,
  });

  final String email;
  final String password;
  final String? displayName;
}
