import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../design_system/tokens/app_colors.dart';
import '../../../../../design_system/tokens/app_radii.dart';
import '../../../../../design_system/tokens/app_spacing.dart';
import '../../../../../design_system/tokens/app_text_styles.dart';
import '../../data/medical_records_repository.dart';

enum _ViewState { empty, loading, error, success }

class MedicalRecordsListPage extends StatefulWidget {
  const MedicalRecordsListPage({super.key});

  @override
  State<MedicalRecordsListPage> createState() => _MedicalRecordsListPageState();
}

class _MedicalRecordsListPageState extends State<MedicalRecordsListPage> {
  final MedicalRecordsRepository _repository = MedicalRecordsRepository();

  late Future<List<MedicalRecordEntry>> _recordsFuture;
  _ViewState _state = _ViewState.success;

  @override
  void initState() {
    super.initState();
    _recordsFuture = _repository.loadRecords();
  }

  Future<void> _reload() async {
    setState(() {
      _recordsFuture = _repository.loadRecords();
    });
    await _recordsFuture;
  }

  void _openUpload() {
    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const MedicalRecordsUploadPage()),
      ).then((_) {
        if (mounted) {
          _reload();
        }
      }),
    );
  }

  void _openDetail(MedicalRecordEntry record) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MedicalRecordDetailPage(record: record),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _FeatureScaffold(
      title: 'Medical records',
      subtitle: 'Archivio documenti clinici, referti e note.',
      actionLabel: 'Upload',
      onAction: _openUpload,
      state: _state,
      onStateChanged: (value) => setState(() => _state = value),
      child: switch (_state) {
        _ViewState.empty => _EmptyState(
            title: 'No documents yet',
            body: 'Upload the first report to start building the archive.',
            icon: Icons.folder_open_outlined,
            actionLabel: 'Upload first file',
            onAction: _openUpload,
          ),
        _ViewState.loading => const _LoadingState(
            title: 'Syncing records',
            body: 'Fetching documents and metadata from the local preview.',
          ),
        _ViewState.error => _EmptyState(
            title: 'Could not load the archive',
            body: 'Retry after checking the network or continue in offline preview.',
            icon: Icons.cloud_off_outlined,
            actionLabel: 'Retry',
            onAction: () {},
          ),
        _ViewState.success => FutureBuilder<List<MedicalRecordEntry>>(
            future: _recordsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _LoadingState(
                  title: 'Syncing records',
                  body: 'Fetching documents and metadata from Supabase or preview data.',
                );
              }

              if (snapshot.hasError) {
                return _EmptyState(
                  title: 'Could not load the archive',
                  body: 'Retry after checking the network or continue in offline preview.',
                  icon: Icons.cloud_off_outlined,
                  actionLabel: 'Retry',
                  onAction: () => unawaited(_reload()),
                );
              }

              final records = snapshot.data ?? const <MedicalRecordEntry>[];
              if (records.isEmpty) {
                return _EmptyState(
                  title: 'No documents yet',
                  body: 'Upload the first report to start building the archive.',
                  icon: Icons.folder_open_outlined,
                  actionLabel: 'Upload first file',
                  onAction: _openUpload,
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SummaryCard(
                    title: '12 documents',
                    body: '2 new files this month, last sync 3 hours ago.',
                    icon: Icons.description_outlined,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ...records.asMap().entries.expand(
                    (entry) {
                      final index = entry.key;
                      final record = entry.value;
                      return <Widget>[
                        _RecordTile(
                          title: record.title,
                          subtitle: record.subtitle,
                          meta: record.meta,
                          badge: record.badge,
                          onTap: () => _openDetail(record),
                        ),
                        if (index != records.length - 1)
                          const SizedBox(height: AppSpacing.sm),
                      ];
                    },
                  ),
                ],
              );
            },
          ),
      },
    );
  }
}

class MedicalRecordsUploadPage extends StatefulWidget {
  const MedicalRecordsUploadPage({super.key});

  @override
  State<MedicalRecordsUploadPage> createState() =>
      _MedicalRecordsUploadPageState();
}

class _MedicalRecordsUploadPageState extends State<MedicalRecordsUploadPage> {
  final MedicalRecordsRepository _repository = MedicalRecordsRepository();
  _ViewState _state = _ViewState.success;
  final MedicalRecordEntry _draftRecord = const MedicalRecordEntry(
    id: 'vaccination-certificate',
    title: 'vaccination_certificate.pdf',
    subtitle: 'Uploaded successfully and ready for metadata review.',
    meta: 'Uploaded successfully',
    badge: 'Verified',
    detailSource: 'Clinica Vet',
    createdAt: '25 Mar 2026, 09:32',
    timeline: [
      MedicalRecordTimelineEntry(label: 'Imported', value: '25 Mar 2026'),
      MedicalRecordTimelineEntry(label: 'Reviewed', value: '25 Mar 2026, 09:45'),
      MedicalRecordTimelineEntry(label: 'Ready for export', value: 'Available'),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return _FeatureScaffold(
      title: 'Upload document',
      subtitle: 'Carica PDF, JPG o PNG e completa i metadati.',
      actionLabel: 'Detail',
      onAction: () {
        unawaited(_repository.saveRecord(_draftRecord));
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => MedicalRecordDetailPage(record: _draftRecord),
          ),
        );
      },
      state: _state,
      onStateChanged: (value) => setState(() => _state = value),
      child: switch (_state) {
        _ViewState.empty => const _EmptyUploadState(),
        _ViewState.loading => const _LoadingState(
            title: 'Uploading document',
            body: 'Processing file and extracting metadata.',
          ),
        _ViewState.error => _EmptyState(
            title: 'Upload failed',
            body: 'Check the file format and try again.',
            icon: Icons.error_outline,
            actionLabel: 'Retry upload',
            onAction: () {},
          ),
        _ViewState.success => const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SummaryCard(
                title: 'vaccination_certificate.pdf',
                body: 'Uploaded successfully and ready for metadata review.',
                icon: Icons.check_circle_outline,
              ),
              SizedBox(height: AppSpacing.lg),
              _MetaGrid(
                items: [
                  _MetaItem('Type', 'Vaccination'),
                  _MetaItem('Date', '25 Mar 2026'),
                  _MetaItem('Source', 'Clinica Vet'),
                  _MetaItem('Format', 'PDF'),
                ],
              ),
              SizedBox(height: AppSpacing.lg),
              _Checklist(),
            ],
          ),
      },
    );
  }
}

class MedicalRecordDetailPage extends StatefulWidget {
  const MedicalRecordDetailPage({super.key, this.record});

  final MedicalRecordEntry? record;

  @override
  State<MedicalRecordDetailPage> createState() => _MedicalRecordDetailPageState();
}

class _MedicalRecordDetailPageState extends State<MedicalRecordDetailPage> {
  _ViewState _state = _ViewState.success;

  @override
  Widget build(BuildContext context) {
    return _FeatureScaffold(
      title: 'Metadata detail',
      subtitle: 'Source, format, date and follow-up notes.',
      actionLabel: 'Back',
      onAction: () => Navigator.of(context).pop(),
      state: _state,
      onStateChanged: (value) => setState(() => _state = value),
      child: switch (_state) {
        _ViewState.empty => const _EmptyState(
            title: 'No document selected',
            body: 'Pick a file from the archive to inspect metadata.',
            icon: Icons.pageview_outlined,
            actionLabel: 'Back to list',
            onAction: null,
          ),
        _ViewState.loading => const _LoadingState(
            title: 'Loading details',
            body: 'Reading preview, source and notes.',
          ),
        _ViewState.error => _EmptyState(
            title: 'Preview unavailable',
            body: 'The metadata is still safe. Try again or re-upload.',
            icon: Icons.broken_image_outlined,
            actionLabel: 'Reload',
            onAction: () {},
          ),
        _ViewState.success => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SummaryCard(
                title: widget.record?.title ?? 'vaccination_certificate.pdf',
                body: widget.record?.detailSource ??
                    'Verified clinic document linked to the active pet profile.',
                icon: Icons.verified_outlined,
              ),
              const SizedBox(height: AppSpacing.lg),
              _MetaGrid(
                items: [
                  _MetaItem('Clinic', widget.record?.detailSource ?? 'Clinica Vet Roma'),
                  _MetaItem('Created', widget.record?.createdAt ?? '25 Mar 2026, 09:32'),
                  const _MetaItem('Pages', '2'),
                  const _MetaItem('Tags', 'Vaccines, yearly check'),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _TimelineCard(timeline: widget.record?.timeline),
            ],
          ),
      },
    );
  }
}

class _FeatureScaffold extends StatelessWidget {
  const _FeatureScaffold({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
    required this.state,
    required this.onStateChanged,
    required this.child,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;
  final _ViewState state;
  final ValueChanged<_ViewState> onStateChanged;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8FBF8),
              Color(0xFFF0F6F3),
              Color(0xFFE0EEE7),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xxl,
              AppSpacing.lg,
              AppSpacing.xxl,
              AppSpacing.xxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(title: title, subtitle: subtitle, actionLabel: actionLabel, onAction: onAction),
                const SizedBox(height: AppSpacing.lg),
                _StateChips(value: state, onChanged: onStateChanged),
                const SizedBox(height: AppSpacing.lg),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _BrandPill(),
              const SizedBox(height: AppSpacing.lg),
              Text(title, style: AppTextStyles.heading),
              const SizedBox(height: AppSpacing.sm),
              Text(subtitle, style: AppTextStyles.body),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        FilledButton(onPressed: onAction, child: Text(actionLabel)),
      ],
    );
  }
}

class _BrandPill extends StatelessWidget {
  const _BrandPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.medical_services_outlined, size: 14, color: AppColors.accent),
          SizedBox(width: AppSpacing.sm),
          Text(
            'VET APP',
            style: TextStyle(color: AppColors.onPrimary, fontSize: 12, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _StateChips extends StatelessWidget {
  const _StateChips({
    required this.value,
    required this.onChanged,
  });

  final _ViewState value;
  final ValueChanged<_ViewState> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _StateChip(label: 'Empty', selected: value == _ViewState.empty, onTap: () => onChanged(_ViewState.empty)),
        _StateChip(label: 'Loading', selected: value == _ViewState.loading, onTap: () => onChanged(_ViewState.loading)),
        _StateChip(label: 'Error', selected: value == _ViewState.error, onTap: () => onChanged(_ViewState.error)),
        _StateChip(label: 'Success', selected: value == _ViewState.success, onTap: () => onChanged(_ViewState.success)),
      ],
    );
  }
}

class _StateChip extends StatelessWidget {
  const _StateChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      labelStyle: TextStyle(
        color: selected ? AppColors.onPrimary : AppColors.secondaryText,
        fontWeight: FontWeight.w700,
      ),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      side: const BorderSide(color: AppColors.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.pill)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.body,
    required this.icon,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String body;
  final IconData icon;
  final String actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return _StateCard(
      accentLabel: 'Preview state',
      title: title,
      body: body,
      icon: icon,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return _LoadingCard(title: title, body: body);
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.accentLabel,
    required this.title,
    required this.body,
    required this.icon,
    required this.actionLabel,
    required this.onAction,
  });

  final String accentLabel;
  final String title;
  final String body;
  final IconData icon;
  final String actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AccentPill(label: accentLabel),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, size: 28, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(title, style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.sm),
          Text(body, style: AppTextStyles.bodySmall),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onAction,
              child: Text(actionLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _AccentPill(label: 'Loading'),
          const SizedBox(height: AppSpacing.lg),
          Text(title, style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.sm),
          Text(body, style: AppTextStyles.bodySmall),
          const SizedBox(height: AppSpacing.xl),
          const _Skeleton(width: double.infinity),
          const SizedBox(height: AppSpacing.sm),
          const _Skeleton(width: double.infinity),
          const SizedBox(height: AppSpacing.sm),
          const _Skeleton(width: 180),
        ],
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 16,
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _AccentPill extends StatelessWidget {
  const _AccentPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF315E55),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.title),
                const SizedBox(height: AppSpacing.sm),
                Text(body, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.badge,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String meta;
  final String badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.description_outlined, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.title.copyWith(fontSize: 17)),
                    const SizedBox(height: AppSpacing.xs),
                    Text(subtitle, style: AppTextStyles.bodySmall),
                    const SizedBox(height: AppSpacing.sm),
                    Text(meta, style: AppTextStyles.caption),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              _Badge(label: badge),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.warmSurface,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF8B5B3E),
        ),
      ),
    );
  }
}

class _MetaGrid extends StatelessWidget {
  const _MetaGrid({required this.items});

  final List<_MetaItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
      ),
      child: Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.md,
        children: items
            .map(
              (item) => SizedBox(
                width: 148,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.label, style: AppTextStyles.caption),
                    const SizedBox(height: AppSpacing.xs),
                    Text(item.value, style: AppTextStyles.bodySmall.copyWith(color: AppColors.text)),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _MetaItem {
  const _MetaItem(this.label, this.value);

  final String label;
  final String value;
}

class _Checklist extends StatelessWidget {
  const _Checklist();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LineItem(text: 'File format supported'),
        _LineItem(text: 'Metadata extracted'),
        _LineItem(text: 'Linked to active pet'),
      ],
    );
  }
}

class _LineItem extends StatelessWidget {
  const _LineItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 18, color: Color(0xFF2D6B60)),
          const SizedBox(width: AppSpacing.sm),
          Text(text, style: AppTextStyles.bodySmall.copyWith(color: AppColors.text)),
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({this.timeline});

  final List<MedicalRecordTimelineEntry>? timeline;

  @override
  Widget build(BuildContext context) {
    final rows = timeline ??
        const [
          MedicalRecordTimelineEntry(label: 'Imported', value: '25 Mar 2026'),
          MedicalRecordTimelineEntry(label: 'Reviewed', value: '25 Mar 2026, 09:45'),
          MedicalRecordTimelineEntry(label: 'Ready for export', value: 'Available'),
        ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Document timeline', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.lg),
          ...rows.map(
            (row) => _TimelineRow(label: row.label, value: row.value),
          ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.text))),
          Text(value, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _EmptyUploadState extends StatelessWidget {
  const _EmptyUploadState();

  @override
  Widget build(BuildContext context) {
    return _EmptyState(
      title: 'Drop a file or browse your device',
      body: 'We will collect type, date and source information after the upload.',
      icon: Icons.cloud_upload_outlined,
      actionLabel: 'Browse files',
      onAction: () {},
    );
  }
}
