import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  late AnimationController _glowCtrl;
  late AnimationController _rotateCtrl;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..forward();
    _glowCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _rotateCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_done') ?? false;
    if (!onboardingDone) {
      Navigator.pushReplacementNamed(context, '/onboarding');
    } else if (Api.hasToken()) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    _glowCtrl.dispose();
    _rotateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: Stack(children: [
        AnimatedBuilder(
          animation: _rotateCtrl,
          builder: (_, __) => CustomPaint(
            size: MediaQuery.of(context).size,
            painter: _StarPainter(_rotateCtrl.value),
          ),
        ),
        Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          ScaleTransition(
            scale: CurvedAnimation(parent: _scaleCtrl, curve: Curves.elasticOut),
            child: AnimatedBuilder(
              animation: _glowCtrl,
              builder: (_, __) => Container(
                width: 140, height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [Color(0xFFFFC107), Color(0xFFFF6B35)]),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFC107).withOpacity(0.5 + _glowCtrl.value * 0.5),
                      blurRadius: 30 + _glowCtrl.value * 30,
                      spreadRadius: 5 + _glowCtrl.value * 10),
                  ],
                ),
                child: const Center(child: Text('H',
                  style: TextStyle(color: Colors.black, fontSize: 72, fontWeight: FontWeight.bold))),
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Text('Hayi',
            style: TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.bold, letterSpacing: -1)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFFFC107).withOpacity(0.5)),
              borderRadius: BorderRadius.circular(20)),
            child: const Text('SESLI SOHBET & OYUN',
              style: TextStyle(color: Color(0xFFFFC107), fontSize: 10, letterSpacing: 3, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 50),
          const SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              minHeight: 3,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation(Color(0xFFFFC107)),
            ),
          ),
        ])),
      ]),
    );
  }
}

class _StarPainter extends CustomPainter {
  final double t;
  _StarPainter(this.t);
  @override
  void paint(Canvas canvas, Size size) {
    final rand = math.Random(42);
    for (int i = 0; i < 60; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final opacity = (0.3 + 0.7 * ((math.sin(t * 2 * math.pi + i) + 1) / 2));
      canvas.drawCircle(Offset(x, y), 1.5 + (i % 3),
        Paint()..color = Colors.white.withOpacity(opacity * 0.6));
    }
  }
  @override
  bool shouldRepaint(_) => true;
}
