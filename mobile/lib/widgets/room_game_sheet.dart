
import 'package:flutter/material.dart';

class RoomGameSheet extends StatelessWidget {
  final Function(String) onSelect;
  const RoomGameSheet({super.key, required this.onSelect});

  static final List<Map<String, String>> games = [
    {'k': 'ludo', 'n': 'Ludo', 'e': '🎲'},
    {'k': 'carrom', 'n': 'Carrom', 'e': '⚫'},
    {'k': 'domino', 'n': 'Domino', 'e': '🀄'},
    {'k': 'umo', 'n': 'UMO', 'e': '🎴'},
    {'k': 'jackaroo', 'n': 'Jackaroo', 'e': '♟'},
    {'k': 'teen_patti', 'n': 'Teen Patti', 'e': '🃏'},
    {'k': 'roulette', 'n': 'Rulet', 'e': '🎯'},
    {'k': 'dragon_tiger', 'n': 'Ejder Kaplan', 'e': '🐅'},
    {'k': 'slot', 'n': 'Slot', 'e': '🎰'},
    {'k': 'bingo', 'n': 'Bingo', 'e': '🎱'},
    {'k': 'football', 'n': 'Football', 'e': '⚽'},
    {'k': 'rocket', 'n': 'Roket', 'e': '🚀'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A0F3E), Color(0xFF0A0E27)],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Oyun Sec',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.95,
              ),
              itemCount: games.length,
              itemBuilder: (_, i) => _card(context, games[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(BuildContext ctx, Map<String, String> g) {
    final e = g['e'] as String;
    final n = g['n'] as String;
    final k = g['k'] as String;
    return GestureDetector(
      onTap: () {
        Navigator.pop(ctx);
        onSelect(k);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2A1F5E), Color(0xFF1A0F3E)],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFFFC107).withOpacity(0.25),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(e, style: const TextStyle(fontSize: 38)),
            const SizedBox(height: 6),
            Text(
              n,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
