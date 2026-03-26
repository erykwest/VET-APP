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
    this.errorMessage = 'Non riesco ad aprire questo profilo pet per la modifica.',
  });

  final PetProfile pet;
  final PetsScreenStatus state;
  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return PetsScaffold(
      title: 'Modifica ${pet.name}.',
      subtitle:
          "Aggiorna i dettagli del profilo senza perdere il tono dell'app, pronto per web e mobile.",
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).maybePop(),
          style: TextButton.styleFrom(foregroundColor: Colors.white),
          child: const Text('Chiudi'),
        ),
      ],
      body: switch (state) {
        PetsScreenStatus.loading =>
          const PetsLoadingView(label: 'Carico il form di modifica...'),
        PetsScreenStatus.error => PetsErrorView(
            title: 'Modifica non disponibile',
            subtitle: errorMessage,
            actionLabel: 'Chiudi',
            onRetry: () => Navigator.of(context).maybePop(),
          ),
        PetsScreenStatus.empty => _PetEditForm(
            pet: pet,
            helperText: 'Nessun dato caricato, quindi la bozza parte pulita.',
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
        'Aggiorna i campi da cambiare e lascia invariato il resto.',
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
            title: 'Bozza profilo',
            subtitle: helperText,
            children: [
              PetFormField(label: 'Nome', initialValue: pet.name),
              const SizedBox(height: 16),
              PetFormField(label: 'Specie', initialValue: pet.species),
              const SizedBox(height: 16),
              PetFormField(label: 'Razza', initialValue: pet.breed),
              const SizedBox(height: 16),
              PetFormField(
                  label: 'Data di nascita', initialValue: pet.birthDateLabel),
              const SizedBox(height: 16),
              PetFormField(label: 'Sesso', initialValue: pet.sex),
              const SizedBox(height: 16),
              PetFormField(label: 'Peso', initialValue: pet.weightLabel),
              const SizedBox(height: 16),
              PetFormField(
                label: 'Note cliniche',
                initialValue: pet.medicalNote,
                maxLines: 4,
              ),
            ],
          ),
          const SizedBox(height: 16),
          PetSection(
            title: 'Salva modifiche',
            subtitle: 'La schermata resta leggera finche non attiviamo la release completa.',
            children: [
              PetActionButton(
                label: 'Salva modifiche',
                icon: Icons.save_rounded,
                primary: true,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Modifiche salvate per la demo.'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              PetActionButton(
                label: 'Archivia profilo',
                icon: Icons.archive_outlined,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("L'azione di archivio e un segnaposto temporaneo."),
                    ),
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

