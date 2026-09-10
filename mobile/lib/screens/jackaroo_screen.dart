import 'package:flutter/material.dart';
import '../services/api.dart';

class JackarooScreen extends StatefulWidget {
  const JackarooScreen({super.key});
  @override
  State<JackarooScreen> createState() => _JackarooScreenState();
}

class _JackarooScreenState extends State<JackarooScreen> {
  int _selectedBet = 1000;
  List<String> _hand = ['2', '5', '7', 'K', 'A'];
  String? _selectedCard;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E4A2C),
      appBar: AppBar(
        title: const Text('Jackaroo'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(children: [
        // Ust - rakip oyuncular
        Container(
          padding: const EdgeInsets.all(12),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _opponent('Ali', 5),
            _opponent('Veli', 5),
            _opponent('Ayse', 5),
          ]),
        ),
        // Orta - tahta
        Expanded(
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFC107), width: 3),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20)],
              ),
              child: Stack(children: [
                for (int i = 0; i < 4; i++)
                  Positioned(
                    left: 20 + (i % 2) * 100.0,
                    top: 20 + (i ~/ 2) * 100.0,
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: [Colors.red, Colors.blue, Colors.yellow, Colors.green][i],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(child: Text('${i + 1}',
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
                    ),
                  ),
                Center(child: Text('🎲', style: TextStyle(fontSize: 60, color: Colors.white.withOpacity(0.3)))),
              ]),
            ),
          ),
        ),
        // Alt - kartlar + bahis
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(children: [
            // Bahis secimi
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              for (final b in [100, 1000, 10000, 50000])
                GestureDetector(
                  onTap: () => setState(() => _selectedBet = b),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: _selectedBet == b
                        ? [const Color(0xFFFFC107), const Color(0xFFFF6B35)]
                        : [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('🪙 ${b >= 1000 ? '${b ~/ 1000}K' : b}',
                      style: TextStyle(
                        color: _selectedBet == b ? Colors.black : Colors.white,
                        fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
            ]),
            const SizedBox(height: 14),
            // Kartlar
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _hand.length,
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => setState(() => _selectedCard = _hand[i]),
                  child: Container(
                    width: 65,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _selectedCard == _hand[i] ? const Color(0xFFFFC107) : Colors.black26,
                        width: _selectedCard == _hand[i] ? 3 : 1),
                      boxShadow: _selectedCard == _hand[i]
                        ? [BoxShadow(color: const Color(0xFFFFC107).withOpacity(0.6), blurRadius: 12)]
                        : null,
                    ),
                    child: Center(child: Text(_hand[i],
                      style: const TextStyle(color: Colors.black,
                        fontSize: 28, fontWeight: FontWeight.bold))),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Oyna butonu
            SizedBox(width: double.infinity, height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _selectedCard == null ? null : () async {
                  try {
                    final r = await Api.dio.post('/games/dice/roll', data: {'bet': _selectedBet, 'pick': 'over'});
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sonuc: ${r.data['roll']}')));
                  } catch (e) {}
                },
                child: const Text('OYNA', style: TextStyle(color: Colors.white,
                  fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2)),
              )),
          ]),
        ),
      ]),
    );
  }

  Widget _opponent(String name, int cards) {
    return Column(children: [
      CircleAvatar(
        radius: 24,
        backgroundColor: const Color(0xFFFFC107),
        child: Text(name[0], style: const TextStyle(color: Colors.black,
          fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      const SizedBox(height: 4),
      Text(name, style: const TextStyle(color: Colors.white, fontSize: 11)),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.style, color: Color(0xFFFFC107), size: 10),
        const SizedBox(width: 2),
        Text('$cards', style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ]),
    ]);
  }
}
