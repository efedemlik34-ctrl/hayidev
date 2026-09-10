import 'package:flutter/material.dart';
import '../services/api.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});
  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  List _weekly = [], _monthly = [], _points = [], _spenders = [];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    _load();
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  Future<void> _load() async {
    try {
      final w = await Api.dio.get('/leaderboard/weekly');
      final m = await Api.dio.get('/leaderboard/monthly');
      final p = await Api.dio.get('/leaderboard/points');
      final s = await Api.dio.get('/leaderboard/spenders');
      setState(() { _weekly = w.data; _monthly = m.data; _points = p.data; _spenders = s.data; });
    } catch (e) { debugPrint(e.toString()); }
  }

  Widget _list(List items, String valueKey, String valuePrefix) {
    if (items.isEmpty) return const Center(child: Text('Veri yok', style: TextStyle(color: Colors.white38)));
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final u = items[i];
        final top3 = i < 3;
        final colors = [
          [const Color(0xFFFFD700), const Color(0xFFFFA000)],
          [const Color(0xFFC0C0C0), const Color(0xFF9E9E9E)],
          [const Color(0xFFCD7F32), const Color(0xFF8B4513)]
        ];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: top3 ? LinearGradient(colors: colors[i]) : null,
            color: top3 ? null : Colors.white10,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: top3 ? Colors.black.withOpacity(0.2) : Colors.white10,
                shape: BoxShape.circle),
              child: Center(child: Text('${i + 1}',
                style: TextStyle(color: top3 ? Colors.black : Colors.white70,
                  fontWeight: FontWeight.bold, fontSize: 15))),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(u['username'] ?? '',
              style: TextStyle(color: top3 ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold, fontSize: 15))),
            Text('$valuePrefix${u[valueKey] ?? 0}',
              style: TextStyle(color: top3 ? Colors.black : Color(0xFFFFC107),
                fontWeight: FontWeight.bold, fontSize: 13)),
          ]),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        title: const Text('Liderlik Tablosu'),
        backgroundColor: Colors.transparent, elevation: 0,
        bottom: TabBar(
          controller: _tabs,
          labelColor: const Color(0xFFFFC107),
          unselectedLabelColor: Colors.white54,
          indicatorColor: const Color(0xFFFFC107),
          isScrollable: true,
          tabs: const [
            Tab(text: 'Haftalik'),
            Tab(text: 'Aylik'),
            Tab(text: 'Puan'),
            Tab(text: 'Harcama'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _list(_weekly, 'won', '🪙 '),
          _list(_monthly, 'won', '🪙 '),
          _list(_points, 'xp', '⭐ '),
          _list(_spenders, 'spent', '💎 '),
        ],
      ),
    );
  }
}
