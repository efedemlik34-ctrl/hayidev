import 'package:flutter/material.dart';
import '../services/api.dart';

class ClanWarScreen extends StatefulWidget {
  final int clanId;
  const ClanWarScreen({super.key, required this.clanId});
  @override
  State<ClanWarScreen> createState() => _ClanWarScreenState();
}

class _ClanWarScreenState extends State<ClanWarScreen> {
  Map<String, dynamic>? _war;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final r = await Api.dio.get('/clans/${widget.clanId}/war');
      setState(() => _war = r.data);
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_war == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A0E27),
        appBar: AppBar(title: const Text('Klan Savasi'), backgroundColor: Colors.transparent),
        body: const Center(child: Text('Aktif savas yok', style: TextStyle(color: Colors.white54))),
      );
    }
    final s1 = _war!['score1'] ?? 0;
    final s2 = _war!['score2'] ?? 0;
    final total = (s1 + s2) == 0 ? 1 : (s1 + s2);
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(title: const Text('Klan Savasi'), backgroundColor: Colors.transparent),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF8B0000), Color(0xFF4A0000)]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(children: [
            Text(_war!['clan1Name'] ?? 'Klan 1', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              Text('$s1', style: const TextStyle(color: Color(0xFFFFC107), fontSize: 40, fontWeight: FontWeight.bold)),
              const Text('VS', style: TextStyle(color: Colors.white54, fontSize: 24)),
              Text('$s2', style: const TextStyle(color: Color(0xFF4FC3F7), fontSize: 40, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Row(children: [
                Expanded(flex: ((s1 / total) * 100).round().clamp(1, 99), child: Container(height: 14, color: const Color(0xFFFFC107))),
                Expanded(flex: ((s2 / total) * 100).round().clamp(1, 99), child: Container(height: 14, color: const Color(0xFF4FC3F7))),
              ]),
            ),
            const SizedBox(height: 8),
            Text(_war!['clan2Name'] ?? 'Klan 2', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ]),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), padding: const EdgeInsets.all(16)),
          onPressed: () async {
            try {
              await Api.dio.post('/clans/war/points', data: {'points': 10});
              _load();
            } catch (e) {}
          },
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('SAVASA KATIL (+10 puan)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ]),
    );
  }
}
