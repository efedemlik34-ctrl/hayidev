import 'package:flutter/material.dart';
import '../services/api.dart';

class UmoScreen extends StatefulWidget {
  const UmoScreen({super.key});
  @override
  State<UmoScreen> createState() => _UmoScreenState();
}

class _UmoScreenState extends State<UmoScreen> {
  int _bet = 500;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0033),
      appBar: AppBar(title: const Text('UMO'), backgroundColor: Colors.transparent),
      body: Column(children: [
        const SizedBox(height: 20),
        const Text('UNO Kart Oyunu', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Expanded(child: Center(child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Container(width: 70, height: 100, decoration: BoxDecoration(color: const Color(0xFFE53935), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white, width: 3)), child: const Center(child: Text('7', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)))),
          Container(width: 70, height: 100, decoration: BoxDecoration(color: const Color(0xFF43A047), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white, width: 3)), child: const Center(child: Text('5', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)))),
        ]))),
        Padding(padding: const EdgeInsets.all(16), child: Row(children: [
          for (final b in [100, 500, 1000, 5000]) GestureDetector(
            onTap: () => setState(() => _bet = b),
            child: Container(margin: const EdgeInsets.symmetric(horizontal: 4), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: _bet == b ? const Color(0xFFFFC107) : Colors.white10, borderRadius: BorderRadius.circular(16)), child: Text('$b', style: TextStyle(color: _bet == b ? Colors.black : Colors.white, fontWeight: FontWeight.bold))),
          ),
        ])),
      ]),
    );
  }
}
