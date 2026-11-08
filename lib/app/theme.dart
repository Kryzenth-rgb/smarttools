import 'package:flutter/material.dart';

class AppColors {
  static const nightBlue = Color(0xFF101C35);
  static const primary = Color(0xFF2563EB);
  static const cyan = Color(0xFF22C1D6);
  static const lightGray = Color(0xFFF3F6FA);
  static const darkBackground = Color(0xFF0B1427);
}

final ValueNotifier<ThemeMode> themeModeNotifier =
    ValueNotifier<ThemeMode>(ThemeMode.system);

ThemeData buildTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: brightness,
  ).copyWith(
    primary: AppColors.primary,
    secondary: AppColors.cyan,
    surface: isDark ? AppColors.nightBlue : Colors.white,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor:
        isDark ? AppColors.darkBackground : AppColors.lightGray,
  );
}
