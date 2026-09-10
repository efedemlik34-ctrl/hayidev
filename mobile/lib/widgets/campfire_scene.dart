import 'dart:math' as math;
import 'package:flutter/material.dart';

class CampfireScene extends StatefulWidget {
  final double height;
  const CampfireScene({super.key, this.height = 180});
  @override
  State<CampfireScene> createState() => _CampfireSceneState();
}

class _CampfireSceneState extends State<CampfireScene> with TickerProviderStateMixin {
  late AnimationController _fireCtrl;
  late AnimationController _sparkCtrl;
  final rand = math.Random();
  late List<_Spark> sparks;

  @override
  void initState() {
    super.initState();
    _fireCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
    _sparkCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    sparks = List.generate(20, (_) => _Spark(
      x: rand.nextDouble(),
      speed: 0.5 + rand.nextDouble() * 1.2,
      size: 2 + rand.nextDouble() * 5,
      hue: rand.nextDouble(),
    ));
  }

  @override
  void dispose() { _fireCtrl.dispose(); _sparkCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Stack(children: [
        // Arka plan - gun batimi gradient
        Positioned.fill(child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Colors.transparent, Color(0xFF1A0A05), Color(0xFF0A0505)],
            ),
          ),
        )),
        // Ay isigi
        Positioned(right: 40, top: 20, child: Container(
          width: 60, height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)]),
            boxShadow: [BoxShadow(color: const Color(0xFFFFECB3).withOpacity(0.6), blurRadius: 40, spreadRadius: 4)],
          ),
        )),
        // Zemin
        Positioned.fill(child: Container(
          margin: EdgeInsets.only(top: widget.height * 0.55),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Color(0xFF2A1810), Color(0xFF0A0505)],
            ),
          ),
        )),
        // Ates
        Positioned(bottom: 0, left: 0, right: 0, child: AnimatedBuilder(
          animation: _fireCtrl,
          builder: (_, __) => CustomPaint(
            size: Size(double.infinity, widget.height * 0.6),
            painter: _FirePainter(_fireCtrl.value),
          ),
        )),
        // Parcaciklar
        Positioned.fill(child: AnimatedBuilder(
          animation: _sparkCtrl,
          builder: (_, __) => Stack(children: sparks.map((s) {
            final t = (_sparkCtrl.value * s.speed) % 1.0;
            final x = s.x * 300 + 40;
            final y = (1 - t) * (widget.height * 0.7);
            return Positioned(
              left: x, bottom: y,
              child: Opacity(
                opacity: (1 - t).clamp(0.0, 1.0),
                child: Container(
                  width: s.size, height: s.size,
                  decoration: BoxDecoration(
                    color: Color.lerp(const Color(0xFFFF6B00), const Color(0xFFFFEB3B), s.hue),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Color.lerp(const Color(0xFFFF6B00), const Color(0xFFFFEB3B), s.hue)!, blurRadius: 10)],
                  ),
                ),
              ),
            );
          }).toList()),
        )),
      ]),
    );
  }
}

class _FirePainter extends CustomPainter {
  final double t;
  _FirePainter(this.t);
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final baseY = size.height;
    // 3 katmanli ates
    for (int layer = 0; layer < 3; layer++) {
      final scale = 1.0 - layer * 0.2;
      final h = (80 + t * 20) * scale;
      final w = (40 + layer * 15) * scale;
      final colors = [
        [const Color(0xFFFF6B00), const Color(0xFFFFCC00), Colors.transparent],
        [const Color(0xFFFF4500), const Color(0xFFFF8C00), Colors.transparent],
        [const Color(0xFFFFEB3B), const Color(0xFFFFEB3B), Colors.transparent],
      ][layer];
      final path = Path()
        ..moveTo(cx - w / 2, baseY)
        ..quadraticBezierTo(cx - w * 0.3, baseY - h * 0.5, cx, baseY - h)
        ..quadraticBezierTo(cx + w * 0.3, baseY - h * 0.5, cx + w / 2, baseY)
        ..close();
      final paint = Paint()..shader = RadialGradient(
        center: Alignment.bottomCenter, radius: 1.2,
        colors: [colors[0], colors[1], colors[2]],
        stops: const [0, 0.6, 1],
      ).createShader(Rect.fromLTWH(cx - w / 2, baseY - h, w, h));
      canvas.drawPath(path, paint);
    }
    // Odunlar
    final logPaint = Paint()..color = const Color(0xFF3E2723);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, baseY - 8), width: 90, height: 20), const Radius.circular(4)), logPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx - 15, baseY - 4), width: 90, height: 20), const Radius.circular(4)), logPaint);
    // Kor
    for (int i = 0; i < 12; i++) {
      final angle = (i / 12) * math.pi * 2;
      final r = 30 + t * 10;
      canvas.drawCircle(
        Offset(cx + math.cos(angle) * r, baseY - 20 + math.sin(angle) * 5),
        2, Paint()..color = const Color(0xFFFF6B00).withOpacity(0.8));
    }
  }
  @override
  bool shouldRepaint(_) => true;
}

class _Spark {
  final double x, speed, size, hue;
  _Spark({required this.x, required this.speed, required this.size, required this.hue});
}
