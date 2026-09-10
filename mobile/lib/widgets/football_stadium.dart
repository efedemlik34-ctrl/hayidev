import 'package:flutter/material.dart';

class FootballStadium extends StatelessWidget {
  const FootballStadium({super.key});
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.6,
      child: Container(
        decoration: BoxDecoration(
          gradient: const RadialGradient(
            colors: [Color(0xFF2E7D32), Color(0xFF1B5E20), Color(0xFF0D3011)],
            radius: 0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(children: [
          Positioned(top: 20, left: 20, right: 20, bottom: 20,
            child: Container(decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 2)))),
          Center(child: Container(width: 2, height: double.infinity,
            color: Colors.white.withOpacity(0.5))),
          Center(child: Container(
            width: 100, height: 100,
            decoration: BoxDecoration(shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 2)))),
          Positioned(top: 0, left: 0, right: 0,
            child: Container(height: 15, decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFFFFC107), Color(0xFFE53935), Color(0xFF2196F3)]),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16))))),
        ]),
      ),
    );
  }
}
