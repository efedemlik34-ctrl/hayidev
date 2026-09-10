import 'package:flutter/material.dart';
import 'voice_room_screen.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  // Casual oyunlar
  final List<Map<String, String>> casualGames = const [
    {'key': 'ludo',        'name': 'Ludo',         'img': 'assets/games/game_icons/ludo.png'},
    {'key': 'ludo_team',   'name': 'Ludo Takimi',  'img': 'assets/games/game_icons/ludo_team.png'},
    {'key': 'carrom',      'name': 'Carrom',       'img': 'assets/games/game_icons/carrom.png'},
    {'key': 'umo',         'name': 'UMO',          'img': 'assets/games/game_icons/umo.png'},
    {'key': 'domino',      'name': 'Domino',       'img': 'assets/games/game_icons/domino.png'},
    {'key': 'jackaroo',    'name': 'Jackaroo',     'img': 'assets/games/game_icons/jackaroo.png'},
  ];

  // Sansli oyunlar (gorseldekiler)
  final List<Map<String, String>> luckyGames = const [
    {'key': 'golden_fortune', 'name': 'Altin Servet',       'img': 'assets/games/game_icons/golden_fortune.png'},
    {'key': 'lucky_pro',      'name': 'Sansli Profesyonel', 'img': 'assets/games/game_icons/lucky_pro.png'},
    {'key': 'lucky_fruit',    'name': 'Sansli Meyve',       'img': 'assets/games/game_icons/lucky_fruit.png'},
    {'key': 'greedy_pro',     'name': 'Acgozlu Pro',        'img': 'assets/games/game_icons/greedy_pro.png'},
    {'key': 'jackpot',        'name': 'Ikramiye',           'img': 'assets/games/game_icons/jackpot.png'},
    {'key': 'teen_patti',     'name': 'Teen Patti',         'img': 'assets/games/game_icons/teen_patti.png'},
    {'key': 'jackpot_slots',  'name': 'Jackpot Slot',       'img': 'assets/games/game_icons/jackpot_slots.png'},
    {'key': 'greedy_box',     'name': 'Acgozlu Kutusu',     'img': 'assets/games/game_icons/greedy_box.png'},
    {'key': 'dragon_tiger',   'name': 'Ejderha Kaplan Slot','img': 'assets/games/game_icons/dragon_tiger.png'},
    {'key': 'roulette',       'name': 'Rulet',              'img': 'assets/games/game_icons/roulette.png'},
    {'key': 'pyramids',       'name': 'Piramit Yuvarlari',  'img': 'assets/games/game_icons/pyramids.png'},
    {'key': 'texas_cowboy',   'name': 'Texas Cowboy',       'img': 'assets/games/game_icons/texas_cowboy.png'},
    {'key': 'football',       'name': 'Football King',      'img': 'assets/games/game_icons/football.png'},
    {'key': 'rocket',         'name': 'Roket Ezmesi',       'img': 'assets/games/game_icons/rocket.png'},
  ];

  void _open(BuildContext ctx, String key) {
    switch (key) {
      case 'rocket':       Navigator.pushNamed(ctx, '/rocket'); break;
      case 'roulette':     Navigator.pushNamed(ctx, '/roulette'); break;
      case 'dragon_tiger': Navigator.pushNamed(ctx, '/dragon-tiger'); break;
      case 'teen_patti':   Navigator.pushNamed(ctx, '/teen-patti'); break;
      case 'bingo':        Navigator.pushNamed(ctx, '/bingo'); break;
      case 'football':     Navigator.pushNamed(ctx, '/football'); break;
      case 'carrom':       Navigator.pushNamed(ctx, '/carrom'); break;
      case 'ludo':         Navigator.pushNamed(ctx, '/ludo'); break;
      case 'umo':          Navigator.pushNamed(ctx, '/umo'); break;
      case 'domino':       Navigator.pushNamed(ctx, '/domino'); break;
      case 'jackaroo':     Navigator.pushNamed(ctx, '/jackaroo'); break;
      case 'golden_fortune':
      case 'lucky_pro':
      case 'lucky_fruit':
      case 'greedy_pro':
      case 'jackpot':
      case 'jackpot_slots':
      case 'greedy_box':
      case 'pyramids':
      case 'texas_cowboy':
        Navigator.pushNamed(ctx, '/slot', arguments: {'theme': key, 'title': key});
        break;
      default:
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text('$key yakinda eklenecek')));
    }
  }

  Widget _gameCard(BuildContext ctx, Map<String, String> g) {
    return GestureDetector(
      onTap: () => _open(ctx, g['key']!),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A0F3E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFC107).withOpacity(0.2)),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              g['img']!,
              width: 60, height: 60,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 60, height: 60,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFFFFC107), Color(0xFFFF6B35)]),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.videogame_asset, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(g['name']!,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ]),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(children: [
        Container(width: 3, height: 16, color: const Color(0xFFFFC107)),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(color: Colors.white,
          fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        title: const Text('Oda Oyunu'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(children: [
        _sectionTitle('Casual Oyunlar'),
        GridView.count(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.9,
          children: casualGames.map((g) => _gameCard(context, g)).toList(),
        ),
        _sectionTitle('Sansli Oyun'),
        GridView.count(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.85,
          children: luckyGames.map((g) => _gameCard(context, g)).toList(),
        ),
        const SizedBox(height: 30),
      ]),
    );
  }
}
