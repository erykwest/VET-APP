class AppRuntimeConfig {
  const AppRuntimeConfig._({
    required this.apiBaseUrl,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
  });

  factory AppRuntimeConfig.fromEnvironment() {
    return const AppRuntimeConfig._(
      apiBaseUrl: String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: '',
      ),
      supabaseUrl: String.fromEnvironment(
        'SUPABASE_URL',
        defaultValue: '',
      ),
      supabaseAnonKey: String.fromEnvironment(
        'SUPABASE_ANON_KEY',
        defaultValue: '',
      ),
    );
  }

  final String apiBaseUrl;
  final String supabaseUrl;
  final String supabaseAnonKey;

  bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
