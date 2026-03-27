import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vet_app_mobile/app/preview/preview_dashboard_page.dart';

void main() {
  testWidgets('preview dashboard renders the core loop first', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PreviewDashboardPage(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Preview Dashboard'), findsOneWidget);
    expect(find.text('Mode: local preview data'), findsOneWidget);
    expect(find.text('Auth: bypassed'), findsOneWidget);
    expect(find.text('Scadenze vicine'), findsOneWidget);
    expect(find.text('Assistente Vet AI'), findsOneWidget);
    expect(find.text('Apri profilo'), findsWidgets);
    expect(find.text('Apri chat'), findsWidgets);
    expect(find.text('Nuovo reminder'), findsWidgets);
    expect(find.text('Records'), findsNothing);
    expect(find.text('Settings'), findsNothing);
  });
}
