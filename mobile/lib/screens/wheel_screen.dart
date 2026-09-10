import 'package:flutter/material.dart';
import '../services/api.dart';

class WheelScreen extends StatefulWidget {
  const WheelScreen({super.key});
  @override
  State<WheelScreen> createState() => _WheelScreenState();
}

class _WheelScreenState extends State<WheelScreen> {
  int _free = 3;
  int _paidCost = 5000;
  bool _spinning = false;
  int? _lastReward;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final r = await Api.dio.get('/wheel');
      setState(() {
        _free = r.data['freeRemaining'] ?? 3;
        _paidCost = r.data['paidCost'] ?? 5000;
      });
    } catch (e) { debugPrint(e.toString()); }
  }

  Future<void> _spin({bool paid = false}) async {
    if (_spinning) return;
    setState(() { _spinning = true; _lastReward = null; });
    try {
      final r = await Api.dio.post('/wheel/spin', data: {'paid': paid});
      setState(() => _lastReward = r.data['reward']);
      await _load();
      if (mounted) {
        showDialog(context: context, builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF1A0F3E),
          title: const Text('🎉 Kazandin!', style: TextStyle(color: Colors.white), textAlign: TextAlign.center),
          content: Text('🪙 ' + (r.data['reward'] ?? 0).toString(), style: const TextStyle(color: Color(0xFFFFC107), fontSize: 32, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Harika!'))],
        ));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: ' + e.toString())));
    } finally {
      if (mounted) setState(() => _spinning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(title: const Text('Carkifelek'), backgroundColor: Colors.transparent),
      body: Column(children: [
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: _free > 0 ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _free > 0 ? Colors.greenAccent : Colors.redAccent),
          ),
          child: Text(_free > 0 ? '🎁 ' + _free.toString() + ' ucretsiz' : 'Ucretsiz hak yok', style: TextStyle(color: _free > 0 ? Colors.greenAccent : Colors.redAccent, fontWeight: FontWeight.bold)),
        ),
        const Spacer(),
        AnimatedRotation(
          turns: _spinning ? 5 : 0,
          duration: const Duration(seconds: 3),
          child: Container(
            width: 220, height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const SweepGradient(colors: [Color(0xFF4CAF50), Color(0xFF2196F3), Color(0xFFFFC107), Color(0xFFFF6B35), Color(0xFFE91E63), Color(0xFF9C27B0), Color(0xFFF44336), Color(0xFF4CAF50)]),
            ),
            child: const Center(child: Text('🎰', style: TextStyle(fontSize: 60))),
          ),
        ),
        const Spacer(),
        Padding(padding: const EdgeInsets.all(20), child: Column(children: [
          if (_free > 0) SizedBox(width: double.infinity, height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              onPressed: _spinning ? null : () => _spin(paid: false),
              child: Text(_spinning ? 'CEVIRIYOR...' : 'UCRETSIZ CEVIR', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            )),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFC107), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              onPressed: _spinning ? null : () => _spin(paid: true),
              child: Text('🪙 ' + _paidCost.toString() + ' ILE CEVIR', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
            )),
        ])),
      ]),
    );
  }
}
