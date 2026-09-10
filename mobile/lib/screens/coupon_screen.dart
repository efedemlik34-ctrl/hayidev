import 'package:flutter/material.dart';
import '../services/api.dart';

class CouponScreen extends StatefulWidget {
  const CouponScreen({super.key});
  @override
  State<CouponScreen> createState() => _CouponScreenState();
}

class _CouponScreenState extends State<CouponScreen> {
  final _code = TextEditingController();
  int? _reward;
  bool _loading = false;

  Future<void> _redeem() async {
    if (_code.text.isEmpty) return;
    setState(() => _loading = true);
    try {
      final r = await Api.dio.post('/coupons/redeem', data: {'code': _code.text});
      setState(() => _reward = r.data['reward']);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('+${r.data['reward']} coin!'), backgroundColor: Colors.green));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Gecersiz veya kullanilmis'), backgroundColor: Colors.red));
    } finally { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(title: const Text('Kupon Kullan'), backgroundColor: Colors.transparent),
      body: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
        const SizedBox(height: 40),
        const Icon(Icons.card_giftcard, color: Color(0xFFFFC107), size: 100),
        const SizedBox(height: 30),
        TextField(controller: _code, style: const TextStyle(color: Colors.white, letterSpacing: 3),
          textAlign: TextAlign.center, textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            hintText: 'KOD', hintStyle: const TextStyle(color: Colors.white38, letterSpacing: 3),
            filled: true, fillColor: Colors.white10,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          )),
        const SizedBox(height: 20),
        SizedBox(width: double.infinity, height: 54,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFC107)),
            onPressed: _loading ? null : _redeem,
            child: Text(_loading ? 'YUKLENIYOR...' : 'KULLAN',
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)),
          )),
        if (_reward != null) ...[
          const SizedBox(height: 30),
          Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)]),
            borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 60),
              const SizedBox(height: 10),
              Text('+$_reward', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
            ])),
        ],
      ])),
    );
  }
}
