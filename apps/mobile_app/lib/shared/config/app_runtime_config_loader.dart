import 'app_env_keys.dart';
import 'app_runtime_config.dart';

class AppRuntimeConfigLoader {
  const AppRuntimeConfigLoader();

  AppRuntimeConfig load() {
    final environment = _parseEnvironment(
      const String.fromEnvironment(
        AppEnvKeys.environment,
        defaultValue: 'development',
      ),
    );
    final demoBypassAuth = const bool.fromEnvironment(
      AppEnvKeys.demoBypassAuth,
      defaultValue: true,
    );
    final configuredApiBaseUrl = const String.fromEnvironment(
      AppEnvKeys.apiBaseUrl,
      defaultValue: '',
    );
    final apiBaseUrl =
        configuredApiBaseUrl.trim().isNotEmpty
            ? configuredApiBaseUrl
            : environment == AppEnvironment.development && demoBypassAuth
            ? 'http://127.0.0.1:8000'
            : '';

    return AppRuntimeConfig(
      environment: environment,
      appName: const String.fromEnvironment(
        AppEnvKeys.appName,
        defaultValue: 'Vet App',
      ),
      apiBaseUrl: apiBaseUrl,
      supabaseUrl: const String.fromEnvironment(
        AppEnvKeys.supabaseUrl,
        defaultValue: '',
      ),
      supabaseAnonKey: const String.fromEnvironment(
        AppEnvKeys.supabaseAnonKey,
        defaultValue: '',
      ),
      demoBypassAuth: demoBypassAuth,
      demoUserEmail: const String.fromEnvironment(
        AppEnvKeys.demoUserEmail,
        defaultValue: 'demo@vetapp.local',
      ),
      demoUserPassword: const String.fromEnvironment(
        AppEnvKeys.demoUserPassword,
        defaultValue: 'VetAppDemo2026!',
      ),
      logLevel: const String.fromEnvironment(
        AppEnvKeys.logLevel,
        defaultValue: 'INFO',
      ),
      enableTelemetry: const bool.fromEnvironment(
        AppEnvKeys.enableTelemetry,
        defaultValue: false,
      ),
    );
  }

  AppEnvironment _parseEnvironment(String value) {
    switch (value.toLowerCase()) {
      case 'production':
        return AppEnvironment.production;
      case 'staging':
        return AppEnvironment.staging;
      default:
        return AppEnvironment.development;
    }
  }
}
