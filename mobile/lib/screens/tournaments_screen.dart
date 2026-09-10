import 'package:flutter/material.dart';
import '../services/api.dart';

class TournamentsScreen extends StatefulWidget {
  const TournamentsScreen({super.key});
  @override
  State<TournamentsScreen> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends State<TournamentsScreen> {
  List _tournaments = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final r = await Api.dio.get('/tournaments');
      setState(() => _tournaments = r.data);
    } catch (e) { debugPrint(e.toString()); }
  }

  Future<void> _join(int id) async {
    try {
      await Api.dio.post('/tournaments/' + id.toString() + '/join');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Turnuvaya katildin!')));
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: ' + e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(title: const Text('Turnuvalar'), backgroundColor: Colors.transparent),
      body: _tournaments.isEmpty
        ? const Center(child: Text('Aktif turnuva yok', style: TextStyle(color: Colors.white54)))
        : ListView.builder(padding: const EdgeInsets.all(12),
            itemCount: _tournaments.length,
            itemBuilder: (_, i) {
              final t = _tournaments[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF8B0000), Color(0xFFFF4500)]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Text('🏆', style: TextStyle(fontSize: 32)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(t['name'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(t['players'].toString() + '/' + t['max_players'].toString() + ' oyuncu', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ])),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: t['status'] == 'reg' ? Colors.green : Colors.redAccent, borderRadius: BorderRadius.circular(10)),
                      child: Text((t['status'] ?? '').toString().toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Text('Giris: 🪙 ' + (t['entry_fee'] ?? 0).toString(), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    const Spacer(),
                    Text('Odul: 🪙 ' + (t['prize_pool'] ?? 0).toString(), style: const TextStyle(color: Color(0xFFFFC107), fontWeight: FontWeight.bold)),
                  ]),
                  if (t['status'] == 'reg') ...[
                    const SizedBox(height: 12),
                    SizedBox(width: double.infinity, height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFC107)),
                        onPressed: () => _join(t['id']),
                        child: const Text('KATIL', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      )),
                  ],
                ]),
              );
            }),
    );
  }
}
