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
    this.errorMessage = 'We could not load your pets right now.',
  });

  final PetsScreenStatus state;
  final List<PetProfile> pets;
  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return PetsScaffold(
      title: 'Your pets, at a glance.',
      subtitle: 'Keep every pet profile, note, and health milestone in one place.',
      actions: [
        IconButton(
          onPressed: () => _openCreate(context),
          icon: const Icon(Icons.add_circle_outline_rounded),
          color: Colors.white,
          style: IconButton.styleFrom(backgroundColor: const Color(0xFF163A35)),
        ),
      ],
      body: switch (state) {
        PetsScreenStatus.loading => const PetsLoadingView(label: 'Loading pet list...'),
        PetsScreenStatus.error => PetsErrorView(
            title: 'Pets not available',
            subtitle: errorMessage,
            onRetry: () {},
          ),
        PetsScreenStatus.empty => PetsEmptyView(
            title: 'No pets yet',
            subtitle: 'Create your first profile to track health, notes, and reminders.',
            actionLabel: 'Create pet',
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
            title: 'Quick overview',
            subtitle: 'The MVP keeps the most important pet data visible first.',
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  PetMetricChip(
                    label: 'Pets registered',
                    value: '3',
                    backgroundColor: Color(0xFFE1F0EA),
                  ),
                  PetMetricChip(
                    label: 'Health alerts',
                    value: '1',
                    backgroundColor: Color(0xFFF6EADF),
                  ),
                  PetMetricChip(
                    label: 'Upcoming visits',
                    value: '2',
                    backgroundColor: Color(0xFFF5F0D8),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          PetSection(
            title: 'Pet list',
            subtitle: 'Tap a profile to open the detail screen or edit it later.',
            children: [
              ...pets.map(
                (pet) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _PetListCard(
                    pet: pet,
                    onTap: () => onOpenPet(pet),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              PetActionButton(
                label: 'Add another pet',
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
            color: Colors.white,
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
