import 'package:flutter/material.dart';
import '../services/api.dart';

class GiftBoxScreen extends StatefulWidget {
  const GiftBoxScreen({super.key});
  @override
  State<GiftBoxScreen> createState() => _GiftBoxScreenState();
}

class _GiftBoxScreenState extends State<GiftBoxScreen> {
  Map? _status;
  int? _reward;
  bool _loading = false;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final r = await Api.dio.get('/gift-box/status');
      setState(() => _status = r.data);
    } catch (_) {}
  }

  Future<void> _open() async {
    setState(() => _loading = true);
    try {
      final r = await Api.dio.post('/gift-box/open');
      setState(() => _reward = r.data['reward']);
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(title: const Text('Gunluk Hediye Kutusu'), backgroundColor: Colors.transparent),
      body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        if (_reward != null) ...[
          const Icon(Icons.celebration, color: Color(0xFFFFC107), size: 100),
          Text('+$_reward', style: const TextStyle(color: Color(0xFFFFC107), fontSize: 60, fontWeight: FontWeight.bold)),
        ] else ...[
          const Icon(Icons.card_giftcard, color: Color(0xFFFFC107), size: 120),
          const SizedBox(height: 30),
          Text(_status != null && _status!['canOpen'] == true
            ? 'Bugunun kutusu seni bekliyor!'
            : 'Bugun acildi, yarin gel!',
            style: const TextStyle(color: Colors.white, fontSize: 16)),
        ],
        const SizedBox(height: 40),
        if (_status != null && _status!['canOpen'] == true && _reward == null)
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFC107), padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16)),
            onPressed: _loading ? null : _open,
            child: const Text('KUTUYU AC', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
      ])),
    );
  }
}
