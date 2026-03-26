import 'package:flutter_test/flutter_test.dart';

import 'package:vet_app_mobile/app/app.dart';
import 'package:vet_app_mobile/app/config/app_bootstrap_state.dart';
import 'package:vet_app_mobile/shared/config/app_runtime_config.dart';

void main() {
  testWidgets('preview dashboard route renders seed dashboard markers', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const VetApp(
        bootstrapState: AppBootstrapState(
          runtimeConfig: AppRuntimeConfig(
            environment: AppEnvironment.development,
            appName: 'Vet App',
            apiBaseUrl: '',
            supabaseUrl: '',
            supabaseAnonKey: '',
            logLevel: 'INFO',
            enableTelemetry: false,
          ),
          supabaseEnabled: false,
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Preview Dashboard'), findsOneWidget);
    expect(find.text('Route: /preview-dashboard'), findsOneWidget);
    expect(find.text('Scadenze vicine'), findsOneWidget);
    expect(find.text('Cartella clinica'), findsOneWidget);
    expect(find.textContaining('Verifica sessione'), findsNothing);
  });
}
