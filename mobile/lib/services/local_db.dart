import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalDB {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Map<String, dynamic> getUser() {
    final raw = _prefs.getString('user');
    if (raw == null) return {};
    return Map<String, dynamic>.from(jsonDecode(raw));
  }

  static Future<void> saveUser(Map<String, dynamic> u) async {
    await _prefs.setString('user', jsonEncode(u));
  }

  static int getBalance() {
    final u = getUser();
    return int.tryParse(u['balance']?.toString() ?? '0') ?? 0;
  }

  static Future<bool> changeBalance(int delta, String type) async {
    final u = getUser();
    final cur = int.tryParse(u['balance']?.toString() ?? '0') ?? 0;
    if (cur + delta < 0) return false;
    u['balance'] = cur + delta;
    await saveUser(u);
    return true;
  }

  static bool get isOffline => true;

  static Future<void> setBalance(int b) async {
    _balance = b;
    final sp = await SharedPreferences.getInstance();
    await sp.setInt('balance', b);
  }

}
