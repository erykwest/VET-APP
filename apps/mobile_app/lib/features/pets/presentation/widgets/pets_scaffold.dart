import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radii.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_text_styles.dart';

class PetsScaffold extends StatelessWidget {
  const PetsScaffold({
    required this.title,
    required this.body,
    super.key,
    this.subtitle,
    this.actions,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF4F8F5),
              Color(0xFFF8FBF8),
              Color(0xFFEAF2ED),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xxl,
              AppSpacing.lg,
              AppSpacing.xxl,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.pets, size: 14, color: AppColors.accent),
                          SizedBox(width: AppSpacing.sm),
                          Text(
                            'Pets',
                            style: TextStyle(
                              color: AppColors.onPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (actions != null) ...actions!,
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(title, style: AppTextStyles.display),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(subtitle!, style: AppTextStyles.body),
                ],
                const SizedBox(height: AppSpacing.xxl),
                Expanded(child: body),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RoundedSurface extends StatelessWidget {
  const RoundedSurface({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    this.backgroundColor = AppColors.surface,
    this.borderColor = AppColors.border,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color backgroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12163A35),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );
  }
}
