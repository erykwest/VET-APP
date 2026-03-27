import '../../shared/config/app_runtime_config.dart';

class AppBootstrapState {
  const AppBootstrapState({
    required this.runtimeConfig,
    required this.supabaseConfigured,
    required this.supabaseInitialized,
    this.supabaseInitializationError,
  });

  final AppRuntimeConfig runtimeConfig;
  final bool supabaseConfigured;
  final bool supabaseInitialized;
  final String? supabaseInitializationError;

  bool get supabaseReady => supabaseConfigured && supabaseInitialized;
  bool get previewMode => !hasApiBaseUrl && !supabaseReady;
  bool get hasApiBaseUrl => runtimeConfig.hasApiBaseUrl;
  bool get shouldBypassAuth =>
      hasApiBaseUrl && runtimeConfig.demoBypassAuth;

  bool get hasSupabaseConfig => runtimeConfig.hasSupabaseCredentials;

  bool get shouldShowSupabaseError => hasSupabaseConfig && !supabaseInitialized;
}
