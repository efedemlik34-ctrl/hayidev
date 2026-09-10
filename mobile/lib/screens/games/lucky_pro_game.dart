
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../services/api.dart';
import '../../services/local_db.dart';

class LuckyProGame extends StatefulWidget {
  const LuckyProGame({super.key});
  @override
  State<LuckyProGame> createState() => _LuckyProGameState();
}

class _LuckyProGameState extends State<LuckyProGame> {
  int _balance = 0;
  int _bet = 1000;
  int _round = 1789;
  int _jackpot = 24859298;
  bool _spinning = false;
  int _activeIdx = -1;
  int _countdown = 4;

  static const List<Map<String, dynamic>> items = [
    {'e': '🍊', 'm': 5}, {'e': '🍋', 'm': 5}, {'e': '🍇', 'm': 5},
    {'e': '🍒', 'm': 5}, {'e': 'Lucky', 'm': 0}, {'e': '⏱️', 'm': 0},
    {'e': 'Lucky', 'm': 0}, {'e': '🍏', 'm': 10}, {'e': '🍉', 'm': 15},
    {'e': '🍑', 'm': 25}, {'e': '🍓', 'm': 45},
  ];

  @override
  void initState() {
    super.initState();
    _balance = LocalDB.getBalance() > 0 ? LocalDB.getBalance() : 69644;
    _tick();
  }

  void _tick() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _countdown = _countdown > 0 ? _countdown - 1 : 4);
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
      await Api.dio.post('/lucky-pro/spin', data: {'bet': _bet});
    } catch (_) {}

    for (int i = 0; i < 20; i++) {
      await Future.delayed(const Duration(milliseconds: 80));
      if (!mounted) return;
      setState(() => _activeIdx = math.Random().nextInt(items.length));
    }

    final winIdx = math.Random().nextInt(items.length);
    final mult = items[winIdx]['m'] as int;
    final win = _bet * mult;

    setState(() {
      _activeIdx = winIdx;
      _balance += win;
      _spinning = false;
      _round++;
    });
    LocalDB.setBalance(_balance);

    if (win > 0 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('+' + win.toString() + ' x' + mult.toString()),
          backgroundColor: Colors.green));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF8B0000), Color(0xFF3E0000)],
          ),
        ),
        child: SafeArea(
          child: Column(children: [
            _title(),
            _jackpotBar(),
            Expanded(child: _grid()),
            _chips(),
            _bottom(),
          ]),
        ),
      ),
    );
  }

  Widget _title() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(children: [
        IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context)),
        const Spacer(),
        Column(children: [
          ShaderMask(
            shaderCallback: (r) => const LinearGradient(colors: [
              Color(0xFFFFD700), Color(0xFFFF6B35)]).createShader(r),
            child: const Text('Lucky Pro', style: TextStyle(
              color: Colors.white, fontSize: 26,
              fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
          ),
          Text('Bugunun turu $_round', style: TextStyle(
            color: Colors.white.withOpacity(0.7), fontSize: 11)),
        ]),
        const Spacer(),
        IconButton(icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context)),
      ]),
    );
  }

  Widget _jackpotBar() {
    return Column(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [
            Color(0xFF4A0000), Color(0xFF8B0000)]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFFC107), width: 2),
        ),
        child: Text('time-limited ⏱️', style: const TextStyle(
          color: Color(0xFFFFC107), fontSize: 11, fontWeight: FontWeight.bold)),
      ),
      const SizedBox(height: 4),
      ShaderMask(
        shaderCallback: (r) => const LinearGradient(colors: [
          Color(0xFFFFD700), Color(0xFFFF6B35)]).createShader(r),
        child: const Text('JACKPOT', style: TextStyle(
          color: Colors.white, fontSize: 28,
          fontWeight: FontWeight.bold, letterSpacing: 3)),
      ),
      Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [
            Color(0xFF4A0000), Color(0xFF8B0000)]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFFC107), width: 2),
        ),
        child: Text(_fmtJ(_jackpot), style: const TextStyle(
          color: Color(0xFFFFC107), fontSize: 22, fontWeight: FontWeight.bold)),
      ),
    ]);
  }

  Widget _grid() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [
          Color(0xFF6B0000), Color(0xFF3E0000)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFC107), width: 3),
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, mainAxisSpacing: 6, crossAxisSpacing: 6,
          childAspectRatio: 1),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final active = _activeIdx == i;
          final it = items[i];
          final isLucky = it['e'] == 'Lucky';
          final isTimer = it['e'] == '⏱️';
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: isLucky
                ? [const Color(0xFFFFD700), const Color(0xFFFF6B35)]
                : [const Color(0xFF2A0A0A), const Color(0xFF1A0000)]),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: active ? const Color(0xFFFFC107) : Colors.white12,
                width: active ? 3 : 1),
              boxShadow: active ? [BoxShadow(
                color: const Color(0xFFFFC107).withOpacity(0.7),
                blurRadius: 16, spreadRadius: 2)] : null,
            ),
            child: Center(child: isTimer
              ? Text('$_countdown', style: const TextStyle(
                  color: Color(0xFFFFC107), fontSize: 30,
                  fontWeight: FontWeight.bold))
              : Column(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(it['e'] as String, style: TextStyle(
                    fontSize: isLucky ? 22 : 34,
                    fontWeight: FontWeight.bold,
                    color: isLucky ? Colors.black : Colors.white)),
                  if ((it['m'] as int) > 0)
                    Text((it['m'] as int).toString() + ' kez',
                      style: const TextStyle(color: Color(0xFFFFC107),
                        fontSize: 9, fontWeight: FontWeight.bold)),
                ])),
          );
        },
      ),
    );
  }

  Widget _chips() {
    final chips = [1000, 10000, 100000, 500000];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: chips.map((c) {
          final sel = _bet == c;
          return GestureDetector(
            onTap: () => setState(() => _bet = c),
            child: Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: sel
                  ? [const Color(0xFFFFC107), const Color(0xFFFF6B35)]
                  : [const Color(0xFF4A0000), const Color(0xFF2A0000)]),
                border: Border.all(color: sel ? Colors.white : Colors.white24, width: 2),
                boxShadow: sel ? [BoxShadow(
                  color: const Color(0xFFFFC107).withOpacity(0.6),
                  blurRadius: 16)] : null,
              ),
              child: Center(child: Text(_fmt(c), style: TextStyle(
                color: sel ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold, fontSize: 13))),
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
            border: Border.all(color: const Color(0xFFFFC107).withOpacity(0.4)),
          ),
          child: Column(children: [
            const Text('Mavi elmas bakiyesi', style: TextStyle(
              color: Colors.white70, fontSize: 10)),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.monetization_on, color: Color(0xFFFFC107), size: 14),
              const SizedBox(width: 4),
              Text(_balance.toString(), style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            ]),
          ]),
        )),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _spinning ? null : _spin,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              gradient: _spinning
                ? LinearGradient(colors: [Colors.grey.shade700, Colors.grey.shade900])
                : const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(_spinning ? '...' : 'SPIN', style: const TextStyle(
              color: Colors.white, fontSize: 16,
              fontWeight: FontWeight.bold, letterSpacing: 2)),
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
