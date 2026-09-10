import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFFFFC107);
  static const Color accent = Color(0xFFFF6B35);
  static const Color darkBg = Color(0xFF0A0E27);
  static const Color darkCard = Color(0xFF1A0F3E);
  static const Color lightBg = Color(0xFFF5F5F7);
  static const Color lightCard = Colors.white;

  static ThemeData dark() => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBg,
    colorScheme: const ColorScheme.dark(
      primary: primary, secondary: accent,
      surface: darkCard, background: darkBg),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent, elevation: 0,
      foregroundColor: Colors.white),
    cardColor: darkCard,
    dialogBackgroundColor: darkCard,
    dividerColor: Colors.white12,
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: darkCard, contentTextStyle: TextStyle(color: Colors.white)),
  );

  static ThemeData light() => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBg,
    colorScheme: const ColorScheme.light(
      primary: primary, secondary: accent,
      surface: lightCard, background: lightBg),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent, elevation: 0,
      foregroundColor: Colors.black),
    cardColor: lightCard,
    dialogBackgroundColor: lightCard,
    dividerColor: Colors.black12,
  );
}
