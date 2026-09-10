import 'package:flutter/material.dart';
import '../services/api.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  Future<void> _play(BuildContext context, String game) async {
    try {
      String path = '/games/slot/spin';
      final Map<String, dynamic> body = {'bet': 1000};
      if (game == 'rocket') { path = '/games/rocket/start'; }
      else if (game == 'roulette') { path = '/games/roulette/spin'; body['type'] = 'red'; }
      else if (game == 'slot') { path = '/games/slot/spin'; }
      else if (game == 'dragon-tiger') { path = '/games/dragon-tiger/play'; body['pick'] = 'dragon'; }
      else if (game == 'coinflip') { path = '/games/coinflip/flip'; body['pick'] = 'heads'; }
      else if (game == 'dice') { path = '/games/dice/roll'; body['pick'] = 'over'; }

      final r = await Api.dio.post(path, data: body);
      if (!context.mounted) return;
      final data = r.data;
      String msg = 'Sonuc: ' + data.toString();
      if (data is Map) {
        if (data.containsKey('payout')) msg = 'Kazanc: ' + data['payout'].toString();
        else if (data.containsKey('winning')) msg = 'Sayi: ' + data['winning'].toString();
        else if (data.containsKey('reels')) msg = 'Sonuc: ' + data['reels'].toString();
        else if (data.containsKey('winner')) msg = 'Kazanan: ' + data['winner'].toString();
        else if (data.containsKey('result')) msg = 'Sonuc: ' + data['result'].toString();
        else if (data.containsKey('roll')) msg = 'Zar: ' + data['roll'].toString();
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: ' + e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final games = [
      {'key': 'rocket', 'name': 'Roket', 'emoji': '🚀', 'color': const Color(0xFF9C27B0)},
      {'key': 'roulette', 'name': 'Rulet', 'emoji': '🎯', 'color': const Color(0xFFF44336)},
      {'key': 'slot', 'name': 'Slot', 'emoji': '🎰', 'color': const Color(0xFFFF9800)},
      {'key': 'dragon-tiger', 'name': 'Ejder-Kaplan', 'emoji': '🐅', 'color': const Color(0xFFFFC107)},
      {'key': 'coinflip', 'name': 'Yazi-Tura', 'emoji': '🪙', 'color': const Color(0xFF2196F3)},
      {'key': 'dice', 'name': 'Zar', 'emoji': '🎲', 'color': const Color(0xFF4CAF50)},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        title: const Text('Oyunlar'),
        backgroundColor: Colors.transparent,
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
        children: games.map((g) {
          final c = g['color'] as Color;
          return GestureDetector(
            onTap: () => _play(context, g['key'] as String),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [c.withOpacity(0.4), c.withOpacity(0.1)]),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: c.withOpacity(0.5), width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(g['emoji'] as String, style: const TextStyle(fontSize: 52)),
                  const SizedBox(height: 10),
                  Text(g['name'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  const Text('Bahis: 1000', style: TextStyle(color: Color(0xFFFFC107), fontSize: 11)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
