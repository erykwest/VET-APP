enum AppEnvironment {
  development,
  staging,
  production,
}

class AppRuntimeConfig {
  const AppRuntimeConfig({
    required this.environment,
    required this.appName,
    required this.apiBaseUrl,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.logLevel,
    required this.enableTelemetry,
  });

  final AppEnvironment environment;
  final String appName;
  final String apiBaseUrl;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String logLevel;
  final bool enableTelemetry;

  bool get hasApiBaseUrl => apiBaseUrl.trim().isNotEmpty;
  bool get hasSupabaseCredentials =>
      supabaseUrl.trim().isNotEmpty && supabaseAnonKey.trim().isNotEmpty;

  bool get isProduction => environment == AppEnvironment.production;
}
