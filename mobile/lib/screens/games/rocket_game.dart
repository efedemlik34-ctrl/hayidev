
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../services/api.dart';
import '../../services/local_db.dart';

class RocketGame extends StatefulWidget {
  const RocketGame({super.key});
  @override
  State<RocketGame> createState() => _RocketGameState();
}

class _RocketGameState extends State<RocketGame>
    with TickerProviderStateMixin {
  int _balance = 0;
  int _bet = 500;
  int _round = 2006;
  double _multiplier = 1.0;
  bool _flying = false;
  bool _cashed = false;
  double _crashAt = 1.0;
  int _countdown = 5;
  List<double> _history = [9.68, 9.54, 7.01, 14.86, 6.64, 3.49];
  late AnimationController _flyCtrl;

  @override
  void initState() {
    super.initState();
    _balance = LocalDB.getBalance() > 0 ? LocalDB.getBalance() : 68644;
    _flyCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 1));
    _prepare();
  }

  void _prepare() {
    setState(() {
      _multiplier = 1.0;
      _flying = false;
      _cashed = false;
      _countdown = 5;
    });
    _tickDown();
  }

  void _tickDown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      if (_countdown > 0) {
        setState(() => _countdown--);
        _tickDown();
      } else {
        _launch();
      }
    });
  }

  void _launch() {
    final r = math.Random();
    _crashAt = 1.0 + r.nextDouble() * 10;
    setState(() {
      _flying = true;
      _multiplier = 1.0;
    });
    _grow();
  }

  void _grow() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted || !_flying) return;
      setState(() {
        _multiplier = _multiplier * 1.05;
      });
      if (_multiplier >= _crashAt) {
        setState(() {
          _flying = false;
          _history.insert(0, _multiplier);
          if (_history.length > 8) _history.removeLast();
          _round++;
        });
        if (!_cashed && _bet > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('CRASH! ${_multiplier.toStringAsFixed(2)}x'),
                backgroundColor: Colors.red));
        }
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) _prepare();
        });
      } else {
        _grow();
      }
    });
  }

  Future<void> _cashout() async {
    if (!_flying || _cashed) return;
    final win = (_bet * _multiplier).round();
    setState(() {
      _cashed = true;
      _balance += win;
    });
    LocalDB.setBalance(_balance);
    try {
      await Api.dio.post('/rocket/cashout', data: {
        'bet': _bet, 'multiplier': _multiplier});
    } catch (_) {}
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Kazandın! +$win'),
          backgroundColor: Colors.green));
  }

  Future<void> _placeBet() async {
    if (_flying) return;
    if (_balance < _bet) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yetersiz bakiye'),
            backgroundColor: Colors.red));
      return;
    }
    setState(() => _balance -= _bet);
    try {
      await Api.dio.post('/rocket/bet', data: {'bet': _bet});
    } catch (_) {}
  }

  @override
  void dispose() {
    _flyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A3E),
      appBar: AppBar(
        title: const Text('Rocket Game'),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF0A1A3E), Color(0xFF000000)],
          ),
        ),
        child: Column(children: [
          _header(),
          Expanded(child: _sky()),
          _historyRow(),
          _controls(),
        ]),
      ),
    );
  }

  Widget _header() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A8A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        Text('$_round. Tur', style: const TextStyle(
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        const Spacer(),
        const Icon(Icons.monetization_on, color: Color(0xFFFFC107), size: 18),
        const SizedBox(width: 4),
        Text(_balance.toString(), style: const TextStyle(
          color: Colors.white, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _sky() {
    return Stack(children: [
      Positioned(
        left: 0, bottom: 0,
        child: CustomPaint(
          size: Size(MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height * 0.4),
          painter: _CurvePainter(progress: _flying ? _multiplier : 0),
        ),
      ),
      if (_flying || _cashed)
        Positioned(
          right: 40,
          bottom: 100 + (_multiplier - 1) * 30,
          child: Transform.rotate(
            angle: -math.pi / 6,
            child: Column(children: [
              Text('${_multiplier.toStringAsFixed(2)}x', style: TextStyle(
                color: _cashed ? Colors.greenAccent : Colors.redAccent,
                fontSize: 32, fontWeight: FontWeight.bold,
                shadows: [Shadow(color: Colors.white, blurRadius: 10)])),
              const Text('🚀', style: TextStyle(fontSize: 40)),
            ]),
          ),
        ),
      if (!_flying && !_cashed)
        Center(child: Text('$_countdown s', style: const TextStyle(
          color: Colors.white, fontSize: 60, fontWeight: FontWeight.bold))),
    ]);
  }

  Widget _historyRow() {
    return Container(
      margin: const EdgeInsets.all(12),
      height: 32,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _history.length,
        itemBuilder: (_, i) {
          final m = _history[i];
          final c = m >= 5 ? Colors.purple.shade700 :
            m >= 2 ? Colors.blue.shade700 : Colors.red.shade700;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: c,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('${m.toStringAsFixed(2)}x', style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
          );
        },
      ),
    );
  }

  Widget _controls() {
    final chips = [500, 5000, 50000, 100000];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Color(0xFF0A1A3E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(children: [
        TextField(
          enabled: false,
          controller: TextEditingController(text:
            _flying ? 'Uçuyor... ${_multiplier.toStringAsFixed(2)}x'
                    : 'Sonraki Turu Bekle'),
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1E3A8A),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: chips.map((c) {
            final sel = _bet == c;
            return GestureDetector(
              onTap: () => setState(() => _bet = c),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: sel
                    ? [const Color(0xFFFFC107), const Color(0xFFFF6B35)]
                    : [const Color(0xFF1E3A8A), const Color(0xFF0F2555)]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(_fmt(c), style: TextStyle(
                  color: sel ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: GestureDetector(
            onTap: _flying ? (_cashed ? null : _cashout) : _placeBet,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: _flying
                  ? (_cashed
                    ? [Colors.grey.shade700, Colors.grey.shade900]
                    : [Colors.orange.shade700, Colors.red.shade700])
                  : [const Color(0xFF4CAF50), const Color(0xFF2E7D32)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(child: Text(
                _flying ? (_cashed ? 'Kazandin ✓' : 'CASH OUT ${(_bet * _multiplier).round()}')
                        : 'BAHIS YAP',
                style: const TextStyle(color: Colors.white,
                  fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2))),
            ),
          ),
        ),
      ]),
    );
  }

  String _fmt(int n) {
    if (n >= 1000000) return (n ~/ 1000000).toString() + 'M';
    if (n >= 1000) return (n ~/ 1000).toString() + 'K';
    return n.toString();
  }
}

class _CurvePainter extends CustomPainter {
  final double progress;
  _CurvePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress < 1.1) return;
    final p = Paint()
      ..color = const Color(0xFFFFC107).withOpacity(0.6)
      ..strokeWidth = 4 ..style = PaintingStyle.stroke;
    final path = Path()..moveTo(0, size.height);
    final h = size.height;
    final w = size.width;
    final factor = (progress - 1).clamp(0.0, 1.0);
    for (double t = 0; t <= factor; t += 0.02) {
      final x = w * t;
      final y = h - (h * 0.9) * math.pow(t, 1.5);
      path.lineTo(x, y);
    }
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_CurvePainter old) => old.progress != progress;
}
