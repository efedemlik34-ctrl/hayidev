import 'package:flutter/material.dart';
import '../services/api.dart';
import '../widgets/slot_reel_animation.dart';
import '../widgets/feedback_service.dart';

class SlotScreen extends StatefulWidget {
  final String title;
  const SlotScreen({super.key, this.title = 'JACKPOT SLOTS'});
  @override
  State<SlotScreen> createState() => _SlotScreenState();
}

class _SlotScreenState extends State<SlotScreen> {
  List<List<String>> _grid = List.generate(5, (_) => ['❓','❓','❓']);
  int _bet = 500;
  bool _spinning = false;
  int _win = 0;
  int _balance = 0;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final r = await Api.dio.get('/user/me');
      setState(() => _balance = r.data['balance'] ?? 0);
    } catch (_) {}
  }

  Future<void> _spin() async {
    if (_spinning) return;
    FeedbackService.light();
    setState(() { _spinning = true; _win = 0; });
    try {
      final r = await Api.dio.post('/games/slot/spin', data: {'bet': _bet});
      final reels = r.data['reels'] as List;
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _grid = List.generate(5, (i) => [reels[i % reels.length].toString()]);
        _win = r.data['payout'] ?? 0;
        _spinning = false;
      });
      if (_win > 0) {
        FeedbackService.jackpot();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('+$_win coin!'), backgroundColor: Colors.green));
      }
      _load();
    } catch (e) {
      setState(() => _spinning = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF4A148C), Color(0xFF1A0033)])),
        child: SafeArea(child: Column(children: [
          AppBar(
            backgroundColor: Colors.transparent, elevation: 0,
            title: Text(widget.title,
              style: const TextStyle(color: Color(0xFFFFC107),
                fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 3)),
            actions: [
              Padding(padding: const EdgeInsets.only(right: 12),
                child: Center(child: Text('🪙 $_balance',
                  style: const TextStyle(color: Color(0xFFFFC107), fontWeight: FontWeight.bold)))),
            ],
          ),
          // Jackpot banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFB8860B), Color(0xFFFFD700), Color(0xFFB8860B)]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: const Color(0xFFFFD700).withOpacity(0.7), blurRadius: 24)]),
            child: const Center(child: Text('🎰 JACKPOT 2.003.052.775',
              style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(height: 20),
          // Slot makinesi
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFFD700), width: 3),
              boxShadow: [
                BoxShadow(color: const Color(0xFFFFD700).withOpacity(0.4), blurRadius: 30),
                BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 10)),
              ]),
            child: SlotMachineAnimation(
              reels: _grid,
              spinning: _spinning,
            ),
          ),
          const SizedBox(height: 20),
          if (_win > 0)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.greenAccent)),
              child: Text('🎉 KAZANC: +$_win coin',
                style: const TextStyle(color: Colors.greenAccent,
                  fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          const Spacer(),
          // Bahis + Spin
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                for (final b in [100, 500, 1000, 5000, 10000])
                  GestureDetector(
                    onTap: _spinning ? null : () => setState(() => _bet = b),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _bet == b ? const Color(0xFFFFC107) : Colors.white10,
                        borderRadius: BorderRadius.circular(14)),
                      child: Text('${b >= 1000 ? '${b ~/ 1000}K' : b}',
                        style: TextStyle(color: _bet == b ? Colors.black : Colors.white,
                          fontSize: 11, fontWeight: FontWeight.bold)),
                    )),
              ]),
              const SizedBox(height: 14),
              SizedBox(width: double.infinity, height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _spinning ? Colors.grey : const Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    shadowColor: Colors.green.withOpacity(0.5),
                    elevation: 8),
                  onPressed: _spinning ? null : _spin,
                  child: Text(_spinning ? 'CEVIRIYOR...' : 'DONUS',
                    style: const TextStyle(color: Colors.white, fontSize: 18,
                      fontWeight: FontWeight.bold, letterSpacing: 3)),
                )),
            ]),
          ),
        ])),
      ),
    );
  }
}
