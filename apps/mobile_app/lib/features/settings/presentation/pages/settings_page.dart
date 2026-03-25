import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radii.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_text_styles.dart';
import '../../../profile/presentation/pages/profile_page.dart';

enum _ViewState { empty, loading, error, success }

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  _ViewState _state = _ViewState.success;
  bool _notifications = true;
  bool _analytics = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8FBF8), Color(0xFFF4F7F1), Color(0xFFE8EFE5)],
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
                const _Header(),
                const SizedBox(height: AppSpacing.lg),
                _StateChips(value: _state, onChanged: (value) => setState(() => _state = value)),
                const SizedBox(height: AppSpacing.lg),
                switch (_state) {
                  _ViewState.empty => _StateCard(
                      label: 'Preferences',
                      title: 'No preferences configured yet.',
                      body: 'Start from profile, theme and notification settings.',
                      icon: Icons.tune_outlined,
                      actionLabel: 'Open profile',
                      onAction: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(builder: (_) => const ProfilePage()),
                      ),
                      footer: const _LogoutPreview(),
                    ),
                  _ViewState.loading => const _LoadingCard(
                      title: 'Loading preferences',
                      body: 'Fetching theme, language and account flags.',
                    ),
                  _ViewState.error => _StateCard(
                      label: 'Settings error',
                      title: 'Preferences could not be loaded.',
                      body: 'Retry after checking your connection or continue with defaults.',
                      icon: Icons.sync_problem_outlined,
                      actionLabel: 'Retry',
                      onAction: () => setState(() => _state = _ViewState.success),
                      footer: const _LogoutPreview(),
                    ),
                  _ViewState.success => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _StateCard(
                          label: 'Account',
                          title: 'Profile and preferences',
                          body: 'Update the owner profile, theme and alert behavior.',
                          icon: Icons.person_outline,
                          actionLabel: 'Open profile',
                          onAction: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(builder: (_) => const ProfilePage()),
                          ),
                          footer: const _LogoutPreview(),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _ToggleCard(
                          title: 'Push notifications',
                          body: 'Receive due date and reminder alerts.',
                          value: _notifications,
                          onChanged: (value) => setState(() => _notifications = value),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _ToggleCard(
                          title: 'Analytics',
                          body: 'Share anonymized usage to improve the app.',
                          value: _analytics,
                          onChanged: (value) => setState(() => _analytics = value),
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
  const _Header();

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
              Text('Settings', style: AppTextStyles.heading),
              const SizedBox(height: AppSpacing.sm),
              Text('Preferences, account controls and debug space.', style: AppTextStyles.body),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        FilledButton(onPressed: () {}, child: const Text('Logout')),
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
          Icon(Icons.settings_outlined, size: 14, color: AppColors.accent),
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
        _Chip(label: 'Empty', selected: value == _ViewState.empty, onTap: () => onChanged(_ViewState.empty)),
        _Chip(label: 'Loading', selected: value == _ViewState.loading, onTap: () => onChanged(_ViewState.loading)),
        _Chip(label: 'Error', selected: value == _ViewState.error, onTap: () => onChanged(_ViewState.error)),
        _Chip(label: 'Success', selected: value == _ViewState.success, onTap: () => onChanged(_ViewState.success)),
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
    required this.footer,
  });

  final String label;
  final String title;
  final String body;
  final IconData icon;
  final String actionLabel;
  final VoidCallback? onAction;
  final Widget footer;

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
          SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: onAction, child: Text(actionLabel)),
          ),
          const SizedBox(height: AppSpacing.lg),
          footer,
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
        style: const TextStyle(color: Color(0xFF315E55), fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
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
            'Debug area',
            style: TextStyle(color: AppColors.onPrimary, fontSize: 20, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Version info, local flags and future diagnostics go here.',
            style: TextStyle(color: AppColors.onPrimary, fontSize: 14, height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _LogoutPreview extends StatelessWidget {
  const _LogoutPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.logout_outlined, color: AppColors.secondaryText),
          const SizedBox(width: AppSpacing.sm),
          Text('Logout action preview', style: AppTextStyles.bodySmall.copyWith(color: AppColors.text)),
        ],
      ),
    );
  }
}
