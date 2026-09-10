
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../services/api.dart';
import '../../services/local_db.dart';

class DragonTigerGame extends StatefulWidget {
  const DragonTigerGame({super.key});
  @override
  State<DragonTigerGame> createState() => _DragonTigerGameState();
}

class _DragonTigerGameState extends State<DragonTigerGame>
    with TickerProviderStateMixin {
  int _balance = 0;
  int _bet = 1000;
  String _choice = '';
  int _round = 2065;
  bool _rolling = false;
  String _result = '';
  String _dragonCard = '?';
  String _tigerCard = '?';
  int _countdown = 15;
  List<String> _history = ['D', 'T', 'D', 'D', 'T', 'D', 'T'];
  late AnimationController _flipCtrl;

  @override
  void initState() {
    super.initState();
    _balance = LocalDB.getBalance() > 0 ? LocalDB.getBalance() : 69644;
    _flipCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _startCountdown();
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      if (_countdown > 0) {
        setState(() => _countdown--);
        _startCountdown();
      } else {
        _play();
      }
    });
  }

  Future<void> _play() async {
    if (_choice.isEmpty) {
      setState(() => _countdown = 15);
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
      await Api.dio.post('/dragon-tiger/bet', data: {
        'amount': _bet,
        'choice': _choice,
      });
    } catch (_) {}

    await _flipCtrl.forward(from: 0);

    final rand = math.Random();
    final d = rand.nextInt(13) + 2;
    final t = rand.nextInt(13) + 2;

    String winner;
    if (d > t) winner = 'dragon';
    else if (t > d) winner = 'tiger';
    else winner = 'tie';

    int payout = 0;
    if (winner == _choice) {
      if (_choice == 'tie') payout = _bet * 25;
      else payout = _bet * 2;
    }

    setState(() {
      _dragonCard = _cardName(d);
      _tigerCard = _cardName(t);
      _result = winner.toUpperCase();
      _balance += payout;
      _rolling = false;
      _round++;
      _history.insert(0, winner == 'dragon' ? 'D' : winner == 'tiger' ? 'T' : 'X');
      if (_history.length > 10) _history.removeLast();
    });
    LocalDB.setBalance(_balance);

    await Future.delayed(const Duration(seconds: 2));
    _flipCtrl.reset();
    setState(() {
      _choice = '';
      _result = '';
      _dragonCard = '?';
      _tigerCard = '?';
      _countdown = 15;
    });
    _startCountdown();
  }

  String _cardName(int v) {
    const names = ['', '', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A'];
    return names[v];
  }

  @override
  void dispose() {
    _flipCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        title: const Text('Dragon Tiger Slot'),
        backgroundColor: Colors.transparent,
      ),
      body: Column(children: [
        _header(),
        Expanded(child: _arena()),
        _history(),
        _betRow(),
        _chips(),
      ]),
    );
  }

  Widget _header() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [
          Color(0xFF4A148C), Color(0xFF9C27B0)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        const Icon(Icons.monetization_on, color: Color(0xFFFFC107)),
        const SizedBox(width: 6),
        Text(_balance.toString(), style: const TextStyle(
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        const Spacer(),
        Text('Raunt $_round', style: const TextStyle(
          color: Colors.white70, fontSize: 12)),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text('$_countdown s', style: const TextStyle(
            color: Color(0xFFFFC107), fontWeight: FontWeight.bold)),
        ),
      ]),
    );
  }

  Widget _arena() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.red.shade900.withOpacity(0.4),
            Colors.blue.shade900.withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFC107).withOpacity(0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _sideCard('EJDERHA', _dragonCard, '🐉', Colors.red),
              AnimatedBuilder(
                animation: _flipCtrl,
                builder: (_, __) => Transform.scale(
                  scale: 1 + math.sin(_flipCtrl.value * math.pi) * 0.2,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(colors: [
                        Color(0xFFFFC107), Color(0xFFFF6B35)]),
                      boxShadow: [BoxShadow(
                        color: const Color(0xFFFFC107).withOpacity(0.6),
                        blurRadius: 20, spreadRadius: 4)],
                    ),
                    child: const Text('VE', style: TextStyle(
                      color: Colors.black, fontSize: 20,
                      fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              _sideCard('KAPLAN', _tigerCard, '🐅', Colors.blue),
            ],
          ),
          if (_result.isNotEmpty) Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text('KAZANAN: $_result', style: const TextStyle(
              color: Color(0xFFFFC107), fontSize: 22,
              fontWeight: FontWeight.bold, letterSpacing: 2)),
          ),
        ],
      ),
    );
  }

  Widget _sideCard(String title, String val, String emoji, MaterialColor c) {
    return Column(children: [
      Text(emoji, style: const TextStyle(fontSize: 40)),
      const SizedBox(height: 8),
      Container(
        width: 80, height: 110,
        decoration: BoxDecoration(
          color: c.shade900.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.shade300, width: 2),
        ),
        child: Center(child: Text(val, style: TextStyle(
          color: Colors.white, fontSize: 42,
          fontWeight: FontWeight.bold))),
      ),
      const SizedBox(height: 8),
      Text(title, style: TextStyle(color: c.shade200,
        fontWeight: FontWeight.bold, letterSpacing: 1)),
      const SizedBox(height: 4),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: c.shade800,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text('X 2.0', style: TextStyle(
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
      ),
    ]);
  }

  Widget _history() {
    return Container(
      margin: const EdgeInsets.all(12),
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _history.length,
        itemBuilder: (_, i) {
          final h = _history[i];
          final isD = h == 'D', isT = h == 'T', isX = h == 'X';
          return Container(
            width: 32, height: 32,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: isD ? Colors.red.shade700 : isT ? Colors.blue.shade700 :
                isX ? Colors.purple.shade700 : Colors.grey.shade800,
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(h, style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11))),
          );
        },
      ),
    );
  }

  Widget _betRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(children: [
        Expanded(child: _choiceBtn('Ejderha', 'dragon', Colors.red.shade700, '🐉')),
        const SizedBox(width: 8),
        Expanded(child: _choiceBtn('Berabere', 'tie',
          Colors.orange.shade700, '🤝')),
        const SizedBox(width: 8),
        Expanded(child: _choiceBtn('Kaplan', 'tiger', Colors.blue.shade700, '🐅')),
      ]),
    );
  }

  Widget _choiceBtn(String label, String key, Color c, String emoji) {
    final sel = _choice == key;
    return GestureDetector(
      onTap: _rolling ? null : () => setState(() => _choice = key),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: sel
            ? [c, c.withOpacity(0.6)]
            : [c.withOpacity(0.4), c.withOpacity(0.2)]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: sel ? Colors.white : c, width: sel ? 2 : 1),
        ),
        child: Column(children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white,
            fontWeight: FontWeight.bold, fontSize: 12)),
        ]),
      ),
    );
  }

  Widget _chips() {
    final chips = [1000, 5000, 10000, 50000, 100000];
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: chips.map((c) {
          final sel = _bet == c;
          return GestureDetector(
            onTap: () => setState(() => _bet = c),
            child: Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: sel
                  ? [const Color(0xFFFFC107), const Color(0xFFFF6B35)]
                  : [const Color(0xFF1A0F3E), const Color(0xFF2A1F5E)]),
                border: Border.all(color: sel ? Colors.white : Colors.white24, width: 2),
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

  String _fmt(int n) {
    if (n >= 1000000) return (n ~/ 1000000).toString() + 'M';
    if (n >= 1000) return (n ~/ 1000).toString() + 'K';
    return n.toString();
  }
}
