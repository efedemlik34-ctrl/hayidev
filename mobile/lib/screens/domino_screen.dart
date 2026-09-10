import 'package:flutter/material.dart';

class DominoScreen extends StatefulWidget {
  const DominoScreen({super.key});
  @override
  State<DominoScreen> createState() => _DominoScreenState();
}

class _DominoScreenState extends State<DominoScreen> {
  final List<List<int>> board = [[3,5],[5,2],[2,6],[6,1]];
  final List<List<int>> hand = [[1,4],[4,4],[2,2],[0,3],[6,6]];

  Widget _tile(List<int> t) => Container(
    width: 42, height: 74,
    margin: const EdgeInsets.symmetric(horizontal: 3),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.black, width: 1.5)),
    child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Text('${t[0]}', style: const TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold)),
      Container(height: 1, color: Colors.black38),
      Text('${t[1]}', style: const TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold)),
    ]),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0F0A),
      appBar: AppBar(title: const Text('Domino'), backgroundColor: Colors.transparent),
      body: Column(children: [
        Expanded(child: Center(child: Container(
          margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1E4A2C), Color(0xFF0D2818)]), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF4CAF50), width: 2)),
          child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: board.map(_tile).toList())),
        ))),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(color: Color(0xFF2B1810), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('SENIN TASLARIN', style: TextStyle(color: Colors.white54, fontSize: 11, letterSpacing: 2)),
            const SizedBox(height: 10),
            SizedBox(height: 90, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: hand.length, itemBuilder: (_, i) => _tile(hand[i]))),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), padding: const EdgeInsets.symmetric(vertical: 12)), onPressed: () {}, child: const Text('TAS CEK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
              const SizedBox(width: 8),
              Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(vertical: 12)), onPressed: () {}, child: const Text('PAS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
            ]),
          ]),
        ),
      ]),
    );
  }
}
