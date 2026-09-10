import 'package:flutter/material.dart';
import '../services/api.dart';

class DragonTigerScreen extends StatefulWidget {
  const DragonTigerScreen({super.key});
  @override
  State<DragonTigerScreen> createState() => _DragonTigerScreenState();
}

class _DragonTigerScreenState extends State<DragonTigerScreen> {
  String? dragon, tiger, winner;
  int bet = 1000;

  Future<void> _play(String pick) async {
    try {
      final r = await Api.dio.post('/games/dragon-tiger/play', data: {'bet': bet, 'pick': pick});
      setState(() { dragon = r.data['dragon']; tiger = r.data['tiger']; winner = r.data['winner']; });
    } catch (e) {}
  }

  Widget _card(String? v) => Container(width: 90, height: 130, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 12)]),
    child: Center(child: v == null ? const Text('?', style: TextStyle(fontSize: 48, color: Colors.black38)) : Text(v, style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.black))));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF8B0000), Color(0xFF0D47A1)])),
        child: SafeArea(child: Column(children: [
          AppBar(backgroundColor: Colors.transparent, elevation: 0, title: const Text('Dragon Tiger Slot', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            Column(children: [const Text('EJDERHA', style: TextStyle(color: Colors.orange, fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 12), _card(dragon)]),
            const Text('VS', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            Column(children: [const Text('KAPLAN', style: TextStyle(color: Colors.blueAccent, fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 12), _card(tiger)]),
          ]),
          const SizedBox(height: 30),
          if (winner != null) Text('KAZANAN: $winner', style: const TextStyle(color: Color(0xFFFFC107), fontSize: 20, fontWeight: FontWeight.bold)),
          const Spacer(),
          Padding(padding: const EdgeInsets.all(16), child: Row(children: [
            Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), onPressed: () => _play('dragon'), child: const Column(children: [Text('🐉', style: TextStyle(fontSize: 26)), Text('EJDERHA x2', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))]))),
            const SizedBox(width: 8),
            Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.purple.shade700, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), onPressed: () => _play('tie'), child: const Column(children: [Text('🤝', style: TextStyle(fontSize: 26)), Text('BERABERE x8', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))]))),
            const SizedBox(width: 8),
            Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), onPressed: () => _play('tiger'), child: const Column(children: [Text('🐅', style: TextStyle(fontSize: 26)), Text('KAPLAN x2', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))]))),
          ])),
        ])),
      ),
    );
  }
}
