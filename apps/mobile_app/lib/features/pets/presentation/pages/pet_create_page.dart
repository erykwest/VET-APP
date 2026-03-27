import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../data/pet_demo_store.dart';
import '../../domain/pet_models.dart';
import '../widgets/pet_avatar.dart';
import '../widgets/pet_profile_form.dart';
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
          'Nome, specie, razza opzionale, data di nascita e peso validato per evitare inserimenti errati.',
      onBack: () => Navigator.of(context).maybePop(),
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
        PetsScreenStatus.empty => const _CreateForm(
            helperText: 'Parti da zero e salva quando il profilo e pronto.',
          ),
        PetsScreenStatus.success => const _CreateForm(),
      },
    );
  }
}

class _CreateForm extends StatefulWidget {
  const _CreateForm({
    this.helperText = 'Compila i campi richiesti per iniziare.',
  });

  final String helperText;

  @override
  State<_CreateForm> createState() => _CreateFormState();
}

class _CreateFormState extends State<_CreateForm> {
  late String _selectedAvatarKey = PetDemoStore.avatarChoices.first.key;
  String? _profileImageDataUrl;
  String? _galleryProvider;
  bool _isPickingPhoto = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PetAvatarPicker(
            selectedKey: _selectedAvatarKey,
            compact: true,
            title: 'Tema visuale',
            subtitle:
                'Le card tema sono piu compatte e scorrono in orizzontale, cosi i campi del profilo restano subito visibili.',
            onSelected: (value) {
              setState(() {
                _selectedAvatarKey = value;
              });
            },
          ),
          const SizedBox(height: 16),
          _ProfilePhotoSection(
            selectedAvatarKey: _selectedAvatarKey,
            profileImageDataUrl: _profileImageDataUrl,
            isPickingPhoto: _isPickingPhoto,
            onPickPhoto: _pickProfilePhoto,
            onClearPhoto: _profileImageDataUrl == null
                ? null
                : () {
                    setState(() {
                      _profileImageDataUrl = null;
                    });
                  },
          ),
          const SizedBox(height: 16),
          _GalleryProviderSection(
            selectedProvider: _galleryProvider,
            onSelected: (value) {
              setState(() {
                _galleryProvider = value;
              });
            },
          ),
          const SizedBox(height: 16),
          PetProfileForm(
            title: 'Nuovo profilo',
            helperText: widget.helperText,
            submitLabel: 'Salva profilo pet',
            onSubmit: (draft) async {
              final pet = PetDemoStore.instance.create(
                name: draft.name,
                species: draft.species,
                breed: draft.breed,
                birthDate: draft.birthDate,
                sex: draft.sex,
                weightKg: draft.weightKg,
                medicalNote: draft.medicalNote,
                avatarKey: _selectedAvatarKey,
                profileImageDataUrl: _profileImageDataUrl,
                galleryProvider: _galleryProvider,
              );
              if (!context.mounted) return;
              Navigator.of(context).pop(pet);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickProfilePhoto() async {
    setState(() {
      _isPickingPhoto = true;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );
      final file = result?.files.firstOrNull;
      final bytes = file?.bytes;
      if (bytes == null || bytes.isEmpty) {
        return;
      }

      final extension = (file?.extension ?? 'png').toLowerCase();
      final mimeType = switch (extension) {
        'jpg' || 'jpeg' => 'image/jpeg',
        'webp' => 'image/webp',
        'gif' => 'image/gif',
        _ => 'image/png',
      };

      setState(() {
        _profileImageDataUrl = 'data:$mimeType;base64,${base64Encode(bytes)}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isPickingPhoto = false;
        });
      }
    }
  }
}

class _ProfilePhotoSection extends StatelessWidget {
  const _ProfilePhotoSection({
    required this.selectedAvatarKey,
    required this.profileImageDataUrl,
    required this.isPickingPhoto,
    required this.onPickPhoto,
    required this.onClearPhoto,
  });

  final String selectedAvatarKey;
  final String? profileImageDataUrl;
  final bool isPickingPhoto;
  final VoidCallback onPickPhoto;
  final VoidCallback? onClearPhoto;

  @override
  Widget build(BuildContext context) {
    final selectedTheme = PetDemoStore.avatarChoiceForKey(selectedAvatarKey);

    return PetSection(
      title: 'Foto profilo del pet',
      subtitle:
          'Puoi caricare una foto reale del pet. Se non la aggiungi, il profilo usera il tema selezionato.',
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PetAvatar(
              label: selectedTheme.key,
              backgroundColor: selectedTheme.backgroundColor,
              size: 92,
              imageDataUrl: profileImageDataUrl,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OutlinedButton.icon(
                    onPressed: isPickingPhoto ? null : onPickPhoto,
                    icon: isPickingPhoto
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.upload_rounded),
                    label: const Text('Carica foto'),
                  ),
                  if (onClearPhoto != null) ...[
                    const SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: onClearPhoto,
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('Rimuovi foto'),
                    ),
                  ],
                  const SizedBox(height: 8),
                  const Text(
                    'Nel demo flow la foto viene mostrata subito nella scheda pet appena salvi.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GalleryProviderSection extends StatelessWidget {
  const _GalleryProviderSection({
    required this.selectedProvider,
    required this.onSelected,
  });

  final String? selectedProvider;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return PetSection(
      title: 'Galleria collegata',
      subtitle:
          'Collega una sorgente foto del pet. Nella scheda finale mostreremo le ultime 8 preview.',
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final provider in PetDemoStore.galleryProviderOptions)
              ChoiceChip(
                label: Text(provider),
                selected: selectedProvider == provider,
                onSelected: (_) => onSelected(provider),
              ),
            ChoiceChip(
              label: const Text('Nessuna'),
              selected: selectedProvider == null,
              onSelected: (_) => onSelected(null),
            ),
          ],
        ),
      ],
    );
  }
}

extension _FirstOrNullExtension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
