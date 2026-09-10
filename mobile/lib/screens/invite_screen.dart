import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api.dart';

class InviteScreen extends StatefulWidget {
  const InviteScreen({super.key});
  @override
  State<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends State<InviteScreen> {
  String _code = '';
  int _count = 0;
  List _invited = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final r = await Api.dio.get('/invite/me');
      setState(() {
        _code = r.data['code'] ?? '';
        _count = r.data['count'] ?? 0;
        _invited = r.data['invited'] ?? [];
      });
    } catch (e) { debugPrint(e.toString()); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(title: const Text('Davet Et'), backgroundColor: Colors.transparent),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFFFC107), Color(0xFFFF6B35)]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(children: [
            const Text('DAVET KODUN', style: TextStyle(color: Colors.black54, fontSize: 11, letterSpacing: 2)),
            const SizedBox(height: 8),
            Text(_code, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 3)),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _code));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kod kopyalandi!')));
                },
                icon: const Icon(Icons.copy, color: Color(0xFFFFC107)),
                label: const Text('KOPYALA', style: TextStyle(color: Color(0xFFFFC107), fontWeight: FontWeight.bold)),
              )),
          ]),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(16)),
          child: Column(children: [
            Text('Toplam davet: ' + _count.toString(), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Her davet = 5000 coin', style: const TextStyle(color: Color(0xFFFFC107), fontSize: 12)),
          ]),
        ),
        const SizedBox(height: 20),
        const Text('Davet Ettiklerim', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ..._invited.map((u) => Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            const Icon(Icons.person, color: Color(0xFFFFC107), size: 18),
            const SizedBox(width: 8),
            Text(u['username'] ?? '', style: const TextStyle(color: Colors.white)),
            const Spacer(),
            Text(u['created_at']?.toString().substring(0, 10) ?? '', style: const TextStyle(color: Colors.white54, fontSize: 11)),
          ]),
        )),
      ]),
    );
  }
}
