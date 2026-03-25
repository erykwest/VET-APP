import 'package:flutter/material.dart';

import '../../domain/pet_models.dart';
import '../widgets/pet_form_field.dart';
import '../widgets/pet_sections.dart';
import '../widgets/pets_scaffold.dart';
import '../widgets/pets_state_views.dart';

class PetEditPage extends StatelessWidget {
  const PetEditPage({
    required this.pet,
    super.key,
    this.state = PetsScreenStatus.success,
    this.errorMessage = 'We could not open this pet profile for editing.',
  });

  final PetProfile pet;
  final PetsScreenStatus state;
  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return PetsScaffold(
      title: 'Edit ${pet.name}.',
      subtitle:
          'Adjust profile details without losing the original tone of the app.',
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).maybePop(),
          style: TextButton.styleFrom(foregroundColor: Colors.white),
          child: const Text('Close'),
        ),
      ],
      body: switch (state) {
        PetsScreenStatus.loading =>
          const PetsLoadingView(label: 'Loading edit form...'),
        PetsScreenStatus.error => PetsErrorView(
            title: 'Edit unavailable',
            subtitle: errorMessage,
            actionLabel: 'Close',
            onRetry: () => Navigator.of(context).maybePop(),
          ),
        PetsScreenStatus.empty => _PetEditForm(
            pet: pet,
            helperText: 'No data was loaded, so this draft starts clean.',
          ),
        PetsScreenStatus.success => _PetEditForm(pet: pet),
      },
    );
  }
}

class _PetEditForm extends StatelessWidget {
  const _PetEditForm({
    required this.pet,
    this.helperText =
        'Update the fields you want to change and keep the rest intact.',
  });

  final PetProfile pet;
  final String helperText;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PetSection(
            title: 'Profile draft',
            subtitle: helperText,
            children: [
              PetFormField(label: 'Name', initialValue: pet.name),
              const SizedBox(height: 16),
              PetFormField(label: 'Species', initialValue: pet.species),
              const SizedBox(height: 16),
              PetFormField(label: 'Breed', initialValue: pet.breed),
              const SizedBox(height: 16),
              PetFormField(
                  label: 'Birth date', initialValue: pet.birthDateLabel),
              const SizedBox(height: 16),
              PetFormField(label: 'Sex', initialValue: pet.sex),
              const SizedBox(height: 16),
              PetFormField(label: 'Weight', initialValue: pet.weightLabel),
              const SizedBox(height: 16),
              PetFormField(
                label: 'Medical notes',
                initialValue: pet.medicalNote,
                maxLines: 4,
              ),
            ],
          ),
          const SizedBox(height: 16),
          PetSection(
            title: 'Save changes',
            subtitle: 'The edit screen stays local until backend wiring lands.',
            children: [
              PetActionButton(
                label: 'Save changes',
                icon: Icons.save_rounded,
                primary: true,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Changes saved locally for now.')),
                  );
                },
              ),
              const SizedBox(height: 12),
              PetActionButton(
                label: 'Archive profile',
                icon: Icons.archive_outlined,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Archive action is a local placeholder.')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
