import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../../design_system/tokens/app_colors.dart';
import '../../../../../design_system/tokens/app_radii.dart';
import '../../../../../design_system/tokens/app_spacing.dart';
import '../../../../../design_system/tokens/app_text_styles.dart';
import '../../../settings/presentation/pages/settings_page.dart';

enum _ViewState { empty, loading, error, success }

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  _ViewState _state = _ViewState.success;
  bool _darkMode = false;

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
    );
  }

  void _showLogoutPreview() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logout pronto per essere collegato al flusso account reale.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8FBF8), Color(0xFFF4F7F1), Color(0xFFE7EEE5)],
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
                _Header(
                  onBack: () => Navigator.of(context).maybePop(),
                  onOpenSettings: _openSettings,
                  onLogoutPreview: _showLogoutPreview,
                ),
                const SizedBox(height: AppSpacing.lg),
                _StateChips(value: _state, onChanged: (value) => setState(() => _state = value)),
                const SizedBox(height: AppSpacing.lg),
                switch (_state) {
                  _ViewState.empty => _StateCard(
                      label: 'Profilo',
                      title: 'Nessun dettaglio disponibile.',
                      body: 'Aggiungi nome, contatti e preferenze per completare l esperienza owner.',
                      icon: Icons.badge_outlined,
                      actionLabel: 'Compila profilo',
                      onAction: () {},
                    ),
                  _ViewState.loading => const _LoadingCard(
                      title: 'Caricamento profilo',
                      body: 'Sto preparando dati owner, contatti e preferenze.',
                    ),
                  _ViewState.error => _StateCard(
                      label: 'Errore profilo',
                      title: 'Non riesco a caricare i dati del profilo.',
                      body: 'Riprova oppure continua con i dati di preview.',
                      icon: Icons.account_circle_outlined,
                      actionLabel: 'Riprova',
                      onAction: () => setState(() => _state = _ViewState.success),
                    ),
                  _ViewState.success => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SummaryCard(
                          title: 'Roberto Vasta',
                          body: 'Profilo owner collegato a 2 pet e pronto per la web app responsive.',
                          icon: Icons.verified_user_outlined,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const _InfoCard(
                          title: 'Contatti',
                          rows: [
                            _InfoRow(label: 'Email', value: 'roberto@example.com'),
                            _InfoRow(label: 'Phone', value: '+39 000 000 000'),
                            _InfoRow(label: 'Citta', value: 'Roma'),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _ToggleCard(
                          title: 'Tema serale',
                          body: 'Anteprima di una palette piu soft per l uso serale.',
                          value: _darkMode,
                          onChanged: (value) => setState(() => _darkMode = value),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        const _InfoCard(
                          title: 'Stato account',
                          rows: [
                            _InfoRow(label: 'Sessione', value: 'Attiva'),
                            _InfoRow(label: 'Privacy', value: 'Aggiornata'),
                            _InfoRow(label: 'Supporto', value: 'Disponibile'),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const _DebugCard(),
                      ],
                    ),
                },
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
    required this.onBack,
    required this.onOpenSettings,
    required this.onLogoutPreview,
  });

  final VoidCallback onBack;
  final VoidCallback onOpenSettings;
  final VoidCallback onLogoutPreview;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [
            TextButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Indietro'),
            ),
            OutlinedButton.icon(
              onPressed: onOpenSettings,
              icon: const Icon(Icons.settings_outlined, size: 18),
              label: const Text('Impostazioni'),
            ),
            FilledButton.tonalIcon(
              onPressed: onLogoutPreview,
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Logout'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        const _BrandPill(),
        const SizedBox(height: AppSpacing.lg),
        const Text('Profilo', style: AppTextStyles.heading),
        const SizedBox(height: AppSpacing.sm),
        const Text('Dati owner, preferenze e dettagli account in un unico posto per la web app responsive.', style: AppTextStyles.body),
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
          Icon(Icons.person_outline, size: 14, color: AppColors.accent),
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
        _Chip(label: 'Vuoto', selected: value == _ViewState.empty, onTap: () => onChanged(_ViewState.empty)),
        _Chip(label: 'Caricamento', selected: value == _ViewState.loading, onTap: () => onChanged(_ViewState.loading)),
        _Chip(label: 'Errore', selected: value == _ViewState.error, onTap: () => onChanged(_ViewState.error)),
        _Chip(label: 'Pronto', selected: value == _ViewState.success, onTap: () => onChanged(_ViewState.success)),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
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
      labelStyle: TextStyle(color: selected ? AppColors.onPrimary : AppColors.secondaryText, fontWeight: FontWeight.w700),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      side: const BorderSide(color: AppColors.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.pill)),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.label,
    required this.title,
    required this.body,
    required this.icon,
    required this.actionLabel,
    required this.onAction,
  });

  final String label;
  final String title;
  final String body;
  final IconData icon;
  final String actionLabel;
  final VoidCallback onAction;

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
          _AccentPill(label: label),
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
          SizedBox(width: double.infinity, child: FilledButton(onPressed: onAction, child: Text(actionLabel))),
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
          const _AccentPill(label: 'Caricamento'),
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
        style: const TextStyle(color: Color(0xFF315E55), fontSize: 12, fontWeight: FontWeight.w700),
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

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.rows,
  });

  final String title;
  final List<_InfoRow> rows;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.lg),
          ...rows.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                children: [
                  Expanded(child: Text(row.label, style: AppTextStyles.caption)),
                  Text(row.value, style: AppTextStyles.bodySmall.copyWith(color: AppColors.text)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

class _ToggleCard extends StatelessWidget {
  const _ToggleCard({
    required this.title,
    required this.body,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String body;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.title.copyWith(fontSize: 17)),
                const SizedBox(height: AppSpacing.xs),
                Text(body, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _DebugCard extends StatelessWidget {
  const _DebugCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prossimi step',
            style: TextStyle(color: AppColors.onPrimary, fontSize: 20, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Qui possiamo far evolvere consensi, preferenze e collegamento account senza cambiare il flusso web.',
            style: TextStyle(color: AppColors.onPrimary, fontSize: 14, height: 1.45),
          ),
        ],
      ),
    );
  }
}
