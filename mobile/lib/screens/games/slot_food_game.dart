
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../services/api.dart';
import '../../services/local_db.dart';

class SlotFoodGame extends StatefulWidget {
  const SlotFoodGame({super.key});
  @override
  State<SlotFoodGame> createState() => _SlotFoodGameState();
}

class _SlotFoodGameState extends State<SlotFoodGame> {
  int _balance = 0;
  int _bet = 600;
  int _win = 0;
  int _jackpot = 993154570;
  bool _spinning = false;
  late List<List<String>> _grid;
  final _rand = math.Random();

  static const List<String> _symbols = [
    '🍟', '🥤', '🎲', '🍊', '🍌', '🍔', '🍕', '🍒', '🎁',
  ];

  @override
  void initState() {
    super.initState();
    _balance = LocalDB.getBalance() > 0 ? LocalDB.getBalance() : 69644;
    _grid = List.generate(5, (_) => List.generate(3,
        (_) => _symbols[_rand.nextInt(_symbols.length)]));
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
      _win = 0;
    });
    try {
      await Api.dio.post('/slot-food/spin', data: {'bet': _bet});
    } catch (_) {}

    for (int i = 0; i < 15; i++) {
      await Future.delayed(const Duration(milliseconds: 90));
      if (!mounted) return;
      setState(() {
        _grid = List.generate(5, (_) => List.generate(3,
            (_) => _symbols[_rand.nextInt(_symbols.length)]));
      });
    }

    final fg = List.generate(5, (_) => List.generate(3,
        (_) => _symbols[_rand.nextInt(_symbols.length)]));
    int win = 0;
    for (int row = 0; row < 3; row++) {
      final first = fg[0][row];
      int count = 1;
      for (int col = 1; col < 5; col++) {
        if (fg[col][row] == first) count++; else break;
      }
      if (count >= 3) {
        win += _bet * (count == 5 ? 30 : count == 4 ? 10 : 3);
      }
    }

    setState(() {
      _grid = fg;
      _win = win;
      _balance += win;
      _spinning = false;
    });
    LocalDB.setBalance(_balance);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF6A1EA0), Color(0xFF2A0F5E)],
          ),
        ),
        child: SafeArea(
          child: Column(children: [
            _title(),
            _jackpotBanner(),
            Expanded(child: _reels()),
            _stats(),
            _controls(),
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
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('⭐⭐⭐', style: TextStyle(fontSize: 18)),
          ]),
          ShaderMask(
            shaderCallback: (r) => const LinearGradient(colors: [
              Color(0xFFFFD700), Color(0xFFFF6B35)]).createShader(r),
            child: const Text('JACKPOT', style: TextStyle(
              color: Colors.white, fontSize: 26,
              fontWeight: FontWeight.bold, letterSpacing: 3)),
          ),
        ]),
        const Spacer(),
        IconButton(icon: const Icon(Icons.apps, color: Colors.white),
          onPressed: () {}),
      ]),
    );
  }

  Widget _jackpotBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [
          Color(0xFF4A148C), Color(0xFF6A1EA0)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFC107), width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('●  ', style: TextStyle(color: Colors.cyanAccent, fontSize: 14)),
          Text(_fmtJ(_jackpot), style: const TextStyle(
            color: Color(0xFFFFC107), fontSize: 22, fontWeight: FontWeight.bold)),
          const Text('  ●', style: TextStyle(color: Colors.cyanAccent, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _reels() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [
          Color(0xFF9C27B0), Color(0xFF4A148C)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFC107), width: 3),
      ),
      child: Row(
        children: List.generate(5, (col) => Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [
                Color(0xFFE8EAF6), Color(0xFFB39DDB)]),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              children: List.generate(3, (row) => Expanded(
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E5F5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(child: Text(
                    _grid[col][row],
                    style: const TextStyle(fontSize: 30))),
                ),
              )),
            ),
          ),
        )),
      ),
    );
  }

  Widget _stats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _stat('Cizgi', '9'),
          _stat('Toplam maliyet', '${_bet * 9}'),
          _stat('Bu turda kazandiniz', _win.toString()),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(children: [
      Text(label, style: const TextStyle(
        color: Colors.white70, fontSize: 10)),
      Text(value, style: const TextStyle(
        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
    ]);
  }

  Widget _controls() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [
          Color(0xFF9C27B0), Color(0xFF6A1EA0)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: [
        Row(children: [
          GestureDetector(
            onTap: () => setState(() => _bet = (_bet - 100).clamp(100, 100000)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('—', style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(child: Center(child: Text(_bet.toString(),
            style: const TextStyle(color: Colors.white, fontSize: 24,
              fontWeight: FontWeight.bold)))),
          GestureDetector(
            onTap: () => setState(() => _bet = (_bet + 100).clamp(100, 100000)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('+', style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: GestureDetector(
            onTap: _spinning ? null : _spin,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [
                  Color(0xFF42A5F5), Color(0xFF1565C0)]),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Center(child: Text('Otomatik', style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
            ),
          )),
          const SizedBox(width: 10),
          Expanded(child: GestureDetector(
            onTap: _spinning ? null : _spin,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: _spinning
                  ? LinearGradient(colors: [Colors.grey.shade700, Colors.grey.shade900])
                  : const LinearGradient(colors: [
                    Color(0xFFFFC107), Color(0xFFFF6B35)]),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(child: Text(_spinning ? '...' : 'Donus',
                style: const TextStyle(color: Colors.white, fontSize: 16,
                  fontWeight: FontWeight.bold))),
            ),
          )),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          const Icon(Icons.monetization_on, color: Color(0xFFFFC107)),
          const SizedBox(width: 4),
          const Text('Bakiye: ', style: TextStyle(color: Colors.white70)),
          Text(_balance.toString(), style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('Sarj', style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ]),
      ]),
    );
  }

  String _fmtJ(int n) {
    return n.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => m[1]! + '.');
  }
}
