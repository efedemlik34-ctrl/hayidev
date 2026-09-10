
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../services/api.dart';
import '../../services/local_db.dart';

class RouletteGame extends StatefulWidget {
  const RouletteGame({super.key});
  @override
  State<RouletteGame> createState() => _RouletteGameState();
}

class _RouletteGameState extends State<RouletteGame>
    with TickerProviderStateMixin {
  int _balance = 0;
  int _bet = 1000;
  int _round = 2521;
  Map<String, int> _bets = {};
  int _result = -1;
  bool _spinning = false;
  int _countdown = 20;
  List<int> _history = [];
  late AnimationController _spinCtrl;

  static const List<int> _redNumbers = [
    1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36];

  @override
  void initState() {
    super.initState();
    _balance = LocalDB.getBalance() > 0 ? LocalDB.getBalance() : 69644;
    _spinCtrl = AnimationController(vsync: this,
        duration: const Duration(seconds: 4));
    _startCountdown();
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      if (_countdown > 0 && !_spinning) {
        setState(() => _countdown--);
        _startCountdown();
      } else if (!_spinning) {
        _spin();
      }
    });
  }

  Future<void> _spin() async {
    if (_bets.isEmpty) {
      setState(() => _countdown = 20);
      _startCountdown();
      return;
    }
    final total = _bets.values.fold<int>(0, (a, b) => a + b);
    if (total > _balance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yetersiz bakiye'),
            backgroundColor: Colors.red));
      return;
    }

    setState(() {
      _spinning = true;
      _balance -= total;
    });
    try {
      await Api.dio.post('/roulette/spin', data: {'bets': _bets});
    } catch (_) {}

    await _spinCtrl.forward(from: 0);
    final num = math.Random().nextInt(37);
    int payout = 0;
    for (final entry in _bets.entries) {
      final k = entry.key;
      final v = entry.value;
      if (k == num.toString()) payout += v * 36;
      else if (k == 'red' && _redNumbers.contains(num)) payout += v * 2;
      else if (k == 'black' && num != 0 && !_redNumbers.contains(num)) payout += v * 2;
      else if (k == 'even' && num != 0 && num % 2 == 0) payout += v * 2;
      else if (k == 'odd' && num % 2 == 1) payout += v * 2;
      else if (k == '1-12' && num >= 1 && num <= 12) payout += v * 3;
      else if (k == '13-24' && num >= 13 && num <= 24) payout += v * 3;
      else if (k == '25-36' && num >= 25 && num <= 36) payout += v * 3;
    }

    setState(() {
      _result = num;
      _balance += payout;
      _spinning = false;
      _round++;
      _history.insert(0, num);
      if (_history.length > 8) _history.removeLast();
    });
    await LocalDB.setBalance(_balance);

    await Future.delayed(const Duration(seconds: 3));
    _spinCtrl.reset();
    setState(() {
      _bets.clear();
      _result = -1;
      _countdown = 20;
    });
    _startCountdown();
  }

  bool _isRed(int n) => _redNumbers.contains(n);

  void _placeBet(String zone) {
    if (_spinning) return;
    if (_balance < _bet) return;
    setState(() {
      _bets[zone] = (_bets[zone] ?? 0) + _bet;
    });
  }

  @override
  void dispose() {
    _spinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        title: const Text('Rulet'),
        backgroundColor: Colors.transparent,
      ),
      body: Column(children: [
        _header(),
        Expanded(child: _wheelArea()),
        _betZones(),
        _chips(),
      ]),
    );
  }

  Widget _header() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          Colors.green.shade900, Colors.green.shade700]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        const Icon(Icons.monetization_on, color: Color(0xFFFFC107)),
        const SizedBox(width: 6),
        Text(_balance.toString(), style: const TextStyle(
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        const Spacer(),
        Text('Tur $_round', style: const TextStyle(
          color: Colors.white70, fontSize: 12)),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text('$_countdown s', style: const TextStyle(
            color: Color(0xFFFFC107), fontWeight: FontWeight.bold)),
        ),
      ]),
    );
  }

  Widget _wheelArea() {
    return Column(children: [
      Expanded(
        child: AnimatedBuilder(
          animation: _spinCtrl,
          builder: (_, __) => Transform.rotate(
            angle: _spinCtrl.value * math.pi * 8,
            child: CustomPaint(
              size: const Size(260, 260),
              painter: _WheelPainter(
                redNumbers: _redNumbers,
                highlight: _result,
              ),
            ),
          ),
        ),
      ),
      if (_result >= 0) Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: _result == 0 ? Colors.green.shade700 :
            _isRed(_result) ? Colors.red.shade700 : Colors.black,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white, width: 3),
        ),
        child: Text(_result.toString(), style: const TextStyle(
          color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
      ),
    ]);
  }

  Widget _betZones() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(children: [
        Row(children: [
          _zone('0', Colors.green.shade700, flex: 1),
          _zone('1-12', Colors.green.shade800, flex: 3),
          _zone('13-24', Colors.green.shade800, flex: 3),
          _zone('25-36', Colors.green.shade800, flex: 3),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          _zone('red', Colors.red.shade700, flex: 1, label: 'Kirmizi'),
          _zone('black', Colors.black, flex: 1, label: 'Siyah'),
          _zone('odd', Colors.green.shade800, flex: 1, label: 'Tek'),
          _zone('even', Colors.green.shade800, flex: 1, label: 'Cift'),
        ]),
      ]),
    );
  }

  Widget _zone(String key, Color c, {int flex = 1, String? label}) {
    final betOn = _bets[key] ?? 0;
    return Expanded(
      flex: flex,
      child: GestureDetector(
        onTap: () => _placeBet(key),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: c,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: betOn > 0 ? const Color(0xFFFFC107) : Colors.white24,
              width: betOn > 0 ? 2 : 1,
            ),
          ),
          child: Column(children: [
            Text(label ?? key, style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
            if (betOn > 0) Text('$betOn', style: const TextStyle(
              color: Color(0xFFFFC107), fontSize: 10,
              fontWeight: FontWeight.bold)),
          ]),
        ),
      ),
    );
  }

  Widget _chips() {
    final chips = [1000, 5000, 10000, 50000];
    final total = _bets.values.fold<int>(0, (a, b) => a + b);
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        if (total > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC107),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('Bahis: $total', style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
          ),
        const Spacer(),
        ...chips.map((c) {
          final sel = _bet == c;
          return GestureDetector(
            onTap: () => setState(() => _bet = c),
            child: Container(
              width: 52, height: 52,
              margin: const EdgeInsets.only(left: 6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: sel
                  ? [const Color(0xFFFFC107), const Color(0xFFFF6B35)]
                  : [const Color(0xFF1A0F3E), const Color(0xFF2A1F5E)]),
                border: Border.all(color: sel ? Colors.white : Colors.white24, width: 2),
              ),
              child: Center(child: Text(_fmt(c), style: TextStyle(
                color: sel ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold, fontSize: 10))),
            ),
          );
        }),
      ]),
    );
  }

  String _fmt(int n) {
    if (n >= 1000) return (n ~/ 1000).toString() + 'K';
    return n.toString();
  }
}

class _WheelPainter extends CustomPainter {
  final List<int> redNumbers;
  final int highlight;
  _WheelPainter({required this.redNumbers, required this.highlight});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 10;
    const segs = 37;
    const segAngle = 2 * math.pi / segs;

    for (int i = 0; i < segs; i++) {
      final startAngle = -math.pi / 2 + i * segAngle;
      Color col;
      if (i == 0) col = Colors.green.shade700;
      else if (redNumbers.contains(i)) col = Colors.red.shade700;
      else col = Colors.black;

      final paint = Paint()
        ..color = i == highlight ? const Color(0xFFFFC107) : col
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        startAngle, segAngle, true, paint,
      );

      final textAngle = startAngle + segAngle / 2;
      final tx = c.dx + math.cos(textAngle) * (r - 20);
      final ty = c.dy + math.sin(textAngle) * (r - 20);
      final tp = TextPainter(
        text: TextSpan(text: i.toString(),
          style: const TextStyle(color: Colors.white, fontSize: 9,
            fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(tx - tp.width / 2, ty - tp.height / 2));
    }

    canvas.drawCircle(c, r + 6, Paint()
      ..color = const Color(0xFFFFC107).withOpacity(0.5)
      ..style = PaintingStyle.stroke ..strokeWidth = 3);
    canvas.drawCircle(c, 20, Paint()..color = const Color(0xFFFFC107));
  }

  @override
  bool shouldRepaint(_) => true;
}
