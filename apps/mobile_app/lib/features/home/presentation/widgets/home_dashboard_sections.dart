import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radii.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_text_styles.dart';

class WarmClinicalDashboardHero extends StatelessWidget {
  const WarmClinicalDashboardHero({
    super.key,
    required this.petName,
    required this.petDetails,
    required this.healthLabel,
    required this.healthDescription,
    required this.petPortrait,
    this.primaryActionLabel,
    this.secondaryActionLabel,
    this.onPrimaryAction,
    this.onSecondaryAction,
    this.accentColor = AppColors.primary,
  });

  final String petName;
  final String petDetails;
  final String healthLabel;
  final String healthDescription;
  final Widget petPortrait;
  final String? primaryActionLabel;
  final String? secondaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final VoidCallback? onSecondaryAction;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return WarmClinicalSectionCard(
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          const Positioned.fill(child: _HeroWash()),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 680;
                final content = <Widget>[
                  Expanded(
                    flex: isCompact ? 0 : 5,
                    child: _HeroCopy(
                      petName: petName,
                      petDetails: petDetails,
                      healthLabel: healthLabel,
                      healthDescription: healthDescription,
                      accentColor: accentColor,
                      primaryActionLabel: primaryActionLabel,
                      secondaryActionLabel: secondaryActionLabel,
                      onPrimaryAction: onPrimaryAction,
                      onSecondaryAction: onSecondaryAction,
                    ),
                  ),
                  if (!isCompact) const SizedBox(width: AppSpacing.xl),
                  Flexible(
                    flex: 4,
                    child: Align(
                      alignment: Alignment.center,
                      child: _PortraitFrame(child: petPortrait),
                    ),
                  ),
                ];

                if (isCompact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeroCopy(
                        petName: petName,
                        petDetails: petDetails,
                        healthLabel: healthLabel,
                        healthDescription: healthDescription,
                        accentColor: accentColor,
                        primaryActionLabel: primaryActionLabel,
                        secondaryActionLabel: secondaryActionLabel,
                        onPrimaryAction: onPrimaryAction,
                        onSecondaryAction: onSecondaryAction,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _PortraitFrame(child: petPortrait),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: content,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class WarmClinicalAiPanel extends StatelessWidget {
  const WarmClinicalAiPanel({
    super.key,
    required this.title,
    required this.prompt,
    required this.suggestions,
    this.onPromptTap,
    this.onSuggestionTap,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.trailing,
    this.accentColor = AppColors.primary,
  });

  final String title;
  final String prompt;
  final List<WarmClinicalAiSuggestion> suggestions;
  final ValueChanged<String>? onPromptTap;
  final ValueChanged<String>? onSuggestionTap;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final Widget? trailing;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return WarmClinicalSectionCard(
      title: title,
      trailing: trailing,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WarmClinicalPromptBubble(
            text: prompt,
            accentColor: accentColor,
            onTap: onPromptTap == null ? null : () => onPromptTap!(prompt),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: suggestions
                .map(
                  (suggestion) => WarmClinicalActionChip(
                    label: suggestion.label,
                    icon: suggestion.icon,
                    onTap: onSuggestionTap == null
                        ? null
                        : () => onSuggestionTap!(suggestion.label),
                  ),
                )
                .toList(),
          ),
          if (primaryActionLabel != null || onPrimaryAction != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Align(
              alignment: Alignment.centerRight,
              child: WarmClinicalPillButton(
                label: primaryActionLabel ?? 'Continue',
                accentColor: accentColor,
                onPressed: onPrimaryAction,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class WarmClinicalReminderSection extends StatelessWidget {
  const WarmClinicalReminderSection({
    super.key,
    required this.title,
    required this.items,
    this.onItemTap,
    this.footerLabel,
    this.onFooterTap,
    this.accentColor = AppColors.primary,
  });

  final String title;
  final List<WarmClinicalReminderItem> items;
  final ValueChanged<WarmClinicalReminderItem>? onItemTap;
  final String? footerLabel;
  final VoidCallback? onFooterTap;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return WarmClinicalSectionCard(
      title: title,
      footerLabel: footerLabel,
      onFooterTap: onFooterTap,
      child: Column(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            WarmClinicalListTile(
              icon: items[index].icon,
              iconColor: items[index].iconColor ?? accentColor,
              title: items[index].title,
              subtitle: items[index].subtitle,
              trailing: items[index].trailing,
              onTap: onItemTap == null ? null : () => onItemTap!(items[index]),
            ),
            if (index != items.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class WarmClinicalDocumentSection extends StatelessWidget {
  const WarmClinicalDocumentSection({
    super.key,
    required this.title,
    required this.items,
    this.onItemTap,
    this.footerLabel,
    this.onFooterTap,
    this.accentColor = AppColors.primary,
  });

  final String title;
  final List<WarmClinicalDocumentItem> items;
  final ValueChanged<WarmClinicalDocumentItem>? onItemTap;
  final String? footerLabel;
  final VoidCallback? onFooterTap;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return WarmClinicalSectionCard(
      title: title,
      footerLabel: footerLabel,
      onFooterTap: onFooterTap,
      child: Column(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            WarmClinicalListTile(
              icon: items[index].icon,
              iconColor: items[index].iconColor ?? accentColor,
              title: items[index].title,
              subtitle: items[index].subtitle,
              trailing: items[index].trailing,
              onTap: onItemTap == null ? null : () => onItemTap!(items[index]),
            ),
            if (index != items.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class WarmClinicalActivitySection extends StatelessWidget {
  const WarmClinicalActivitySection({
    super.key,
    required this.title,
    required this.items,
    this.onItemTap,
    this.footerLabel,
    this.onFooterTap,
    this.accentColor = AppColors.primary,
  });

  final String title;
  final List<WarmClinicalActivityItem> items;
  final ValueChanged<WarmClinicalActivityItem>? onItemTap;
  final String? footerLabel;
  final VoidCallback? onFooterTap;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return WarmClinicalSectionCard(
      title: title,
      footerLabel: footerLabel,
      onFooterTap: onFooterTap,
      child: Column(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            WarmClinicalTimelineTile(
              date: items[index].date,
              title: items[index].title,
              subtitle: items[index].subtitle,
              accentColor: items[index].accentColor ?? accentColor,
              onTap: onItemTap == null ? null : () => onItemTap!(items[index]),
            ),
            if (index != items.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class WarmClinicalSectionCard extends StatelessWidget {
  const WarmClinicalSectionCard({
    super.key,
    this.title,
    this.subtitle,
    this.trailing,
    this.footerLabel,
    this.onFooterTap,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.child,
  });

  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final String? footerLabel;
  final VoidCallback? onFooterTap;
  final EdgeInsetsGeometry padding;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 28,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null || subtitle != null || trailing != null)
                _SectionHeader(
                  title: title,
                  subtitle: subtitle,
                  trailing: trailing,
                ),
              if (title != null || subtitle != null || trailing != null)
                const SizedBox(height: AppSpacing.md),
              if (child != null) child!,
              if (footerLabel != null) ...[
                const SizedBox(height: AppSpacing.md),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: onFooterTap,
                    icon: const Icon(Icons.chevron_right_rounded, size: 18),
                    label: Text(footerLabel!),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      textStyle: AppTextStyles.button,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class WarmClinicalActionRow extends StatelessWidget {
  const WarmClinicalActionRow({
    super.key,
    required this.actions,
  });

  final List<WarmClinicalActionButton> actions;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: actions
          .map(
            (action) => WarmClinicalActionButtonWidget(
              label: action.label,
              icon: action.icon,
              accentColor: action.accentColor,
              onPressed: action.onPressed,
            ),
          )
          .toList(),
    );
  }
}

class WarmClinicalStatusBadge extends StatelessWidget {
  const WarmClinicalStatusBadge({
    super.key,
    required this.label,
    this.icon,
    this.backgroundColor = AppColors.accentSoft,
    this.foregroundColor = AppColors.primaryStrong,
  });

  final String label;
  final IconData? icon;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: foregroundColor),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: foregroundColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WarmClinicalMetricPill extends StatelessWidget {
  const WarmClinicalMetricPill({
    super.key,
    required this.label,
    required this.value,
    this.accentColor = AppColors.primary,
  });

  final String label;
  final String value;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: accentColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class WarmClinicalPromptBubble extends StatelessWidget {
  const WarmClinicalPromptBubble({
    super.key,
    required this.text,
    this.onTap,
    this.accentColor = AppColors.primary,
  });

  final String text;
  final VoidCallback? onTap;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final bubble = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadii.large),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: Icon(
              Icons.spa_rounded,
              size: 18,
              color: accentColor,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return bubble;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.large),
      child: bubble,
    );
  }
}

class WarmClinicalActionChip extends StatelessWidget {
  const WarmClinicalActionChip({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: icon == null
          ? null
          : Icon(
              icon,
              size: 18,
              color: AppColors.primary,
            ),
      label: Text(label),
      onPressed: onTap,
      backgroundColor: AppColors.surfaceElevated,
      side: const BorderSide(color: AppColors.border),
      labelStyle: AppTextStyles.bodySmall.copyWith(
        color: AppColors.text,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
    );
  }
}

class WarmClinicalAiSuggestion {
  const WarmClinicalAiSuggestion({
    required this.label,
    this.icon,
  });

  final String label;
  final IconData? icon;
}

class WarmClinicalPillButton extends StatelessWidget {
  const WarmClinicalPillButton({
    super.key,
    required this.label,
    this.onPressed,
    this.accentColor = AppColors.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: accentColor,
        foregroundColor: AppColors.onPrimary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        textStyle: AppTextStyles.button,
      ),
      child: Text(label),
    );
  }
}

class WarmClinicalActionButtonWidget extends StatelessWidget {
  const WarmClinicalActionButtonWidget({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.accentColor = AppColors.primary,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon ?? Icons.arrow_forward_rounded, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: accentColor,
        side: const BorderSide(color: AppColors.border),
        backgroundColor: AppColors.surfaceElevated,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        textStyle: AppTextStyles.button,
      ),
    );
  }
}

class WarmClinicalReminderItem {
  const WarmClinicalReminderItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.trailing,
    this.iconColor,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? trailing;
  final Color? iconColor;
}

class WarmClinicalDocumentItem {
  const WarmClinicalDocumentItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.trailing,
    this.iconColor,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? trailing;
  final Color? iconColor;
}

class WarmClinicalActivityItem {
  const WarmClinicalActivityItem({
    required this.date,
    required this.title,
    required this.subtitle,
    this.accentColor,
  });

  final String date;
  final String title;
  final String subtitle;
  final Color? accentColor;
}

class WarmClinicalActionButton {
  const WarmClinicalActionButton({
    required this.label,
    this.icon,
    this.onPressed,
    this.accentColor = AppColors.primary,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color accentColor;
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final String? title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null)
                Text(
                  title!,
                  style: AppTextStyles.title,
                ),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle!,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class WarmClinicalListTile extends StatelessWidget {
  const WarmClinicalListTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor = AppColors.primary,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadii.medium),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
          if (onTap != null && trailing == null)
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.mutedText,
            ),
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.large),
      child: content,
    );
  }
}

class WarmClinicalTimelineTile extends StatelessWidget {
  const WarmClinicalTimelineTile({
    super.key,
    required this.date,
    required this.title,
    required this.subtitle,
    this.accentColor = AppColors.primary,
    this.onTap,
  });

  final String date;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tile = Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              date,
              style: AppTextStyles.caption.copyWith(
                color: accentColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          if (onTap != null)
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.mutedText,
            ),
        ],
      ),
    );

    if (onTap == null) {
      return tile;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.large),
      child: tile,
    );
  }
}

class _PortraitFrame extends StatelessWidget {
  const _PortraitFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 180),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceElevated,
            AppColors.accentSoft.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        child: child,
      ),
    );
  }
}

class _HeroWash extends StatelessWidget {
  const _HeroWash();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.background,
            AppColors.surface,
            AppColors.accentSoft.withValues(alpha: 0.8),
          ],
        ),
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({
    required this.petName,
    required this.petDetails,
    required this.healthLabel,
    required this.healthDescription,
    required this.accentColor,
    required this.primaryActionLabel,
    required this.secondaryActionLabel,
    required this.onPrimaryAction,
    required this.onSecondaryAction,
  });

  final String petName;
  final String petDetails;
  final String healthLabel;
  final String healthDescription;
  final Color accentColor;
  final String? primaryActionLabel;
  final String? secondaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          petName,
          style: AppTextStyles.display,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          petDetails,
          style: AppTextStyles.body.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        WarmClinicalStatusBadge(
          label: healthLabel,
          icon: Icons.favorite_rounded,
          backgroundColor: accentColor.withValues(alpha: 0.12),
          foregroundColor: accentColor,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          healthDescription,
          style: AppTextStyles.body,
        ),
        if (primaryActionLabel != null || secondaryActionLabel != null) ...[
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              if (primaryActionLabel != null)
                WarmClinicalPillButton(
                  label: primaryActionLabel!,
                  accentColor: accentColor,
                  onPressed: onPrimaryAction,
                ),
              if (secondaryActionLabel != null)
                WarmClinicalActionButtonWidget(
                  label: secondaryActionLabel!,
                  icon: Icons.chat_bubble_outline_rounded,
                  onPressed: onSecondaryAction,
                  accentColor: accentColor,
                ),
            ],
          ),
        ],
      ],
    );
  }
}
