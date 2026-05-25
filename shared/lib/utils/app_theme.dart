import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  const AppColors({
    required this.primary,
    required this.onPrimary,
    required this.memberBubble,
    required this.trainerBubble,
    required this.primaryLight,
  });

  final Color primary;
  final Color onPrimary;
  final Color memberBubble;
  final Color trainerBubble;
  final Color primaryLight;

  static const success = Color(0xFF12B76A);
  static const warning = Color(0xFFF79009);
  static const error = Color(0xFFD92D20);
  static const neutral50 = Color(0xFFF8FAFC);
  static const neutral100 = Color(0xFFF1F5F9);
  static const neutral200 = Color(0xFFE2E8F0);
  static const neutral500 = Color(0xFF64748B);
  static const neutral700 = Color(0xFF334155);
  static const neutral900 = Color(0xFF0F172A);

  static AppColors guru = const AppColors(
    primary: Color(0xFF1769E0),
    onPrimary: Colors.white,
    memberBubble: Color(0xFF1769E0),
    trainerBubble: Color(0xFFE50914),
    primaryLight: Color(0xFFE8F1FD),
  );

  static AppColors trainer = const AppColors(
    primary: Color(0xFFE50914),
    onPrimary: Colors.white,
    memberBubble: Color(0xFF1769E0),
    trainerBubble: Color(0xFFE50914),
    primaryLight: Color(0xFFFEECEC),
  );
}

ThemeData buildAppTheme(AppColors colors) {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: colors.primary,
      onPrimary: colors.onPrimary,
      surface: Colors.white,
      surfaceContainerHighest: AppColors.neutral100,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.neutral50,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.neutral900,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.neutral900,
        letterSpacing: -0.3,
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.neutral900,
        letterSpacing: -0.5,
        height: 1.2,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.neutral900,
        letterSpacing: -0.3,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.neutral900,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: AppColors.neutral700, height: 1.5),
      bodyMedium: TextStyle(fontSize: 14, color: AppColors.neutral500, height: 1.45),
      labelLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.neutral900,
        letterSpacing: -0.2,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.zero,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.primary,
        side: BorderSide(color: colors.primary.withValues(alpha: 0.4)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: AppColors.neutral500),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.neutral200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.neutral200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.neutral200, thickness: 1),
  );
}
