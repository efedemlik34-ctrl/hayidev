import 'package:flutter/material.dart';

class CarromBoard extends StatelessWidget {
  final VoidCallback? onTap;
  const CarromBoard({super.key, this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            gradient: const RadialGradient(
              colors: [Color(0xFFE8C99B), Color(0xFFC99D6A), Color(0xFF8B6914)],
              center: Alignment.center, radius: 0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF4E342E), width: 20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 30, spreadRadius: 4)],
          ),
          child: Stack(children: [
            Positioned(top: 20, left: 20, child: _pocket()),
            Positioned(top: 20, right: 20, child: _pocket()),
            Positioned(bottom: 20, left: 20, child: _pocket()),
            Positioned(bottom: 20, right: 20, child: _pocket()),
            Center(child: Container(
              width: 34, height: 34,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [Color(0xFFE53935), Color(0xFF8B0000)])),
            )),
            ..._buildRing(12, 65, false),
            ..._buildRing(8, 105, true),
          ]),
        ),
      ),
    );
  }

  List<Widget> _buildRing(int count, double radius, bool isBlack) {
    return List.generate(count, (i) => Positioned(
      left: 180 + radius * (i % 3 - 1) * 0.6,
      top: 180 + radius * (i % 5 - 2) * 0.4,
      child: Container(
        width: 24, height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isBlack
            ? const RadialGradient(colors: [Color(0xFF424242), Color(0xFF000000)])
            : const RadialGradient(colors: [Colors.white, Color(0xFFBDBDBD)]),
          border: Border.all(color: Colors.black.withOpacity(0.3), width: 1.5)),
      ),
    ));
  }

  Widget _pocket() => Container(
    width: 46, height: 46,
    decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
  );
}
