import 'package:flutter_test/flutter_test.dart';

import 'package:vet_app_mobile/app/app.dart';
import 'package:vet_app_mobile/app/config/app_bootstrap_state.dart';
import 'package:vet_app_mobile/shared/config/app_runtime_config.dart';

void main() {
  testWidgets('Vet app boots into splash flow', (WidgetTester tester) async {
    await tester.pumpWidget(
      const VetApp(
        bootstrapState: AppBootstrapState(
          runtimeConfig: AppRuntimeConfig(
            environment: AppEnvironment.development,
            appName: 'Vet App',
            apiBaseUrl: 'http://127.0.0.1:8000',
            supabaseUrl: '',
            supabaseAnonKey: '',
            logLevel: 'INFO',
            enableTelemetry: false,
          ),
          supabaseEnabled: false,
        ),
      ),
    );

    expect(find.text('VET APP'), findsOneWidget);
    expect(find.textContaining('Verifica sessione'), findsOneWidget);
  });
}
