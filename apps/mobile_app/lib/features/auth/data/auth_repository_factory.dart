import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/auth/auth.dart';
import '../../../shared/config/app_runtime_config_loader.dart';
import 'auth_repository_impl.dart';
import 'fake_auth_remote_data_source.dart';
import 'memory_auth_session_store.dart';
import 'supabase_auth_remote_data_source.dart';

class AuthRepositoryFactory {
  const AuthRepositoryFactory({
    AppRuntimeConfigLoader? configLoader,
  }) : _configLoader = configLoader ?? const AppRuntimeConfigLoader();

  final AppRuntimeConfigLoader _configLoader;
  static AuthRepositoryImpl? _cachedRepository;

  AuthRepositoryImpl create() {
    final cachedRepository = _cachedRepository;
    if (cachedRepository != null) {
      return cachedRepository;
    }

    final config = _configLoader.load();
    final hasSupabaseClient =
        config.hasSupabaseCredentials && _hasSupabaseClient();
    final sessionStore = MemoryAuthSessionStore(
      initialContext: hasSupabaseClient ? _readSupabaseContext() : null,
    );
    final remoteDataSource = hasSupabaseClient
        ? SupabaseAuthRemoteDataSource(config: config)
        : FakeAuthRemoteDataSource();

    final repository = AuthRepositoryImpl(
      remoteDataSource: remoteDataSource,
      sessionStore: sessionStore,
    );
    _cachedRepository = repository;
    return repository;
  }

  static bool _hasSupabaseClient() {
    try {
      Supabase.instance.client;
      return true;
    } catch (_) {
      return false;
    }
  }

  static AuthContext? _readSupabaseContext() {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null || session.user.email == null) {
        return null;
      }

      final user = AppUser(
        id: session.user.id,
        email: session.user.email!,
        displayName: session.user.userMetadata?['display_name'] as String?,
        createdAt: DateTime.tryParse(session.user.createdAt) ??
            DateTime.now().toUtc(),
        onboardingCompleted:
            session.user.userMetadata?['onboarding_completed'] as bool? ?? false,
      );

      return AuthContext(
        user: user,
        session: AppSession(
          user: user,
          accessToken: session.accessToken,
          refreshToken: session.refreshToken ?? '',
          createdAt: DateTime.tryParse(session.user.createdAt) ??
              DateTime.now().toUtc(),
          expiresAt: session.expiresAt == null
              ? null
              : DateTime.fromMillisecondsSinceEpoch(
                  session.expiresAt! * 1000,
                  isUtc: true,
                ),
        ),
        onboardingCompleted: user.onboardingCompleted,
      );
    } catch (_) {
      return null;
    }
  }
}
