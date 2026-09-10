import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalDB {
  static Map<String, dynamic> _user = <String, dynamic>{};
  static int _balance = 0;

  static Map<String, dynamic> getUser() => _user;
  static int getBalance() => _balance;

  static Future<void> init() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final userStr = sp.getString('user');
      if (userStr != null && userStr.isNotEmpty) {
        final decoded = jsonDecode(userStr);
        if (decoded is Map) {
          _user = Map<String, dynamic>.from(decoded);
        }
      }
      _balance = sp.getInt('balance') ?? 0;
    } catch (_) {
      _user = <String, dynamic>{};
      _balance = 0;
    }
  }

  static Future<void> setUser(Map<String, dynamic> u) async {
    _user = u;
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setString('user', jsonEncode(u));
    } catch (_) {}
  }

  static Future<void> setBalance(int b) async {
    _balance = b;
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setInt('balance', b);
    } catch (_) {}
  }

  static Future<void> addBalance(int amount) async {
    _balance = _balance + amount;
    if (_balance < 0) _balance = 0;
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setInt('balance', _balance);
    } catch (_) {}
  }

  static Future<void> clear() async {
    _user = <String, dynamic>{};
    _balance = 0;
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.clear();
    } catch (_) {}
  }
}
