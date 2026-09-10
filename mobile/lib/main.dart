import 'package:flutter/material.dart';
import 'services/api.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Api.init();
  runApp(const HayiDevApp());
}

class HayiDevApp extends StatelessWidget {
  const HayiDevApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HayiDev',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0E27),
        primaryColor: const Color(0xFFFFC107),
      ),
      initialRoute: Api.hasToken() ? '/home' : '/',
      routes: {
        '/': (_) => const LoginScreen(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}
