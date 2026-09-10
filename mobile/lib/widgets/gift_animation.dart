import 'dart:math' as math;
import 'package:flutter/material.dart';

class GiftAnimation extends StatefulWidget {
  final String emoji;
  final String senderName;
  final String giftName;
  final VoidCallback? onComplete;
  const GiftAnimation({super.key, required this.emoji, required this.senderName,
    required this.giftName, this.onComplete});
  @override
  State<GiftAnimation> createState() => _GiftAnimationState();
}

class _GiftAnimationState extends State<GiftAnimation> with TickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  late AnimationController _particleCtrl;
  late AnimationController _fadeCtrl;
  final rand = math.Random();
  late List<_Particle> particles;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _particleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    particles = List.generate(50, (_) => _Particle(
      x: rand.nextDouble(), y: rand.nextDouble(),
      dx: (rand.nextDouble() - 0.5) * 2, dy: -1 - rand.nextDouble() * 2,
      size: 4 + rand.nextDouble() * 8,
      color: [Colors.amber, Colors.orange, Colors.pink, Colors.purple][rand.nextInt(4)],
    ));

    _run();
  }

  Future<void> _run() async {
    await _scaleCtrl.forward();
    _particleCtrl.repeat();
    await Future.delayed(const Duration(milliseconds: 1600));
    await _fadeCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    widget.onComplete?.call();
  }

  @override
  void dispose() {
    _scaleCtrl.dispose(); _particleCtrl.dispose(); _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(child: AnimatedBuilder(
      animation: Listenable.merge([_scaleCtrl, _particleCtrl, _fadeCtrl]),
      builder: (_, __) {
        final scale = Curves.elasticOut.transform(_scaleCtrl.value);
        return Opacity(
          opacity: (1 - _fadeCtrl.value).clamp(0.0, 1.0),
          child: Stack(fit: StackFit.expand, children: [
            Container(color: Colors.black.withOpacity(0.5 * _scaleCtrl.value)),
            ...particles.map((p) {
              final t = _particleCtrl.value;
              return Positioned(
                left: p.x * MediaQuery.of(context).size.width + p.dx * t * 200,
                top: p.y * MediaQuery.of(context).size.height + p.dy * t * 400,
                child: Opacity(
                  opacity: (1 - t).clamp(0.0, 1.0),
                  child: Container(width: p.size, height: p.size,
                    decoration: BoxDecoration(color: p.color, shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: p.color, blurRadius: 8)])),
                ),
              );
            }),
            Center(child: Transform.scale(scale: 0.3 + scale * 0.9, child: Column(
              mainAxisSize: MainAxisSize.min, children: [
                Text(widget.emoji, style: const TextStyle(fontSize: 140)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFFFC107), Color(0xFFFF6B35)]),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.6), blurRadius: 20)]),
                  child: Column(children: [
                    Text(widget.senderName, style: const TextStyle(color: Colors.white,
                      fontSize: 16, fontWeight: FontWeight.bold)),
                    const Text('hediye gonderdi', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  ]),
                ),
                const SizedBox(height: 10),
                Text(widget.giftName, style: const TextStyle(color: Colors.white,
                  fontSize: 20, fontWeight: FontWeight.bold)),
              ]))),
          ]),
        );
      },
    ));
  }
}

class _Particle {
  final double x, y, dx, dy, size;
  final Color color;
  _Particle({required this.x, required this.y, required this.dx, required this.dy,
    required this.size, required this.color});
}
