import 'package:flutter/material.dart';
import '../services/api.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});
  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List _lb = [];
  int _tab = 0;
  final _tabs = ['Haftalik', 'Aylik', 'Genel'];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final path = _tab == 0 ? '/leaderboard/weekly'
        : _tab == 1 ? '/leaderboard/monthly'
        : '/leaderboard';
      final r = await Api.dio.get(path);
      setState(() => _lb = r.data);
    } catch (_) {}
  }

  int _fmt(dynamic n) {
    try { return int.parse(n.toString()); } catch (_) { return 0; }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        title: const Text('Liderlik Tablosu'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Column(children: [
        // Tab
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(children: List.generate(_tabs.length, (i) {
            final isSel = _tab == i;
            return Expanded(child: GestureDetector(
              onTap: () { setState(() => _tab = i); _load(); },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: isSel
                    ? const LinearGradient(colors: [Color(0xFFFFC107), Color(0xFFFF6B35)])
                    : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: Text(_tabs[i],
                  style: TextStyle(color: isSel ? Colors.black : Colors.white60,
                    fontWeight: FontWeight.bold, fontSize: 12))),
              ),
            ));
          })),
        ),
        // Liste
        Expanded(child: _lb.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFC107)))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _lb.length,
              itemBuilder: (_, i) {
                final u = _lb[i];
                final top3 = i < 3;
                final colors = [
                  [const Color(0xFFFFD700), const Color(0xFFFFA000)],
                  [const Color(0xFFC0C0C0), const Color(0xFF9E9E9E)],
                  [const Color(0xFFCD7F32), const Color(0xFF8B4513)],
                ];
                final medals = ['🥇', '🥈', '🥉'];
                final bal = _fmt(u['balance'] ?? u['won'] ?? 0);

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: top3
                      ? LinearGradient(colors: colors[i])
                      : null,
                    color: top3 ? null : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: top3
                      ? null
                      : Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Row(children: [
                    SizedBox(width: 36,
                      child: top3
                        ? Text(medals[i], style: const TextStyle(fontSize: 22))
                        : Text('${i + 1}',
                            style: const TextStyle(color: Colors.white70,
                              fontWeight: FontWeight.bold, fontSize: 16))),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: top3
                        ? Colors.black.withOpacity(0.2)
                        : const Color(0xFF2A1F5E),
                      child: Text(
                        (u['username']?.toString() ?? '?')[0].toUpperCase(),
                        style: TextStyle(
                          color: top3 ? Colors.black : const Color(0xFFFFC107),
                          fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(u['username']?.toString() ?? '',
                      style: TextStyle(
                        color: top3 ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold, fontSize: 14))),
                    Row(children: [
                      Icon(Icons.monetization_on,
                        color: top3 ? Colors.black : const Color(0xFFFFC107),
                        size: 14),
                      const SizedBox(width: 4),
                      Text('$bal',
                        style: TextStyle(
                          color: top3 ? Colors.black : const Color(0xFFFFC107),
                          fontWeight: FontWeight.bold, fontSize: 13)),
                    ]),
                  ]),
                );
              },
            ),
        ),
      ]),
    );
  }
}
