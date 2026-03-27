import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'config/app_bootstrap_state.dart';
import '../features/chat/data/chat_demo_store.dart';
import '../features/pets/data/pet_demo_store.dart';
import '../shared/config/app_runtime_config_loader.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    usePathUrlStrategy();
  }

  final runtimeConfig = const AppRuntimeConfigLoader().load();
  var supabaseConfigured = runtimeConfig.hasSupabaseCredentials;
  var supabaseInitialized = false;
  String? supabaseInitializationError;

  if (supabaseConfigured) {
    try {
      await Supabase.initialize(
        url: runtimeConfig.supabaseUrl,
        anonKey: runtimeConfig.supabaseAnonKey,
      );
      supabaseInitialized = true;
    } catch (error) {
      supabaseInitialized = false;
      supabaseInitializationError = error.toString();
      debugPrint('Supabase initialization failed: $error');
    }
  } else {
    supabaseInitializationError =
        'Missing SUPABASE_URL or SUPABASE_ANON_KEY dart defines.';
    debugPrint('Supabase initialization skipped: missing configuration.');
  }

  if (runtimeConfig.hasApiBaseUrl) {
    try {
      await PetDemoStore.instance.initialize();
      await ChatDemoStore.instance.ensureLoaded();
    } catch (error) {
      debugPrint('Backend bootstrap warmup failed: $error');
    }
  }

  runApp(
    VetApp(
      bootstrapState: AppBootstrapState(
        runtimeConfig: runtimeConfig,
        supabaseConfigured: supabaseConfigured,
        supabaseInitialized: supabaseInitialized,
        supabaseInitializationError: supabaseInitializationError,
      ),
    ),
  );
}
