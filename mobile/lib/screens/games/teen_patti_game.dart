
import 'package:flutter/material.dart';
import '../../services/api.dart';
import '../../services/local_db.dart';

class TeenPattiGame extends StatefulWidget {
  const TeenPattiGame({super.key});
  @override
  State<TeenPattiGame> createState() => _TeenPattiGameState();
}

class _TeenPattiGameState extends State<TeenPattiGame> {
  int _balance = 0;
  int _bet = 1000;
  int _round = 2299;
  int _countdown = 20;
  int _myPot = 0;
  final List<int> _pots = [0, 175000, 13000];
  final List<int> _myBets = [0, 0, 0];
  int _selectedPlayer = 1;

  @override
  void initState() {
    super.initState();
    _balance = LocalDB.getBalance() > 0 ? LocalDB.getBalance() : 69644;
    _tick();
  }

  void _tick() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _countdown = _countdown > 0 ? _countdown - 1 : 20);
      _tick();
    });
  }

  void _betOn(int idx) {
    if (_balance < _bet) return;
    setState(() {
      _balance -= _bet;
      _myBets[idx] += _bet;
      _myPot += _bet;
    });
  }

  Future<void> _play() async {
    if (_myPot == 0) return;
    try {
      await Api.dio.post('/teen-patti/bet', data: {
        'bets': _myBets, 'total': _myPot,
      });
    } catch (_) {}

    await Future.delayed(const Duration(seconds: 1));

    final winner = (DateTime.now().millisecondsSinceEpoch % 3);
    final win = _myBets[winner] * 3;

    setState(() {
      _balance += win;
      _myBets[0] = 0;
      _myBets[1] = 0;
      _myBets[2] = 0;
      _myPot = 0;
      _round++;
    });
    LocalDB.setBalance(_balance);

    if (win > 0 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kazandin! +' + win.toString()),
          backgroundColor: Colors.green));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4A1A3E),
      body: SafeArea(
        child: Column(children: [
          _header(),
          _timerRow(),
          Expanded(child: _arena()),
          _topRow(),
          _chips(),
        ]),
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [
              Color(0xFFFFC107), Color(0xFFFF6B35)]),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFF176), width: 3),
            boxShadow: [BoxShadow(
              color: const Color(0xFFFFC107).withOpacity(0.6),
              blurRadius: 20, spreadRadius: 2)],
          ),
          child: const Text('Teen Patti', style: TextStyle(
            color: Colors.black, fontSize: 24,
            fontWeight: FontWeight.bold, letterSpacing: 2)),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ]),
    );
  }

  Widget _timerRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(children: [
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(colors: [
              Color(0xFF4CAF50), Color(0xFF2E7D32)]),
            border: Border.all(color: Color(0xFFFFC107), width: 4),
            boxShadow: [BoxShadow(color: Color(0xFF4CAF50).withOpacity(0.5),
              blurRadius: 15)],
          ),
          child: Center(child: Text('$_countdown', style: const TextStyle(
            color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold))),
        ),
        const Spacer(),
        Text('Raunt $_round', style: const TextStyle(
          color: Color(0xFFFFC107), fontSize: 16,
          fontWeight: FontWeight.bold, letterSpacing: 1)),
        const Spacer(),
        Container(width: 60, height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(0.3))),
      ]),
    );
  }

  Widget _arena() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        _playerSlot(0, Colors.green),
        const SizedBox(width: 8),
        _playerSlot(1, Colors.red),
        const SizedBox(width: 8),
        _playerSlot(2, Colors.amber),
      ]),
    );
  }

  Widget _playerSlot(int idx, MaterialColor c) {
    final sel = _selectedPlayer == idx;
    final myB = _myBets[idx];
    return Expanded(child: GestureDetector(
      onTap: () => setState(() => _selectedPlayer = idx),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: c.shade900.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: sel ? Colors.white : c.shade300,
            width: sel ? 3 : 1),
        ),
        child: Column(children: [
          Text('Tencere: ${_pots[idx]}', style: const TextStyle(
            color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          ...List.generate(3, (_) => Container(
            height: 40,
            margin: const EdgeInsets.symmetric(vertical: 3),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [
                Color(0xFFFFD700), Color(0xFFFFA000)]),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFFFF176), width: 2),
            ),
            child: const Center(child: Text('👑',
              style: TextStyle(fontSize: 18))),
          )),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(children: [
              Text('Benim: $myB', style: const TextStyle(
                color: Colors.white, fontSize: 10)),
            ]),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => _betOn(idx),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [c.shade600, c.shade900]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(child: Text('BAHIS',
                style: TextStyle(color: Colors.white, fontSize: 11,
                  fontWeight: FontWeight.bold))),
            ),
          ),
        ]),
      ),
    ));
  }

  Widget _topRow() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [
          Color(0xFF8B0000), Color(0xFF4A0000)]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        const Text('TOP5', style: TextStyle(
          color: Color(0xFFFFC107), fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        ...List.generate(3, (i) => CircleAvatar(
          radius: 16,
          backgroundColor: [Colors.amber, Colors.grey, Colors.brown][i],
          child: const Text('👑', style: TextStyle(fontSize: 14)),
        )),
        const Spacer(),
        GestureDetector(
          onTap: _play,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [
                Color(0xFF4CAF50), Color(0xFF2E7D32)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('OYNA', style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.people, color: Color(0xFFFFC107), size: 22),
      ]),
    );
  }

  Widget _chips() {
    final chips = [1000, 5000, 10000, 100000];
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [
              Color(0xFFFFC107), Color(0xFFFF6B35)]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(children: [
            const Icon(Icons.monetization_on, color: Colors.black, size: 16),
            const SizedBox(width: 4),
            Text(_balance.toString(), style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold)),
          ]),
        ),
        const Spacer(),
        ...chips.map((c) {
          final sel = _bet == c;
          return GestureDetector(
            onTap: () => setState(() => _bet = c),
            child: Container(
              width: 52, height: 52,
              margin: const EdgeInsets.only(left: 6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: sel
                  ? [const Color(0xFFFFC107), const Color(0xFFFF6B35)]
                  : [const Color(0xFF1A0F3E), const Color(0xFF2A1F5E)]),
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
}
