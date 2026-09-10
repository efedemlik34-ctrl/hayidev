import 'package:flutter/material.dart';
import '../services/api.dart';
import 'login_screen.dart';

class SocialLoginScreen extends StatelessWidget {
  const SocialLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () {},
                child: const Text('Geri bildirim',
                  style: TextStyle(color: Colors.white54, decoration: TextDecoration.underline)),
              ),
            ),
            const Spacer(),
            // Logo
            Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)]),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF4CAF50).withOpacity(0.5), blurRadius: 30, spreadRadius: 4),
                ],
              ),
              child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('🤚', style: TextStyle(fontSize: 48)),
                Text('Hayi', style: TextStyle(color: Color(0xFFFFEB3B),
                  fontSize: 22, fontWeight: FontWeight.bold)),
              ])),
            ),
            const Spacer(),
            // Facebook
            SizedBox(width: double.infinity, height: 54,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1877F2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
                ),
                onPressed: () {},
                icon: const Icon(Icons.facebook, color: Colors.white, size: 26),
                label: const Text('Facebook', style: TextStyle(color: Colors.white,
                  fontSize: 16, fontWeight: FontWeight.bold)),
              )),
            const SizedBox(height: 12),
            // Google
            SizedBox(width: double.infinity, height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
                ),
                onPressed: () {},
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    width: 24, height: 24,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: const Center(child: Text('G', style: TextStyle(
                      color: Color(0xFF4285F4), fontWeight: FontWeight.bold, fontSize: 22))),
                  ),
                  const SizedBox(width: 12),
                  const Text('Google', style: TextStyle(color: Colors.black,
                    fontSize: 16, fontWeight: FontWeight.bold)),
                ]),
              )),
            const SizedBox(height: 24),
            // Alt ikonlar (email + snapchat)
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              GestureDetector(
                onTap: () => Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const LoginScreen())),
                child: Container(
                  width: 58, height: 58,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFB300), shape: BoxShape.circle),
                  child: const Icon(Icons.email, color: Colors.white, size: 28),
                ),
              ),
              const SizedBox(width: 24),
              Container(
                width: 58, height: 58,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEB3B), shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt, color: Colors.black, size: 28),
              ),
            ]),
            const SizedBox(height: 24),
            const Text('Giris yaparak Kullanim Sartlari ve Gizlilik Politikasi\'yi kabul etmis olursunuz.',
              style: TextStyle(color: Colors.white54, fontSize: 11),
              textAlign: TextAlign.center),
            const SizedBox(height: 12),
          ]),
        ),
      ),
    );
  }
}
