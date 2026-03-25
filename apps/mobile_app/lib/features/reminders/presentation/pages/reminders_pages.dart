import 'package:flutter/material.dart';

import '../../../../../design_system/tokens/app_colors.dart';
import '../../../../../design_system/tokens/app_radii.dart';
import '../../../../../design_system/tokens/app_spacing.dart';
import '../../../../../design_system/tokens/app_text_styles.dart';

enum _ViewState { empty, loading, error, success }

class RemindersListPage extends StatefulWidget {
  const RemindersListPage({super.key});

  @override
  State<RemindersListPage> createState() => _RemindersListPageState();
}

class _RemindersListPageState extends State<RemindersListPage> {
  _ViewState _state = _ViewState.success;

  @override
  Widget build(BuildContext context) {
    return _Shell(
      title: 'Reminders',
      subtitle: 'Vaccini, trattamenti e visite da tenere sotto controllo.',
      actionLabel: 'Create',
      onAction: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const ReminderCreatePage()),
      ),
      state: _state,
      onStateChanged: (value) => setState(() => _state = value),
      child: switch (_state) {
        _ViewState.empty => _StatePanel(
            label: 'No reminders',
            title: 'Your reminder list is empty.',
            body: 'Create the first vaccine or treatment reminder to stay on schedule.',
            icon: Icons.event_note_outlined,
            actionLabel: 'Create reminder',
            onAction: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ReminderCreatePage()),
            ),
          ),
        _ViewState.loading => const _LoadingPanel(
            title: 'Loading reminders',
            body: 'Reading due dates, repeat rules and owner notes.',
          ),
        _ViewState.error => _StatePanel(
            label: 'Sync error',
            title: 'Reminder sync failed.',
            body: 'The local preview is still available. Retry once the network is back.',
            icon: Icons.wifi_off_outlined,
            actionLabel: 'Retry',
            onAction: () {},
          ),
        _ViewState.success => const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SummaryCard(
                title: '5 active reminders',
                body: 'Next due in 3 days, 2 recurring tasks and 1 manual note.',
                icon: Icons.schedule_outlined,
              ),
              SizedBox(height: AppSpacing.lg),
              _ReminderTile(
                title: 'Antiparasitic treatment',
                subtitle: 'Every 30 days',
                due: 'Due in 3 days',
                badge: 'Priority',
              ),
              SizedBox(height: AppSpacing.sm),
              _ReminderTile(
                title: 'Annual vaccine',
                subtitle: 'Yearly recurrence',
                due: 'Due in 27 days',
                badge: 'Planned',
              ),
              SizedBox(height: AppSpacing.sm),
              _ReminderTile(
                title: 'Follow-up visit',
                subtitle: 'Manual reminder',
                due: 'Tomorrow 11:30',
                badge: 'Soon',
              ),
            ],
          ),
      },
    );
  }
}

class ReminderCreatePage extends StatefulWidget {
  const ReminderCreatePage({super.key});

  @override
  State<ReminderCreatePage> createState() => _ReminderCreatePageState();
}

class _ReminderCreatePageState extends State<ReminderCreatePage> {
  _ViewState _state = _ViewState.success;

  @override
  Widget build(BuildContext context) {
    return _Shell(
      title: 'Create reminder',
      subtitle: 'Add a new due date, recurrence and note.',
      actionLabel: 'Edit',
      onAction: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const ReminderEditPage()),
      ),
      state: _state,
      onStateChanged: (value) => setState(() => _state = value),
      child: switch (_state) {
        _ViewState.empty => _StatePanel(
            label: 'Draft',
            title: 'Start with a quick reminder draft.',
            body: 'We will capture title, date, recurrence and a short note.',
            icon: Icons.edit_calendar_outlined,
            actionLabel: 'Continue',
            onAction: () {},
          ),
        _ViewState.loading => const _LoadingPanel(
            title: 'Preparing form',
            body: 'Loading recurrence options and reminder defaults.',
          ),
        _ViewState.error => _StatePanel(
            label: 'Validation error',
            title: 'Some fields are missing.',
            body: 'Fill the title and due date before saving the reminder.',
            icon: Icons.rule_outlined,
            actionLabel: 'Fix fields',
            onAction: () {},
          ),
        _ViewState.success => const _FormPanel(
            title: 'New reminder',
            body: 'Title, date and recurrence are ready for saving.',
            items: [
              _FormItem(label: 'Title', value: 'Vaccination reminder'),
              _FormItem(label: 'Due date', value: '25 Apr 2026'),
              _FormItem(label: 'Recurrence', value: 'Every 12 months'),
              _FormItem(label: 'Note', value: 'Bring the health booklet'),
            ],
          ),
      },
    );
  }
}

class ReminderEditPage extends StatefulWidget {
  const ReminderEditPage({super.key});

  @override
  State<ReminderEditPage> createState() => _ReminderEditPageState();
}

class _ReminderEditPageState extends State<ReminderEditPage> {
  _ViewState _state = _ViewState.success;

  @override
  Widget build(BuildContext context) {
    return _Shell(
      title: 'Edit reminder',
      subtitle: 'Adjust recurrence, note and due date.',
      actionLabel: 'Back',
      onAction: () => Navigator.of(context).pop(),
      state: _state,
      onStateChanged: (value) => setState(() => _state = value),
      child: switch (_state) {
        _ViewState.empty => _StatePanel(
            label: 'Edit mode',
            title: 'Nothing selected to edit.',
            body: 'Choose a reminder from the list to update its date or note.',
            icon: Icons.tune_outlined,
            actionLabel: 'Back',
            onAction: () => Navigator.of(context).pop(),
          ),
        _ViewState.loading => const _LoadingPanel(
            title: 'Loading reminder',
            body: 'Reading repeat rules, local notes and alert settings.',
          ),
        _ViewState.error => _StatePanel(
            label: 'Save failed',
            title: 'The reminder update was not saved.',
            body: 'Try again after checking the due date and recurrence values.',
            icon: Icons.save_outlined,
            actionLabel: 'Retry save',
            onAction: () {},
          ),
        _ViewState.success => const _FormPanel(
            title: 'Edit reminder',
            body: 'All fields are prefilled and ready to save.',
            items: [
              _FormItem(label: 'Title', value: 'Antiparasitic treatment'),
              _FormItem(label: 'Due date', value: '28 Mar 2026'),
              _FormItem(label: 'Recurrence', value: 'Every 30 days'),
              _FormItem(label: 'Alert', value: 'Push notification'),
            ],
          ),
      },
    );
  }
}

class _Shell extends StatelessWidget {
  const _Shell({
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
              Color(0xFFF4F7EE),
              Color(0xFFEAF0DC),
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
          Icon(Icons.notifications_active_outlined, size: 14, color: AppColors.accent),
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

class _StatePanel extends StatelessWidget {
  const _StatePanel({
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
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return _Card(
      label: label,
      title: title,
      body: body,
      icon: icon,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return _Card(
      label: 'Loading',
      title: title,
      body: body,
      icon: Icons.hourglass_empty_outlined,
      actionLabel: 'Please wait',
      onAction: null,
      loading: true,
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.label,
    required this.title,
    required this.body,
    required this.icon,
    required this.actionLabel,
    required this.onAction,
    this.loading = false,
  });

  final String label;
  final String title;
  final String body;
  final IconData icon;
  final String actionLabel;
  final VoidCallback? onAction;
  final bool loading;

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
          if (loading) ...[
            const _Skeleton(width: double.infinity),
            const SizedBox(height: AppSpacing.sm),
            const _Skeleton(width: 180),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onAction,
                child: Text(actionLabel),
              ),
            ),
          ],
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

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({
    required this.title,
    required this.subtitle,
    required this.due,
    required this.badge,
  });

  final String title;
  final String subtitle;
  final String due;
  final String badge;

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
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.notifications_active_outlined, color: AppColors.primary),
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
                Text(due, style: AppTextStyles.caption),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          _Badge(label: badge),
        ],
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

class _FormPanel extends StatelessWidget {
  const _FormPanel({
    required this.title,
    required this.body,
    required this.items,
  });

  final String title;
  final String body;
  final List<_FormItem> items;

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
          Text(title, style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.sm),
          Text(body, style: AppTextStyles.bodySmall),
          const SizedBox(height: AppSpacing.xl),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _InputLike(label: item.label, value: item.value),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: FilledButton(onPressed: () {}, child: const Text('Save')),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton(onPressed: () {}, child: const Text('Cancel')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FormItem {
  const _FormItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

class _InputLike extends StatelessWidget {
  const _InputLike({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: AppTextStyles.bodySmall.copyWith(color: AppColors.text)),
        ],
      ),
    );
  }
}
