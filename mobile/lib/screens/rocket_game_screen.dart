import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/api.dart';
import '../widgets/rocket_animation.dart';
import '../widgets/feedback_service.dart';

class RocketGameScreen extends StatefulWidget {
  const RocketGameScreen({super.key});
  @override
  State<RocketGameScreen> createState() => _RocketGameScreenState();
}

class _RocketGameScreenState extends State<RocketGameScreen> {
  double _multiplier = 1.00;
  bool _playing = false;
  bool _crashed = false;
  double _crashPoint = 0;
  int _bet = 1000;
  int _balance = 0;
  Timer? _timer;
  final List<double> _history = [];

  @override
  void initState() { super.initState(); _load(); }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  Future<void> _load() async {
    try {
      final r = await Api.dio.get('/user/me');
      setState(() => _balance = r.data['balance'] ?? 0);
    } catch (_) {}
  }

  Future<void> _start() async {
    FeedbackService.medium();
    try {
      await Api.dio.post('/games/rocket/start', data: {'bet': _bet});
      setState(() { _playing = true; _crashed = false; _multiplier = 1.00; });
      _crashPoint = 1.5 + math.Random().nextDouble() * 6;
      _timer = Timer.periodic(const Duration(milliseconds: 100), (t) {
        if (!mounted) { t.cancel(); return; }
        setState(() => _multiplier = double.parse((_multiplier + 0.03).toStringAsFixed(2)));
        if (_multiplier >= _crashPoint) {
          t.cancel();
          setState(() { _crashed = true; _playing = false; });
          FeedbackService.error();
          _history.insert(0, _crashPoint);
          if (_history.length > 6) _history.removeLast();
        }
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> _cashout() async {
    try {
      _timer?.cancel();
      final r = await Api.dio.post('/games/rocket/cashout');
      FeedbackService.jackpot();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Kazandin! ${r.data['multiplier']}x = +${r.data['payout']}'),
          backgroundColor: Colors.green));
      }
      setState(() => _playing = false);
      _load();
    } catch (e) {
      setState(() { _playing = false; _crashed = true; });
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1F5C),
      body: SafeArea(child: Stack(children: [
        // Animasyonlu roket
        Positioned.fill(child: RocketAnimation(
          multiplier: _multiplier,
          crashed: _crashed,
          flying: _playing,
        )),

        // Ust bar
        Positioned(top: 0, left: 0, right: 0, child: Container(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC107).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFC107))),
              child: Row(children: [
                const Icon(Icons.star, color: Color(0xFFFFC107), size: 14),
                const SizedBox(width: 4),
                Text('$_balance', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ]),
            ),
          ]),
        )),

        // Buyuk baslik
        Positioned(top: 60, left: 0, right: 0, child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('ROCKET', style: TextStyle(
              color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold,
              shadows: [Shadow(color: const Color(0xFF3B82F6), blurRadius: 20)])),
            const Text(' 🚀', style: TextStyle(fontSize: 38)),
          ])),

        // Carpan gostergesi
        Positioned(top: 160, left: 0, right: 0, child: Center(
          child: Text('${_multiplier.toStringAsFixed(2)}x',
            style: TextStyle(
              color: _crashed ? Colors.red : (_multiplier > 3 ? const Color(0xFF4CAF50) : Colors.white),
              fontSize: 72, fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Colors.black.withOpacity(0.7), blurRadius: 20)])),
        )),

        // Gecmis
        Positioned(top: 260, left: 16, right: 16, child: Wrap(
          spacing: 6, runSpacing: 6,
          children: _history.map((h) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: h >= 2 ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8)),
            child: Text('${h.toStringAsFixed(2)}x',
              style: TextStyle(color: h >= 2 ? Colors.greenAccent : Colors.redAccent,
                fontSize: 11, fontWeight: FontWeight.bold)),
          )).toList(),
        )),

        // Alt panel
        Positioned(bottom: 0, left: 0, right: 0, child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0xFF1A3AB8),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              for (final b in [500, 5000, 50000, 100000])
                GestureDetector(
                  onTap: _playing ? null : () => setState(() => _bet = b),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: _bet == b ? const Color(0xFFFFC107) : Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14)),
                    child: Text('🪙 ${b >= 1000 ? '${b ~/ 1000}K' : b}',
                      style: TextStyle(color: _bet == b ? Colors.black : Colors.white,
                        fontSize: 12, fontWeight: FontWeight.bold)),
                  )),
            ]),
            const SizedBox(height: 14),
            SizedBox(width: double.infinity, height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _playing ? const Color(0xFFFF6B35) : const Color(0xFF4CAF50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                onPressed: _playing ? _cashout : _start,
                child: Text(_playing
                  ? 'CEKIL (${(_bet * _multiplier).floor()})'
                  : 'BAHIS OYNA',
                  style: const TextStyle(color: Colors.white, fontSize: 18,
                    fontWeight: FontWeight.bold, letterSpacing: 2)),
              )),
          ]),
        )),
      ])),
    );
  }
}
