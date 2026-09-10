import 'package:flutter/material.dart';

class LudoScreen extends StatefulWidget {
  const LudoScreen({super.key});
  @override
  State<LudoScreen> createState() => _LudoScreenState();
}

class _LudoScreenState extends State<LudoScreen> {
  int dice = 0;

  Widget _corner(Color c) => Container(
    width: 110, height: 110,
    decoration: BoxDecoration(color: c.withOpacity(0.2), border: Border.all(color: c, width: 2)),
    child: Center(child: Container(width: 70, height: 70, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: c, width: 2)),
      child: Center(child: Wrap(spacing: 4, runSpacing: 4, children: List.generate(4, (i) => Container(width: 14, height: 14, decoration: BoxDecoration(color: c, shape: BoxShape.circle))))))),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(title: const Text('Ludo'), backgroundColor: Colors.transparent),
      body: Column(children: [
        Expanded(child: Center(child: AspectRatio(aspectRatio: 1, child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFFC107), width: 4)),
          child: Stack(children: [
            Positioned(top: 0, left: 0, child: _corner(Colors.red)),
            Positioned(top: 0, right: 0, child: _corner(Colors.green)),
            Positioned(bottom: 0, right: 0, child: _corner(Colors.yellow)),
            Positioned(bottom: 0, left: 0, child: _corner(Colors.blue)),
            Center(child: Container(width: 100, height: 100, decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFFFC107), Color(0xFFFF6B35)])), child: const Center(child: Text('🏠', style: TextStyle(fontSize: 40))))),
          ]),
        )))),
        Padding(padding: const EdgeInsets.all(20), child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFC107), padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
          onPressed: () => setState(() => dice = 1 + (DateTime.now().millisecondsSinceEpoch % 6)),
          child: Text(dice == 0 ? '🎲 ZAR AT' : '🎲 $dice', style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
        )),
      ]),
    );
  }
}
