import 'package:flutter/material.dart';

class CarromScreen extends StatelessWidget {
  const CarromScreen({super.key});

  Widget _hole() => Container(width: 32, height: 32, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0F0A),
      appBar: AppBar(title: const Text('Carrom'), backgroundColor: Colors.transparent),
      body: Column(children: [
        const SizedBox(height: 20),
        Expanded(child: Center(child: AspectRatio(aspectRatio: 1, child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFFD2A679), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF4E342E), width: 14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20)]),
          child: Stack(children: [
            Positioned(top: 12, left: 12, child: _hole()),
            Positioned(top: 12, right: 12, child: _hole()),
            Positioned(bottom: 12, left: 12, child: _hole()),
            Positioned(bottom: 12, right: 12, child: _hole()),
            Center(child: Container(width: 30, height: 30, decoration: BoxDecoration(color: Colors.red.shade700, shape: BoxShape.circle, border: Border.all(color: Colors.black, width: 2)))),
            ...List.generate(18, (i) => Positioned(
              left: 100.0 + (i % 6) * 30, top: 100.0 + (i ~/ 6) * 60,
              child: Container(width: 22, height: 22, decoration: BoxDecoration(color: i % 5 == 0 ? Colors.red : Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.black, width: 1.5))),
            )),
          ]),
        )))),
        Padding(padding: const EdgeInsets.all(16), child: Row(children: [
          Expanded(child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), padding: const EdgeInsets.symmetric(vertical: 14)), child: const Text('NISAN AL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
          const SizedBox(width: 12),
          Expanded(child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B35), padding: const EdgeInsets.symmetric(vertical: 14)), child: const Text('VUR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
        ])),
      ]),
    );
  }
}
