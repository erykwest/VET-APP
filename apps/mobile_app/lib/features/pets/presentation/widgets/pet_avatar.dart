import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_text_styles.dart';
import '../../data/pet_demo_store.dart';

class PetAvatar extends StatelessWidget {
  const PetAvatar({
    required this.label,
    required this.backgroundColor,
    super.key,
    this.size = 72,
  });

  final String label;
  final Color backgroundColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isPreset = _looksLikePresetKey(label);
    final preset = isPreset
        ? PetDemoStore.avatarChoiceForKey(label)
        : PetDemoStore.avatarChoices.first;
    final accentColor = isPreset ? preset.accentColor : backgroundColor;
    final gradient = _avatarGradient(backgroundColor, accentColor, isPreset);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.55)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1E163A35),
            blurRadius: 16,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -size * 0.18,
            top: -size * 0.16,
            child: Container(
              width: size * 0.74,
              height: size * 0.74,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -size * 0.18,
            bottom: -size * 0.12,
            child: Container(
              width: size * 0.52,
              height: size * 0.52,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: isPreset
                ? _PresetArtwork(
                    label: preset.label,
                    subtitle: preset.subtitle,
                    icon: preset.icon,
                    compact: size < 80,
                  )
                : _MonogramArtwork(
                    label: label,
                    accentColor: accentColor,
                  ),
          ),
          Positioned(
            right: 6,
            bottom: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPreset ? Icons.photo_rounded : Icons.pets_rounded,
                    size: 11,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isPreset ? 'demo' : 'id',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PetAvatarPicker extends StatelessWidget {
  const PetAvatarPicker({
    required this.selectedKey,
    required this.onSelected,
    super.key,
    this.title = 'Scegli un avatar demo',
    this.subtitle =
        'Nessun upload reale: seleziona un ritratto locale e lo ritroverai nella lista.',
    this.options = PetDemoStore.avatarChoices,
  });

  final String selectedKey;
  final ValueChanged<String> onSelected;
  final String title;
  final String subtitle;
  final List<PetAvatarChoice> options;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.title),
        const SizedBox(height: AppSpacing.xs),
        Text(subtitle, style: AppTextStyles.bodySmall),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            for (final option in options)
              PetAvatarChoiceTile(
                option: option,
                selected: option.key == selectedKey,
                onTap: () => onSelected(option.key),
              ),
          ],
        ),
      ],
    );
  }
}

class PetAvatarChoiceTile extends StatelessWidget {
  const PetAvatarChoiceTile({
    required this.option,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final PetAvatarChoice option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: 162,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected ? option.accentColor : AppColors.border,
              width: selected ? 1.8 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: selected
                    ? option.accentColor.withValues(alpha: 0.18)
                    : const Color(0x0F000000),
                blurRadius: selected ? 20 : 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PetAvatar(
                label: option.key,
                backgroundColor: option.backgroundColor,
                size: 96,
              ),
              const SizedBox(height: 12),
              Text(
                option.label,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                option.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.mutedText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PresetArtwork extends StatelessWidget {
  const _PresetArtwork({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.compact,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.82),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.onPrimary,
            fontSize: compact ? 12 : 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.1,
            shadows: const [
              Shadow(
                color: Color(0x44000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        if (!compact) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xECFFFFFF),
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}

class _MonogramArtwork extends StatelessWidget {
  const _MonogramArtwork({
    required this.label,
    required this.accentColor,
  });

  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final trimmed = label.trim();
    final monogram = trimmed.isEmpty
        ? '?'
        : String.fromCharCode(trimmed.runes.first).toUpperCase();

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.55),
            shape: BoxShape.circle,
          ),
        ),
        Text(
          monogram,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: accentColor,
          ),
        ),
      ],
    );
  }
}

bool _looksLikePresetKey(String label) {
  final trimmed = label.trim();
  return trimmed.startsWith('portrait-') ||
      trimmed.startsWith('photo-') ||
      trimmed.startsWith('avatar-');
}

List<Color> _avatarGradient(
  Color backgroundColor,
  Color accentColor,
  bool preset,
) {
  final white = Colors.white;
  final softBackground = Color.lerp(backgroundColor, white, preset ? 0.1 : 0.24)!;
  final strongAccent = Color.lerp(accentColor, const Color(0xFF163A35), 0.12)!;
  return [softBackground, strongAccent];
}
