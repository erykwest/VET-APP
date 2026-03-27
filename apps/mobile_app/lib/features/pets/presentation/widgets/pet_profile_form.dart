import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_text_styles.dart';
import '../../data/pet_demo_store.dart';
import '../../domain/pet_models.dart';
import 'pet_sections.dart';

class PetProfileDraft {
  const PetProfileDraft({
    required this.name,
    required this.species,
    required this.breed,
    required this.birthDate,
    required this.sex,
    required this.weightKg,
    required this.medicalNote,
  });

  final String name;
  final String species;
  final String? breed;
  final DateTime birthDate;
  final String sex;
  final double weightKg;
  final String medicalNote;
}

class PetProfileForm extends StatefulWidget {
  const PetProfileForm({
    required this.title,
    required this.submitLabel,
    required this.onSubmit,
    super.key,
    this.initialPet,
    this.helperText = 'Compila i campi richiesti per continuare.',
    this.scrollable = true,
  });

  final PetProfile? initialPet;
  final String title;
  final String helperText;
  final String submitLabel;
  final Future<void> Function(PetProfileDraft draft) onSubmit;
  final bool scrollable;

  @override
  State<PetProfileForm> createState() => _PetProfileFormState();
}

class _PetProfileFormState extends State<PetProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _weightController;
  late final TextEditingController _notesController;
  late String? _species;
  late String? _breed;
  late String? _mixedBreedSize;
  late String? _sex;
  DateTime? _birthDate;

  @override
  void initState() {
    super.initState();
    final pet = widget.initialPet;
    _nameController = TextEditingController(text: pet?.name ?? '');
    _weightController = TextEditingController(
      text: _weightFromLabel(pet?.weightLabel),
    );
    _notesController = TextEditingController(text: pet?.medicalNote ?? '');
    _species = pet?.species;
    _breed = _initialBreedSelection(pet?.breed);
    _mixedBreedSize = _initialMixedBreedSize(pet?.breed);
    _sex = pet?.sex;
    _birthDate = _parseBirthDate(pet?.birthDateLabel);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final breedOptions = _breedOptionsForSelectedSpecies();
    final showMixedBreedSize = _shouldShowMixedBreedSize;

    final form = Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PetSection(
            title: widget.title,
            subtitle: widget.helperText,
            children: [
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration('Nome', 'Moka'),
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'Inserisci il nome del pet.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                initialValue: _species,
                decoration: _inputDecoration('Specie', 'Seleziona una specie'),
                items: PetDemoStore.speciesOptions
                    .map(
                      (option) => DropdownMenuItem<String>(
                        value: option.label,
                        child: Text(option.label),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  setState(() {
                    _species = value;
                    _breed = null;
                    _mixedBreedSize = null;
                  });
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Seleziona una specie.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                initialValue: breedOptions.contains(_breed) ? _breed : null,
                decoration: _inputDecoration('Razza', _breedHintText()),
                items: breedOptions
                    .map(
                      (breed) => DropdownMenuItem<String>(
                        value: breed == 'Razza non specificata' ? '' : breed,
                        child: Text(breed),
                      ),
                    )
                    .toList(growable: false),
                onChanged: _species == null
                    ? null
                    : (value) {
                        setState(() {
                          _breed = value;
                          if (value != PetProfile.mixedBreedLabel) {
                            _mixedBreedSize = null;
                          }
                        });
                      },
              ),
              if (_species != null &&
                  PetDemoStore.isFallbackSpecies(_species!)) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Per specie speciali puoi completare il profilo piu tardi o chiedere una mano in chat.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.mutedText,
                  ),
                ),
              ],
              if (showMixedBreedSize) ...[
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  initialValue: _mixedBreedSize,
                  decoration: _inputDecoration(
                    'Taglia',
                    'Obbligatoria per i meticci',
                  ),
                  items: PetProfile.mixedBreedSizeOptions
                      .map(
                        (size) => DropdownMenuItem<String>(
                          value: size,
                          child: Text(size),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) {
                    setState(() {
                      _mixedBreedSize = value;
                    });
                  },
                  validator: (value) {
                    if (_shouldShowMixedBreedSize &&
                        (value == null || value.trim().isEmpty)) {
                      return 'Seleziona la taglia del meticcio.';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              InkWell(
                onTap: _pickBirthDate,
                borderRadius: BorderRadius.circular(18),
                child: InputDecorator(
                  decoration: _inputDecoration(
                    'Data di nascita',
                    'Seleziona una data',
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _birthDate == null
                              ? 'Seleziona una data'
                              : _formatDate(_birthDate!),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: _birthDate == null
                                ? AppColors.mutedText
                                : AppColors.text,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.calendar_month_rounded,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
              if (_birthDate == null) ...[
                const SizedBox(height: 6),
                Text(
                  'Seleziona la data di nascita.',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.red.shade700,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                initialValue: _sex,
                decoration: _inputDecoration('Sesso', 'Seleziona'),
                items: PetDemoStore.sexOptions
                    .map(
                      (sex) => DropdownMenuItem<String>(
                        value: sex,
                        child: Text(sex),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  setState(() {
                    _sex = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Seleziona il sesso.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _weightController,
                textInputAction: TextInputAction.next,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9,\.]')),
                ],
                decoration: _inputDecoration('Peso', 'Es. 18,4'),
                validator: (value) {
                  final parsed = _parseWeight(value);
                  if (parsed == null) {
                    return 'Inserisci un peso valido.';
                  }
                  if (parsed <= 0) {
                    return 'Il peso deve essere maggiore di zero.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _notesController,
                maxLines: 4,
                decoration: _inputDecoration(
                  'Note cliniche',
                  'Aggiungi note brevi su dieta, farmaci o comportamento.',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          PetSection(
            title: 'Salva profilo',
            subtitle: 'I campi contrassegnati sono obbligatori.',
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.save_rounded),
                  label: Text(widget.submitLabel),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (widget.scrollable) {
      return SingleChildScrollView(
        child: form,
      );
    }

    return form;
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
      ),
    );
  }

  Future<void> _pickBirthDate() async {
    final initialDate = _birthDate ?? DateTime(2021, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid || _birthDate == null) {
      setState(() {});
      return;
    }

    final draft = PetProfileDraft(
      name: _nameController.text.trim(),
      species: _species!.trim(),
      breed: _resolvedBreedSelection(),
      birthDate: _birthDate!,
      sex: _sex!.trim(),
      weightKg: _parseWeight(_weightController.text)!,
      medicalNote: _notesController.text.trim(),
    );

    await widget.onSubmit(draft);
  }

  List<String> _breedOptionsForSelectedSpecies() {
    final species = _species;
    if (species == null || species.trim().isEmpty) {
      return const ['Razza non specificata'];
    }
    return PetDemoStore.breedsForSpecies(species);
  }

  bool get _shouldShowMixedBreedSize {
    final species = _species;
    return species != null &&
        PetDemoStore.supportsMixedBreed(species) &&
        _breed == PetProfile.mixedBreedLabel;
  }

  String _breedHintText() {
    final species = _species;
    if (species == null || species.trim().isEmpty) {
      return 'Seleziona prima la specie';
    }

    if (PetDemoStore.isFallbackSpecies(species)) {
      return 'Facoltativa. Per specie speciali puoi chiedere una mano in chat.';
    }

    return 'Facoltativa';
  }

  String? _initialBreedSelection(String? breed) {
    final normalized = breed?.trim() ?? '';
    if (normalized.isEmpty || normalized == 'Razza non specificata') {
      return null;
    }

    if (PetProfile.isMixedBreedLabel(normalized)) {
      return PetProfile.mixedBreedLabel;
    }

    return normalized;
  }

  String? _initialMixedBreedSize(String? breed) {
    return PetProfile.mixedBreedSizeFromLabel(breed);
  }

  String? _resolvedBreedSelection() {
    final breed = _normalizeBreed(_breed);
    if (breed == null) {
      return null;
    }

    if (breed == PetProfile.mixedBreedLabel) {
      final size = _mixedBreedSize;
      if (size == null || size.trim().isEmpty) {
        return breed;
      }
      return PetProfile.mixedBreedLabelForSize(size);
    }

    return breed;
  }

  String? _normalizeBreed(String? breed) {
    final text = breed?.trim() ?? '';
    if (text.isEmpty || text == 'Razza non specificata') {
      return null;
    }
    return text;
  }

  double? _parseWeight(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) {
      return null;
    }

    final normalized = raw.replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  String _weightFromLabel(String? label) {
    final raw = label?.replaceAll('kg', '').trim() ?? '';
    return raw.replaceAll(',', '.');
  }

  DateTime? _parseBirthDate(String? label) {
    if (label == null || label.trim().isEmpty) {
      return null;
    }

    final parts = label.split(' ');
    if (parts.length < 3) {
      return null;
    }

    final day = int.tryParse(parts[0]);
    final month = _monthNumber(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) {
      return null;
    }

    return DateTime(year, month, day);
  }

  int? _monthNumber(String label) {
    const months = {
      'Gen': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'Mag': 5,
      'Giu': 6,
      'Lug': 7,
      'Ago': 8,
      'Set': 9,
      'Ott': 10,
      'Nov': 11,
      'Dic': 12,
    };

    return months[label];
  }

  String _formatDate(DateTime date) {
    const months = [
      'Gen',
      'Feb',
      'Mar',
      'Apr',
      'Mag',
      'Giu',
      'Lug',
      'Ago',
      'Set',
      'Ott',
      'Nov',
      'Dic',
    ];

    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }
}
