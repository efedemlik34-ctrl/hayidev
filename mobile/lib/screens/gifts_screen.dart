import 'package:flutter/material.dart';
import '../services/api.dart';

class GiftsScreen extends StatefulWidget {
  const GiftsScreen({super.key});
  @override
  State<GiftsScreen> createState() => _GiftsScreenState();
}

class _GiftsScreenState extends State<GiftsScreen> {
  List _gifts = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final r = await Api.dio.get('/gifts');
      setState(() => _gifts = r.data);
    } catch (e) { debugPrint(e.toString()); }
  }

  void _showSend(Map<String, dynamic> g) {
    final ctrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1A0F3E),
      title: Text(g['name'] ?? '', style: const TextStyle(color: Colors.white)),
      content: TextField(controller: ctrl, keyboardType: TextInputType.number,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(hintText: 'Alici user ID', hintStyle: TextStyle(color: Colors.white38))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Iptal')),
        TextButton(onPressed: () async {
          final id = int.tryParse(ctrl.text);
          if (id == null) return;
          try {
            await Api.dio.post('/gifts/send', data: {'receiverId': id, 'giftKey': g['key']});
            if (ctx.mounted) Navigator.pop(ctx);
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hediye gonderildi!')));
          } catch (e) {
            if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Hata: ' + e.toString())));
          }
        }, child: const Text('GONDER')),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(title: const Text('Hediye Katalogu'), backgroundColor: Colors.transparent),
      body: _gifts.isEmpty
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFC107)))
        : GridView.count(
            padding: const EdgeInsets.all(12),
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.85,
            children: _gifts.map((g) => GestureDetector(
              onTap: () => _showSend(g),
              child: Container(
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(g['icon'] ?? '?', style: const TextStyle(fontSize: 34)),
                  const SizedBox(height: 4),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(g['name'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 10), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis)),
                  Text(g['price'].toString(), style: const TextStyle(color: Color(0xFFFFC107), fontSize: 10)),
                ]),
              ),
            )).toList(),
          ),
    );
  }
}
