import '../../shared/config/app_runtime_config.dart';

class AppBootstrapState {
  const AppBootstrapState({
    required this.runtimeConfig,
    required this.supabaseEnabled,
  });

  final AppRuntimeConfig runtimeConfig;
  final bool supabaseEnabled;
}
