import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/pet_demo_store.dart';
import '../../data/post_visit_recap_store.dart';
import '../../domain/pet_models.dart';
import '../widgets/pet_avatar.dart';
import '../widgets/pet_profile_form.dart';
import '../widgets/pets_scaffold.dart';
import '../widgets/pets_state_views.dart';

class PetEditPage extends StatelessWidget {
  const PetEditPage({
    required this.pet,
    super.key,
    this.state = PetsScreenStatus.success,
    this.errorMessage =
        'Non riesco ad aprire questo profilo pet per la modifica.',
  });

  final PetProfile pet;
  final PetsScreenStatus state;
  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return PetsScaffold(
      title: 'Modifica ${pet.name}.',
      subtitle:
          'Aggiorna i dettagli del profilo senza perdere il tono dell app, con campi validati e selezioni guidate.',
      onBack: () => Navigator.of(context).maybePop(),
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
        PetsScreenStatus.empty => _EditForm(
            pet: pet,
            helperText: 'Nessun dato caricato, quindi la bozza parte pulita.',
          ),
        PetsScreenStatus.success => _EditForm(pet: pet),
      },
    );
  }
}

class _EditForm extends StatefulWidget {
  const _EditForm({
    required this.pet,
    this.helperText =
        'Aggiorna i campi da cambiare e lascia invariato il resto.',
  });

  final PetProfile pet;
  final String helperText;

  @override
  State<_EditForm> createState() => _EditFormState();
}

class _EditFormState extends State<_EditForm> {
  late String _selectedAvatarKey =
      PetDemoStore.resolveAvatarKey(widget.pet.avatarEmoji);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PetAvatarPicker(
          title: 'Aggiorna avatar preview',
          subtitle:
              'Puoi cambiare anche il ritratto, senza toccare il profilo reale.',
          selectedKey: _selectedAvatarKey,
          onSelected: (value) {
            setState(() {
              _selectedAvatarKey = value;
            });
          },
        ),
        const SizedBox(height: 16),
        Expanded(
          child: PetProfileForm(
            title: 'Bozza profilo',
            helperText: widget.helperText,
            initialPet: widget.pet,
            submitLabel: 'Salva modifiche',
            onSubmit: (draft) async {
              final updated = widget.pet.copyWith(
                name: draft.name,
                species: draft.species,
                breed: draft.breed ?? '',
                birthDateLabel: _formatDate(draft.birthDate),
                sex: draft.sex,
                weightLabel: _formatWeight(draft.weightKg),
                medicalNote: draft.medicalNote,
                avatarEmoji: _selectedAvatarKey,
              );
              PetDemoStore.instance.upsert(updated);
              if (!context.mounted) return;
              await _showPostVisitRecapSheet(updated);
              if (!context.mounted) return;
              Navigator.of(context).pop(updated);
            },
          ),
        ),
      ],
    );
  }

  String _formatWeight(double weightKg) {
    final normalized = weightKg
        .toStringAsFixed(weightKg.truncateToDouble() == weightKg ? 0 : 1);
    return '${normalized.replaceAll('.', ',')} kg';
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

  Future<void> _showPostVisitRecapSheet(PetProfile pet) async {
    final preview = PostVisitRecapStore.instance.buildPetRecapText(pet);
    final metrics = await PostVisitRecapStore.instance.metricsForEntry(pet.id);
    if (!mounted) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Invia riepilogo visita',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF163A35),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Profilo aggiornato. Ora puoi inoltrare il recap a vet, partner o pet sitter.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7FAF8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  preview,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Color(0xFF163A35),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _RecapChip(label: metrics.shareClicksLabel),
                  _RecapChip(label: metrics.shareCopiesLabel),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.icon(
                    onPressed: () async {
                      await _sharePetRecap(pet, preview);
                      if (sheetContext.mounted) {
                        Navigator.of(sheetContext).pop();
                      }
                    },
                    icon: const Icon(Icons.chat_bubble_outline_rounded),
                    label: const Text('Invia riepilogo visita'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await _copyPetRecap(pet, preview);
                      if (sheetContext.mounted) {
                        Navigator.of(sheetContext).pop();
                      }
                    },
                    icon: const Icon(Icons.copy_all_rounded),
                    label: const Text('Copia'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Metriche hook: post_visit_recap_clicked e post_visit_recap_copied.',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF5C726D),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _sharePetRecap(PetProfile pet, String preview) async {
    try {
      await PostVisitRecapStore.instance.recordShareClicked(pet.id);
      final launched = await launchUrl(
        Uri.parse('https://wa.me/?text=${Uri.encodeComponent(preview)}'),
      );
      if (!mounted) {
        return;
      }
      if (!launched) {
        await Clipboard.setData(ClipboardData(text: preview));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('WhatsApp non disponibile. Riepilogo copiato.'),
          ),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Riepilogo visita di ${pet.name} pronto in WhatsApp.'),
        ),
      );
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: preview));
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invio non riuscito. Riepilogo copiato.'),
        ),
      );
    }
  }

  Future<void> _copyPetRecap(PetProfile pet, String preview) async {
    await Clipboard.setData(ClipboardData(text: preview));
    await PostVisitRecapStore.instance.recordShareCopied(pet.id);
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Riepilogo visita di ${pet.name} copiato.'),
      ),
    );
  }
}

class _RecapChip extends StatelessWidget {
  const _RecapChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1ED),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Color(0xFF315E55),
        ),
      ),
    );
  }
}
