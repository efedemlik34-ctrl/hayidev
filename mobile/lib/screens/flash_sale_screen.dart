import 'package:flutter/material.dart';
import '../services/api.dart';

class FlashSaleScreen extends StatefulWidget {
  const FlashSaleScreen({super.key});
  @override
  State<FlashSaleScreen> createState() => _FlashSaleScreenState();
}

class _FlashSaleScreenState extends State<FlashSaleScreen> {
  List _sales = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final r = await Api.dio.get('/flash-sale/active');
      setState(() => _sales = r.data);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(title: const Text('Firsat Indirimleri'), backgroundColor: Colors.transparent),
      body: _sales.isEmpty ? const Center(child: Text('Aktif indirim yok', style: TextStyle(color: Colors.white54)))
        : ListView.builder(padding: const EdgeInsets.all(16), itemCount: _sales.length,
          itemBuilder: (_, i) {
            final s = _sales[i];
            return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFE91E63), Color(0xFF9C27B0)]),
                borderRadius: BorderRadius.circular(16)),
              child: Row(children: [
                Text('%${s['discount']}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(width: 16),
                Expanded(child: Text(s['name'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 16))),
              ]));
          }),
    );
  }
}
