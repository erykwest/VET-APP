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
    await tester.pumpAndSettle();

    expect(find.byType(PreviewDashboardPage), findsWidgets);
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

  testWidgets('routes to home shell when API base url is configured', (
    tester,
  ) async {
    await tester.pumpWidget(
      VetApp(
        bootstrapState: _bootstrapState(
          supabaseConfigured: false,
          supabaseInitialized: false,
          apiBaseUrl: 'http://127.0.0.1:8000',
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();

    expect(find.byType(HomeShellPage), findsOneWidget);
    expect(find.byType(PreviewDashboardPage), findsNothing);
  });
}

AppBootstrapState _bootstrapState({
  required bool supabaseConfigured,
  required bool supabaseInitialized,
  String apiBaseUrl = '',
}) {
  return AppBootstrapState(
    runtimeConfig: AppRuntimeConfig(
      environment: AppEnvironment.development,
      appName: 'Vet App',
      apiBaseUrl: apiBaseUrl,
      supabaseUrl: supabaseConfigured ? 'https://example.supabase.co' : '',
      supabaseAnonKey: supabaseConfigured ? 'anon-key' : '',
      demoBypassAuth: true,
      demoUserEmail: 'demo@vetapp.local',
      demoUserPassword: 'VetAppDemo2026!',
      logLevel: 'INFO',
      enableTelemetry: false,
    ),
    supabaseConfigured: supabaseConfigured,
    supabaseInitialized: supabaseInitialized,
  );
}
