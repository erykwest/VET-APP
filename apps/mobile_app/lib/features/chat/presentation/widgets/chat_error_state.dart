import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_text_styles.dart';

class ChatErrorState extends StatelessWidget {
  const ChatErrorState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7E0D9),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.cloud_off_outlined,
                  color: Color(0xFF8B4E3D),
                  size: 34,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(title, style: AppTextStyles.title),
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onAction,
                  child: Text(actionLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
