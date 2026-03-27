import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/config/app_runtime_config_loader.dart';
import 'auth_repository_impl.dart';
import 'fake_auth_remote_data_source.dart';
import 'persistent_auth_session_store.dart';
import 'supabase_auth_session_store.dart';
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
    final supabaseClient = _readSupabaseClient();
    final hasSupabaseConfig = config.hasSupabaseCredentials;
    final sessionStore = hasSupabaseConfig
        ? SupabaseAuthSessionStore(
            currentSession: () => supabaseClient?.currentSession,
            authStateChanges: supabaseClient?.onAuthStateChange ??
                const Stream<AuthState>.empty(),
          )
        : PersistentAuthSessionStore();
    final remoteDataSource = hasSupabaseConfig
        ? SupabaseAuthRemoteDataSource(
            config: config,
            client: supabaseClient,
          )
        : FakeAuthRemoteDataSource();

    final repository = AuthRepositoryImpl(
      remoteDataSource: remoteDataSource,
      sessionStore: sessionStore,
    );
    _cachedRepository = repository;
    return repository;
  }

  static GoTrueClient? _readSupabaseClient() {
    try {
      return Supabase.instance.client.auth;
    } catch (_) {
      return null;
    }
  }
}
