import 'package:flutter/material.dart';

class AppColors {
  static const Color bgDark = Color(0xFF0A0E27);
  static const Color bgCard = Color(0xFF1A0F3E);
  static const Color bgCard2 = Color(0xFF0F0A2E);
  static const Color gold = Color(0xFFFFC107);
  static const Color goldDark = Color(0xFFFF8C00);
  static const Color orange = Color(0xFFFF6B35);
  static const Color purple = Color(0xFF9C27B0);
  static const Color purpleDark = Color(0xFF6A1B9A);
  static const Color deepPurple = Color(0xFF4A148C);
  static const Color red = Color(0xFFF44336);
  static const Color green = Color(0xFF4CAF50);
  static const Color blue = Color(0xFF2196F3);
  static const Color pink = Color(0xFFE91E63);
  static const Color cyan = Color(0xFF00BCD4);

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gold, goldDark, orange],
  );

  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purpleDark, deepPurple],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [bgCard, bgCard2],
  );
}

class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

class AppTheme {
  static ThemeData dark() => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bgDark,
    primaryColor: AppColors.gold,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.gold,
      secondary: AppColors.orange,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.white,
      centerTitle: true,
    ),
  );
}
