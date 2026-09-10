import 'package:flutter/material.dart';
import '../services/api.dart';

class TournamentBracketScreen extends StatefulWidget {
  final int tournamentId;
  const TournamentBracketScreen({super.key, required this.tournamentId});
  @override
  State<TournamentBracketScreen> createState() => _TournamentBracketScreenState();
}

class _TournamentBracketScreenState extends State<TournamentBracketScreen> {
  Map<String, dynamic>? _data;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final r = await Api.dio.get('/tournaments/${widget.tournamentId}/bracket');
      setState(() => _data = r.data);
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_data == null) return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFFFFC107))));
    final rounds = _data!['rounds'] as List? ?? [];
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(title: const Text('Turnuva Bracket'), backgroundColor: Colors.transparent),
      body: rounds.isEmpty
        ? const Center(child: Text('Bracket henuz baslamadi', style: TextStyle(color: Colors.white54)))
        : ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            itemCount: rounds.length,
            itemBuilder: (_, ri) {
              final round = rounds[ri] as List;
              return Container(
                width: 220,
                margin: const EdgeInsets.only(right: 16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Tur ${ri + 1}', style: const TextStyle(color: Color(0xFFFFC107), fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...round.map((m) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: m['winner'] != null ? Colors.greenAccent : Colors.white24),
                    ),
                    child: Column(children: [
                      _player(m['p1'], m['winner'] == m['p1']),
                      const Divider(color: Colors.white12, height: 16),
                      _player(m['p2'], m['winner'] == m['p2']),
                    ]),
                  )),
                ]),
              );
            },
          ),
    );
  }

  Widget _player(String? name, bool isWinner) => Row(children: [
    Icon(isWinner ? Icons.emoji_events : Icons.person, color: isWinner ? const Color(0xFFFFC107) : Colors.white54, size: 18),
    const SizedBox(width: 8),
    Expanded(child: Text(name ?? '-', style: TextStyle(color: isWinner ? const Color(0xFFFFC107) : Colors.white70, fontWeight: isWinner ? FontWeight.bold : FontWeight.normal, fontSize: 13))),
  ]);
}
