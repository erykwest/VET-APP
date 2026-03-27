import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vet_app_mobile/features/chat/chat.dart';
import 'package:vet_app_mobile/features/chat/data/chat_demo_store.dart';
import 'package:vet_app_mobile/features/chat/data/chat_seed_data.dart';

void main() {
  setUp(() {
    ChatDemoStore.instance.reset();
  });

  testWidgets('shows seeded chat conversations', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ChatConversationsPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Moka e le sue conversazioni'), findsOneWidget);
    expect(
      find.text(
          'Domande, risposte e prossimi passi nello stesso flusso, senza perdere il contesto del pet.'),
      findsOneWidget,
    );
    expect(find.textContaining('Moka - appetito e controllo'), findsOneWidget);
    expect(find.textContaining('Moka - promemoria vaccino'), findsNothing);
    expect(find.text('Sync backend'), findsOneWidget);
  });

  testWidgets('renders empty chat state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ChatConversationsPage(
          state: ChatScreenState.empty,
          conversations: [],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nessuna conversazione ancora'), findsOneWidget);
    expect(
      find.text(
          'Avvia una chat reale per vedere il flusso completo dell assistente veterinario.'),
      findsOneWidget,
    );
    expect(find.text('Apri la prima chat'), findsOneWidget);
  });

  testWidgets('renders conversation detail with composer', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ChatConversationDetailPage(
          conversationId: 'conv-1',
          initialConversation: ChatSeedData.detail,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Moka - appetito e controllo'), findsWidgets);
    expect(find.textContaining('Scrivi una domanda su Moka'), findsOneWidget);
    expect(find.textContaining('Per sicurezza ti lascio anche un mini piano'),
        findsOneWidget);
  });
}
