import 'package:flutter/material.dart';
import '../services/api.dart';
import '../widgets/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/user_avatar.dart';

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
          : _tab == 1 ? '/leaderboard/monthly' : '/leaderboard';
      final r = await Api.dio.get(path);
      setState(() => _lb = r.data is List ? r.data : []);
    } catch (_) {
      setState(() => _lb = []);
    }
  }

  int _i(dynamic n) {
    try { return int.parse(n.toString()); } catch (_) { return 0; }
  }

  String _short(int n) {
    if (n >= 1e9) return (n / 1e9).toStringAsFixed(1) + 'B';
    if (n >= 1e6) return (n / 1e6).toStringAsFixed(1) + 'M';
    if (n >= 1e3) return (n / 1e3).toStringAsFixed(1) + 'K';
    return n.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(title: const Text('Liderlik')),
      body: Column(children: [
        _tabBar(),
        Expanded(child: _lb.isEmpty
          ? const Center(child: Text('Bos',
              style: TextStyle(color: Colors.white54)))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _lb.length,
              itemBuilder: (_, i) => _card(_lb[i], i),
            )),
      ]),
    );
  }

  Widget _tabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppRadius.lg)),
      child: Row(children: List.generate(_tabs.length, (i) {
        final sel = _tab == i;
        return Expanded(child: GestureDetector(
          onTap: () { setState(() => _tab = i); _load(); },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              gradient: sel ? AppColors.goldGradient : null,
              borderRadius: BorderRadius.circular(AppRadius.md)),
            child: Center(child: Text(_tabs[i], style: TextStyle(
              color: sel ? Colors.black : Colors.white60,
              fontWeight: FontWeight.bold, fontSize: 12))))));
      })),
    );
  }

  Widget _card(Map u, int i) {
    final name = u['username']?.toString() ?? '?';
    final bal = _i(u['balance'] ?? u['won'] ?? 0);
    final medals = ['🥇', '🥈', '🥉'];
    final top3 = i < 3;
    final colors = [
      [const Color(0xFFFFD700), const Color(0xFFFFA000)],
      [const Color(0xFFC0C0C0), const Color(0xFF9E9E9E)],
      [const Color(0xFFCD7F32), const Color(0xFF8B4513)],
    ];

    if (top3) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors[i]),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [BoxShadow(
            color: colors[i][0].withOpacity(0.5),
            blurRadius: 20, offset: const Offset(0, 8))]),
        child: Row(children: [
          Text(medals[i], style: const TextStyle(fontSize: 30)),
          const SizedBox(width: 10),
          UserAvatar(name: name, size: 52, frame: 'gold'),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black,
                  fontWeight: FontWeight.bold, fontSize: 16)),
              Text('Lv ${u['level'] ?? 0}', style: TextStyle(
                color: Colors.black.withOpacity(0.6), fontSize: 11)),
            ])),
          Flexible(child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text('🪙 ${_short(bal)}', style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold,
              fontSize: 15)))),
        ]),
      );
    }

    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(children: [
        SizedBox(width: 30, child: Text('${i + 1}',
          style: const TextStyle(color: Colors.white70,
            fontWeight: FontWeight.bold, fontSize: 15))),
        UserAvatar(name: name, size: 40),
        const SizedBox(width: 12),
        Expanded(child: Text(name, maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white,
            fontWeight: FontWeight.bold, fontSize: 14))),
        Flexible(child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('🪙 ${_short(bal)}', style: const TextStyle(
            color: AppColors.gold, fontWeight: FontWeight.bold,
            fontSize: 13)))),
      ]),
    );
  }
}
