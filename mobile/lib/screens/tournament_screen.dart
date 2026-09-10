import 'package:flutter/material.dart';
import '../services/api.dart';

class TournamentScreen extends StatefulWidget {
  const TournamentScreen({super.key});
  @override
  State<TournamentScreen> createState() => _TournamentScreenState();
}

class _TournamentScreenState extends State<TournamentScreen> {
  List _tournaments = [], _lb = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final r1 = await Api.dio.get('/tournaments');
      setState(() => _tournaments = r1.data);
      if (_tournaments.isNotEmpty) {
        final r2 = await Api.dio.get(
          '/tournaments/${_tournaments[0]['id']}/leaderboard');
        setState(() => _lb = r2.data);
      }
    } catch (_) {}
  }

  Future<void> _join(int id) async {
    try {
      await Api.dio.post('/tournaments/$id/join');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Turnuvaya katildin!'),
          backgroundColor: Colors.green));
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(title: const Text('Turnuvalar'),
        backgroundColor: Colors.transparent),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFFFFD700), Color(0xFFFF6B35), Color(0xFF9C27B0)]),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(
              color: const Color(0xFFFFC107).withOpacity(0.4),
              blurRadius: 24, offset: const Offset(0, 8))]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12)),
                child: const Text('CANLI', style: TextStyle(
                  color: Colors.white, fontSize: 10,
                  fontWeight: FontWeight.bold))),
              const Spacer(),
              const Text('5.000.000 ODUL',
                style: TextStyle(color: Colors.white, fontSize: 12,
                  fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 16),
            const Text('Haftalik Turnuva', style: TextStyle(
              color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('En cok coin kazanan 10 kisi odul alir',
              style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14))),
                onPressed: _tournaments.isEmpty
                  ? null : () => _join(_tournaments[0]['id']),
                child: const Text('KATIL', style: TextStyle(
                  color: Color(0xFFFFC107), fontWeight: FontWeight.bold,
                  letterSpacing: 2)))),
          ])),
        const SizedBox(height: 20),
        const Text('Aktif Turnuvalar', style: TextStyle(
          color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ..._tournaments.map((t) => Container(
          margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [
              Color(0xFF1A0F3E), Color(0xFF0F0A2E)]),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFFFC107).withOpacity(0.3))),
          child: Row(children: [
            Container(width: 46, height: 46,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [
                  Color(0xFFFFC107), Color(0xFFFF6B35)]),
                borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.emoji_events, color: Colors.black)),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t['name']?.toString() ?? 'Turnuva',
                  style: const TextStyle(color: Colors.white,
                    fontWeight: FontWeight.bold, fontSize: 14)),
                Text('Odul: ${t['prize'] ?? 0}',
                  style: const TextStyle(color: Color(0xFFFFC107),
                    fontSize: 11)),
              ])),
            Container(padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC107).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10)),
              child: Text('${t['players'] ?? 0}/${t['max'] ?? 100}',
                style: const TextStyle(color: Color(0xFFFFC107),
                  fontWeight: FontWeight.bold, fontSize: 11))),
          ]))),
        const SizedBox(height: 20),
        const Text('Turnuva Liderlik', style: TextStyle(
          color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ..._lb.take(10).toList().asMap().entries.map((e) {
          final i = e.key; final u = e.value;
          final medals = ['🥇', '🥈', '🥉']; final top3 = i < 3;
          return Container(margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: top3 ? LinearGradient(colors: [
                const Color(0xFFFFD700).withOpacity(0.3),
                const Color(0xFFFF6B35).withOpacity(0.3)]) : null,
              color: top3 ? null : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: top3 ? Border.all(
                color: const Color(0xFFFFC107)) : null),
            child: Row(children: [
              SizedBox(width: 32, child: top3
                ? Text(medals[i], style: const TextStyle(fontSize: 20))
                : Text('${i + 1}', style: const TextStyle(
                    color: Colors.white70, fontWeight: FontWeight.bold))),
              const SizedBox(width: 8),
              Expanded(child: Text(u['username']?.toString() ?? '',
                style: const TextStyle(color: Colors.white,
                  fontWeight: FontWeight.bold, fontSize: 13))),
              Text('${u['score'] ?? 0}', style: const TextStyle(
                color: Color(0xFFFFC107), fontWeight: FontWeight.bold,
                fontSize: 12)),
            ]));
        }),
      ]));
  }
}
