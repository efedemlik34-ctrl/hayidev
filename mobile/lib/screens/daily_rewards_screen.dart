import 'package:flutter/material.dart';
import '../services/api.dart';

class DailyRewardsScreen extends StatefulWidget {
  const DailyRewardsScreen({super.key});
  @override
  State<DailyRewardsScreen> createState() => _DailyRewardsScreenState();
}

class _DailyRewardsScreenState extends State<DailyRewardsScreen> {
  Map? _data;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final r = await Api.dio.get('/daily/7day');
      setState(() => _data = r.data);
    } catch (_) {}
  }

  Future<void> _claim() async {
    try {
      final r = await Api.dio.post('/daily/claim');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('+${r.data['reward']} coin!'), backgroundColor: Colors.green));
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_data == null) return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFFFFC107))));
    final rewards = _data!['rewards'] as List;
    final current = _data!['currentDay'] as int;
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(title: const Text('Gunluk Oduller'), backgroundColor: Colors.transparent),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFFFC107), Color(0xFFFF6B35)]),
          borderRadius: BorderRadius.circular(20)),
          child: Column(children: [
            Text('Seri: ${_data!['streak']} gun', style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
            Text('7. gun: 150.000 coin!', style: const TextStyle(color: Colors.black87, fontSize: 14)),
          ])),
        const SizedBox(height: 20),
        ...rewards.map((r) {
          final day = r['day'] as int;
          final done = day < current;
          final isCurrent = day == current;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: isCurrent ? const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)]) : null,
              color: isCurrent ? null : Colors.white10,
              borderRadius: BorderRadius.circular(12),
              border: isCurrent ? Border.all(color: Colors.greenAccent, width: 2) : null),
            child: Row(children: [
              Text(r['icon'] as String, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(child: Text('${day}. Gun', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              Text('🪙 ${r['reward']}', style: const TextStyle(color: Color(0xFFFFC107), fontWeight: FontWeight.bold, fontSize: 16)),
              if (done) const Padding(padding: EdgeInsets.only(left: 8), child: Icon(Icons.check_circle, color: Colors.greenAccent)),
            ]));
        }),
        const SizedBox(height: 20),
        SizedBox(height: 54, child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFC107)),
          onPressed: _claim,
          child: const Text('BUGUNKU ODULU AL', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)),
        )),
      ]),
    );
  }
}
