import 'package:flutter/material.dart';

import '../../domain/pet_models.dart';
import '../widgets/pet_avatar.dart';
import '../widgets/pet_sections.dart';
import '../widgets/pets_scaffold.dart';
import '../widgets/pets_state_views.dart';
import 'pet_edit_page.dart';
import 'pets_list_page.dart';

class PetDetailPage extends StatelessWidget {
  const PetDetailPage({
    super.key,
    this.pet,
    this.state = PetsScreenStatus.success,
    this.errorMessage = 'This pet profile is unavailable right now.',
  });

  final PetProfile? pet;
  final PetsScreenStatus state;
  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return PetsScaffold(
      title: pet?.name ?? 'Pet detail',
      subtitle: pet == null
          ? 'Open a profile to see the full history.'
          : 'All the key info for this profile.',
      actions: [
        IconButton(
          onPressed: pet == null ? null : () => _openEdit(context),
          icon: const Icon(Icons.edit_outlined),
          color: Colors.white,
          style: IconButton.styleFrom(backgroundColor: const Color(0xFF163A35)),
        ),
      ],
      body: switch (state) {
        PetsScreenStatus.loading => const PetsLoadingView(label: 'Loading pet detail...'),
        PetsScreenStatus.error => PetsErrorView(
            title: 'Pet detail unavailable',
            subtitle: errorMessage,
            onRetry: () {},
          ),
        PetsScreenStatus.empty => PetsEmptyView(
            title: 'No pet selected',
            subtitle: 'Choose a profile from the list to inspect details, notes, and next steps.',
            actionLabel: 'Back to list',
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
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => PetEditPage(pet: pet ?? samplePets.first)),
    );
  }

  void _backToList(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const PetsListPage()),
    );
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
            title: 'Profile summary',
            children: [
              PetInfoRow(label: 'Species', value: pet.species),
              PetInfoRow(label: 'Breed', value: pet.breed),
              PetInfoRow(label: 'Birth date', value: pet.birthDateLabel),
              PetInfoRow(label: 'Sex', value: pet.sex),
              PetInfoRow(label: 'Weight', value: pet.weightLabel),
            ],
          ),
          const SizedBox(height: 16),
          PetSection(
            title: 'Medical note',
            subtitle: 'Short context that helps the vet and the owner keep continuity.',
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
              PetInfoRow(label: 'Next visit', value: pet.nextVisitLabel),
            ],
          ),
          const SizedBox(height: 16),
          PetSection(
            title: 'Actions',
            children: [
              PetActionButton(
                label: 'Edit profile',
                icon: Icons.edit_rounded,
                primary: true,
                onPressed: onEdit,
              ),
              const SizedBox(height: 12),
              PetActionButton(
                label: 'Back to list',
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
