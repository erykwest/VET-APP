import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'config/app_bootstrap_state.dart';
import '../shared/config/app_runtime_config_loader.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    usePathUrlStrategy();
  }

  final runtimeConfig = const AppRuntimeConfigLoader().load();
  var supabaseEnabled = false;

  if (runtimeConfig.hasSupabaseCredentials) {
    await Supabase.initialize(
      url: runtimeConfig.supabaseUrl,
      anonKey: runtimeConfig.supabaseAnonKey,
    );
    supabaseEnabled = true;
  }

  runApp(
    VetApp(
      bootstrapState: AppBootstrapState(
        runtimeConfig: runtimeConfig,
        supabaseEnabled: supabaseEnabled,
      ),
    ),
  );
}
