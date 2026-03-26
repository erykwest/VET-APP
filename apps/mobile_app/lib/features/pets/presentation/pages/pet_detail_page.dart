import 'package:flutter/material.dart';

import '../../domain/pet_models.dart';
import '../widgets/pet_avatar.dart';
import '../widgets/pet_sections.dart';
import '../widgets/pets_scaffold.dart';
import '../widgets/pets_state_views.dart';
import 'pet_edit_page.dart';

class PetDetailPage extends StatelessWidget {
  const PetDetailPage({
    super.key,
    this.pet,
    this.state = PetsScreenStatus.success,
    this.errorMessage = 'Questo profilo pet non è disponibile al momento.',
  });

  final PetProfile? pet;
  final PetsScreenStatus state;
  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return PetsScaffold(
      title: pet?.name ?? 'Dettaglio pet',
      subtitle: pet == null
          ? 'Apri un profilo per vedere tutta la cronologia.'
          : 'Tutte le informazioni chiave di questo profilo.',
      actions: [
        IconButton(
          onPressed: pet == null ? null : () => _openEdit(context),
          icon: const Icon(Icons.edit_outlined),
          color: Colors.white,
          style: IconButton.styleFrom(backgroundColor: const Color(0xFF163A35)),
        ),
      ],
      body: switch (state) {
        PetsScreenStatus.loading =>
          const PetsLoadingView(label: 'Carico il dettaglio pet...'),
        PetsScreenStatus.error => PetsErrorView(
            title: 'Dettaglio pet non disponibile',
            subtitle: errorMessage,
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
            pet: pet ?? samplePets.first,
            onEdit: () => _openEdit(context),
            onBackToList: () => _backToList(context),
          ),
      },
    );
  }

  void _openEdit(BuildContext context) {
    final profile = pet ?? samplePets.first;
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => PetEditPage(pet: profile)),
    );
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
  final VoidCallback onEdit;
  final VoidCallback onBackToList;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RoundedSurface(
            backgroundColor: Colors.white,
            child: Row(
              children: [
                PetAvatar(
                  label: pet.avatarEmoji,
                  backgroundColor: pet.accentColor,
                  size: 84,
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF173A35),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        pet.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF5C726D),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
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
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PetSection(
            title: 'Riepilogo profilo',
            children: [
              PetInfoRow(label: 'Specie', value: pet.species),
              PetInfoRow(label: 'Razza', value: pet.breed),
              PetInfoRow(label: 'Data di nascita', value: pet.birthDateLabel),
              PetInfoRow(label: 'Sesso', value: pet.sex),
              PetInfoRow(label: 'Peso', value: pet.weightLabel),
            ],
          ),
          const SizedBox(height: 16),
          PetSection(
            title: 'Nota clinica',
            subtitle:
                'Contesto breve che aiuta vet e owner a mantenere continuità.',
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
