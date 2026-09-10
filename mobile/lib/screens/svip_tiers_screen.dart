import 'package:flutter/material.dart';
import '../services/api.dart';

class SvipTiersScreen extends StatefulWidget {
  const SvipTiersScreen({super.key});
  @override
  State<SvipTiersScreen> createState() => _SvipTiersScreenState();
}

class _SvipTiersScreenState extends State<SvipTiersScreen> {
  List _tiers = [];
  Map? _my;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final t = await Api.dio.get('/svip/tiers');
      final m = await Api.dio.get('/svip/my');
      setState(() { _tiers = t.data; _my = m.data; });
    } catch (_) {}
  }

  Future<void> _buy(int level) async {
    try {
      await Api.dio.post('/svip/buy', data: {'level': level});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('SVIP aktif!')));
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = [const Color(0xFF9C27B0), const Color(0xFFE91E63), const Color(0xFFFFC107)];
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(title: const Text('SVIP'), backgroundColor: Colors.transparent),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        if (_my != null && (_my!['level'] ?? 0) > 0)
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFFFC107), Color(0xFFFF6B35)]),
            borderRadius: BorderRadius.circular(16)),
            child: Text('Aktif: SVIP ${_my!['level']}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
        const SizedBox(height: 16),
        ..._tiers.map((t) {
          final lvl = t['level'] as int;
          final c = colors[(lvl - 1) % colors.length];
          return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [c.withOpacity(0.4), c.withOpacity(0.1)]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: c, width: 2)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t['name'], style: TextStyle(color: c, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(t['perks'], style: const TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: Text('🪙 ${t['price']}', style: TextStyle(color: c, fontWeight: FontWeight.bold))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: c),
                  onPressed: () => _buy(lvl),
                  child: const Text('SATIN AL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ]),
            ]));
        }),
      ]),
    );
  }
}
