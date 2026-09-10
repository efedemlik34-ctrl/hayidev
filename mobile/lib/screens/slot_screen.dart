import 'package:flutter/material.dart';
import '../services/api.dart';

class SlotScreen extends StatefulWidget {
  final String title;
  const SlotScreen({super.key, this.title = 'Jackpot Slots'});
  @override
  State<SlotScreen> createState() => _SlotScreenState();
}

class _SlotScreenState extends State<SlotScreen> {
  List<List<String>> grid = List.generate(5, (_) => List.filled(3, '❓'));
  int bet = 500;
  bool spinning = false;
  int win = 0;

  Future<void> _spin() async {
    setState(() { spinning = true; win = 0; });
    try {
      final r = await Api.dio.post('/games/slot/spin', data: {'bet': bet});
      await Future.delayed(const Duration(milliseconds: 800));
      final reels = r.data['reels'] as List;
      setState(() {
        grid = List.generate(5, (i) => [reels[0].toString(), reels[0].toString(), reels[0].toString()]);
        win = r.data['payout'] ?? 0;
        spinning = false;
      });
    } catch (e) { setState(() => spinning = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF4A148C), Color(0xFF1A0033)])),
        child: SafeArea(child: Column(children: [
          AppBar(backgroundColor: Colors.transparent, elevation: 0, title: Text(widget.title.toUpperCase(), style: const TextStyle(color: Color(0xFFFFC107), fontSize: 20, fontWeight: FontWeight.bold))),
          Container(margin: const EdgeInsets.symmetric(horizontal: 16), padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFB8860B), Color(0xFFFFD700), Color(0xFFB8860B)]), borderRadius: BorderRadius.circular(20)), child: const Center(child: Text('🎰 JACKPOT 2.003.052.775', style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold)))),
          const SizedBox(height: 16),
          Expanded(child: Container(margin: const EdgeInsets.symmetric(horizontal: 16), padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFFFD700), width: 3)), child: GridView.builder(gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, mainAxisSpacing: 4, crossAxisSpacing: 4), itemCount: 15, itemBuilder: (_, i) { final col = i ~/ 3; final row = i % 3; return Container(decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)), child: Center(child: Text(grid[col][row], style: const TextStyle(fontSize: 26)))); }))),
          if (win > 0) Padding(padding: const EdgeInsets.all(8), child: Text('KAZANC: +$win', style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold))),
          Padding(padding: const EdgeInsets.all(16), child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              for (final b in [100, 500, 1000, 5000]) GestureDetector(
                onTap: spinning ? null : () => setState(() => bet = b),
                child: Container(margin: const EdgeInsets.symmetric(horizontal: 3), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: bet == b ? const Color(0xFFFFC107) : Colors.white10, borderRadius: BorderRadius.circular(14)), child: Text('$b', style: TextStyle(color: bet == b ? Colors.black : Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
              ),
            ]),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, height: 56, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), onPressed: spinning ? null : _spin, child: Text(spinning ? 'CEVIRIYOR...' : 'DONUS', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)))),
          ])),
        ])),
      ),
    );
  }
}
