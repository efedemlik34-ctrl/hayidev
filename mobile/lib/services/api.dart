import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'local_db.dart';

class Api {
  // ⚠️ Bu IP'yi kendi bilgisayarinin IP'si ile degistir
  // ipconfig yazarak IPv4 adresini ogren
  static const String BASE_IP = "192.168.1.7";
  static const int BASE_PORT = 3000;
  static const String baseUrl = "http://$BASE_IP:$BASE_PORT/api";
  static const String socketUrl = "http://$BASE_IP:$BASE_PORT";

  static final Dio dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ));

  static String? _token;

  static Future<void> init() async {
    final sp = await SharedPreferences.getInstance();
    _token = sp.getString('token');
    if (_token != null) {
      dio.options.headers['Authorization'] = 'Bearer $_token';
    }
    dio.interceptors.add(InterceptorsWrapper(
      onError: (e, handler) {
        print('[API] ' + e.requestOptions.path + ' - ' + e.message);
        handler.next(e);
      },
    ));
  }

  static Future<void> setToken(String token) async {
    _token = token;
    dio.options.headers['Authorization'] = 'Bearer $token';
    final sp = await SharedPreferences.getInstance();
    await sp.setString('token', token);
  }

  static Future<void> clearToken() async {
    _token = null;
    dio.options.headers.remove('Authorization');
    final sp = await SharedPreferences.getInstance();
    await sp.remove('token');
  }

  static Future<dynamic> getWithCache(String path) async {
    final r = await dio.get(path);
    return r.data;
  }

  static Future<Map<String, dynamic>?> login(
      String username, String password) async {
    try {
      final r = await dio.post('/auth/login', data: {
        'username': username, 'password': password,
      });
      await setToken(r.data['token']);
      await LocalDB.setUser(r.data['user']);
      await LocalDB.setBalance(r.data['user']['balance'] ?? 0);
      return r.data['user'];
    } catch (e) {
      print('login: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> register(
      String username, String password) async {
    try {
      final r = await dio.post('/auth/register', data: {
        'username': username, 'password': password,
      });
      await setToken(r.data['token']);
      await LocalDB.setUser(r.data['user']);
      await LocalDB.setBalance(r.data['user']['balance'] ?? 0);
      return r.data['user'];
    } catch (e) {
      print('register: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> me() async {
    try {
      final r = await dio.get('/user/me');
      await LocalDB.setUser(r.data);
      await LocalDB.setBalance(r.data['balance'] ?? 0);
      return r.data;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> logout() async {
    await clearToken();
    await LocalDB.clear();
    return true;
  }
}
