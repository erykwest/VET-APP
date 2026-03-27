import 'package:flutter_test/flutter_test.dart';
import 'package:vet_app_mobile/app/app.dart';
import 'package:vet_app_mobile/app/config/app_bootstrap_state.dart';
import 'package:vet_app_mobile/app/preview/preview_dashboard_page.dart';
import 'package:vet_app_mobile/app/shell/home_shell_page.dart';
import 'package:vet_app_mobile/shared/config/app_runtime_config.dart';

void main() {
  testWidgets('falls back to preview dashboard when Supabase is unavailable', (
    tester,
  ) async {
    await tester.pumpWidget(
      VetApp(
        bootstrapState: _bootstrapState(
          supabaseConfigured: false,
          supabaseInitialized: false,
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(PreviewDashboardPage), findsOneWidget);
    expect(find.byType(HomeShellPage), findsOneWidget);
  });

  testWidgets('starts from splash flow when Supabase is ready', (tester) async {
    await tester.pumpWidget(
      VetApp(
        bootstrapState: _bootstrapState(
          supabaseConfigured: true,
          supabaseInitialized: true,
        ),
      ),
    );

    await tester.pump();

    expect(find.text('VET APP'), findsOneWidget);
    expect(
      find.textContaining('Verifico la sessione Supabase'),
      findsOneWidget,
    );
  });
}

AppBootstrapState _bootstrapState({
  required bool supabaseConfigured,
  required bool supabaseInitialized,
}) {
  return AppBootstrapState(
    runtimeConfig: AppRuntimeConfig(
      environment: AppEnvironment.development,
      appName: 'Vet App',
      apiBaseUrl: '',
      supabaseUrl: supabaseConfigured ? 'https://example.supabase.co' : '',
      supabaseAnonKey: supabaseConfigured ? 'anon-key' : '',
      logLevel: 'INFO',
      enableTelemetry: false,
    ),
    supabaseConfigured: supabaseConfigured,
    supabaseInitialized: supabaseInitialized,
  );
}
