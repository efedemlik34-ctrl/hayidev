
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../services/api.dart';
import '../../services/local_db.dart';

class JackpotEagleGame extends StatefulWidget {
  const JackpotEagleGame({super.key});
  @override
  State<JackpotEagleGame> createState() => _JackpotEagleGameState();
}

class _JackpotEagleGameState extends State<JackpotEagleGame> {
  int _balance = 0;
  int _bet = 500;
  int _win = 0;
  int _jackpot = 2003052775;
  bool _spinning = false;
  late List<List<String>> _grid;
  final _rand = math.Random();

  static const List<String> _symbols = [
    'Q', 'A', 'K', 'J', '🦅', '🎁', '💎',
  ];

  @override
  void initState() {
    super.initState();
    _balance = LocalDB.getBalance() > 0 ? LocalDB.getBalance() : 69644;
    _grid = List.generate(3, (_) => List.generate(3,
        (_) => _symbols[_rand.nextInt(_symbols.length)]));
  }

  Color _symbolColor(String s) {
    if (s == 'Q') return Colors.purple.shade400;
    if (s == 'A') return Colors.pink.shade400;
    if (s == 'K') return Colors.green.shade400;
    if (s == 'J') return Colors.orange.shade400;
    return Colors.white;
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
      await Api.dio.post('/jackpot-eagle/spin', data: {'bet': _bet});
    } catch (_) {}

    for (int i = 0; i < 15; i++) {
      await Future.delayed(const Duration(milliseconds: 90));
      if (!mounted) return;
      setState(() {
        _grid = List.generate(3, (_) => List.generate(3,
            (_) => _symbols[_rand.nextInt(_symbols.length)]));
      });
    }

    int win = 0;
    for (int row = 0; row < 3; row++) {
      final first = _grid[0][row];
      if (_grid[1][row] == first && _grid[2][row] == first) {
        win += _bet * (first == '🦅' ? 50 : first == '💎' ? 30 : 10);
      }
    }

    setState(() {
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
            colors: [Color(0xFF8B0000), Color(0xFF4A0000)],
          ),
        ),
        child: SafeArea(
          child: Column(children: [
            _title(),
            _jackpotBar(),
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
        IconButton(icon: const Icon(Icons.music_note, color: Colors.white),
          onPressed: () {}),
        IconButton(icon: const Icon(Icons.list, color: Colors.white),
          onPressed: () {}),
        const Spacer(),
        ShaderMask(
          shaderCallback: (r) => const LinearGradient(colors: [
            Color(0xFFFFD700), Color(0xFFFF6B35)]).createShader(r),
          child: const Text('JACKPOT SLOTS', style: TextStyle(
            color: Colors.white, fontSize: 20,
            fontWeight: FontWeight.bold, letterSpacing: 2)),
        ),
        const Spacer(),
        IconButton(icon: const Icon(Icons.help, color: Colors.white),
          onPressed: () {}),
        IconButton(icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context)),
      ]),
    );
  }

  Widget _jackpotBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [
          Color(0xFFFFC107), Color(0xFFFF8C00), Color(0xFFFFC107)]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.red.shade900, width: 3),
        boxShadow: [BoxShadow(
          color: const Color(0xFFFFC107).withOpacity(0.7),
          blurRadius: 20, spreadRadius: 3)],
      ),
      child: Text(_fmtJ(_jackpot), textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF4A0000), fontSize: 22,
          fontWeight: FontWeight.bold)),
    );
  }

  Widget _reels() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [
          Color(0xFF8B0000), Color(0xFF4A0000)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFC107), width: 4),
        boxShadow: [BoxShadow(
          color: const Color(0xFFFFC107).withOpacity(0.4),
          blurRadius: 20, spreadRadius: 2)],
      ),
      child: Row(
        children: List.generate(3, (col) => Expanded(
          child: Column(
            children: List.generate(3, (row) => Expanded(
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: const Color(0xFF6A0000),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.purple.shade700, width: 2),
                ),
                child: Center(child: Text(
                  _grid[col][row],
                  style: TextStyle(
                    fontSize: _grid[col][row].length > 1 ? 34 : 42,
                    color: _symbolColor(_grid[col][row]),
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(2, 2), blurRadius: 4)],
                  ),
                )),
              ),
            )),
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
        gradient: const LinearGradient(colors: [
          Color(0xFF6A1EA0), Color(0xFF4A148C)]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _stat('donus cizgisi', '27'),
          _stat('toplam donus', '${_bet * 27}'),
          _stat('kazanc', _win.toString()),
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
          Color(0xFF9C27B0), Color(0xFF4A148C)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: [
        Row(children: [
          GestureDetector(
            onTap: () => setState(() => _bet = (_bet - 100).clamp(100, 10000)),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [
                  Color(0xFFFFC107), Color(0xFFFF8C00)]),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Center(child: Text('—', style: TextStyle(
                color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold))),
            ),
          ),
          Expanded(child: Center(child: Text(_bet.toString(),
            style: const TextStyle(color: Colors.white, fontSize: 24,
              fontWeight: FontWeight.bold)))),
          GestureDetector(
            onTap: () => setState(() => _bet = (_bet + 100).clamp(100, 10000)),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [
                  Color(0xFFFFC107), Color(0xFFFF8C00)]),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Center(child: Text('+', style: TextStyle(
                color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold))),
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
              child: const Center(child: Text('AUTO', style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
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
                    Color(0xFF4CAF50), Color(0xFF2E7D32)]),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(child: Text(_spinning ? '...' : 'SPIN',
                style: const TextStyle(color: Colors.white, fontSize: 18,
                  fontWeight: FontWeight.bold))),
            ),
          )),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          const Icon(Icons.monetization_on, color: Color(0xFFFFC107)),
          const SizedBox(width: 4),
          Text(_balance.toString(), style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [
                Color(0xFF42A5F5), Color(0xFF1565C0)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text('Yeniden sarj et', style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
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
