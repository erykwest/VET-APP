import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radii.dart';

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
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadii.large),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: size * 0.42,
            fontWeight: FontWeight.w800,
            color: AppColors.text,
          ),
        ),
      ),
    );
  }
}
