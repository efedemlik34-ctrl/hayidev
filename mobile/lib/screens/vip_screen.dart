import 'package:flutter/material.dart';
import '../services/api.dart';

class VipScreen extends StatefulWidget {
  const VipScreen({super.key});
  @override
  State<VipScreen> createState() => _VipScreenState();
}

class _VipScreenState extends State<VipScreen> {
  List _tiers = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final r = await Api.dio.get('/vip');
      setState(() => _tiers = r.data);
    } catch (e) { debugPrint(e.toString()); }
  }

  Future<void> _buy(int level) async {
    try {
      await Api.dio.post('/vip/buy', data: {'level': level});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('VIP ' + level.toString() + ' aktif!')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: ' + e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = [Color(0xFFCD7F32), Color(0xFFC0C0C0), Color(0xFFFFD700), Color(0xFFE91E63), Color(0xFF9C27B0)];
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(title: const Text('VIP'), backgroundColor: Colors.transparent),
      body: _tiers.isEmpty
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFC107)))
        : ListView.builder(padding: const EdgeInsets.all(16),
            itemCount: _tiers.length,
            itemBuilder: (_, i) {
              final t = _tiers[i];
              final c = colors[i % colors.length];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [c.withOpacity(0.3), c.withOpacity(0.05)]),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: c, width: 2),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(Icons.workspace_premium, color: Colors.white, size: 32),
                    const SizedBox(width: 12),
                    Text(t['name'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Text(t['price'].toString(), style: TextStyle(color: c, fontSize: 16, fontWeight: FontWeight.bold)),
                  ]),
                  const SizedBox(height: 8),
                  Text('Gunluk odul bonusu: +%' + (i * 5 + 5).toString(), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 12),
                  SizedBox(width: double.infinity, height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: c),
                      onPressed: () => _buy(t['level']),
                      child: const Text('SATIN AL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    )),
                ]),
              );
            }),
    );
  }
}
