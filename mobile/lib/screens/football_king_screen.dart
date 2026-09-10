import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/football_stadium.dart';
import '../services/local_db.dart';
import '../services/feedback_service.dart';

class FootballKingScreen extends StatefulWidget {
  const FootballKingScreen({super.key});
  @override
  State<FootballKingScreen> createState() => _FootballKingScreenState();
}

class _FootballKingScreenState extends State<FootballKingScreen> {
  final teams = [
    {'name': 'Fenerbahce', 'icon': '🟡', 'mult': 100},
    {'name': 'Galatasaray', 'icon': '🔴', 'mult': 100},
    {'name': 'Besiktas', 'icon': '⚫', 'mult': 20},
    {'name': 'Trabzonspor', 'icon': '🔵', 'mult': 20},
    {'name': 'Adana Demir', 'icon': '🔷', 'mult': 8},
    {'name': 'Sivasspor', 'icon': '🔺', 'mult': 8},
  ];
  int selected = 0;
  int bet = 1000;
  String? result;

  Future<void> _play() async {
    final ok = await LocalDB.changeBalance(-bet, 'football_bet');
    if (!ok) {
      setState(() => result = 'Yetersiz bakiye');
      return;
    }
    FeedbackService.light();
    await Future.delayed(const Duration(seconds: 2));
    final winner = Random().nextInt(teams.length);
    if (winner == selected) {
      final win = bet * (teams[selected]['mult'] as int);
      await LocalDB.changeBalance(win, 'football_win');
      FeedbackService.jackpot();
      setState(() => result = '🎉 KAZANDIN! +$win');
    } else {
      FeedbackService.error();
      setState(() => result = 'Kaybettin. Kazanan: ${teams[winner]['name']}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A2E1A),
      appBar: AppBar(
        title: const Text('Football King'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(children: [
        const SizedBox(height: 12),
        // Stadyum
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: const FootballStadium(),
        ),
        const SizedBox(height: 20),
        // Takimlar
        Expanded(child: GridView.count(
          padding: const EdgeInsets.all(16),
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.0,
          children: List.generate(teams.length, (i) {
            final t = teams[i];
            final isSel = selected == i;
            return GestureDetector(
              onTap: () => setState(() => selected = i),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: isSel
                    ? [const Color(0xFF1B5E20), const Color(0xFF0D3D1F)]
                    : [Colors.white10, Colors.white.withOpacity(0.05)]),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSel ? const Color(0xFFFFC107) : Colors.white24,
                    width: isSel ? 3 : 1)),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(t['icon'] as String, style: const TextStyle(fontSize: 36)),
                  const SizedBox(height: 6),
                  Text(t['name'] as String, style: const TextStyle(color: Colors.white,
                    fontSize: 11, fontWeight: FontWeight.bold)),
                  Text('x${t['mult']}', style: const TextStyle(color: Color(0xFFFFC107),
                    fontSize: 11, fontWeight: FontWeight.bold)),
                ]),
              ));
          }),
        )),
        // Sonuc
        if (result != null)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: result!.startsWith('🎉') ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12)),
            child: Text(result!, style: TextStyle(
              color: result!.startsWith('🎉') ? Colors.greenAccent : Colors.redAccent,
              fontWeight: FontWeight.bold)),
          ),
        // Buton
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(width: double.infinity, height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              onPressed: _play,
              child: Text('OYNA ($bet)',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            )),
        ),
      ]),
    );
  }
}
