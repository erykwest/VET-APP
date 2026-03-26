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
    this.errorMessage = 'Al momento non riesco a creare un nuovo profilo pet.',
  });

  final PetsScreenStatus state;
  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return PetsScaffold(
      title: 'Crea un profilo pet.',
      subtitle:
          'Manteniamo la prima versione leggera: nome, specie, razza e basi cliniche, pronta per web e mobile.',
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).maybePop(),
          style: TextButton.styleFrom(foregroundColor: Colors.white),
          child: const Text('Annulla'),
        ),
      ],
      body: switch (state) {
        PetsScreenStatus.loading =>
          const PetsLoadingView(label: 'Preparo il form di creazione...'),
        PetsScreenStatus.error => PetsErrorView(
            title: 'Form di creazione non disponibile',
            subtitle: errorMessage,
            actionLabel: 'Chiudi',
            onRetry: () => Navigator.of(context).maybePop(),
          ),
        PetsScreenStatus.empty => const _PetCreateForm(
            modeLabel: 'Bozza vuota',
            helperText:
                'Parti da zero e salva quando il profilo e pronto.',
          ),
        PetsScreenStatus.success => const _PetCreateForm(),
      },
    );
  }
}

class _PetCreateForm extends StatelessWidget {
  const _PetCreateForm({
    this.modeLabel = 'Nuovo profilo',
    this.helperText = 'Compila i campi minimi per iniziare.',
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
              PetFormField(label: 'Nome', hintText: 'Moka'),
              SizedBox(height: 16),
              PetFormField(label: 'Specie', hintText: 'Cane'),
              SizedBox(height: 16),
              PetFormField(label: 'Razza', hintText: 'Border Collie'),
              SizedBox(height: 16),
              PetFormField(label: 'Data di nascita', hintText: 'Apr 2021'),
              SizedBox(height: 16),
              PetFormField(label: 'Sesso', hintText: 'Femmina'),
              SizedBox(height: 16),
              PetFormField(label: 'Peso', hintText: '18,4 kg'),
              SizedBox(height: 16),
              PetFormField(
                label: 'Note cliniche',
                hintText:
                    'Aggiungi note brevi su dieta, farmaci o comportamento.',
                maxLines: 4,
              ),
            ],
          ),
          const SizedBox(height: 16),
          PetSection(
            title: 'Salva bozza',
            subtitle: "Questa MVP mantiene l azione semplice in attesa della release completa.",
            children: [
              PetActionButton(
                label: 'Salva profilo pet',
                icon: Icons.save_rounded,
                primary: true,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profilo pet salvato per la demo.'),
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

