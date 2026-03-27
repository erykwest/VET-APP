import 'package:flutter/material.dart';

import '../../data/pet_demo_store.dart';
import '../../domain/pet_models.dart';
import '../widgets/pet_avatar.dart';
import '../widgets/pet_sections.dart';
import '../widgets/pets_scaffold.dart';
import '../widgets/pets_state_views.dart';
import 'pet_edit_page.dart';

class PetDetailPage extends StatefulWidget {
  const PetDetailPage({
    super.key,
    this.pet,
    this.state = PetsScreenStatus.success,
    this.errorMessage = 'Questo profilo pet non e disponibile al momento.',
  });

  final PetProfile? pet;
  final PetsScreenStatus state;
  final String errorMessage;

  @override
  State<PetDetailPage> createState() => _PetDetailPageState();
}

class _PetDetailPageState extends State<PetDetailPage> {
  PetProfile? _pet;

  @override
  void initState() {
    super.initState();
    _pet = widget.pet ?? PetDemoStore.instance.list().firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    final pet = _pet ?? widget.pet ?? PetDemoStore.instance.list().firstOrNull;

    return PetsScaffold(
      title: pet?.name ?? 'Dettaglio pet',
      subtitle: pet == null
          ? 'Apri un profilo per vedere tutta la cronologia.'
          : 'Tutte le informazioni chiave di questo profilo.',
      onBack: () => Navigator.of(context).maybePop(),
      actions: [
        IconButton(
          onPressed: pet == null ? null : () => _openEdit(context, pet),
          icon: const Icon(Icons.edit_outlined),
          color: Colors.white,
          style: IconButton.styleFrom(backgroundColor: const Color(0xFF163A35)),
        ),
      ],
      body: switch (widget.state) {
        PetsScreenStatus.loading =>
          const PetsLoadingView(label: 'Carico il dettaglio pet...'),
        PetsScreenStatus.error => PetsErrorView(
            title: 'Dettaglio pet non disponibile',
            subtitle: widget.errorMessage,
            actionLabel: 'Torna alla lista',
            onRetry: () => _backToList(context),
          ),
        PetsScreenStatus.empty => PetsEmptyView(
            title: 'Nessun pet selezionato',
            subtitle:
                'Scegli un profilo dalla lista per vedere dettagli, note e prossimi passi.',
            actionLabel: 'Torna alla lista',
            onAction: () => _backToList(context),
          ),
        PetsScreenStatus.success => _PetDetailContent(
            pet: pet ?? PetDemoStore.instance.list().first,
            onEdit: pet == null ? null : () => _openEdit(context, pet),
            onBackToList: () => _backToList(context),
          ),
      },
    );
  }

  Future<void> _openEdit(BuildContext context, PetProfile pet) async {
    final updated = await Navigator.of(context).push<PetProfile>(
      MaterialPageRoute<PetProfile>(
        builder: (_) => PetEditPage(pet: pet),
      ),
    );

    if (!mounted) return;
    if (updated != null) {
      setState(() {
        _pet = updated;
      });
    }
  }

  void _backToList(BuildContext context) {
    Navigator.of(context).maybePop();
  }
}

class _PetDetailContent extends StatelessWidget {
  const _PetDetailContent({
    required this.pet,
    required this.onEdit,
    required this.onBackToList,
  });

  final PetProfile pet;
  final VoidCallback? onEdit;
  final VoidCallback onBackToList;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RoundedSurface(
            backgroundColor: const Color(0xFFF9FBF8),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 720;

                final badge = Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE1F0EA),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    pet.healthBadge,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF315E55),
                    ),
                  ),
                );

                final summary = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet.name,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF173A35),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      pet.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF5C726D),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        badge,
                        _DetailBadge(
                          label: PetDemoStore.avatarChoiceLabelForKey(
                            pet.avatarEmoji,
                          ),
                        ),
                        _DetailBadge(label: pet.species),
                        _DetailBadge(label: pet.breedLabel),
                        _DetailBadge(label: pet.weightLabel),
                      ],
                    ),
                  ],
                );

                return isWide
                    ? Row(
                        children: [
                          PetAvatar(
                            label: pet.avatarEmoji,
                            backgroundColor: pet.accentColor,
                            size: 84,
                          ),
                          const SizedBox(width: 18),
                          Expanded(child: summary),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PetAvatar(
                            label: pet.avatarEmoji,
                            backgroundColor: pet.accentColor,
                            size: 84,
                          ),
                          const SizedBox(height: 16),
                          summary,
                        ],
                      );
              },
            ),
          ),
          const SizedBox(height: 16),
          PetSection(
            title: 'Riepilogo profilo',
            subtitle: 'I campi chiave da consultare velocemente.',
            trailing: const _DetailBadge(label: 'Scheda'),
            children: [
              PetInfoRow(label: 'Specie', value: pet.species),
              PetInfoRow(
                label: 'Avatar',
                value: PetDemoStore.avatarChoiceLabelForKey(pet.avatarEmoji),
              ),
              PetInfoRow(label: 'Razza', value: pet.breedLabel),
              PetInfoRow(label: 'Data di nascita', value: pet.birthDateLabel),
              PetInfoRow(label: 'Sesso', value: pet.sex),
              PetInfoRow(label: 'Peso', value: pet.weightLabel),
            ],
          ),
          const SizedBox(height: 16),
          PetSection(
            title: 'Nota clinica',
            subtitle: 'Contesto breve che aiuta vet e owner a mantenere continuita.',
            trailing: const _DetailBadge(label: 'Insight'),
            children: [
              Text(
                pet.medicalNote,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Color(0xFF173A35),
                ),
              ),
              const SizedBox(height: 16),
              PetInfoRow(label: 'Prossima visita', value: pet.nextVisitLabel),
            ],
          ),
          const SizedBox(height: 16),
          PetSection(
            title: 'Azioni',
            subtitle: 'Modifica o torna indietro senza perdere il contesto.',
            children: [
              PetActionButton(
                label: 'Modifica profilo',
                icon: Icons.edit_rounded,
                primary: true,
                onPressed: onEdit,
              ),
              const SizedBox(height: 12),
              PetActionButton(
                label: 'Torna alla lista',
                icon: Icons.list_rounded,
                onPressed: onBackToList,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailBadge extends StatelessWidget {
  const _DetailBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF2E9DE),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Color(0xFF6C4A36),
        ),
      ),
    );
  }
}

extension _IterableFirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
