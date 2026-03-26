import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radii.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_text_styles.dart';
import '../../../chat/presentation/pages/chat_conversations_page.dart';
import '../../../medical_records/presentation/pages/medical_records_pages.dart';
import '../../../reminders/presentation/pages/reminders_pages.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';

enum _HomeScenario { loading, empty, error, success }

class HomePlaceholderPage extends StatefulWidget {
  const HomePlaceholderPage({super.key});

  @override
  State<HomePlaceholderPage> createState() => _HomePlaceholderPageState();
}

class _HomePlaceholderPageState extends State<HomePlaceholderPage> {
  _HomeScenario _scenario = _HomeScenario.success;

  static const _ownerName = 'Roberto';
  static const _activePetName = 'Moka';

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ProfilePage()),
    );
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
    );
  }

  void _openChat() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ChatConversationsPage()),
    );
  }

  void _openRecords() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const MedicalRecordsListPage()),
    );
  }

  void _openReminders() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const RemindersListPage()),
    );
  }

  void _showComingSoon(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title in arrivo nella prossima release.')),
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
            colors: [
              Color(0xFFF5F9F7),
              Color(0xFFE8F2ED),
              Color(0xFFDCEBE3),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              const _GlowBackground(),
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.lg,
                  AppSpacing.xl,
                  AppSpacing.xxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TopBar(
                      scenario: _scenario,
                      onOpenProfile: _openProfile,
                      onOpenSettings: _openSettings,
                      onScenarioChanged: (value) {
                        setState(() {
                          _scenario = value;
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _scenarioContent(),
                    const SizedBox(height: AppSpacing.xl),
                    const _MetricsRow(),
                    const SizedBox(height: AppSpacing.xl),
                    Text('Cabina di regia', style: AppTextStyles.title.copyWith(fontSize: 18)),
                    const SizedBox(height: AppSpacing.md),
                    _ControlPanel(
                      ownerName: _ownerName,
                      activePetName: _activePetName,
                      onOpenChat: _openChat,
                      onOpenRecords: _openRecords,
                      onOpenReminders: _openReminders,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text('Pet attivo', style: AppTextStyles.title.copyWith(fontSize: 18)),
                    const SizedBox(height: AppSpacing.md),
                    _ActivePetCard(onTap: _openProfile),
                    const SizedBox(height: AppSpacing.xl),
                    Text('Prossima scadenza', style: AppTextStyles.title.copyWith(fontSize: 18)),
                    const SizedBox(height: AppSpacing.md),
                    const _ReminderCard(),
                    const SizedBox(height: AppSpacing.xl),
                    Text('Ultima chat e ultimo record', style: AppTextStyles.title.copyWith(fontSize: 18)),
                    const SizedBox(height: AppSpacing.md),
                    _PreviewRow(
                      onOpenChat: _openChat,
                      onOpenRecords: _openRecords,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text('Scorciatoie rapide', style: AppTextStyles.title.copyWith(fontSize: 18)),
                    const SizedBox(height: AppSpacing.md),
                    _ShortcutGrid(
                      onOpenProfile: _openProfile,
                      onOpenSettings: _openSettings,
                      onOpenChat: _openChat,
                      onOpenRecords: _openRecords,
                      onOpenReminders: _openReminders,
                      onShowComingSoon: _showComingSoon,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text('Stato generale', style: AppTextStyles.title.copyWith(fontSize: 18)),
                    const SizedBox(height: AppSpacing.md),
                    _buildStatusCard(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scenarioContent() {
    switch (_scenario) {
      case _HomeScenario.loading:
        return const _LoadingState();
      case _HomeScenario.empty:
        return const _EmptyState();
      case _HomeScenario.error:
        return _ErrorState(
          onRetry: () {
            setState(() {
              _scenario = _HomeScenario.loading;
            });
            Future<void>.delayed(const Duration(milliseconds: 900), () {
              if (!mounted) return;
              setState(() {
                _scenario = _HomeScenario.success;
              });
            });
          },
        );
      case _HomeScenario.success:
        return const _SuccessState();
    }
  }

  Widget _buildStatusCard() {
    switch (_scenario) {
      case _HomeScenario.loading:
        return const _StatusCard(
          title: 'Aggiornamento in corso',
          subtitle: 'Recupero il riepilogo del giorno.',
          icon: Icons.hourglass_top_rounded,
          accentColor: AppColors.accentSoft,
        );
      case _HomeScenario.empty:
        return const _StatusCard(
          title: 'Nessun pet attivo',
          subtitle: 'Crea il primo profilo per personalizzare la dashboard.',
          icon: Icons.pets_rounded,
          accentColor: AppColors.warmSurface,
        );
      case _HomeScenario.error:
        return const _StatusCard(
          title: 'Riepilogo non disponibile',
          subtitle: 'C e stato un problema nel recupero dei dati.',
          icon: Icons.cloud_off_rounded,
          accentColor: Color(0xFFF7DDD2),
        );
      case _HomeScenario.success:
        return const _StatusCard(
          title: 'Tutto sotto controllo',
          subtitle: 'Pet, reminder, chat e documenti sono pronti per la demo.',
          icon: Icons.check_circle_rounded,
          accentColor: AppColors.accentSoft,
        );
    }
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.scenario,
    required this.onOpenProfile,
    required this.onOpenSettings,
    required this.onScenarioChanged,
  });

  final _HomeScenario scenario;
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenSettings;
  final ValueChanged<_HomeScenario> onScenarioChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
              child: const Text(
                'VET APP',
                style: TextStyle(
                  color: AppColors.onPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Ciao, Roberto',
              style: AppTextStyles.display,
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              "La giornata del tuo pet, in un colpo d'occhio nella web app responsive.",
              style: AppTextStyles.body,
            ),
          ],
        ),
        const Spacer(),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          alignment: WrapAlignment.end,
          children: [
            TextButton.icon(
              onPressed: onOpenProfile,
              icon: const Icon(Icons.person_outline_rounded, size: 18),
              label: const Text('Profilo'),
            ),
            TextButton.icon(
              onPressed: onOpenSettings,
              icon: const Icon(Icons.settings_outlined, size: 18),
              label: const Text('Impostazioni'),
            ),
            PopupMenuButton<_HomeScenario>(
              initialValue: scenario,
              onSelected: onScenarioChanged,
              icon: const Icon(
                Icons.tune_rounded,
                color: AppColors.primary,
              ),
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: _HomeScenario.loading,
                  child: Text('Caricamento'),
                ),
                PopupMenuItem(
                  value: _HomeScenario.empty,
                  child: Text('Vuoto'),
                ),
                PopupMenuItem(
                  value: _HomeScenario.error,
                  child: Text('Errore'),
                ),
                PopupMenuItem(
                  value: _HomeScenario.success,
                  child: Text('Pronto'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _SuccessState extends StatelessWidget {
  const _SuccessState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14163A35),
            blurRadius: 26,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _PillChip(
                label: '1 pet attivo',
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
              ),
              _PillChip(
                label: '1 reminder imminente',
                backgroundColor: AppColors.warmSurface,
                foregroundColor: Color(0xFF7B4A2E),
              ),
              _PillChip(
                label: 'Chat pronta',
                backgroundColor: AppColors.accentSoft,
                foregroundColor: Color(0xFF315E55),
              ),
              _PillChip(
                label: 'Record disponibile',
                backgroundColor: Color(0xFFE7EEF8),
                foregroundColor: Color(0xFF355B78),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xl),
          Text('Moka e pronta per la giornata.', style: AppTextStyles.heading),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Hai gia il quadro chiaro: prossimo controllo, ultima chat utile e documento clinico recente in vista.',
            style: AppTextStyles.body,
          ),
        ],
      ),
    );
  }
}

class _ActivePetCard extends StatelessWidget {
  const _ActivePetCard({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.pets_rounded,
              color: AppColors.primary,
              size: 34,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Moka',
                  style: AppTextStyles.title,
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  'Cane meticcio, 4 anni, 17.8 kg',
                  style: AppTextStyles.bodySmall,
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  'Ultimo controllo: 12 giorni fa',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mutedText,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onTap,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}

class _MetricsRow extends StatelessWidget {
  const _MetricsRow();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        _MetricCard(
          label: 'Pet registrati',
          value: '1',
          hint: 'Moka attiva',
          backgroundColor: Color(0xFFE1F0EA),
          icon: Icons.pets_rounded,
        ),
        _MetricCard(
          label: 'Scadenze',
          value: '1',
          hint: 'Entro 3 giorni',
          backgroundColor: Color(0xFFF6EADF),
          icon: Icons.notifications_active_rounded,
        ),
        _MetricCard(
          label: 'Chat',
          value: '1',
          hint: 'Thread pronto',
          backgroundColor: Color(0xFFE7EEF8),
          icon: Icons.chat_bubble_rounded,
        ),
      ],
    );
  }
}

class _ControlPanel extends StatelessWidget {
  const _ControlPanel({
    required this.ownerName,
    required this.activePetName,
    required this.onOpenChat,
    required this.onOpenRecords,
    required this.onOpenReminders,
  });

  final String ownerName;
  final String activePetName;
  final VoidCallback onOpenChat;
  final VoidCallback onOpenRecords;
  final VoidCallback onOpenReminders;

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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.dashboard_rounded, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$ownerName x $activePetName', style: AppTextStyles.title),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Tutto quello che serve per la prova della web app in un solo punto.',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _ActionPill(
                label: 'Apri chat',
                icon: Icons.chat_bubble_outline_rounded,
                onTap: onOpenChat,
              ),
              _ActionPill(
                label: 'Apri record',
                icon: Icons.description_outlined,
                onTap: onOpenRecords,
              ),
              _ActionPill(
                label: 'Vedi reminder',
                icon: Icons.notifications_active_outlined,
                onTap: onOpenReminders,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard();

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
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.warmSurface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.notifications_active_outlined,
              color: Color(0xFF8B5B3E),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Antiparassitario', style: AppTextStyles.title),
                SizedBox(height: AppSpacing.xs),
                Text(
                  'Scade tra 3 giorni, da tenere allineato con il calendario.',
                  style: AppTextStyles.bodySmall,
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  'Promemoria attivo per Moka',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mutedText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const _Badge(label: 'Presto'),
        ],
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({
    required this.onOpenChat,
    required this.onOpenRecords,
  });

  final VoidCallback onOpenChat;
  final VoidCallback onOpenRecords;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sideBySide = constraints.maxWidth >= 420;
        final chatCard = _PreviewCard(
          title: 'Ultima chat',
          subtitle: 'Puoi dirmi se questo calo di appetito merita una visita?',
          meta: 'Risposta utile, tono rassicurante e contesto attivo',
          icon: Icons.chat_bubble_outline_rounded,
          onTap: onOpenChat,
        );
        final recordCard = _PreviewCard(
          title: 'Ultimo record',
          subtitle: 'Richiamo vaccinale di Moka',
          meta: '25 Mar 2026 - Clinica Vet Roma - pronto da condividere',
          icon: Icons.description_outlined,
          onTap: onOpenRecords,
        );

        if (sideBySide) {
          return Row(
            children: [
              Expanded(child: chatCard),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: recordCard),
            ],
          );
        }

        return Column(
          children: [
            chatCard,
            const SizedBox(height: AppSpacing.md),
            recordCard,
          ],
        );
      },
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String meta;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(title, style: AppTextStyles.title.copyWith(fontSize: 17)),
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(meta, style: AppTextStyles.caption),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.hint,
    required this.backgroundColor,
    required this.icon,
  });

  final String label;
  final String value;
  final String hint;
  final Color backgroundColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 22, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 2),
          Text(hint, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.pill),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
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

class _ShortcutGrid extends StatelessWidget {
  const _ShortcutGrid({
    required this.onOpenProfile,
    required this.onOpenSettings,
    required this.onOpenChat,
    required this.onOpenRecords,
    required this.onOpenReminders,
    required this.onShowComingSoon,
  });

  final VoidCallback onOpenProfile;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenChat;
  final VoidCallback onOpenRecords;
  final VoidCallback onOpenReminders;
  final ValueChanged<String> onShowComingSoon;

  @override
  Widget build(BuildContext context) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: 0.95,
      ),
      children: [
        _ShortcutTile(
          icon: Icons.person_outline_rounded,
          label: 'Profilo',
          caption: 'Apri',
          onTap: onOpenProfile,
        ),
        _ShortcutTile(
          icon: Icons.chat_bubble_outline_rounded,
          label: 'Chat',
          caption: 'Apri',
          onTap: onOpenChat,
        ),
        _ShortcutTile(
          icon: Icons.description_outlined,
          label: 'Record',
          caption: 'Apri',
          onTap: onOpenRecords,
        ),
        _ShortcutTile(
          icon: Icons.notifications_active_outlined,
          label: 'Reminder',
          caption: 'Apri',
          onTap: onOpenReminders,
        ),
        _ShortcutTile(
          icon: Icons.settings_outlined,
          label: 'Impostazioni',
          caption: 'Preferenze',
          onTap: onOpenSettings,
        ),
        _ShortcutTile(
          icon: Icons.medical_services_outlined,
          label: 'Clinica',
          caption: 'In arrivo',
          onTap: () => onShowComingSoon('Clinica'),
        ),
      ],
    );
  }
}

class _ShortcutTile extends StatelessWidget {
  const _ShortcutTile({
    required this.icon,
    required this.label,
    required this.caption,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String caption;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 26,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                caption,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.title,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const _StatePanel(
      icon: Icons.hourglass_top_rounded,
      title: 'Sto preparando la dashboard',
      subtitle: 'Recupero i dati del pet, dei reminder e dei documenti.',
      child: _SkeletonBlock(),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const _StatePanel(
      icon: Icons.pets_rounded,
      title: 'Nessun pet attivo',
      subtitle: 'Crea il primo profilo per sbloccare la dashboard completa.',
      child: _EmptyActions(),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _StatePanel(
      icon: Icons.cloud_off_rounded,
      title: 'Non riesco a caricare i dati',
      subtitle: 'Controlla la connessione o riprova tra poco.',
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onRetry,
          child: const Text('Riprova'),
        ),
      ),
    );
  }
}

class _StatePanel extends StatelessWidget {
  const _StatePanel({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10163A35),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(title, style: AppTextStyles.heading),
          const SizedBox(height: AppSpacing.sm),
          Text(subtitle, style: AppTextStyles.body),
          const SizedBox(height: AppSpacing.xl),
          child,
        ],
      ),
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _SkeletonLine(widthFactor: 1),
        SizedBox(height: AppSpacing.sm),
        _SkeletonLine(widthFactor: 0.88),
        SizedBox(height: AppSpacing.sm),
        _SkeletonLine(widthFactor: 0.72),
      ],
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({required this.widthFactor});

  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        child: Container(
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.border.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}

class _EmptyActions extends StatelessWidget {
  const _EmptyActions();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            child: const Text('Crea il primo pet'),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {},
            child: const Text('Scopri come funziona'),
          ),
        ),
      ],
    );
  }
}

class _PillChip extends StatelessWidget {
  const _PillChip({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          height: 1.2,
          fontWeight: FontWeight.w700,
          color: foregroundColor,
        ),
      ),
    );
  }
}

class _GlowBackground extends StatelessWidget {
  const _GlowBackground();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              left: -90,
              top: -50,
              child: _GlowCircle(
                size: 220,
                color: AppColors.accent.withValues(alpha: 0.18),
              ),
            ),
            Positioned(
              right: -70,
              top: 160,
              child: _GlowCircle(
                size: 180,
                color: AppColors.accentSoft.withValues(alpha: 0.28),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
