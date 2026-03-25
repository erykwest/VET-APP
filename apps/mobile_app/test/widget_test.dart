import 'package:flutter_test/flutter_test.dart';

import 'package:vet_app_mobile/app/app.dart';

void main() {
  testWidgets('Vet app boots into splash flow', (WidgetTester tester) async {
    await tester.pumpWidget(const VetApp());

    expect(find.text('VET APP'), findsOneWidget);
    expect(find.textContaining('Verifica sessione'), findsOneWidget);
  });
}
