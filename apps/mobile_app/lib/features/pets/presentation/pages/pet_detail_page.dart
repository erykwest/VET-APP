import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/pet_demo_store.dart';
import '../../data/pet_share_snapshot_store.dart';
import '../../domain/pet_models.dart';
import '../widgets/pet_avatar.dart';
import '../widgets/pet_sections.dart';
import '../widgets/pets_scaffold.dart';
import '../widgets/pets_state_views.dart';
import 'pet_edit_page.dart';

enum _ShareFeedbackState {
  none,
  whatsapp,
  telegram,
  instagram,
  x,
  copied,
}

class PetDetailPage extends StatefulWidget {
  const PetDetailPage({
    super.key,
    this.pet,
    this.state = PetsScreenStatus.success,
    this.errorMessage = 'Questo profilo pet non e disponibile al momento.',
  });

  final PetProfile? pet;
  final PetsScreenStatus state;
  final String errorMessage;

  @override
  State<PetDetailPage> createState() => _PetDetailPageState();
}

class _PetDetailPageState extends State<PetDetailPage> {
  PetProfile? _pet;
  PetShareSnapshotMetrics _shareMetrics = const PetShareSnapshotMetrics();
  bool _isSharing = false;
  _ShareFeedbackState _shareFeedback = _ShareFeedbackState.none;

  @override
  void initState() {
    super.initState();
    _pet = widget.pet ?? PetDemoStore.instance.list().firstOrNull;
    _loadShareMetrics();
  }

  @override
  Widget build(BuildContext context) {
    final pet = _pet ?? widget.pet ?? PetDemoStore.instance.list().firstOrNull;

    return PetsScaffold(
      title: pet?.name ?? 'Dettaglio pet',
      subtitle: pet == null
          ? 'Apri un profilo per vedere tutta la cronologia.'
          : 'Tutte le informazioni chiave di questo profilo.',
      onBack: () => Navigator.of(context).maybePop(),
      actions: [
        IconButton(
          onPressed:
              pet == null || _isSharing ? null : () => _shareOnWhatsApp(pet),
          icon: _isSharing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.open_in_new_rounded),
          color: Colors.white,
          style: IconButton.styleFrom(backgroundColor: const Color(0xFF163A35)),
          tooltip: 'Condividi su WhatsApp',
        ),
        IconButton(
          onPressed:
              pet == null || _isSharing ? null : () => _shareOnTelegram(pet),
          icon: const Icon(Icons.send_rounded),
          color: Colors.white,
          style: IconButton.styleFrom(backgroundColor: const Color(0xFF163A35)),
          tooltip: 'Condividi su Telegram',
        ),
        IconButton(
          onPressed: pet == null ? null : () => _openEdit(context, pet),
          icon: const Icon(Icons.edit_outlined),
          color: Colors.white,
          style: IconButton.styleFrom(backgroundColor: const Color(0xFF163A35)),
        ),
      ],
      body: switch (widget.state) {
        PetsScreenStatus.loading =>
          const PetsLoadingView(label: 'Carico il dettaglio pet...'),
        PetsScreenStatus.error => PetsErrorView(
            title: 'Dettaglio pet non disponibile',
            subtitle: widget.errorMessage,
            actionLabel: 'Torna alla lista',
            onRetry: () => _backToList(context),
          ),
        PetsScreenStatus.empty => PetsEmptyView(
            title: 'Nessun pet selezionato',
            subtitle:
                'Scegli un profilo dalla lista per vedere dettagli, note e prossimi passi.',
            actionLabel: 'Torna alla lista',
            onAction: () => _backToList(context),
          ),
        PetsScreenStatus.success => _PetDetailContent(
            pet: pet ?? PetDemoStore.instance.list().first,
            onEdit: pet == null ? null : () => _openEdit(context, pet),
            onBackToList: () => _backToList(context),
            onShareToWhatsApp:
                pet == null || _isSharing ? null : () => _shareOnWhatsApp(pet),
            onShareToTelegram:
                pet == null || _isSharing ? null : () => _shareOnTelegram(pet),
            onShareToInstagram:
                pet == null || _isSharing ? null : () => _shareOnInstagram(pet),
            onShareToX: pet == null || _isSharing ? null : () => _shareOnX(pet),
            onCopyUpdate:
                pet == null || _isSharing ? null : () => _copyPetSnapshot(pet),
            shareMetrics: _shareMetrics,
            shareFeedback: _shareFeedback,
            sharePreview: pet == null
                ? ''
                : PetShareSnapshotStore.instance.buildSnapshotText(pet),
          ),
      },
    );
  }

  Future<void> _loadShareMetrics() async {
    final pet = _pet ?? widget.pet ?? PetDemoStore.instance.list().firstOrNull;
    if (pet == null) {
      return;
    }

    final metrics = await PetShareSnapshotStore.instance.metricsForPet(pet.id);
    if (!mounted) {
      return;
    }

    setState(() {
      _shareMetrics = metrics;
    });
  }

  Future<void> _shareOnWhatsApp(PetProfile pet) async {
    await _shareToExternalApp(
      pet: pet,
      shareUriBuilder: (snapshot) => Uri.parse(
        'https://wa.me/?text=${Uri.encodeComponent(snapshot)}',
      ),
      successState: _ShareFeedbackState.whatsapp,
      successMessage:
          'WhatsApp aperto con l update di ${pet.name} pronto da inviare.',
      fallbackMessage:
          'WhatsApp non disponibile. Update di ${pet.name} copiato come fallback.',
      errorMessage:
          'Non sono riuscito ad aprire WhatsApp. Update di ${pet.name} copiato come fallback.',
    );
  }

  Future<void> _shareOnTelegram(PetProfile pet) async {
    await _shareToExternalApp(
      pet: pet,
      shareUriBuilder: (snapshot) => Uri.parse(
        'https://t.me/share/url?url=&text=${Uri.encodeComponent(snapshot)}',
      ),
      successState: _ShareFeedbackState.telegram,
      successMessage:
          'Telegram aperto con l update di ${pet.name} pronto da inviare.',
      fallbackMessage:
          'Telegram non disponibile. Update di ${pet.name} copiato come fallback.',
      errorMessage:
          'Non sono riuscito ad aprire Telegram. Update di ${pet.name} copiato come fallback.',
    );
  }

  Future<void> _shareOnInstagram(PetProfile pet) async {
    if (_isSharing) {
      return;
    }

    setState(() {
      _isSharing = true;
      _shareFeedback = _ShareFeedbackState.none;
    });

    try {
      final snapshot = PetShareSnapshotStore.instance.buildSnapshotText(pet);
      final metrics = await PetShareSnapshotStore.instance.recordShareClicked(
        pet.id,
      );
      await Clipboard.setData(ClipboardData(text: snapshot));
      final launched = await launchUrl(
        Uri.parse('https://www.instagram.com/direct/inbox/'),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _shareMetrics = metrics;
        _shareFeedback = _ShareFeedbackState.instagram;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            launched
                ? 'Instagram Direct aperto. Update di ${pet.name} copiato e pronto da incollare.'
                : 'Instagram Direct non disponibile. Update di ${pet.name} copiato come fallback.',
          ),
        ),
      );
    } catch (_) {
      final snapshot = PetShareSnapshotStore.instance.buildSnapshotText(pet);
      await Clipboard.setData(ClipboardData(text: snapshot));

      if (!mounted) {
        return;
      }

      setState(() {
        _shareFeedback = _ShareFeedbackState.copied;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Non sono riuscito ad aprire Instagram Direct. Update di ${pet.name} copiato come fallback.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  Future<void> _shareOnX(PetProfile pet) async {
    await _shareToExternalApp(
      pet: pet,
      shareUriBuilder: (snapshot) => Uri.parse(
        'https://x.com/intent/post?text=${Uri.encodeComponent(snapshot)}',
      ),
      successState: _ShareFeedbackState.x,
      successMessage:
          'X aperto con l update di ${pet.name} pronto da pubblicare.',
      fallbackMessage:
          'X non disponibile. Update di ${pet.name} copiato come fallback.',
      errorMessage:
          'Non sono riuscito ad aprire X. Update di ${pet.name} copiato come fallback.',
    );
  }

  Future<void> _shareToExternalApp({
    required PetProfile pet,
    required Uri Function(String snapshot) shareUriBuilder,
    required _ShareFeedbackState successState,
    required String successMessage,
    required String fallbackMessage,
    required String errorMessage,
  }) async {
    if (_isSharing) {
      return;
    }

    setState(() {
      _isSharing = true;
      _shareFeedback = _ShareFeedbackState.none;
    });

    try {
      final snapshot = PetShareSnapshotStore.instance.buildSnapshotText(pet);
      final metrics = await PetShareSnapshotStore.instance.recordShareClicked(
        pet.id,
      );
      final launched = await launchUrl(shareUriBuilder(snapshot));

      if (!mounted) {
        return;
      }

      if (!launched) {
        await Clipboard.setData(ClipboardData(text: snapshot));
        setState(() {
          _shareMetrics = metrics;
          _shareFeedback = _ShareFeedbackState.copied;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              fallbackMessage,
            ),
          ),
        );
        return;
      }

      setState(() {
        _shareMetrics = metrics;
        _shareFeedback = successState;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage),
        ),
      );
    } catch (_) {
      final snapshot = PetShareSnapshotStore.instance.buildSnapshotText(pet);
      await Clipboard.setData(ClipboardData(text: snapshot));

      if (!mounted) {
        return;
      }

      setState(() {
        _shareFeedback = _ShareFeedbackState.copied;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  Future<void> _copyPetSnapshot(PetProfile pet) async {
    if (_isSharing) {
      return;
    }

    setState(() {
      _isSharing = true;
      _shareFeedback = _ShareFeedbackState.none;
    });

    try {
      final snapshot = PetShareSnapshotStore.instance.buildSnapshotText(pet);
      await Clipboard.setData(ClipboardData(text: snapshot));
      final metrics =
          await PetShareSnapshotStore.instance.recordShareCopied(pet.id);

      if (!mounted) {
        return;
      }

      setState(() {
        _shareMetrics = metrics;
        _shareFeedback = _ShareFeedbackState.copied;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Update copiato. Puoi incollarlo in WhatsApp, email o note condivise.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Non sono riuscito a copiare l update di ${pet.name}. Riprova tra un attimo.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  Future<void> _openEdit(BuildContext context, PetProfile pet) async {
    final updated = await Navigator.of(context).push<PetProfile>(
      MaterialPageRoute<PetProfile>(
        builder: (_) => PetEditPage(pet: pet),
      ),
    );

    if (!mounted) return;
    if (updated != null) {
      setState(() {
        _pet = updated;
      });
    }
  }

  void _backToList(BuildContext context) {
    Navigator.of(context).maybePop();
  }
}

class _PetDetailContent extends StatelessWidget {
  const _PetDetailContent({
    required this.pet,
    required this.onEdit,
    required this.onBackToList,
    required this.onShareToWhatsApp,
    required this.onShareToTelegram,
    required this.onShareToInstagram,
    required this.onShareToX,
    required this.onCopyUpdate,
    required this.shareMetrics,
    required this.shareFeedback,
    required this.sharePreview,
  });

  final PetProfile pet;
  final VoidCallback? onEdit;
  final VoidCallback onBackToList;
  final VoidCallback? onShareToWhatsApp;
  final VoidCallback? onShareToTelegram;
  final VoidCallback? onShareToInstagram;
  final VoidCallback? onShareToX;
  final VoidCallback? onCopyUpdate;
  final PetShareSnapshotMetrics shareMetrics;
  final _ShareFeedbackState shareFeedback;
  final String sharePreview;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RoundedSurface(
            backgroundColor: const Color(0xFFF9FBF8),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 720;

                final badge = Container(
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
                );

                final summary = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet.name,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF173A35),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      pet.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF5C726D),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        badge,
                        _DetailBadge(
                          label: PetDemoStore.avatarChoiceLabelForKey(
                            pet.avatarEmoji,
                          ),
                        ),
                        _DetailBadge(label: pet.species),
                        _DetailBadge(label: pet.breedLabel),
                        _DetailBadge(label: pet.weightLabel),
                      ],
                    ),
                  ],
                );

                return isWide
                    ? Row(
                        children: [
                          PetAvatar(
                            label: pet.avatarEmoji,
                            backgroundColor: pet.accentColor,
                            size: 84,
                          ),
                          const SizedBox(width: 18),
                          Expanded(child: summary),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PetAvatar(
                            label: pet.avatarEmoji,
                            backgroundColor: pet.accentColor,
                            size: 84,
                          ),
                          const SizedBox(height: 16),
                          summary,
                        ],
                      );
              },
            ),
          ),
          const SizedBox(height: 16),
          PetSection(
            title: 'Riepilogo profilo',
            subtitle: 'I campi chiave da consultare velocemente.',
            trailing: const _DetailBadge(label: 'Scheda'),
            children: [
              PetInfoRow(label: 'Specie', value: pet.species),
              PetInfoRow(
                label: 'Avatar',
                value: PetDemoStore.avatarChoiceLabelForKey(pet.avatarEmoji),
              ),
              PetInfoRow(label: 'Razza', value: pet.breedLabel),
              PetInfoRow(label: 'Data di nascita', value: pet.birthDateLabel),
              PetInfoRow(label: 'Sesso', value: pet.sex),
              PetInfoRow(label: 'Peso', value: pet.weightLabel),
            ],
          ),
          const SizedBox(height: 16),
          PetSection(
            title: 'Nota clinica',
            subtitle:
                'Contesto breve che aiuta vet e owner a mantenere continuita.',
            trailing: const _DetailBadge(label: 'Insight'),
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
              PetInfoRow(label: 'Prossima visita', value: pet.nextVisitLabel),
            ],
          ),
          const SizedBox(height: 16),
          PetSection(
            title: 'Azioni',
            subtitle: 'Modifica o torna indietro senza perdere il contesto.',
            children: [
              PetActionButton(
                label: 'Modifica profilo',
                icon: Icons.edit_rounded,
                onPressed: onEdit,
              ),
              const SizedBox(height: 12),
              PetActionButton(
                label: 'Torna alla lista',
                icon: Icons.list_rounded,
                onPressed: onBackToList,
              ),
            ],
          ),
          const SizedBox(height: 16),
          PetSection(
            title: 'Condivisione rapida',
            subtitle:
                'Trasforma il profilo in un update pronto da inoltrare a vet, partner o pet sitter.',
            trailing: _DetailBadge(label: shareMetrics.copyFallbacksLabel),
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: 280,
                    child: PetActionButton(
                      label: 'Condividi su WhatsApp',
                      icon: Icons.open_in_new_rounded,
                      primary: true,
                      onPressed: onShareToWhatsApp,
                    ),
                  ),
                  SizedBox(
                    width: 260,
                    child: PetActionButton(
                      label: 'Condividi su Telegram',
                      icon: Icons.send_rounded,
                      onPressed: onShareToTelegram,
                    ),
                  ),
                  SizedBox(
                    width: 260,
                    child: PetActionButton(
                      label: 'Apri Instagram Direct',
                      icon: Icons.camera_alt_outlined,
                      onPressed: onShareToInstagram,
                    ),
                  ),
                  SizedBox(
                    width: 220,
                    child: PetActionButton(
                      label: 'Condividi su X',
                      icon: Icons.alternate_email_rounded,
                      onPressed: onShareToX,
                    ),
                  ),
                  SizedBox(
                    width: 220,
                    child: PetActionButton(
                      label: 'Copia update',
                      icon: Icons.copy_all_rounded,
                      onPressed: onCopyUpdate,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _DetailBadge(label: shareMetrics.shareLaunchesLabel),
                  _DetailBadge(
                      label: 'Ultima: ${shareMetrics.lastSharedLabel}'),
                  if (shareFeedback == _ShareFeedbackState.whatsapp)
                    const _DetailBadge(label: 'WhatsApp aperto'),
                  if (shareFeedback == _ShareFeedbackState.telegram)
                    const _DetailBadge(label: 'Telegram aperto'),
                  if (shareFeedback == _ShareFeedbackState.instagram)
                    const _DetailBadge(label: 'Instagram aperto'),
                  if (shareFeedback == _ShareFeedbackState.x)
                    const _DetailBadge(label: 'X aperto'),
                  if (shareFeedback == _ShareFeedbackState.copied)
                    const _DetailBadge(label: 'Update copiato'),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FBF8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE4DDD2)),
                ),
                child: Text(
                  sharePreview,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Color(0xFF173A35),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Metriche hook: pet_snapshot_share_clicked e pet_snapshot_share_copied.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5C726D),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailBadge extends StatelessWidget {
  const _DetailBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF2E9DE),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Color(0xFF6C4A36),
        ),
      ),
    );
  }
}

extension _IterableFirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
