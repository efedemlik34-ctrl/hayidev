import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _dark = true;
  bool get isDark => _dark;

  ThemeProvider() { _load(); }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    _dark = sp.getBool('dark') ?? true;
    notifyListeners();
  }

  Future<void> toggle() async {
    _dark = !_dark;
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('dark', _dark);
    notifyListeners();
  }

  ThemeData get theme => _dark ? _darkTheme() : _lightTheme();

  ThemeData _darkTheme() => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0A0E27),
    primaryColor: const Color(0xFFFFC107),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFFFC107),
      secondary: Color(0xFFFF6B35),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.white,
    ),
  );

  ThemeData _lightTheme() => ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFFFFC107),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFFFFC107),
      secondary: Color(0xFFFF6B35),
    ),
  );
}
