import 'package:flutter/material.dart';

import '../../design_system/tokens/app_colors.dart';
import '../../design_system/tokens/app_spacing.dart';
import '../shell/home_shell_page.dart';

class PreviewDashboardPage extends StatelessWidget {
  const PreviewDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        HomeShellPage(),
        Positioned(
          left: AppSpacing.lg,
          top: AppSpacing.lg,
          child: _PreviewDebugBadge(),
        ),
      ],
    );
  }
}

class _PreviewDebugBadge extends StatelessWidget {
  const _PreviewDebugBadge();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xE6163A35),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0x335FD6B3)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Preview Dashboard',
                style: TextStyle(
                  color: AppColors.onPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Mode: local preview data',
                style: TextStyle(
                  color: Color(0xFFD7E7E1),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Auth: bypassed',
                style: TextStyle(
                  color: Color(0xFFD7E7E1),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Route: /preview-dashboard',
                style: TextStyle(
                  color: Color(0xFFD7E7E1),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
