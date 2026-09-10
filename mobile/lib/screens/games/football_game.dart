
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../services/api.dart';
import '../../services/local_db.dart';

class FootballGame extends StatefulWidget {
  const FootballGame({super.key});
  @override
  State<FootballGame> createState() => _FootballGameState();
}

class _FootballGameState extends State<FootballGame> {
  int _balance = 0;
  int _bet = 1000;
  int _round = 1923;
  int _countdown = 12;
  int _selectedTeam = -1;
  Map<int, int> _myBets = {};

  static const List<Map<String, dynamic>> teams = [
    {'n': 'Fenerbahce', 'e': '🟡', 'm': 100, 'c': Colors.yellow},
    {'n': 'Galatasaray', 'e': '🔴', 'm': 100, 'c': Colors.red},
    {'n': 'Besiktas', 'e': '⚫', 'm': 20, 'c': Colors.black},
    {'n': 'Trabzonspor', 'e': '🔵', 'm': 20, 'c': Colors.blue},
    {'n': 'Adana Demir', 'e': '🟢', 'm': 8, 'c': Colors.green},
    {'n': 'Kayserispor', 'e': '🟠', 'm': 3, 'c': Colors.orange},
    {'n': 'Sivasspor', 'e': '🔴', 'm': 3, 'c': Colors.redAccent},
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
      if (_countdown > 0) {
        setState(() => _countdown--);
        _tick();
      } else {
        _play();
      }
    });
  }

  Future<void> _play() async {
    if (_myBets.isEmpty) {
      setState(() => _countdown = 12);
      _tick();
      return;
    }
    try {
      await Api.dio.post('/football/bet', data: {
        'bets': _myBets, 'round': _round,
      });
    } catch (_) {}

    await Future.delayed(const Duration(seconds: 2));

    final winIdx = math.Random().nextInt(teams.length);
    final mult = teams[winIdx]['m'] as int;
    final myBet = _myBets[winIdx] ?? 0;
    final win = myBet * mult;

    setState(() {
      _balance += win;
      _myBets.clear();
      _round++;
      _countdown = 12;
    });
    LocalDB.setBalance(_balance);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(teams[winIdx]['n'] + ' kazandi! x' + mult.toString()),
          backgroundColor: win > 0 ? Colors.green : Colors.red));
    }
    _tick();
  }

  void _placeBet(int idx) {
    if (_balance < _bet) return;
    setState(() {
      _balance -= _bet;
      _myBets[idx] = (_myBets[idx] ?? 0) + _bet;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF1E88E5), Color(0xFF0A4A26), Color(0xFF1B5E20)],
          ),
        ),
        child: SafeArea(
          child: Column(children: [
            _header(),
            Expanded(child: _stadium()),
            _bottom(),
          ]),
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(children: [
        IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context)),
        const Spacer(),
        Column(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [
                Color(0xFF00BCD4), Color(0xFF4CAF50)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text('$_round. Tur', style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        ]),
        const Spacer(),
        IconButton(icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context)),
      ]),
    );
  }

  Widget _stadium() {
    return Column(children: [
      Expanded(child: _teamCircle()),
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text('Yuksek getiri, yuksek oran', style: TextStyle(
          color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center),
      ),
      const SizedBox(height: 12),
      const Text('Zaman Sec', style: TextStyle(
        color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [
            Color(0xFF00BCD4), Color(0xFF4CAF50)]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Text('$_countdown', style: const TextStyle(
          color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
      ),
      const SizedBox(height: 12),
    ]);
  }

  Widget _teamCircle() {
    return LayoutBuilder(builder: (ctx, cst) {
      final w = cst.maxWidth;
      return Stack(children: [
        Positioned(left: w * 0.05, top: 30,
          child: _teamBadge(0, w * 0.32)),
        Positioned(left: w * 0.34, top: 0,
          child: _teamBadge(1, w * 0.32)),
        Positioned(left: w * 0.65, top: 30,
          child: _teamBadge(2, w * 0.32)),
        Positioned(left: w * 0.34, top: 130,
          child: _teamBadge(3, w * 0.32)),
        Positioned(left: w * 0.05, top: 190,
          child: _teamBadge(4, w * 0.32)),
        Positioned(left: w * 0.34, top: 200,
          child: _teamBadge(5, w * 0.32)),
        Positioned(left: w * 0.65, top: 190,
          child: _teamBadge(6, w * 0.32)),
      ]);
    });
  }

  Widget _teamBadge(int idx, double size) {
    final t = teams[idx];
    final myBet = _myBets[idx] ?? 0;
    final c = t['c'] as Color;
    return GestureDetector(
      onTap: () => _placeBet(idx),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(children: [
            const Icon(Icons.people, color: Colors.white, size: 12),
            const SizedBox(width: 2),
            const Text('12.41K', style: TextStyle(
              color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ]),
        ),
        const SizedBox(height: 2),
        Container(
          width: size, height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [c.withOpacity(0.9), c.withOpacity(0.5)]),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: myBet > 0 ? [BoxShadow(
              color: const Color(0xFFFFC107),
              blurRadius: 20, spreadRadius: 3)] : null,
          ),
          child: Center(child: Text(t['e'] as String,
            style: const TextStyle(fontSize: 32))),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text('X ${t['m']}', style: const TextStyle(
            color: Color(0xFFFFC107), fontSize: 11, fontWeight: FontWeight.bold)),
        ),
        if (myBet > 0) Text('+$myBet', style: const TextStyle(
          color: Color(0xFFFFC107), fontSize: 10, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _bottom() {
    final chips = [100, 1000, 10000, 50000];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(children: [
        Row(children: [
          const Text('Secimim', style: TextStyle(color: Colors.white70, fontSize: 11)),
          const SizedBox(width: 16),
          const Text('Tum Secimler', style: TextStyle(color: Colors.white70, fontSize: 11)),
          const Spacer(),
          const Text('Populer', style: TextStyle(color: Colors.white70, fontSize: 11)),
        ]),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: chips.map((c) {
            final sel = _bet == c;
            return GestureDetector(
              onTap: () => setState(() => _bet = c),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: sel
                    ? [const Color(0xFF4CAF50), const Color(0xFF2E7D32)]
                    : [const Color(0xFF00BCD4), const Color(0xFF0277BD)]),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: sel ? Colors.white : Colors.white24, width: 2),
                ),
                child: Text(_fmt(c), style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.monetization_on, color: Color(0xFFFFC107)),
          const SizedBox(width: 4),
          Text(_balance.toString(), style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold)),
          const Spacer(),
          const Text('Bugun Kazananlar ', style: TextStyle(
            color: Colors.white70, fontSize: 11)),
          const Icon(Icons.monetization_on, color: Color(0xFFFFC107), size: 14),
          const Text(' 0', style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        ]),
      ]),
    );
  }

  String _fmt(int n) {
    if (n >= 1000) return (n ~/ 1000).toString() + 'K';
    return n.toString();
  }
}
