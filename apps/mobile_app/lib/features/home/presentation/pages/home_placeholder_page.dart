import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radii.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_text_styles.dart';

enum _HomeScenario { loading, empty, error, success }

class HomePlaceholderPage extends StatefulWidget {
  const HomePlaceholderPage({super.key});

  @override
  State<HomePlaceholderPage> createState() => _HomePlaceholderPageState();
}

class _HomePlaceholderPageState extends State<HomePlaceholderPage> {
  _HomeScenario _scenario = _HomeScenario.success;

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
                      onScenarioChanged: (value) {
                        setState(() {
                          _scenario = value;
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _scenarioContent(),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'Scorciatoie rapide',
                      style: AppTextStyles.title.copyWith(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const _ShortcutGrid(),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'Stato generale',
                      style: AppTextStyles.title.copyWith(
                        fontSize: 18,
                      ),
                    ),
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
          subtitle: 'C\'e stato un problema nel recupero dei dati locali.',
          icon: Icons.cloud_off_rounded,
          accentColor: Color(0xFFF7DDD2),
        );
      case _HomeScenario.success:
        return const _StatusCard(
          title: 'Tutto sotto controllo',
          subtitle: "Reminder, documenti e chat sono pronti per l'uso.",
          icon: Icons.check_circle_rounded,
          accentColor: AppColors.accentSoft,
        );
    }
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.scenario,
    required this.onScenarioChanged,
  });

  final _HomeScenario scenario;
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
              "La giornata del tuo pet, in un colpo d'occhio.",
              style: AppTextStyles.body,
            ),
          ],
        ),
        const Spacer(),
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
              child: Text('Loading'),
            ),
            PopupMenuItem(
              value: _HomeScenario.empty,
              child: Text('Empty'),
            ),
            PopupMenuItem(
              value: _HomeScenario.error,
              child: Text('Error'),
            ),
            PopupMenuItem(
              value: _HomeScenario.success,
              child: Text('Success'),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _HeroCard(),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            Text(
              'Pet attivo',
              style: AppTextStyles.title.copyWith(fontSize: 18),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {},
              child: const Text('Cambia'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        const _ActivePetCard(),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              const _PillChip(
                label: 'Chat pronta',
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
              ),
              const _PillChip(
                label: '2 documenti nuovi',
                backgroundColor: AppColors.warmSurface,
                foregroundColor: Color(0xFF7B4A2E),
              ),
              const _PillChip(
                label: '1 reminder oggi',
                backgroundColor: AppColors.accentSoft,
                foregroundColor: Color(0xFF315E55),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const Text(
            'Oggi il tuo pet ha 3 azioni importanti.',
            style: AppTextStyles.heading,
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Controlla i reminder, aggiorna i documenti recenti e apri la chat se hai un dubbio.',
            style: AppTextStyles.body,
          ),
        ],
      ),
    );
  }
}

class _ActivePetCard extends StatelessWidget {
  const _ActivePetCard();

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
                  'Gatto europeo, 3 anni, 4.6 kg',
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
            onPressed: () {},
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}

class _ShortcutGrid extends StatelessWidget {
  const _ShortcutGrid();

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
      children: const [
        _ShortcutTile(
          icon: Icons.chat_bubble_rounded,
          label: 'Chat',
          caption: 'Apri',
        ),
        _ShortcutTile(
          icon: Icons.description_rounded,
          label: 'Documenti',
          caption: 'Archivi',
        ),
        _ShortcutTile(
          icon: Icons.notifications_active_rounded,
          label: 'Reminder',
          caption: 'Scadenze',
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
  });

  final IconData icon;
  final String label;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.9),
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
    return Column(
      children: const [
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
