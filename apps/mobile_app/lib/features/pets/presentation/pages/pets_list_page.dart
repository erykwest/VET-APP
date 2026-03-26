import 'package:flutter/material.dart';

import '../../domain/pet_models.dart';
import '../widgets/pet_avatar.dart';
import '../widgets/pet_sections.dart';
import '../widgets/pets_scaffold.dart';
import '../widgets/pets_state_views.dart';
import 'pet_create_page.dart';
import 'pet_detail_page.dart';

class PetsListPage extends StatelessWidget {
  const PetsListPage({
    super.key,
    this.state = PetsScreenStatus.success,
    this.pets = samplePets,
    this.errorMessage = 'Al momento non riesco a caricare i profili pet.',
  });

  final PetsScreenStatus state;
  final List<PetProfile> pets;
  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return PetsScaffold(
      title: "I tuoi pet, in un colpo d'occhio.",
      subtitle:
          'Qui trovi il pet principale, le prossime scadenze e il secondo profilo pronto da aprire.',
      actions: [
        IconButton(
          onPressed: () => _openCreate(context),
          icon: const Icon(Icons.add_circle_outline_rounded),
          color: Colors.white,
          style: IconButton.styleFrom(backgroundColor: const Color(0xFF163A35)),
        ),
      ],
      body: switch (state) {
        PetsScreenStatus.loading =>
          const PetsLoadingView(label: 'Carico la lista pet...'),
        PetsScreenStatus.error => PetsErrorView(
            title: 'Pet non disponibili',
            subtitle: errorMessage,
            actionLabel: 'Indietro',
            onRetry: () => Navigator.of(context).maybePop(),
          ),
        PetsScreenStatus.empty => PetsEmptyView(
            title: 'Nessun pet ancora',
            subtitle:
                'Crea il primo profilo per tenere sotto controllo salute, note e scadenze.',
            actionLabel: 'Crea pet',
            onAction: () => _openCreate(context),
          ),
        PetsScreenStatus.success => _PetsListContent(
            pets: pets,
            onAddPet: () => _openCreate(context),
            onOpenPet: (pet) => _openDetail(context, pet),
          ),
      },
    );
  }

  void _openCreate(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const PetCreatePage()),
    );
  }

  void _openDetail(BuildContext context, PetProfile pet) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => PetDetailPage(pet: pet)),
    );
  }
}

class _PetsListContent extends StatelessWidget {
  const _PetsListContent({
    required this.pets,
    required this.onAddPet,
    required this.onOpenPet,
  });

  final List<PetProfile> pets;
  final VoidCallback onAddPet;
  final ValueChanged<PetProfile> onOpenPet;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PetSection(
            title: 'Panoramica demo',
            subtitle:
                'Mostriamo subito il pet principale, una scadenza vicina e il profilo di supporto.',
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  PetMetricChip(
                    label: 'Pet registrati',
                    value: '2',
                    backgroundColor: Color(0xFFE1F0EA),
                  ),
                  PetMetricChip(
                    label: 'Scadenze vicine',
                    value: '1',
                    backgroundColor: Color(0xFFF6EADF),
                  ),
                  PetMetricChip(
                    label: 'Note cliniche',
                    value: '1',
                    backgroundColor: Color(0xFFF5F0D8),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          PetSection(
            title: 'Profilo principale',
            subtitle:
                'Questo è il volto della demo: una card forte, leggibile e coerente con home, chat e reminder.',
            children: [
              if (pets.isNotEmpty)
                _FeaturedPetCard(
                  pet: pets.first,
                  onTap: () => onOpenPet(pets.first),
                )
              else
                const SizedBox.shrink(),
              if (pets.length > 1) ...[
                const SizedBox(height: 14),
                const Text(
                  'Profilo secondario',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF7C8F89),
                  ),
                ),
                const SizedBox(height: 10),
                ...pets.skip(1).map(
                  (pet) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _PetListCard(
                      pet: pet,
                      onTap: () => onOpenPet(pet),
                    ),
                  ),
                ),
              ],
              if (pets.isEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Nessun pet disponibile al momento.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5C726D),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              PetActionButton(
                label: 'Aggiungi un altro pet',
                icon: Icons.add_rounded,
                primary: true,
                onPressed: onAddPet,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeaturedPetCard extends StatelessWidget {
  const _FeaturedPetCard({
    required this.pet,
    required this.onTap,
  });

  final PetProfile pet;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FBF8),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFE4DDD2)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x10163A35),
                blurRadius: 18,
                offset: Offset(0, 10),
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
                    size: 72,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _DemoPill(label: 'Pet attivo'),
                        const SizedBox(height: 8),
                        Text(
                          pet.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF173A35),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pet.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF5C726D),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Color(0xFF7C8F89)),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _InfoChip(label: pet.healthBadge, backgroundColor: const Color(0xFFE1F0EA)),
                  _InfoChip(label: pet.weightLabel, backgroundColor: const Color(0xFFF6EADF)),
                  _InfoChip(label: pet.birthDateLabel, backgroundColor: const Color(0xFFF5F0D8)),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                pet.medicalNote,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF5C726D),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE4DDD2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event_available_outlined, size: 18, color: Color(0xFF2D6B60)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        pet.nextVisitLabel,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF173A35),
                        ),
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
}

class _PetListCard extends StatelessWidget {
  const _PetListCard({
    required this.pet,
    required this.onTap,
  });

  final PetProfile pet;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFCFDFC),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE4DDD2)),
          ),
          child: Row(
            children: [
              PetAvatar(
                label: pet.avatarEmoji,
                backgroundColor: pet.accentColor,
                size: 64,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF173A35),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pet.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF5C726D),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      pet.medicalNote,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF7C8F89),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      pet.nextVisitLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF7C8F89),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF7C8F89)),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.backgroundColor,
  });

  final String label;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF173A35),
        ),
      ),
    );
  }
}

class _DemoPill extends StatelessWidget {
  const _DemoPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF163A35),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
          color: Colors.white,
        ),
      ),
    );
  }
}
