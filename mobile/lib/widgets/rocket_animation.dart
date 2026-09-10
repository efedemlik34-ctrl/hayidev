import 'dart:math' as math;
import 'package:flutter/material.dart';

class RocketAnimation extends StatefulWidget {
  final double multiplier;
  final bool crashed;
  final bool flying;
  const RocketAnimation({super.key, this.multiplier = 1.0, this.crashed = false, this.flying = false});
  @override
  State<RocketAnimation> createState() => _RocketAnimationState();
}

class _RocketAnimationState extends State<RocketAnimation> with TickerProviderStateMixin {
  late AnimationController _flyCtrl;
  late AnimationController _starCtrl;
  late AnimationController _particleCtrl;
  final rand = math.Random();

  @override
  void initState() {
    super.initState();
    _flyCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _starCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
    _particleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    if (widget.flying) { _flyCtrl.repeat(); _particleCtrl.repeat(); }
  }

  @override
  void didUpdateWidget(RocketAnimation old) {
    super.didUpdateWidget(old);
    if (widget.flying && !old.flying) { _flyCtrl.repeat(); _particleCtrl.repeat(); }
    else if (!widget.flying && old.flying) { _flyCtrl.stop(); _particleCtrl.stop(); }
  }

  @override
  void dispose() {
    _flyCtrl.dispose(); _starCtrl.dispose(); _particleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: MediaQuery.of(context).size,
      painter: _RocketPainter(_flyCtrl, _starCtrl, _particleCtrl, widget.crashed, widget.flying),
    );
  }
}

class _RocketPainter extends CustomPainter {
  final Animation<double> fly, star, particle;
  final bool crashed, flying;
  _RocketPainter(this.fly, this.star, this.particle, this.crashed, this.flying)
      : super(repaint: Listenable.merge([fly, star, particle]));

  @override
  void paint(Canvas canvas, Size size) {
    // Stars
    for (int i = 0; i < 80; i++) {
      final x = (i * 137.5 + star.value * 20 * (1 + i % 3)) % size.width;
      final y = (i * 73.3 + star.value * 15 * (1 + i % 2)) % size.height;
      final b = (0.3 + 0.7 * math.sin(star.value * 2 * math.pi + i)).clamp(0, 1);
      canvas.drawCircle(Offset(x, y), 1 + (i % 3), Paint()..color = Colors.white.withOpacity(b * 0.6));
    }

    if (flying || crashed) {
      final t = fly.value;
      final sx = 80.0;
      final sy = size.height * 0.8;
      final ex = sx + t * (size.width - 200);
      final ey = sy - t * (size.height * 0.6) - math.sin(t * math.pi) * 50;

      final path = Path()..moveTo(sx, sy);
      for (double p = 0; p <= t; p += 0.02) {
        path.lineTo(sx + p * (size.width - 200),
                    sy - p * (size.height * 0.6) - math.sin(p * math.pi) * 50);
      }
      canvas.drawPath(path, Paint()
        ..color = const Color(0xFFFFC107).withOpacity(0.3)
        ..style = PaintingStyle.stroke..strokeWidth = 20
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15));
      canvas.drawPath(path, Paint()
        ..shader = LinearGradient(colors: [
          const Color(0xFFFF6B35).withOpacity(0.2), const Color(0xFFFFC107),
        ], begin: Alignment.bottomLeft, end: Alignment.topRight)
          .createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.stroke..strokeWidth = 5..strokeCap = StrokeCap.round);

      // Rocket
      canvas.save();
      canvas.translate(ex, ey);
      canvas.rotate(-math.pi / 4);

      canvas.drawPath(Path()
        ..moveTo(0, -40)
        ..quadraticBezierTo(20, -20, 15, 20)
        ..lineTo(-15, 20)
        ..quadraticBezierTo(-20, -20, 0, -40)..close(),
        Paint()..shader = const LinearGradient(
          colors: [Colors.white, Color(0xFFE0E0E0)],
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(-20, -40, 40, 80)));

      canvas.drawPath(Path()
        ..moveTo(0, -40)
        ..quadraticBezierTo(10, -50, 0, -60)
        ..quadraticBezierTo(-10, -50, 0, -40)..close(),
        Paint()..color = const Color(0xFFE53935));

      canvas.drawCircle(const Offset(0, -10), 8, Paint()..color = const Color(0xFF4FC3F7));
      canvas.drawCircle(const Offset(0, -10), 8, Paint()
        ..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);

      if (flying && !crashed) {
        final flame = math.sin(particle.value * 2 * math.pi) * 10 + 30;
        canvas.drawPath(Path()
          ..moveTo(-12, 20)
          ..quadraticBezierTo(0, 20 + flame, 12, 20)
          ..quadraticBezierTo(0, 20 + flame * 0.5, -12, 20)..close(),
          Paint()..shader = const LinearGradient(
            colors: [Color(0xFFFFEB3B), Color(0xFFFF6B35), Color(0xFFE53935)],
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(-15, 20, 30, flame)));
      }
      canvas.restore();

      if (crashed) {
        for (int i = 0; i < 30; i++) {
          final angle = (i / 30) * 2 * math.pi;
          final dist = particle.value * 100 * (0.5 + rand.nextDouble() * 0.5);
          final r = (1 - particle.value) * 10;
          if (r > 0) {
            canvas.drawCircle(Offset(ex + math.cos(angle) * dist, ey + math.sin(angle) * dist),
              r, Paint()..color = [const Color(0xFFFF5722), const Color(0xFFFFC107), const Color(0xFFFF9800)][i % 3].withOpacity(1 - particle.value));
          }
        }
      }
    }
  }

  final rand = math.Random();
  @override
  bool shouldRepaint(_) => true;
}
