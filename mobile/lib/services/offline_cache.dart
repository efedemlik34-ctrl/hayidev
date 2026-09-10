import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineCache {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> save(String key, dynamic data) async {
    try {
      await _prefs.setString('cache_$key', jsonEncode(data));
      await _prefs.setInt('cache_${key}_ts', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Cache save error: $e');
    }
  }

  static dynamic load(String key) {
    try {
      final raw = _prefs.getString('cache_$key');
      if (raw == null) return null;
      return jsonDecode(raw);
    } catch (e) {
      return null;
    }
  }

  static DateTime? lastUpdated(String key) {
    final ts = _prefs.getInt('cache_${key}_ts');
    if (ts == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ts);
  }

  static Future<void> clear(String key) async {
    await _prefs.remove('cache_$key');
    await _prefs.remove('cache_${key}_ts');
  }

  static Future<void> clearAll() async {
    final keys = _prefs.getKeys().where((k) => k.startsWith('cache_')).toList();
    for (final k in keys) {
      await _prefs.remove(k);
    }
  }

  static bool has(String key) => _prefs.containsKey('cache_$key');
}
