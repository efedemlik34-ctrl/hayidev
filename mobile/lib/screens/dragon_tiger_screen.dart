import 'package:flutter/material.dart';
import '../services/api.dart';
import '../widgets/dt_card.dart';
import '../widgets/card_deal_animation.dart';
import '../widgets/feedback_service.dart';

class DragonTigerScreen extends StatefulWidget {
  const DragonTigerScreen({super.key});
  @override
  State<DragonTigerScreen> createState() => _DragonTigerScreenState();
}

class _DragonTigerScreenState extends State<DragonTigerScreen> {
  String? _dragon, _tiger, _winner;
  int _bet = 1000;
  bool _dealt = false;

  Future<void> _play(String pick) async {
    setState(() => _dealt = false);
    try {
      final r = await Api.dio.post('/games/dragon-tiger/play', data: {'bet': _bet, 'pick': pick});
      setState(() {
        _dragon = r.data['dragon'];
        _tiger = r.data['tiger'];
        _winner = r.data['winner'];
        _dealt = true;
      });
      FeedbackService.medium();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF8B0000), Color(0xFF4A0000), Color(0xFF0D47A1)])),
        child: SafeArea(child: Column(children: [
          AppBar(
            backgroundColor: Colors.transparent, elevation: 0,
            title: const Text('Dragon Tiger Slot',
              style: TextStyle(color: Colors.white, fontSize: 20,
                fontWeight: FontWeight.bold, letterSpacing: 2)),
          ),
          const SizedBox(height: 20),
          // Kartlar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              Column(children: [
                const Text('EJDERHA', style: TextStyle(color: Colors.orange,
                  fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 3)),
                const SizedBox(height: 12),
                DragonTigerCard(
                  value: _dragon,
                  suit: '♠',
                  isDragon: true,
                  visible: _dealt,
                ),
              ]),
              Column(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFFFC107), Color(0xFFFF6B35)]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.6), blurRadius: 20)]),
                  child: const Text('VS', style: TextStyle(color: Colors.black,
                    fontSize: 24, fontWeight: FontWeight.bold)),
                ),
              ]),
              Column(children: [
                const Text('KAPLAN', style: TextStyle(color: Colors.lightBlueAccent,
                  fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 3)),
                const SizedBox(height: 12),
                DragonTigerCard(
                  value: _tiger,
                  suit: '♥',
                  isDragon: false,
                  visible: _dealt,
                ),
              ]),
            ]),
          ),
          const SizedBox(height: 30),
          if (_winner != null && _dealt)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFC107), width: 2)),
              child: Text('KAZANAN: ${_winner == 'dragon' ? 'EJDERHA' : _winner == 'tiger' ? 'KAPLAN' : 'BERABERE'}',
                style: const TextStyle(color: Color(0xFFFFC107),
                  fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          const Spacer(),
          // Bahis + butonlar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                for (final b in [100, 1000, 5000, 10000, 50000])
                  GestureDetector(
                    onTap: () => setState(() => _bet = b),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _bet == b ? const Color(0xFFFFC107) : Colors.white10,
                        borderRadius: BorderRadius.circular(14)),
                      child: Text('${b >= 1000 ? '${b ~/ 1000}K' : b}',
                        style: TextStyle(color: _bet == b ? Colors.black : Colors.white,
                          fontSize: 11, fontWeight: FontWeight.bold)),
                    )),
              ]),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: _betBtn('EJDERHA x2', Icons.local_fire_department,
                  const Color(0xFFE53935), () => _play('dragon'))),
                const SizedBox(width: 8),
                Expanded(child: _betBtn('BERABERE x8', Icons.handshake,
                  const Color(0xFF9C27B0), () => _play('tie'))),
                const SizedBox(width: 8),
                Expanded(child: _betBtn('KAPLAN x2', Icons.whatshot,
                  const Color(0xFF2196F3), () => _play('tiger'))),
              ]),
            ]),
          ),
        ])),
      ),
    );
  }

  Widget _betBtn(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color, color.withOpacity(0.6)]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 16, offset: const Offset(0, 4))]),
        child: Column(children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white,
            fontSize: 11, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }
}
