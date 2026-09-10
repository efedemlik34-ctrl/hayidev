
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../services/api.dart';
import '../../services/local_db.dart';

class GreedyProGame extends StatefulWidget {
  const GreedyProGame({super.key});
  @override
  State<GreedyProGame> createState() => _GreedyProGameState();
}

class _GreedyProGameState extends State<GreedyProGame>
    with TickerProviderStateMixin {
  int _balance = 0;
  int _bet = 1000;
  int _jackpot = 20571318;
  int _countdown = 28;
  bool _spinning = false;
  late AnimationController _wheelCtrl;

  static const List<Map<String, dynamic>> items = [
    {'e': '🍅', 'm': 5}, {'e': '🥬', 'm': 5}, {'e': '🌽', 'm': 5},
    {'e': '🥕', 'm': 5}, {'e': '🌭', 'm': 10}, {'e': '🍝', 'm': 15},
    {'e': '🍖', 'm': 25}, {'e': '🥩', 'm': 45},
  ];

  @override
  void initState() {
    super.initState();
    _balance = LocalDB.getBalance() > 0 ? LocalDB.getBalance() : 69644;
    _wheelCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3));
    _tick();
  }

  void _tick() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _countdown = _countdown > 0 ? _countdown - 1 : 28);
      _tick();
    });
  }

  Future<void> _spin() async {
    if (_balance < _bet) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yetersiz bakiye'),
            backgroundColor: Colors.red));
      return;
    }
    setState(() {
      _spinning = true;
      _balance -= _bet;
    });
    try {
      await Api.dio.post('/greedy-pro/spin', data: {'bet': _bet});
    } catch (_) {}

    await _wheelCtrl.forward(from: 0);
    final idx = math.Random().nextInt(items.length);
    final mult = items[idx]['m'] as int;
    final win = _bet * mult;

    setState(() {
      _balance += win;
      _spinning = false;
    });
    LocalDB.setBalance(_balance);
    _wheelCtrl.reset();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(items[idx]['e'] + ' x' + mult.toString() +
          ' → +' + win.toString()),
          backgroundColor: Colors.green));
    }
  }

  @override
  void dispose() {
    _wheelCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF2A0F5E), Color(0xFF0F0520)],
          ),
        ),
        child: SafeArea(
          child: Column(children: [
            _jackpotBar(),
            Expanded(child: _wheel()),
            _chips(),
            _bottom(),
          ]),
        ),
      ),
    );
  }

  Widget _jackpotBar() {
    return Column(children: [
      const SizedBox(height: 8),
      ShaderMask(
        shaderCallback: (r) => const LinearGradient(colors: [
          Color(0xFFFFD700), Color(0xFFFF6B35)]).createShader(r),
        child: const Text('JACKPOT', style: TextStyle(
          color: Colors.white, fontSize: 30,
          fontWeight: FontWeight.bold, letterSpacing: 4)),
      ),
      Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [
            Color(0xFF3A0A6A), Color(0xFF6A1EA0)]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFFC107), width: 2),
        ),
        child: Text(_fmtJ(_jackpot), style: const TextStyle(
          color: Color(0xFFFFC107), fontSize: 22, fontWeight: FontWeight.bold)),
      ),
    ]);
  }

  Widget _wheel() {
    return Stack(alignment: Alignment.center, children: [
      AnimatedBuilder(
        animation: _wheelCtrl,
        builder: (_, __) => Transform.rotate(
          angle: _wheelCtrl.value * math.pi * 6,
          child: CustomPaint(
            size: const Size(320, 320),
            painter: _FoodWheelPainter(items),
          ),
        ),
      ),
      Container(
        width: 140, height: 140,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(colors: [
            Color(0xFFFFC107), Color(0xFFFF6B35)]),
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: [BoxShadow(color: const Color(0xFFFFC107).withOpacity(0.7),
            blurRadius: 30, spreadRadius: 4)],
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('👨‍🍳', style: TextStyle(fontSize: 36)),
            const Text('Greedy Pro', style: TextStyle(
              color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
            Text('$_countdown s', style: const TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
          ]),
      ),
    ]);
  }

  Widget _chips() {
    final chips = [1000, 10000, 100000, 500000, 1000000];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: chips.map((c) {
          final sel = _bet == c;
          return GestureDetector(
            onTap: () => setState(() => _bet = c),
            child: Container(
              width: 58, height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: sel
                  ? [const Color(0xFFFFC107), const Color(0xFFFF6B35)]
                  : [const Color(0xFF6A1EA0), const Color(0xFF3A0A6A)]),
                border: Border.all(color: sel ? Colors.white : Colors.white24, width: 2),
                boxShadow: sel ? [BoxShadow(
                  color: const Color(0xFFFFC107).withOpacity(0.6),
                  blurRadius: 16)] : null,
              ),
              child: Center(child: Text(_fmt(c), style: TextStyle(
                color: sel ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold, fontSize: 11))),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _bottom() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        Expanded(child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: [
            const Text('Kalan madeni paralar', style: TextStyle(
              color: Colors.white70, fontSize: 10)),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.monetization_on, color: Color(0xFFFFC107), size: 14),
              const SizedBox(width: 4),
              Text(_balance.toString(), style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            ]),
          ]),
        )),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _spinning ? null : _spin,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: _spinning
                ? LinearGradient(colors: [Colors.grey.shade700, Colors.grey.shade900])
                : const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(_spinning ? '...' : 'CEVIR', style: const TextStyle(
              color: Colors.white, fontSize: 14,
              fontWeight: FontWeight.bold, letterSpacing: 1)),
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

  String _fmtJ(int n) {
    return n.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => m[1]! + '.');
  }
}

class _FoodWheelPainter extends CustomPainter {
  final List<Map<String, dynamic>> items;
  _FoodWheelPainter(this.items);

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 10;
    const segs = 8;
    const segAngle = 2 * math.pi / segs;

    for (int i = 0; i < segs; i++) {
      final startAngle = -math.pi / 2 + i * segAngle;
      final paint = Paint()
        ..color = i % 2 == 0 ? const Color(0xFF6A1EA0) : const Color(0xFF3A0A6A)
        ..style = PaintingStyle.fill;
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        startAngle, segAngle, true, paint);

      final textAngle = startAngle + segAngle / 2;
      final tx = c.dx + math.cos(textAngle) * (r - 45);
      final ty = c.dy + math.sin(textAngle) * (r - 45);
      final tp = TextPainter(
        text: TextSpan(text: items[i]['e'] as String,
          style: const TextStyle(fontSize: 26)),
        textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(tx - tp.width / 2, ty - tp.height / 2));

      final mp = TextPainter(
        text: TextSpan(text: 'x${items[i]['m']}',
          style: const TextStyle(color: Color(0xFFFFC107),
            fontSize: 12, fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr)..layout();
      final my = c.dy + math.sin(textAngle) * (r - 15);
      mp.paint(canvas, Offset(tx - mp.width / 2, my));
    }

    canvas.drawCircle(c, r + 4, Paint()
      ..color = const Color(0xFFFFC107) ..style = PaintingStyle.stroke
      ..strokeWidth = 4);
  }

  @override
  bool shouldRepaint(_) => false;
}
