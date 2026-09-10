
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../services/api.dart';
import '../../services/local_db.dart';

class GoldenFortuneGame extends StatefulWidget {
  const GoldenFortuneGame({super.key});
  @override
  State<GoldenFortuneGame> createState() => _GoldenFortuneGameState();
}

class _GoldenFortuneGameState extends State<GoldenFortuneGame> {
  int _balance = 0;
  int _bet = 50000;
  int _win = 0;
  bool _spinning = false;
  late List<List<String>> _grid;
  final _rand = math.Random();

  static const List<String> _symbols = [
    '9', '10', 'J', 'Q', 'K', 'A', '🐢', '🐉', '🦁', '🦅', '🐟', '🧧',
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
      await Api.dio.post('/golden-fortune/spin', data: {'bet': _bet});
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
        win += _bet * (count == 5 ? 60 : count == 4 ? 15 : 4);
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
            colors: [Color(0xFF6A1EA0), Color(0xFF2A0F5E), Color(0xFF1A0520)],
          ),
        ),
        child: SafeArea(
          child: Column(children: [
            _title(),
            _jackpots(),
            Expanded(child: _godImage()),
            _reels(),
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
        IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context)),
        const Spacer(),
        const Text('Golden Fortune', style: TextStyle(
          color: Color(0xFFFFC107), fontSize: 22,
          fontWeight: FontWeight.bold, letterSpacing: 1)),
        const Spacer(),
        IconButton(icon: const Icon(Icons.grid_view, color: Colors.white),
          onPressed: () {}),
      ]),
    );
  }

  Widget _jackpots() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(children: [
        _jackpot('GRAND', '78,571,200', Colors.red.shade900, '👑'),
        const SizedBox(height: 4),
        _jackpot('MEGA', '11,664,600', Colors.purple.shade900, '🦅'),
        const SizedBox(height: 4),
        Row(children: [
          Expanded(child: _jackpot('MAJOR', '11,428,200', Colors.orange.shade900, '👑')),
          const SizedBox(width: 4),
          Expanded(child: _jackpot('MINOR', '1,250,000', Colors.blue.shade900, '🏆')),
          const SizedBox(width: 4),
          Expanded(child: _jackpot('MINI', '500,000', Colors.green.shade900, '🦁')),
        ]),
      ]),
    );
  }

  Widget _jackpot(String label, String value, Color c, String emoji) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [c, c.withOpacity(0.7)]),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFC107), width: 2),
      ),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 6),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(
              color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            Text(value, style: const TextStyle(
              color: Color(0xFFFFC107), fontSize: 14, fontWeight: FontWeight.bold)),
          ]),
        ),
      ]),
    );
  }

  Widget _godImage() {
    return Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('🧧👑🧧', style: TextStyle(fontSize: 60)),
        const Text('财神', style: TextStyle(
          color: Color(0xFFFFC107), fontSize: 40, fontWeight: FontWeight.bold)),
      ],
    ));
  }

  Widget _reels() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [
          Color(0xFF6A1EA0), Color(0xFF3A0A6A)]),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFC107), width: 3),
      ),
      child: SizedBox(
        height: 200,
        child: Row(
          children: List.generate(5, (col) => Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [
                  Color(0xFF4A148C), Color(0xFF2A0F5E)]),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                children: List.generate(3, (row) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A0520).withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(child: Text(
                      _grid[col][row],
                      style: TextStyle(
                        fontSize: 26,
                        color: _isSpecial(_grid[col][row])
                          ? const Color(0xFFFFC107) : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                  ),
                )),
              ),
            ),
          )),
        ),
      ),
    );
  }

  bool _isSpecial(String s) => ['🐢', '🐉', '🦁', '🦅', '🐟', '🧧'].contains(s);

  Widget _controls() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        Row(children: [
          _stat('BAKIYE', _fmt(_balance), Colors.purple.shade900),
          const SizedBox(width: 8),
          _stat('KAZANC', _fmt(_win), Colors.green.shade900),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          GestureDetector(
            onTap: () => setState(() => _bet = (_bet ~/ 2).clamp(100, 1000000)),
            child: Container(width: 46, height: 46,
              decoration: BoxDecoration(color: Colors.blue.shade900,
                borderRadius: BorderRadius.circular(23)),
              child: const Icon(Icons.remove, color: Colors.white)),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _spinning ? null : _spin,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 18),
              decoration: BoxDecoration(
                gradient: _spinning
                  ? LinearGradient(colors: [Colors.grey.shade700, Colors.grey.shade900])
                  : const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)]),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(
                  color: Colors.green.withOpacity(0.5),
                  blurRadius: 20, spreadRadius: 2)],
              ),
              child: Text(_spinning ? '...' : 'SPIN', style: const TextStyle(
                color: Colors.white, fontSize: 20,
                fontWeight: FontWeight.bold, letterSpacing: 3)),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => setState(() => _bet = (_bet * 2).clamp(100, 1000000)),
            child: Container(width: 46, height: 46,
              decoration: BoxDecoration(color: Colors.blue.shade900,
                borderRadius: BorderRadius.circular(23)),
              child: const Icon(Icons.add, color: Colors.white)),
          ),
        ]),
      ]),
    );
  }

  Widget _stat(String label, String value, Color c) {
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(10)),
      child: Column(children: [
        Text(label, style: const TextStyle(
          color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(
          color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      ]),
    ));
  }

  String _fmt(int n) {
    if (n >= 1000000) return (n ~/ 1000000).toString() + 'M';
    if (n >= 1000) return (n ~/ 1000).toString() + 'K';
    return n.toString();
  }
}
