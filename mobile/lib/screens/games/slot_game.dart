
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../services/api.dart';
import '../../services/local_db.dart';

class SlotGame extends StatefulWidget {
  const SlotGame({super.key});
  @override
  State<SlotGame> createState() => _SlotGameState();
}

class _SlotGameState extends State<SlotGame> {
  int _balance = 0;
  int _bet = 1000;
  int _win = 0;
  bool _spinning = false;
  late List<List<String>> _grid;
  final _rand = math.Random();
  static const List<String> _symbols = ['9', '10', 'J', 'Q', 'K', 'A', '🐉', '🦁', '🦅', '💎'];

  @override
  void initState() {
    super.initState();
    _balance = LocalDB.getBalance() > 0 ? LocalDB.getBalance() : 68644;
    _grid = List.generate(5, (_) => List.generate(4,
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
      await Api.dio.post('/slot/spin', data: {'bet': _bet});
    } catch (_) {}

    for (int tick = 0; tick < 15; tick++) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
      setState(() {
        _grid = List.generate(5, (_) => List.generate(4,
            (_) => _symbols[_rand.nextInt(_symbols.length)]));
      });
    }

    final finalGrid = List.generate(5, (_) => List.generate(4,
        (_) => _symbols[_rand.nextInt(_symbols.length)]));
    int win = 0;
    for (int row = 0; row < 4; row++) {
      final first = finalGrid[0][row];
      int count = 1;
      for (int col = 1; col < 5; col++) {
        if (finalGrid[col][row] == first) count++;
        else break;
      }
      if (count >= 3) {
        final mult = count == 5 ? 50 : count == 4 ? 10 : 3;
        win += _bet * mult;
      }
    }

    setState(() {
      _grid = finalGrid;
      _win = win;
      _balance += win;
      _spinning = false;
    });
    await await LocalDB.setBalance(_balance);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0033),
      appBar: AppBar(
        title: const Text('Pyramid Slots'),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF2A1A4A), Color(0xFF0F0A1E)],
          ),
        ),
        child: Column(children: [
          _jackpots(),
          Expanded(child: _reels()),
          _controls(),
        ]),
      ),
    );
  }

  Widget _jackpots() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        children: [
          _jackpotBox('GRAND', '40,000', Colors.red.shade900),
          _jackpotBox('MAJOR', '20,000', Colors.purple.shade900),
          _jackpotBox('MINOR', '10,000', Colors.blue.shade900),
          _jackpotBox('MINI', '5,000', Colors.green.shade900),
        ],
      ),
    );
  }

  Widget _jackpotBox(String label, String value, Color c) {
    return Expanded(child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFC107), width: 1.5),
      ),
      child: Column(children: [
        Text(label, style: const TextStyle(
          color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(
          color: Color(0xFFFFC107), fontSize: 12, fontWeight: FontWeight.bold)),
      ]),
    ));
  }

  Widget _reels() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [
          Color(0xFF4A3A1A), Color(0xFF2A1A0A)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFC107), width: 3),
      ),
      child: Row(
        children: List.generate(5, (col) => Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Color(0xFF1E0F3E), Color(0xFF2E1A5E)]),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              children: List.generate(4, (row) => Expanded(
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A1A4A).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(child: Text(
                    _grid[col][row],
                    style: TextStyle(
                      fontSize: 30,
                      color: _isSymbol(_grid[col][row])
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
    );
  }

  bool _isSymbol(String s) => ['🐉', '🦁', '🦅', '💎'].contains(s);

  Widget _controls() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        Row(
          children: [
            _stat('BET', _fmt(_bet), Colors.blue.shade800),
            const SizedBox(width: 8),
            _stat('WIN', _fmt(_win), Colors.green.shade800),
            const SizedBox(width: 8),
            _stat('BALANCE', _fmt(_balance), Colors.purple.shade800),
          ],
        ),
        const SizedBox(height: 12),
        Row(children: [
          GestureDetector(
            onTap: () => setState(() => _bet = (_bet ~/ 2).clamp(100, 1000000)),
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: Colors.blue.shade900,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.remove, color: Colors.white),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _spinning ? null : _spin,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
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
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: Colors.blue.shade900,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _stat(String label, String value, Color c) {
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(10),
      ),
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
