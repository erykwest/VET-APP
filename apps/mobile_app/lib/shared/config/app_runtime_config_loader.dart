import 'app_env_keys.dart';
import 'app_runtime_config.dart';

class AppRuntimeConfigLoader {
  const AppRuntimeConfigLoader();

  AppRuntimeConfig load() {
    return AppRuntimeConfig(
      environment: _parseEnvironment(
        const String.fromEnvironment(
          AppEnvKeys.environment,
          defaultValue: 'development',
        ),
      ),
      appName: const String.fromEnvironment(
        AppEnvKeys.appName,
        defaultValue: 'Vet App',
      ),
      apiBaseUrl: const String.fromEnvironment(
        AppEnvKeys.apiBaseUrl,
        defaultValue: 'http://127.0.0.1:8000',
      ),
      supabaseUrl: const String.fromEnvironment(
        AppEnvKeys.supabaseUrl,
        defaultValue: 'https://ywbuzgwbkrmkukkpysbz.supabase.co',
      ),
      supabaseAnonKey: const String.fromEnvironment(
        AppEnvKeys.supabaseAnonKey,
        defaultValue: 'sb_publishable_t5vFAehg91FYPh_rFLOiUQ_Wv9tFh5m',
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
