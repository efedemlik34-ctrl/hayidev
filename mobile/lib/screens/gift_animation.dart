import 'dart:math' as math;
import 'package:flutter/material.dart';

class GiftAnimation extends StatefulWidget {
  final Map<String, dynamic> gift;
  final String senderName;
  final int quantity;
  const GiftAnimation({
    super.key,
    required this.gift,
    this.senderName = 'Sen',
    this.quantity = 1,
  });
  @override
  State<GiftAnimation> createState() => _GiftAnimationState();
}

class _GiftAnimationState extends State<GiftAnimation>
    with TickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  late AnimationController _particleCtrl;
  late AnimationController _fadeCtrl;
  final rand = math.Random();
  late List<_P> particles;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _particleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500));
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

    particles = List.generate(40, (_) => _P(
      x: rand.nextDouble(), y: rand.nextDouble() * 0.5 + 0.3,
      dx: (rand.nextDouble() - 0.5) * 2,
      dy: -1 - rand.nextDouble() * 2,
      size: 4 + rand.nextDouble() * 8,
      color: [Colors.amber, Colors.orange, Colors.pink, Colors.purple, Colors.red][rand.nextInt(5)],
    ));

    _scaleCtrl.forward();
    _particleCtrl.repeat();
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) _fadeCtrl.forward();
    });
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    _particleCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final icon = widget.gift['icon'] ?? '🎁';
    final name = widget.gift['name'] ?? 'Hediye';
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleCtrl, _particleCtrl, _fadeCtrl]),
      builder: (_, __) {
        final scale = Curves.elasticOut.transform(_scaleCtrl.value);
        final opacity = (1 - _fadeCtrl.value).clamp(0.0, 1.0);
        return Opacity(
          opacity: opacity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ...particles.map((p) {
                final t = _particleCtrl.value;
                return Positioned(
                  left: MediaQuery.of(context).size.width * p.x + p.dx * t * 200,
                  top: MediaQuery.of(context).size.height * p.y + p.dy * t * 400,
                  child: Opacity(
                    opacity: (1 - t).clamp(0.0, 1.0),
                    child: Transform.rotate(
                      angle: t * math.pi * 4,
                      child: Container(
                        width: p.size, height: p.size,
                        decoration: BoxDecoration(
                          color: p.color, shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: p.color, blurRadius: 10)],
                        ),
                      ),
                    ),
                  ),
                );
              }),
              Transform.scale(
                scale: scale,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  ShaderMask(
                    shaderCallback: (r) => const LinearGradient(
                      colors: [Color(0xFFFFC107), Color(0xFFFF6B35), Color(0xFFFFC107)],
                    ).createShader(r),
                    child: Text(icon, style: const TextStyle(fontSize: 140)),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFFFC107), Color(0xFFFF6B35)]),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.6), blurRadius: 20)],
                    ),
                    child: Column(children: [
                      Text(widget.senderName,
                        style: const TextStyle(color: Colors.black,
                          fontSize: 14, fontWeight: FontWeight.bold)),
                      Text('$name${widget.quantity > 1 ? ' x${widget.quantity}' : ''}',
                        style: const TextStyle(color: Colors.white,
                          fontSize: 13, fontWeight: FontWeight.bold)),
                    ]),
                  ),
                ]),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _P {
  final double x, y, dx, dy, size;
  final Color color;
  _P({required this.x, required this.y, required this.dx, required this.dy,
    required this.size, required this.color});
}
