
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../services/api.dart';
import '../../services/local_db.dart';

class JackpotChestGame extends StatefulWidget {
  const JackpotChestGame({super.key});
  @override
  State<JackpotChestGame> createState() => _JackpotChestGameState();
}

class _JackpotChestGameState extends State<JackpotChestGame> {
  int _balance = 0;
  int _bet = 1000;
  int _countdown = 27;
  bool _rolling = false;
  int _jackpot = 26489598;
  Map<String, int> _bets = {};
  int _selectedChest = -1;

  static const List<Map<String, dynamic>> chests = [
    {'mult': 5, 'emoji': '🟢', 'c': Colors.green},
    {'mult': 35, 'emoji': '🐉', 'c': Colors.red},
    {'mult': 25, 'emoji': '🔥', 'c': Colors.deepOrange},
    {'mult': 5, 'emoji': '🔷', 'c': Colors.blue},
    {'mult': 15, 'emoji': '🐲', 'c': Colors.teal},
    {'mult': 5, 'emoji': '💜', 'c': Colors.purple},
    {'mult': 5, 'emoji': '🟡', 'c': Colors.amber},
    {'mult': 10, 'emoji': '👑', 'c': Colors.yellow},
    {'mult': 25, 'emoji': '💎', 'c': Colors.cyan},
  ];

  @override
  void initState() {
    super.initState();
    _balance = LocalDB.getBalance() > 0 ? LocalDB.getBalance() : 69644;
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
    if (_selectedChest < 0) {
      setState(() => _countdown = 27);
      _startCountdown();
      return;
    }
    if (_balance < _bet) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yetersiz bakiye'),
            backgroundColor: Colors.red));
      return;
    }
    setState(() {
      _rolling = true;
      _balance -= _bet;
    });
    try {
      await Api.dio.post('/jackpot/chest', data: {
        'chestIndex': _selectedChest, 'bet': _bet});
    } catch (_) {}

    await Future.delayed(const Duration(seconds: 2));
    final winIdx = math.Random().nextInt(chests.length);
    final mult = chests[winIdx]['mult'] as int;
    final win = _bet * mult;

    setState(() {
      _balance += win;
      _rolling = false;
    });
    LocalDB.setBalance(_balance);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A0F3E),
        title: Text('Kazanan Sandık! x$mult',
          style: const TextStyle(color: Color(0xFFFFC107))),
        content: Text('+$win coin', style: const TextStyle(
          color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _selectedChest = -1;
                _countdown = 27;
              });
              _startCountdown();
            },
            child: const Text('TAMAM'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0A0A),
      appBar: AppBar(
        title: const Text('Jackpot'),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF4A0A0A), Color(0xFF1A0A0A)],
          ),
        ),
        child: Column(children: [
          _jackpotHeader(),
          Expanded(child: _chests()),
          _betRow(),
          _bottomBar(),
        ]),
      ),
    );
  }

  Widget _jackpotHeader() {
    return Column(children: [
      const SizedBox(height: 12),
      ShaderMask(
        shaderCallback: (r) => const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFF6B35)]).createShader(r),
        child: const Text('JACKPOT', style: TextStyle(
          color: Colors.white, fontSize: 32,
          fontWeight: FontWeight.bold, letterSpacing: 4)),
      ),
      Text(_fmtJ(_jackpot), style: const TextStyle(
        color: Color(0xFFFFC107), fontSize: 34, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.shade900,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text('Zaman Seçin $_countdown s', style: const TextStyle(
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    ]);
  }

  Widget _chests() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, mainAxisSpacing: 8, crossAxisSpacing: 8),
      itemCount: chests.length,
      itemBuilder: (_, i) {
        final chest = chests[i];
        final sel = _selectedChest == i;
        return GestureDetector(
          onTap: _rolling ? null : () => setState(() => _selectedChest = i),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                (chest['c'] as Color).withOpacity(0.7),
                (chest['c'] as Color).withOpacity(0.3),
              ]),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: sel ? const Color(0xFFFFC107) : Colors.white24,
                width: sel ? 3 : 1,
              ),
              boxShadow: sel ? [BoxShadow(
                color: const Color(0xFFFFC107).withOpacity(0.7),
                blurRadius: 20, spreadRadius: 4)] : null,
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(chest['emoji'] as String,
                  style: const TextStyle(fontSize: 36)),
                const SizedBox(height: 4),
                Text('x${chest['mult']}', style: const TextStyle(
                  color: Color(0xFFFFC107), fontSize: 18,
                  fontWeight: FontWeight.bold)),
              ]),
          ),
        );
      },
    );
  }

  Widget _betRow() {
    final keys = [
      {'l': '1K', 'v': 1000, 'e': '🗝️'},
      {'l': '10K', 'v': 10000, 'e': '🗝️'},
      {'l': '50K', 'v': 50000, 'e': '🗝️'},
      {'l': '100K', 'v': 100000, 'e': '🗝️'},
      {'l': '1M', 'v': 1000000, 'e': '🗝️'},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: keys.map((k) {
          final sel = _bet == k['v'];
          return GestureDetector(
            onTap: () => setState(() => _bet = k['v'] as int),
            child: Column(children: [
              Text(k['e'] as String, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: sel ? const Color(0xFFFFC107) : Colors.black45,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(k['l'] as String, style: TextStyle(
                  color: sel ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold, fontSize: 10)),
              ),
            ]),
          );
        }).toList(),
      ),
    );
  }

  Widget _bottomBar() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        const Icon(Icons.monetization_on, color: Color(0xFFFFC107)),
        const SizedBox(width: 6),
        Text(_balance.toString(), style: const TextStyle(
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        const Spacer(),
        Text('Bugün Kazan: 0', style: TextStyle(
          color: Colors.white.withOpacity(0.6), fontSize: 11)),
      ]),
    );
  }

  String _fmtJ(int n) {
    return n.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => m[1]! + '.');
  }
}
