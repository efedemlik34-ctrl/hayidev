import 'dart:math' as math;
import 'package:flutter/material.dart';

class LevelUpOverlay extends StatefulWidget {
  final int oldLevel, newLevel;
  final VoidCallback onComplete;
  const LevelUpOverlay({super.key, required this.oldLevel, required this.newLevel,
    required this.onComplete});
  @override
  State<LevelUpOverlay> createState() => _LevelUpOverlayState();
}

class _LevelUpOverlayState extends State<LevelUpOverlay> with TickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  late AnimationController _burstCtrl;
  late AnimationController _fadeCtrl;
  final rand = math.Random();
  late List<_Conf> confetti;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _burstCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    confetti = List.generate(80, (_) => _Conf(
      x: rand.nextDouble(), y: -0.3 - rand.nextDouble() * 0.3,
      dx: (rand.nextDouble() - 0.5) * 0.3, speed: 0.5 + rand.nextDouble() * 0.5,
      size: 8 + rand.nextDouble() * 10,
      color: [Colors.amber, Colors.orange, Colors.pink, Colors.purple, Colors.blue, Colors.green][rand.nextInt(6)],
      rot: rand.nextDouble() * math.pi * 2,
    ));

    _run();
  }

  Future<void> _run() async {
    _burstCtrl.repeat();
    await _scaleCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 1800));
    await _fadeCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    widget.onComplete();
  }

  @override
  void dispose() {
    _scaleCtrl.dispose(); _burstCtrl.dispose(); _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(color: Colors.transparent, child: AnimatedBuilder(
      animation: Listenable.merge([_scaleCtrl, _burstCtrl, _fadeCtrl]),
      builder: (_, __) => Opacity(
        opacity: (1 - _fadeCtrl.value).clamp(0.0, 1.0),
        child: Stack(fit: StackFit.expand, children: [
          Container(color: Colors.black.withOpacity(0.75 * _scaleCtrl.value)),
          ...confetti.map((c) {
            final t = _burstCtrl.value * c.speed;
            return Positioned(
              left: c.x * MediaQuery.of(context).size.width + c.dx * t * 300,
              top: (c.y + t) * MediaQuery.of(context).size.height,
              child: Transform.rotate(angle: c.rot + t * math.pi * 4,
                child: Container(width: c.size, height: c.size * 1.5,
                  decoration: BoxDecoration(color: c.color, borderRadius: BorderRadius.circular(2)))),
            );
          }),
          Center(child: Transform.scale(
            scale: Curves.elasticOut.transform(_scaleCtrl.value),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              ShaderMask(
                shaderCallback: (r) => const LinearGradient(
                  colors: [Color(0xFFFFC107), Color(0xFFFF6B35), Color(0xFFFFC107)]).createShader(r),
                child: const Text('SEVIYE ATLADIN!', style: TextStyle(color: Colors.white,
                  fontSize: 30, fontWeight: FontWeight.bold))),
              const SizedBox(height: 20),
              Container(
                width: 170, height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(colors: [Color(0xFFFFC107), Color(0xFFFF6B35)]),
                  boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.7), blurRadius: 60, spreadRadius: 10)]),
                child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('SEVIYE', style: TextStyle(color: Colors.black,
                    fontSize: 14, fontWeight: FontWeight.bold)),
                  Text('${widget.newLevel}', style: const TextStyle(color: Colors.black,
                    fontSize: 72, fontWeight: FontWeight.bold, height: 1)),
                ]))),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFFFFC107))),
                child: Text('${widget.oldLevel}  →  ${widget.newLevel}',
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))),
            ]))),
        ]),
      ),
    ));
  }
}

class _Conf {
  final double x, y, dx, speed, size, rot;
  final Color color;
  _Conf({required this.x, required this.y, required this.dx, required this.speed,
    required this.size, required this.color, required this.rot});
}
