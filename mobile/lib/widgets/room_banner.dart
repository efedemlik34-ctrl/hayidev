import 'dart:math' as math;
import 'package:flutter/material.dart';

class RoomBanner extends StatefulWidget {
  final VoidCallback? onTap;
  const RoomBanner({super.key, this.onTap});
  @override
  State<RoomBanner> createState() => _RoomBannerState();
}

class _RoomBannerState extends State<RoomBanner> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        height: 70,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF4A148C), Color(0xFF6A1B9A), Color(0xFF8E24AA), Color(0xFF4A148C)]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFD700), width: 2),
          boxShadow: [
            BoxShadow(color: const Color(0xFF8E24AA).withOpacity(0.6), blurRadius: 16, spreadRadius: 2),
          ],
        ),
        child: Stack(children: [
          // Donen isik
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => Positioned(
              left: -100 + _ctrl.value * 500,
              top: 0, bottom: 0,
              child: Transform.rotate(
                angle: -0.3,
                child: Container(
                  width: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Colors.white.withOpacity(0), Colors.white.withOpacity(0.4), Colors.white.withOpacity(0)]),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(children: [
              const Text('⭐', style: TextStyle(fontSize: 30)),
              const SizedBox(width: 8),
              const Expanded(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('öldü sayın', style: TextStyle(color: Colors.white,
                    fontSize: 13, fontWeight: FontWeight.bold)),
                  Text('ready Pro\'da 20000', style: TextStyle(color: Color(0xFFFFEB3B),
                    fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              )),
              // Turuncu meyve ikonu
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  gradient: const RadialGradient(colors: [Color(0xFFFF9800), Color(0xFFE65100)]),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: const Color(0xFFFF9800).withOpacity(0.7), blurRadius: 14)],
                ),
                child: const Center(child: Text('🍊', style: TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFFC107), Color(0xFFFF8A00)]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text('Gidip oyna', style: TextStyle(color: Colors.black,
                  fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
