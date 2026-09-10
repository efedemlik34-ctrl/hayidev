import 'package:flutter/material.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  final events = const [
    {'title': 'Yukleme Yildizi', 'emoji': '⭐', 'period': '01.08 - 01.11',
      'colors': [Color(0xFF2196F3), Color(0xFF0D47A1)]},
    {'title': 'Kaderin Aski', 'emoji': '💕', 'period': '20.08 - 27.08',
      'colors': [Color(0xFFE91E63), Color(0xFF9C27B0)]},
    {'title': 'Yukleme Odulleri', 'emoji': '🎁', 'period': '21.08 - 28.08',
      'colors': [Color(0xFF9C27B0), Color(0xFF4A148C)]},
    {'title': 'Tuketim Subvansiyonu', 'emoji': '💰', 'period': '31.07 - 31.10',
      'colors': [Color(0xFFFFC107), Color(0xFFFF6B35)]},
    {'title': 'Recharge Bonus Event', 'emoji': '🐉', 'period': '17.06 - 30.06',
      'colors': [Color(0xFFF44336), Color(0xFF8B0000)]},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        title: const Row(children: [
          Text('Etkinlik', style: TextStyle(color: Colors.white)),
          Spacer(),
          Text('Meydan', style: TextStyle(color: Colors.white38)),
        ]),
        backgroundColor: Colors.transparent,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: events.length,
        itemBuilder: (_, i) {
          final e = events[i];
          final colors = e['colors'] as List<Color>;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 160,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: colors),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: colors[0].withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))],
            ),
            child: Stack(children: [
              Positioned(
                right: 16, top: 16, bottom: 16,
                child: Center(child: Text(e['emoji'] as String,
                  style: const TextStyle(fontSize: 80))),
              ),
              Positioned(
                left: 16, bottom: 16,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC107),
                      borderRadius: BorderRadius.circular(8)),
                    child: const Text('Yeni', style: TextStyle(color: Colors.black,
                      fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  Text(e['title'] as String,
                    style: const TextStyle(color: Colors.white,
                      fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Etkinlik zamani: ${e['period']}',
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
                ]),
              ),
            ]),
          );
        },
      ),
    );
  }
}
