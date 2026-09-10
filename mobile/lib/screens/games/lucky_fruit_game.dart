
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../services/api.dart';
import '../../services/local_db.dart';

class LuckyFruitGame extends StatefulWidget {
  const LuckyFruitGame({super.key});
  @override
  State<LuckyFruitGame> createState() => _LuckyFruitGameState();
}

class _LuckyFruitGameState extends State<LuckyFruitGame> {
  int _balance = 0;
  int _bet = 1000;
  int _round = 1790;
  int _jackpot = 23237278;
  bool _spinning = false;
  int _activeIdx = -1;

  static const List<Map<String, dynamic>> fruits = [
    {'e': '🍊', 'm': 5}, {'e': '🍋', 'm': 5}, {'e': '🍇', 'm': 5},
    {'e': '🍒', 'm': 5}, {'e': '30', 'm': 0}, {'e': '🍏', 'm': 10},
    {'e': '🍉', 'm': 15}, {'e': '🍑', 'm': 25}, {'e': '🍓', 'm': 45},
  ];

  @override
  void initState() {
    super.initState();
    _balance = LocalDB.getBalance() > 0 ? LocalDB.getBalance() : 69644;
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
      await Api.dio.post('/lucky-fruit/spin', data: {'bet': _bet});
    } catch (_) {}

    for (int i = 0; i < 20; i++) {
      await Future.delayed(const Duration(milliseconds: 80));
      if (!mounted) return;
      setState(() => _activeIdx = math.Random().nextInt(fruits.length));
    }

    final winIdx = math.Random().nextInt(fruits.length);
    final mult = fruits[winIdx]['m'] as int;
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
        SnackBar(content: Text('+' + win.toString() + ' coin! x' + mult.toString()),
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
            colors: [Color(0xFF8B4513), Color(0xFF3E1F0A)],
          ),
        ),
        child: SafeArea(
          child: Column(children: [
            _topBar(),
            _jackpotHeader(),
            Expanded(child: _grid()),
            _chips(),
            _bottomBar(),
          ]),
        ),
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        const Spacer(),
        Column(children: [
          const Text('Lucky Fruit', style: TextStyle(
            color: Colors.white, fontSize: 22,
            fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
          Text('Bugunun turu $_round', style: TextStyle(
            color: Colors.white.withOpacity(0.7), fontSize: 11)),
        ]),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ]),
    );
  }

  Widget _jackpotHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: [
        ShaderMask(
          shaderCallback: (r) => const LinearGradient(colors: [
            Color(0xFFFFD700), Color(0xFFFF6B35),
            Color(0xFFFFD700)]).createShader(r),
          child: const Text('JACKPOT', style: TextStyle(
            color: Colors.white, fontSize: 30,
            fontWeight: FontWeight.bold, letterSpacing: 4,
            shadows: [Shadow(color: Colors.black, blurRadius: 8)])),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [
              Color(0xFF4A0000), Color(0xFF8B0000)]),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFFC107), width: 2),
          ),
          child: Text(_fmt(_jackpot), style: const TextStyle(
            color: Color(0xFFFFC107), fontSize: 24, fontWeight: FontWeight.bold)),
        ),
      ]),
    );
  }

  Widget _grid() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [
          Color(0xFF3E1F0A), Color(0xFF6B3410)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFC107), width: 3),
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, mainAxisSpacing: 6, crossAxisSpacing: 6),
        itemCount: fruits.length,
        itemBuilder: (_, i) {
          final active = _activeIdx == i;
          final f = fruits[i];
          return Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(0xFF2A1A0A), Color(0xFF1A0A00)]),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: active ? const Color(0xFFFFC107) : Colors.white12,
                width: active ? 3 : 1),
              boxShadow: active ? [BoxShadow(
                color: const Color(0xFFFFC107).withOpacity(0.6),
                blurRadius: 16, spreadRadius: 2)] : null,
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(f['e'] as String, style: const TextStyle(fontSize: 42)),
                const SizedBox(height: 4),
                Text((f['m'] as int) > 0
                  ? (f['m'] as int).toString() + ' kat kazan'
                  : 'WILD', style: const TextStyle(
                  color: Color(0xFFFFC107), fontSize: 10,
                  fontWeight: FontWeight.bold)),
              ]),
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
            child: Column(children: [
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: sel
                    ? [const Color(0xFFFFC107), const Color(0xFFFF6B35)]
                    : [const Color(0xFF6B3410), const Color(0xFF3E1F0A)]),
                  border: Border.all(color: sel ? Colors.white : Colors.white24, width: 2),
                  boxShadow: sel ? [BoxShadow(
                    color: const Color(0xFFFFC107).withOpacity(0.6),
                    blurRadius: 16, spreadRadius: 2)] : null,
                ),
                child: Center(child: Text(_fmt(c), style: TextStyle(
                  color: sel ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold, fontSize: 13))),
              ),
            ]),
          );
        }).toList(),
      ),
    );
  }

  Widget _bottomBar() {
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
            const Text('Coins bakiyesi', style: TextStyle(
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
}
