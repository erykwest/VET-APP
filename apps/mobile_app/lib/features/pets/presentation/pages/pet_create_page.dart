import 'package:flutter/material.dart';

import '../../domain/pet_models.dart';
import '../widgets/pet_form_field.dart';
import '../widgets/pet_sections.dart';
import '../widgets/pets_scaffold.dart';
import '../widgets/pets_state_views.dart';

class PetCreatePage extends StatelessWidget {
  const PetCreatePage({
    super.key,
    this.state = PetsScreenStatus.success,
    this.errorMessage = 'We could not create a new pet profile right now.',
  });

  final PetsScreenStatus state;
  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return PetsScaffold(
      title: 'Create a pet profile.',
      subtitle:
          'Keep the first version light: name, species, breed, and the clinical basics.',
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).maybePop(),
          style: TextButton.styleFrom(foregroundColor: Colors.white),
          child: const Text('Cancel'),
        ),
      ],
      body: switch (state) {
        PetsScreenStatus.loading =>
          const PetsLoadingView(label: 'Preparing creation form...'),
        PetsScreenStatus.error => PetsErrorView(
            title: 'Creation form failed',
            subtitle: errorMessage,
            actionLabel: 'Close',
            onRetry: () => Navigator.of(context).maybePop(),
          ),
        PetsScreenStatus.empty => const _PetCreateForm(
            modeLabel: 'Empty draft',
            helperText:
                'Start from scratch and save when the profile is ready.',
          ),
        PetsScreenStatus.success => const _PetCreateForm(),
      },
    );
  }
}

class _PetCreateForm extends StatelessWidget {
  const _PetCreateForm({
    this.modeLabel = 'New profile',
    this.helperText = 'Fill in the minimum fields to get started.',
  });

  final String modeLabel;
  final String helperText;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PetSection(
            title: modeLabel,
            subtitle: helperText,
            children: const [
              PetFormField(label: 'Name', hintText: 'Luna'),
              SizedBox(height: 16),
              PetFormField(label: 'Species', hintText: 'Dog'),
              SizedBox(height: 16),
              PetFormField(label: 'Breed', hintText: 'Border Collie'),
              SizedBox(height: 16),
              PetFormField(label: 'Birth date', hintText: 'Apr 2021'),
              SizedBox(height: 16),
              PetFormField(label: 'Sex', hintText: 'Female'),
              SizedBox(height: 16),
              PetFormField(label: 'Weight', hintText: '18.4 kg'),
              SizedBox(height: 16),
              PetFormField(
                label: 'Medical notes',
                hintText:
                    'Add short notes about diet, medications, or behavior.',
                maxLines: 4,
              ),
            ],
          ),
          const SizedBox(height: 16),
          PetSection(
            title: 'Save draft',
            subtitle: 'This MVP keeps the action local and backend-free.',
            children: [
              PetActionButton(
                label: 'Save pet profile',
                icon: Icons.save_rounded,
                primary: true,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Pet profile saved locally for now.')),
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
