import 'package:flutter/material.dart';

class CpLevelScreen extends StatefulWidget {
  const CpLevelScreen({super.key});
  @override
  State<CpLevelScreen> createState() => _CpLevelScreenState();
}

class _CpLevelScreenState extends State<CpLevelScreen> {
  int _cp = 4500;
  int _level = 4;

  int _xpFor(int level) => level * 1000;

  @override
  Widget build(BuildContext context) {
    final currentXp = _cp % _xpFor(_level + 1);
    final needed = _xpFor(_level + 1);
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(title: const Text('CP Leveli'), backgroundColor: Colors.transparent, elevation: 0),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // Buyuk CP karti
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE91E63), Color(0xFF9C27B0)]),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Color(0xFFE91E63).withOpacity(0.5), blurRadius: 24)],
          ),
          child: Column(children: [
            const Text('❤️', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 10),
            Text('CP Level $_level',
              style: const TextStyle(color: Colors.white,
                fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: currentXp / needed,
                minHeight: 12,
                backgroundColor: Colors.black.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            ),
            const SizedBox(height: 6),
            Text('$currentXp / $needed XP',
              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12)),
          ]),
        ),
        const SizedBox(height: 24),
        const Text('Seviyeler', style: TextStyle(color: Colors.white,
          fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...[
          {'lvl': 1, 'name': 'Tanisma', 'color': Color(0xFF4CAF50), 'emoji': '🌱'},
          {'lvl': 2, 'name': 'Flort', 'color': Color(0xFF2196F3), 'emoji': '💙'},
          {'lvl': 3, 'name': 'Sevgili', 'color': Color(0xFFE91E63), 'emoji': '💗'},
          {'lvl': 4, 'name': 'Asik', 'color': Color(0xFF9C27B0), 'emoji': '💜'},
          {'lvl': 5, 'name': 'Evli', 'color': Color(0xFFFFC107), 'emoji': '💍'},
          {'lvl': 6, 'name': 'Ruh Esi', 'color': Color(0xFFFF5722), 'emoji': '🔥'},
        ].map((t) {
          final isDone = (_cp / 1000).floor() >= (t['lvl'] as int);
          final isCurrent = _level == t['lvl'];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: isCurrent ? LinearGradient(
                colors: [(t['color'] as Color).withOpacity(0.4),
                  (t['color'] as Color).withOpacity(0.1)]) : null,
              color: isCurrent ? null : Colors.white10,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isCurrent ? t['color'] as Color : Colors.transparent),
            ),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: (t['color'] as Color).withOpacity(0.2),
                  shape: BoxShape.circle),
                child: Center(child: Text(t['emoji'] as String,
                  style: const TextStyle(fontSize: 22))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Lv.${t['lvl']} • ${t['name']}',
                  style: const TextStyle(color: Colors.white,
                    fontSize: 15, fontWeight: FontWeight.bold)),
                Text('${(t['lvl'] as int) * 1000} CP',
                  style: const TextStyle(color: Colors.white54, fontSize: 11)),
              ])),
              if (isDone) Icon(Icons.check_circle, color: t['color'] as Color, size: 26),
              if (isCurrent) const Icon(Icons.star, color: Color(0xFFFFC107), size: 26),
            ]),
          );
        }),
      ]),
    );
  }
}
