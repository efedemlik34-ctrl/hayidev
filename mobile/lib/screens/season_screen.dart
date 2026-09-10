import 'package:flutter/material.dart';
import '../services/api.dart';

class SeasonScreen extends StatefulWidget {
  const SeasonScreen({super.key});
  @override
  State<SeasonScreen> createState() => _SeasonScreenState();
}

class _SeasonScreenState extends State<SeasonScreen> {
  Map<String, dynamic>? _data;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final r = await Api.dio.get('/seasons/current');
      setState(() => _data = r.data);
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_data == null) return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFFFFC107))));
    final s = _data!['season'] as Map? ?? {};
    final my = _data!['my'] as Map? ?? {};
    final lb = _data!['leaderboard'] as List? ?? [];
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(title: const Text('Sezon'), backgroundColor: Colors.transparent),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF8B0000), Color(0xFFFF4500), Color(0xFFFFD700)]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s['name'] ?? 'Sezon', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Odul havuzu: 🪙 ${s['reward_pool'] ?? 0}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                const Icon(Icons.person, color: Color(0xFFFFC107)),
                const SizedBox(width: 8),
                Text('Puanlarim: ${my['points'] ?? 0}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 20),
        const Text('Liderlik', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...lb.asMap().entries.map((e) {
          final i = e.key;
          final u = e.value;
          final top = i < 3;
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: top ? const Color(0xFFFFC107).withOpacity(0.2) : Colors.white10,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(children: [
              SizedBox(width: 30, child: Text('${i + 1}', style: TextStyle(color: top ? const Color(0xFFFFC107) : Colors.white70, fontWeight: FontWeight.bold))),
              Expanded(child: Text(u['username'] ?? '', style: const TextStyle(color: Colors.white))),
              Text('${u['points'] ?? 0}', style: const TextStyle(color: Color(0xFFFFC107), fontWeight: FontWeight.bold)),
            ]),
          );
        }),
      ]),
    );
  }
}
