import 'package:flutter/material.dart';

import 'app_theme.dart';

class AppDecorations {
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: AppColors.neutral900.withValues(alpha: 0.06),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: AppColors.neutral900.withValues(alpha: 0.03),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  static BoxDecoration surfaceCard({Color? borderColor}) => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor ?? AppColors.neutral200.withValues(alpha: 0.8),
        ),
        boxShadow: cardShadow,
      );

  static LinearGradient headerGradient(Color primary) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          primary,
          Color.lerp(primary, Colors.black, 0.15)!,
        ],
      );
}
