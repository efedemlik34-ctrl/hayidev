import 'package:flutter/material.dart';
import '../services/api.dart';

class ClansScreen extends StatefulWidget {
  const ClansScreen({super.key});
  @override
  State<ClansScreen> createState() => _ClansScreenState();
}

class _ClansScreenState extends State<ClansScreen> {
  List _clans = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final r = await Api.dio.get('/clans');
      setState(() => _clans = r.data);
    } catch (e) { debugPrint(e.toString()); }
  }

  void _create() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1A0F3E),
      title: const Text('Klan Olustur', style: TextStyle(color: Colors.white)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: 'Klan adi', hintStyle: TextStyle(color: Colors.white38))),
        const SizedBox(height: 8),
        TextField(controller: descCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: 'Aciklama', hintStyle: TextStyle(color: Colors.white38))),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Iptal')),
        TextButton(onPressed: () async {
          try {
            await Api.dio.post('/clans/create', data: {'name': nameCtrl.text, 'description': descCtrl.text});
            if (ctx.mounted) Navigator.pop(ctx);
            _load();
          } catch (e) {
            if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Hata: ' + e.toString())));
          }
        }, child: const Text('OLUSTUR')),
      ],
    ));
  }

  Future<void> _join(int id) async {
    try {
      await Api.dio.post('/clans/' + id.toString() + '/join');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kata katildin!')));
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: ' + e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(title: const Text('Klanlar'), backgroundColor: Colors.transparent,
        actions: [IconButton(icon: const Icon(Icons.add, color: Color(0xFFFFC107)), onPressed: _create)]),
      body: _clans.isEmpty
        ? const Center(child: Text('Klan yok', style: TextStyle(color: Colors.white54)))
        : ListView.builder(padding: const EdgeInsets.all(12),
            itemCount: _clans.length,
            itemBuilder: (_, i) {
              final c = _clans[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(14)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Text('🛡️', style: TextStyle(fontSize: 32)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(c['name'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Sahip: ' + (c['owner'] ?? ''), style: const TextStyle(color: Colors.white54, fontSize: 11)),
                      Text(c['members'].toString() + ' uye', style: const TextStyle(color: Color(0xFFFFC107), fontSize: 11)),
                    ])),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFC107)),
                      onPressed: () => _join(c['id']),
                      child: const Text('KATIL', style: TextStyle(color: Colors.black, fontSize: 12)),
                    ),
                  ]),
                ]),
              );
            }),
    );
  }
}
