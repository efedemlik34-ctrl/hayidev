import 'package:flutter/material.dart';
import '../services/api.dart';

class TeenPattiScreen extends StatefulWidget {
  const TeenPattiScreen({super.key});
  @override
  State<TeenPattiScreen> createState() => _TeenPattiScreenState();
}

class _TeenPattiScreenState extends State<TeenPattiScreen> {
  int bet = 1000;
  List? playerHand, dealerHand;
  bool win = false;

  Future<void> _play() async {
    try {
      final r = await Api.dio.post('/games/teen-patti/play', data: {'bet': bet});
      setState(() { playerHand = r.data['playerHand']; dealerHand = r.data['dealerHand']; win = r.data['win'] ?? false; });
    } catch (e) {}
  }

  Widget _card(Map? c) => Container(width: 60, height: 90, margin: const EdgeInsets.symmetric(horizontal: 4), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8)]),
    child: Center(child: c == null ? const Text('?', style: TextStyle(fontSize: 32, color: Colors.black38)) : Text(c['r'] ?? '?', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black))));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF8B1538), Color(0xFF4A0A1F)])),
        child: SafeArea(child: Column(children: [
          AppBar(backgroundColor: Colors.transparent, elevation: 0, title: const Text('Teen Patti', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))),
          const Text('DEALER', style: TextStyle(color: Color(0xFFFFC107), fontSize: 12, letterSpacing: 3)),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(3, (i) => _card(dealerHand != null && i < dealerHand!.length ? dealerHand![i] : null))),
          const SizedBox(height: 40),
          Container(padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10), decoration: BoxDecoration(color: playerHand == null ? Colors.white10 : (win ? Colors.green.withOpacity(0.4) : Colors.red.withOpacity(0.4)), borderRadius: BorderRadius.circular(20)), child: Text(playerHand == null ? 'VS' : (win ? 'KAZANDIN!' : 'KAYBETTIN'), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
          const SizedBox(height: 40),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(3, (i) => _card(playerHand != null && i < playerHand!.length ? playerHand![i] : null))),
          const SizedBox(height: 12),
          const Text('SENIN ELIN', style: TextStyle(color: Color(0xFFFFC107), fontSize: 12, letterSpacing: 3)),
          const Spacer(),
          Padding(padding: const EdgeInsets.all(20), child: SizedBox(width: double.infinity, height: 56, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), onPressed: _play, child: const Text('OYNA', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2))))),
        ])),
      ),
    );
  }
}
