import 'package:flutter/material.dart';

import '../../../chat/domain/chat_models.dart';
import '../../../pets/domain/pet_models.dart';

class HomeDashboardInsightSection {
  const HomeDashboardInsightSection({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.items,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final List<HomeDashboardInsightItem> items;
}

class HomeDashboardInsightItem {
  const HomeDashboardInsightItem({
    required this.title,
    required this.body,
    required this.icon,
    required this.accentColor,
    this.badge,
    this.ctaLabel,
    this.ctaDetail,
    this.sourceLabel,
  });

  final String title;
  final String body;
  final IconData icon;
  final Color accentColor;
  final String? badge;
  final String? ctaLabel;
  final String? ctaDetail;
  final String? sourceLabel;
}

class HomeDashboardInsightComposer {
  const HomeDashboardInsightComposer._();

  static List<HomeDashboardInsightSection> buildForPet(
    PetProfile pet, {
    List<ChatConversationSummary> conversations = const [],
    DateTime? now,
  }) {
    final clock = now ?? DateTime.now();
    final ageSnapshot = PetAgeSnapshot.fromBirthDateLabel(
      pet.birthDateLabel,
      now: clock,
    );
    final firstConversation =
        conversations.isNotEmpty ? conversations.first : null;

    return [
      HomeDashboardInsightSection(
        eyebrow: 'Oggi',
        title: 'Suggerimenti utili',
        subtitle: 'Piccoli check che ti fanno risparmiare tempo in chat.',
        items: [
          HomeDashboardInsightItem(
            title: 'Partenza tranquilla',
            body:
                'Se devi andare oltre confine, controlla vaccini, antiparassitari e documenti prima di fare il check-in. Meglio un minuto qui che una corsa dopo.',
            icon: Icons.flight_takeoff_rounded,
            accentColor: const Color(0xFFE5856F),
            badge: 'Viaggio',
            ctaLabel: 'Chiedi in chat',
            ctaDetail: 'Ti preparo il check rapido prima di partire.',
            sourceLabel: 'Basato su viaggio',
          ),
          HomeDashboardInsightItem(
            title: 'Sintomo in due righe',
            body:
                'Se qualcosa non ti convince, scrivilo come lo diresti al vet in ascensore: cosa vedi, da quando, quanto spesso. Breve, pulito, utile.',
            icon: Icons.chat_bubble_outline_rounded,
            accentColor: const Color(0xFF5F9F86),
            badge: 'Chat',
            ctaLabel: 'Apri assistente',
            ctaDetail: firstConversation == null
                ? 'Inizia il primo scambio quando vuoi.'
                : 'Riparti da ${firstConversation.title}.',
            sourceLabel: 'Basato sulla chat',
          ),
          HomeDashboardInsightItem(
            title: 'Routine che abbassa il rumore',
            body:
                'Pasti, acqua e movimento piu o meno alla stessa ora tengono la giornata stabile. Il corpo ama la regolarita piu di quanto sembri.',
            icon: Icons.schedule_rounded,
            accentColor: const Color(0xFF6F91A3),
            badge: 'Routine',
            sourceLabel: 'Basato sulla giornata',
          ),
        ],
      ),
      HomeDashboardInsightSection(
        eyebrow: 'Razza e sviluppo',
        title: 'Cosa leggere nel profilo',
        subtitle: 'Razza, fase di vita e taglia dicono piu di un nome scritto bene.',
        items: [
          HomeDashboardInsightItem(
            title: pet.breedLabel,
            body: _breedInsightFor(pet),
            icon: Icons.pets_rounded,
            accentColor: const Color(0xFF2E686A),
            badge: pet.species,
            sourceLabel: 'Basato sulla razza',
          ),
          HomeDashboardInsightItem(
            title: 'Fase di sviluppo: ${ageSnapshot.stageLabel}',
            body: ageSnapshot.copyText,
            icon: Icons.timeline_rounded,
            accentColor: const Color(0xFFE0A35B),
            badge: ageSnapshot.ageLabel,
            sourceLabel: 'Basato sull\'eta',
          ),
          HomeDashboardInsightItem(
            title: _sizeHintTitleForPet(pet),
            body: _sizeHintBodyForPet(pet),
            icon: Icons.straighten_rounded,
            accentColor: const Color(0xFF6F91A3),
            badge: _sizeHintBadgeForPet(pet),
            sourceLabel: 'Basato sulla scheda animale',
          ),
        ],
      ),
      HomeDashboardInsightSection(
        eyebrow: 'Meteo',
        title: 'Tip del giorno',
        subtitle: 'Il meteo cambia, l\'acqua fresca no.',
        items: [
          HomeDashboardInsightItem(
            title: 'Se oggi fa caldo',
            body:
                'Porta acqua extra, scegli l\'ombra e taglia le uscite nelle ore bollenti. Le zampe non amano l\'asfalto versione piastra.',
            icon: Icons.thermostat_rounded,
            accentColor: const Color(0xFFE5856F),
            badge: 'Caldo',
            ctaLabel: 'Borraccia su Amazon',
            ctaDetail: 'Accessorio utile per le uscite piu lunghe.',
            sourceLabel: 'Basato sul meteo',
          ),
          HomeDashboardInsightItem(
            title: 'Se arriva pioggia',
            body:
                'Metti un asciugamano vicino alla porta e controlla le zampe appena rientra: meno caos, meno acqua in giro, meno drammi sul pavimento.',
            icon: Icons.grain_rounded,
            accentColor: const Color(0xFF5F9F86),
            badge: 'Pioggia',
            sourceLabel: 'Basato sul meteo',
          ),
          HomeDashboardInsightItem(
            title: 'Se tira vento',
            body:
                'Con pet piccoli o orecchie sensibili, meglio una passeggiata breve e facile. Il vento fa scena, ma non sempre fa bene.',
            icon: Icons.air_rounded,
            accentColor: const Color(0xFF6F91A3),
            badge: 'Vento',
            sourceLabel: 'Basato sul meteo',
          ),
        ],
      ),
    ];
  }

  static String _breedInsightFor(PetProfile pet) {
    final breed = pet.breedLabel.toLowerCase();
    final species = pet.species.toLowerCase();

    if (breed.contains('meticcio')) {
      return 'Per un meticcio conta piu l\'equilibrio che l\'etichetta: peso, denti, fiato e routine raccontano tutto quello che serve.';
    }

    if (breed.contains('border collie')) {
      return 'Il border collie ragiona veloce: giochi mentali, regole chiare e movimento utile valgono piu di una corsa senza meta.';
    }

    if (breed.contains('golden retriever')) {
      return 'Il golden ama la compagnia e la calma. Peso, articolazioni e ritmo quotidiano meritano un occhio gentile ma costante.';
    }

    if (breed.contains('europeo') && species.contains('gatto')) {
      return 'Un europeo a pelo corto vive bene con controllo dentale, gioco breve e ambiente stimolante. Poco rumore, molta sostanza.';
    }

    if (species.contains('gatto')) {
      return 'Per un gatto la routine conta piu di quanto sembri: cibo, lettiera e spazi tranquilli aiutano piu di mille consigli casuali.';
    }

    return 'Ogni razza ha i suoi dettagli, ma la cosa migliore resta leggere il carattere insieme a peso, appetito e livello di energia.';
  }

  static String _sizeHintTitleForPet(PetProfile pet) {
    final breed = pet.breedLabel.toLowerCase();
    if (breed.contains('meticcio')) {
      return 'Seleziona anche la taglia';
    }

    if (pet.species.toLowerCase().contains('gatto')) {
      return 'La taglia resta utile solo come contesto';
    }

    return 'Taglia e struttura contano';
  }

  static String _sizeHintBodyForPet(PetProfile pet) {
    final breed = pet.breedLabel.toLowerCase();
    if (breed.contains('meticcio')) {
      return 'Per i meticci la taglia aiuta a rifinire alimentazione, spostamenti e routine. Scegli tra toy, piccola, medio-piccola, media, medio-grande, grande o gigante.';
    }

    if (pet.species.toLowerCase().contains('gatto')) {
      return 'Per i gatti conta piu la corporatura reale che la parola "taglia". Se vuoi, la app puo comunque usare quel dato per affilare i consigli.';
    }

    return 'La struttura del pet cambia i consigli su movimento, cibo e gestione quotidiana. Tenerla a vista evita suggerimenti troppo generici.';
  }

  static String? _sizeHintBadgeForPet(PetProfile pet) {
    final breed = pet.breedLabel.toLowerCase();
    if (breed.contains('meticcio')) {
      return 'Taglia richiesta';
    }

    if (pet.species.toLowerCase().contains('gatto')) {
      return 'Contesto utile';
    }

    return 'Dato chiave';
  }
}

class PetAgeSnapshot {
  const PetAgeSnapshot({
    required this.ageLabel,
    required this.stageLabel,
    required this.copyText,
    this.months,
  });

  final String ageLabel;
  final String stageLabel;
  final String copyText;
  final int? months;

  factory PetAgeSnapshot.fromBirthDateLabel(
    String birthDateLabel, {
    required DateTime now,
  }) {
    final parsed = _MonthYear.tryParse(birthDateLabel);
    if (parsed == null) {
      return const PetAgeSnapshot(
        ageLabel: 'Eta non specificata',
        stageLabel: 'fase non definita',
        copyText:
            'L\'eta non e stata inserita con un formato leggibile, quindi qui ci limitiamo a un consiglio prudente e generico.',
      );
    }

    final months = ((now.year - parsed.year) * 12) + (now.month - parsed.month);
    final safeMonths = months < 0 ? 0 : months;
    final years = safeMonths ~/ 12;
    final remainingMonths = safeMonths % 12;
    final ageLabel = _buildAgeLabel(years, remainingMonths);
    final stageLabel = _stageLabelForMonths(safeMonths);
    final copyText = _stageCopyForMonths(safeMonths, ageLabel, stageLabel);

    return PetAgeSnapshot(
      ageLabel: ageLabel,
      stageLabel: stageLabel,
      copyText: copyText,
      months: safeMonths,
    );
  }

  static String _buildAgeLabel(int years, int months) {
    final parts = <String>[];
    if (years > 0) {
      parts.add('$years ${years == 1 ? 'anno' : 'anni'}');
    }
    if (months > 0) {
      parts.add('$months ${months == 1 ? 'mese' : 'mesi'}');
    }
    if (parts.isEmpty) {
      return 'Meno di 1 mese';
    }
    return parts.join(' e ');
  }

  static String _stageLabelForMonths(int months) {
    if (months < 6) {
      return 'neo arrivato';
    }
    if (months < 12) {
      return 'cucciolo in crescita';
    }
    if (months < 24) {
      return 'giovane adulto';
    }
    if (months < 84) {
      return 'adulto';
    }
    return 'maturo';
  }

  static String _stageCopyForMonths(
    int months,
    String ageLabel,
    String stageLabel,
  ) {
    if (months < 6) {
      return 'Ha appena iniziato a prendere posto in casa: routine morbida, sonno buono e zero fretta fanno davvero la differenza.';
    }
    if (months < 12) {
      return 'A $ageLabel il cervello e il corpo corrono insieme: regole chiare, gioco breve e tanta coerenza aiutano a non trasformare l\'energia in caos creativo.';
    }
    if (months < 24) {
      return 'A $ageLabel e nella fase "$stageLabel": energia alta, curiosita enorme e bisogno di confini gentili ma fermi.';
    }
    if (months < 84) {
      return 'A $ageLabel e in piena fase adulta: routine stabile, controlli regolari e attenzione al peso tengono la macchina ben tarata.';
    }
    return 'A $ageLabel conviene tenere un occhio in piu su mobilita, appetito e piccoli cambiamenti quotidiani. La calma qui vale doppio.';
  }
}

class _MonthYear {
  const _MonthYear(this.month, this.year);

  final int month;
  final int year;

  static _MonthYear? tryParse(String input) {
    final normalized = input.trim().toLowerCase();
    final parts = normalized.split(RegExp(r'\s+'));
    if (parts.length < 2) {
      return null;
    }

    final year = int.tryParse(parts.last);
    if (year == null) {
      return null;
    }

    final month = _monthNumberFromLabel(parts.first);
    if (month == null) {
      return null;
    }

    return _MonthYear(month, year);
  }

  static int? _monthNumberFromLabel(String label) {
    final normalized = label.toLowerCase();
    const months = <String, int>{
      'gen': 1,
      'feb': 2,
      'mar': 3,
      'apr': 4,
      'mag': 5,
      'giu': 6,
      'lug': 7,
      'ago': 8,
      'set': 9,
      'ott': 10,
      'nov': 11,
      'dic': 12,
    };

    for (final entry in months.entries) {
      if (normalized.startsWith(entry.key)) {
        return entry.value;
      }
    }

    return null;
  }
}
