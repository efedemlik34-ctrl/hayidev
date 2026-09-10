import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/api.dart';

class RocketGameScreen extends StatefulWidget {
  const RocketGameScreen({super.key});
  @override
  State<RocketGameScreen> createState() => _RocketGameScreenState();
}

class _RocketGameScreenState extends State<RocketGameScreen> with TickerProviderStateMixin {
  double _multiplier = 1.00;
  bool _playing = false;
  bool _crashed = false;
  double _crashPoint = 0;
  int _selectedBet = 1000;
  int _balance = 0;
  Timer? _timer;
  late AnimationController _flyCtrl;
  final List<double> _history = [];

  @override
  void initState() {
    super.initState();
    _flyCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _loadBalance();
  }

  @override
  void dispose() { _timer?.cancel(); _flyCtrl.dispose(); super.dispose(); }

  Future<void> _loadBalance() async {
    try {
      final r = await Api.dio.get('/user/me');
      setState(() => _balance = r.data['balance']);
    } catch (e) {}
  }

  void _start() async {
    try {
      await Api.dio.post('/games/rocket/start', data: {'bet': _selectedBet});
      setState(() { _playing = true; _crashed = false; _multiplier = 1.00; });
      _flyCtrl.repeat();
      _crashPoint = 1.5 + math.Random().nextDouble() * 6;
      _timer = Timer.periodic(const Duration(milliseconds: 100), (t) {
        if (!mounted) { t.cancel(); return; }
        setState(() => _multiplier = double.parse((_multiplier + 0.03).toStringAsFixed(2)));
        if (_multiplier >= _crashPoint) {
          t.cancel();
          _flyCtrl.stop();
          setState(() { _crashed = true; _playing = false; });
          _history.insert(0, _crashPoint);
          if (_history.length > 6) _history.removeLast();
        }
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _cashout() async {
    try {
      _timer?.cancel();
      _flyCtrl.stop();
      final r = await Api.dio.post('/games/rocket/cashout');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Kazandin! ${r.data['multiplier']}x = +${r.data['payout']}'),
          backgroundColor: Colors.green));
      }
      setState(() { _playing = false; });
      _loadBalance();
    } catch (e) {
      setState(() { _playing = false; _crashed = true; });
      _loadBalance();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1F5C),
      body: SafeArea(child: Column(children: [
        // Ust bar
        Container(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1A3AB8),
                borderRadius: BorderRadius.circular(20)),
              child: const Text('2006. Tur', style: TextStyle(color: Colors.white, fontSize: 12)),
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
                Text('$_balance', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ]),
            ),
          ]),
        ),
        // Buyuk baslik
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('ROCKET', style: TextStyle(
            color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold,
            shadows: [Shadow(color: const Color(0xFF3B82F6), blurRadius: 20)])),
          const Text(' 🚀', style: TextStyle(fontSize: 38)),
        ]),
        const SizedBox(height: 12),
        // Ucan roket + carpan
        Expanded(
          child: Stack(children: [
            // Yildizlar
            ...List.generate(30, (i) => Positioned(
              left: (i * 137.5) % 400, top: (i * 73.3) % 500,
              child: Container(width: 2, height: 2,
                decoration: const BoxDecoration(color: Colors.white54, shape: BoxShape.circle)),
            )),
            // Carpan
            Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('${_multiplier.toStringAsFixed(2)}x',
                  style: TextStyle(
                    color: _crashed ? Colors.red : (_multiplier > 3 ? const Color(0xFF4CAF50) : Colors.white),
                    fontSize: 72, fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 20)])),
                if (_crashed)
                  Text('PATLADI @ ${_crashPoint.toStringAsFixed(2)}x',
                    style: const TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold)),
              ]),
            ),
            // Ucan roket
            if (_playing)
              AnimatedBuilder(
                animation: _flyCtrl,
                builder: (_, __) => Positioned(
                  left: 40 + (_flyCtrl.value % 1) * 200,
                  bottom: 100 + (_flyCtrl.value % 1) * 200,
                  child: Transform.rotate(
                    angle: -0.6,
                    child: const Text('🚀', style: TextStyle(fontSize: 54)),
                  ),
                ),
              ),
          ]),
        ),
        // Alt panel
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0xFF1A3AB8),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(children: [
            // Bahis sec
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              for (final b in [500, 5000, 50000, 100000])
                GestureDetector(
                  onTap: _playing ? null : () => setState(() => _selectedBet = b),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: _selectedBet == b ? const Color(0xFFFFC107) : Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14)),
                    child: Text('🪙 ${b >= 1000 ? '${b ~/ 1000}K' : b}',
                      style: TextStyle(color: _selectedBet == b ? Colors.black : Colors.white,
                        fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
            ]),
            const SizedBox(height: 14),
            // Ana buton
            SizedBox(width: double.infinity, height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _playing ? const Color(0xFFFF6B35) : const Color(0xFF4CAF50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _playing ? _cashout : _start,
                child: Text(_playing ? 'CEKIL (${(_selectedBet * _multiplier).floor()})' : 'BAHIS OYNA',
                  style: const TextStyle(color: Colors.white, fontSize: 17,
                    fontWeight: FontWeight.bold, letterSpacing: 2)),
              )),
            const SizedBox(height: 8),
            // Gecmis
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              for (final h in _history.take(6))
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: h >= 2 ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8)),
                  child: Text('${h.toStringAsFixed(2)}x',
                    style: TextStyle(color: h >= 2 ? Colors.greenAccent : Colors.redAccent,
                      fontSize: 11, fontWeight: FontWeight.bold)),
                ),
            ]),
          ]),
        ),
      ])),
    );
  }
}
