import 'offline_cache.dart';
import 'socket.dart';
import 'socket.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Api {
  static const baseUrl = 'http://192.168.1.7:3000/api';
  static final dio = Dio(BaseOptions(baseUrl: baseUrl));
  static String? _token;
  static Future<void> init() async {
    final p = await SharedPreferences.getInstance();
    _token = p.getString('token');
    dio.interceptors.add(InterceptorsWrapper(onRequest: (o, h) {
      if (_token != null) o.headers['Authorization'] = 'Bearer $_token';
      h.next(o);
    }));
  }
  static bool hasToken() => _token != null;
  static Future<String?> getToken() async => _token;
  static Future<void> setToken(String t) async {
    _token = t;
    final p = await SharedPreferences.getInstance();
    await p.setString('token', t);
    try {
      SocketService.connect(t);
    } catch (_) {}
  }
  static Future<void> logout() async {
    _token = null;
    final p = await SharedPreferences.getInstance();
    await p.remove('token');
    try {
      SocketService.disconnect();
    } catch (_) {}
  }

  /// GET isteği — online ise backend, offline ise cache
  static Future<dynamic> getWithCache(String path) async {
    try {
      final r = await dio.get(path);
      // Cache'e kaydet
      try {
        await OfflineCache.save(path.replaceAll('/', '_'), r.data);
      } catch (_) {}
      return r.data;
    } catch (e) {
      // Cache'den oku
      try {
        final cached = OfflineCache.load(path.replaceAll('/', '_'));
        if (cached != null) return cached;
      } catch (_) {}
      rethrow;
    }
  }

}
