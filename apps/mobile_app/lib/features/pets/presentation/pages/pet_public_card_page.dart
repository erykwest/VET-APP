import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/pet_demo_store.dart';
import '../../data/pet_public_card_store.dart';
import '../../domain/pet_models.dart';
import '../widgets/pet_avatar.dart';

class PetPublicCardPage extends StatefulWidget {
  const PetPublicCardPage({
    super.key,
    this.petId,
  });

  final String? petId;

  @override
  State<PetPublicCardPage> createState() => _PetPublicCardPageState();
}

class _PetPublicCardPageState extends State<PetPublicCardPage> {
  PetPublicCardMetrics _metrics = const PetPublicCardMetrics();

  PetProfile? get _pet {
    final petId = widget.petId;
    if (petId == null || petId.trim().isEmpty) {
      return PetDemoStore.instance.list().firstOrNull;
    }
    return PetDemoStore.instance.byId(petId) ??
        PetDemoStore.instance.list().firstOrNull;
  }

  @override
  void initState() {
    super.initState();
    _loadMetricsAndTrackOpen();
  }

  @override
  Widget build(BuildContext context) {
    final pet = _pet;
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: pet == null
              ? const _MissingPetState()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Pet card pubblica',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF163A35),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: const Color(0xFFE2EAE6)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14163A35),
                            blurRadius: 22,
                            offset: Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              PetAvatar(
                                label: pet.avatarEmoji,
                                backgroundColor: pet.accentColor,
                                size: 86,
                                imageDataUrl: pet.profileImageDataUrl,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      pet.name,
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF163A35),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${pet.species} - ${pet.breedLabel}',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF5C726D),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _MetricPill(label: pet.healthBadge),
                              _MetricPill(label: pet.nextVisitLabel),
                              _MetricPill(label: _metrics.openLabel),
                              _MetricPill(label: _metrics.shareLabel),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _InfoRow(label: 'Stato', value: pet.healthBadge),
                          _InfoRow(
                              label: 'Prossima visita',
                              value: pet.nextVisitLabel),
                          _InfoRow(label: 'Nota breve', value: pet.medicalNote),
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7FAF8),
                              borderRadius: BorderRadius.circular(18),
                              border:
                                  Border.all(color: const Color(0xFFE2EAE6)),
                            ),
                            child: Text(
                              '${PetPublicCardStore.instance.buildDemoLink(pet.id)}\n\n${PetPublicCardStore.instance.buildCardPreviewText(pet)}',
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                color: Color(0xFF163A35),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: () => _shareCard(pet),
                            icon: const Icon(Icons.share_outlined),
                            label: const Text('Condividi pet card'),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Metriche hook: pet_card_opened e pet_card_shared.',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF5C726D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _loadMetricsAndTrackOpen() async {
    final pet = _pet;
    if (pet == null) {
      return;
    }

    final metrics = await PetPublicCardStore.instance.recordOpened(pet.id);
    if (!mounted) {
      return;
    }

    setState(() {
      _metrics = metrics;
    });
  }

  Future<void> _shareCard(PetProfile pet) async {
    final payload = [
      PetPublicCardStore.instance.buildDemoLink(pet.id),
      '',
      PetPublicCardStore.instance.buildCardPreviewText(pet),
    ].join('\n');
    await Clipboard.setData(ClipboardData(text: payload));
    final metrics = await PetPublicCardStore.instance.recordShared(pet.id);
    if (!mounted) {
      return;
    }

    setState(() {
      _metrics = metrics;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'Pet card copiata con link demo e riepilogo pronto da inoltrare.'),
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1ED),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF315E55),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF7C8F89),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              height: 1.4,
              fontWeight: FontWeight.w600,
              color: Color(0xFF163A35),
            ),
          ),
        ],
      ),
    );
  }
}

class _MissingPetState extends StatelessWidget {
  const _MissingPetState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE2EAE6)),
      ),
      child: const Text(
        'Nessun pet disponibile per generare la card pubblica.',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xFF163A35),
        ),
      ),
    );
  }
}

extension _FirstOrNullExtension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
