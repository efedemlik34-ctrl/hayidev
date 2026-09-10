
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../services/api.dart';
import '../../services/local_db.dart';

class BullCowboyGame extends StatefulWidget {
  const BullCowboyGame({super.key});
  @override
  State<BullCowboyGame> createState() => _BullCowboyGameState();
}

class _BullCowboyGameState extends State<BullCowboyGame> {
  int _balance = 0;
  int _bet = 1000;
  int _round = 2375;
  int _countdown = 13;
  bool _rolling = false;
  Map<String, int> _bets = {};
  String _result = '';
  int _jackpot = 977285370;

  @override
  void initState() {
    super.initState();
    _balance = LocalDB.getBalance() > 0 ? LocalDB.getBalance() : 68644;
    _startCountdown();
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      if (_countdown > 0 && !_rolling) {
        setState(() => _countdown--);
        _startCountdown();
      } else if (!_rolling) {
        _play();
      }
    });
  }

  Future<void> _play() async {
    if (_bets.isEmpty) {
      setState(() => _countdown = 13);
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
      _rolling = true;
      _balance -= total;
    });
    try {
      await Api.dio.post('/bull-cowboy/bet', data: {'bets': _bets});
    } catch (_) {}

    await Future.delayed(const Duration(seconds: 2));

    final rand = math.Random();
    final bullPts = rand.nextInt(50) + 50;
    final cowboyPts = rand.nextInt(50) + 50;
    String winner;
    if (bullPts > cowboyPts) winner = 'bull';
    else if (cowboyPts > bullPts) winner = 'cowboy';
    else winner = 'draw';

    int payout = 0;
    for (final e in _bets.entries) {
      if (e.key == winner) {
        payout += e.value * (winner == 'draw' ? 20 : 2);
      }
    }

    setState(() {
      _balance += payout;
      _result = winner.toUpperCase();
      _rolling = false;
      _round++;
    });
    await LocalDB.setBalance(_balance);

    await Future.delayed(const Duration(seconds: 3));
    setState(() {
      _bets.clear();
      _result = '';
      _countdown = 13;
    });
    _startCountdown();
  }

  void _place(String key) {
    if (_rolling) return;
    setState(() => _bets[key] = (_bets[key] ?? 0) + _bet);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8B4513),
      appBar: AppBar(
        title: const Text('Bull vs Cowboy'),
        backgroundColor: const Color(0xFF6B3410),
      ),
      body: SafeArea(
        child: Column(children: [
          _topBanner(),
          _resultRow(),
          Expanded(child: _betGrid()),
          _bottomBar(),
        ]),
      ),
    );
  }

  Widget _topBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: Colors.red.shade900,
      child: Row(children: [
        const Text('🐂', style: TextStyle(fontSize: 32)),
        const Spacer(),
        Text('BIG WIN', style: TextStyle(
          color: Colors.yellow.shade300, fontSize: 26,
          fontWeight: FontWeight.bold, letterSpacing: 3,
          shadows: [Shadow(color: Colors.orange, blurRadius: 10)])),
        const Spacer(),
        const Text('🤠', style: TextStyle(fontSize: 32)),
      ]),
    );
  }

  Widget _resultRow() {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.brown.shade800,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: [
        Row(children: [
          Text('Sonuç', style: TextStyle(
            color: Colors.yellow.shade300, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          ...List.generate(7, (i) => Container(
            width: 10, height: 10,
            margin: const EdgeInsets.only(right: 3),
            decoration: BoxDecoration(
              color: i < 3 ? Colors.red : Colors.blue,
              shape: BoxShape.circle,
            ),
          )),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.orange.shade700,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('$_countdown s', style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
          ),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text('3♦', style: TextStyle(
              color: Colors.red, fontSize: 28, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 6),
          ...List.generate(4, (_) => Container(
            width: 40, height: 55,
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [
                Color(0xFF8B0000), Color(0xFF4A0000)]),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFFFC107), width: 1),
            ),
            child: const Center(child: Text('♦', style: TextStyle(
              color: Color(0xFFFFC107), fontSize: 20))),
          )),
        ]),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('Tur $_round', style: const TextStyle(
            color: Colors.white70, fontSize: 11)),
          const SizedBox(width: 12),
          Text('JACKPOT | ${_fmtJ(_jackpot)}',
            style: TextStyle(color: Colors.yellow.shade300,
              fontWeight: FontWeight.bold, fontSize: 13)),
        ]),
      ]),
    );
  }

  Widget _betGrid() {
    final opts = [
      {'k': 'bull', 'n': 'Bull Win', 'm': 'x2', 'c': Colors.brown.shade700},
      {'k': 'draw', 'n': 'Draw', 'm': 'x20', 'c': Colors.grey.shade700},
      {'k': 'cowboy', 'n': 'Cowboy Win', 'm': 'x2', 'c': Colors.brown.shade900},
      {'k': 'suited', 'n': 'Suited/Connector', 'm': 'x1.66', 'c': Colors.brown.shade600},
      {'k': 'high', 'n': 'High Card', 'm': 'x2.2', 'c': Colors.brown.shade700},
      {'k': 'twopair', 'n': 'Two Pair', 'm': 'x3.1', 'c': Colors.brown.shade700},
      {'k': 'pair', 'n': 'Pair', 'm': 'x8.5', 'c': Colors.brown.shade700},
      {'k': 'three', 'n': 'Three of a Kind', 'm': 'x4.7', 'c': Colors.brown.shade700},
      {'k': 'boat', 'n': 'Boat/Full House', 'm': 'x20', 'c': Colors.brown.shade700},
      {'k': 'aa', 'n': 'AA', 'm': 'x100', 'c': Colors.brown.shade700},
      {'k': 'four', 'n': 'Four of a Kind', 'm': 'x248', 'c': Colors.brown.shade700},
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Wrap(
        spacing: 6, runSpacing: 6,
        children: opts.map((o) {
          final k = o['k'] as String;
          final bet = _bets[k] ?? 0;
          return GestureDetector(
            onTap: () => _place(k),
            child: Container(
              width: (MediaQuery.of(context).size.width - 34) / 3,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: o['c'] as Color,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: bet > 0 ? const Color(0xFFFFC107) : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(children: [
                Text(o['n'] as String, textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white,
                    fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(o['m'] as String, style: TextStyle(
                  color: Colors.yellow.shade300, fontSize: 14,
                  fontWeight: FontWeight.bold)),
                if (bet > 0) Text('$bet', style: const TextStyle(
                  color: Color(0xFFFFC107), fontSize: 10)),
              ]),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _bottomBar() {
    final total = _bets.values.fold<int>(0, (a, b) => a + b);
    final chips = [1000, 5000, 10000, 50000];
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.brown.shade900,
      child: Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(children: [
            const Icon(Icons.monetization_on, color: Color(0xFFFFC107), size: 16),
            const SizedBox(width: 4),
            Text(_fmt(_balance), style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
          ]),
        ),
        if (total > 0) Padding(
          padding: const EdgeInsets.only(left: 6),
          child: Text('+$total', style: const TextStyle(
            color: Colors.green, fontWeight: FontWeight.bold)),
        ),
        const Spacer(),
        ...chips.map((c) {
          final sel = _bet == c;
          return GestureDetector(
            onTap: () => setState(() => _bet = c),
            child: Container(
              width: 44, height: 44,
              margin: const EdgeInsets.only(left: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: sel
                  ? [const Color(0xFFFFC107), const Color(0xFFFF6B35)]
                  : [Colors.grey.shade800, Colors.grey.shade900]),
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
