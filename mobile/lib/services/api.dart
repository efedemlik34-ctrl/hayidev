import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Api {
  static const baseUrl = 'http://10.0.2.2:3000/api';
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
  static Future<void> setToken(String t) async {
    _token = t;
    final p = await SharedPreferences.getInstance();
    await p.setString('token', t);
  }
  static Future<void> logout() async {
    _token = null;
    final p = await SharedPreferences.getInstance();
    await p.remove('token');
  }
}
