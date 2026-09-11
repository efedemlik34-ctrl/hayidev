import 'package:flutter/material.dart';
import '../widgets/app_theme.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  static const List<Map<String, String>> casual = [
    {'key': 'ludo', 'name': 'Ludo', 'img': 'assets/games/game_icons/ludo.png'},
    {'key': 'ludo_team', 'name': 'Ludo Takimi', 'img': 'assets/games/game_icons/ludo_team.png'},
    {'key': 'carrom', 'name': 'Carrom', 'img': 'assets/games/game_icons/carrom.png'},
    {'key': 'umo', 'name': 'UMO', 'img': 'assets/games/game_icons/umo.png'},
    {'key': 'domino', 'name': 'Domino', 'img': 'assets/games/game_icons/domino.png'},
    {'key': 'jackaroo', 'name': 'Jackaroo', 'img': 'assets/games/game_icons/jackaroo.png'},
  ];

  static const List<Map<String, String>> lucky = [
    {'key': 'golden_fortune', 'name': 'Altin Servet', 'img': 'assets/games/game_icons/golden_fortune.png'},
    {'key': 'lucky_pro', 'name': 'Sansli Pro', 'img': 'assets/games/game_icons/lucky_pro.png'},
    {'key': 'lucky_fruit', 'name': 'Sansli Meyve', 'img': 'assets/games/game_icons/lucky_fruit.png'},
    {'key': 'greedy_pro', 'name': 'Acgozlu Pro', 'img': 'assets/games/game_icons/greedy_pro.png'},
    {'key': 'jackpot', 'name': 'Ikramiye', 'img': 'assets/games/game_icons/jackpot.png'},
    {'key': 'teen_patti', 'name': 'Teen Patti', 'img': 'assets/games/game_icons/teen_patti.png'},
    {'key': 'jackpot_slots', 'name': 'Jackpot Slot', 'img': 'assets/games/game_icons/jackpot_slots.png'},
    {'key': 'greedy_box', 'name': 'Acgozlu Kutusu', 'img': 'assets/games/game_icons/greedy_box.png'},
    {'key': 'dragon_tiger', 'name': 'Ejder Kaplan', 'img': 'assets/games/game_icons/dragon_tiger.png'},
    {'key': 'roulette', 'name': 'Rulet', 'img': 'assets/games/game_icons/roulette.png'},
    {'key': 'pyramids', 'name': 'Piramit', 'img': 'assets/games/game_icons/pyramids.png'},
    {'key': 'texas_cowboy', 'name': 'Texas Cowboy', 'img': 'assets/games/game_icons/texas_cowboy.png'},
    {'key': 'football', 'name': 'Football', 'img': 'assets/games/game_icons/football.png'},
    {'key': 'rocket', 'name': 'Roket', 'img': 'assets/games/game_icons/rocket.png'},
  ];

  void _open(BuildContext c, String key) {
    switch (key) {
      case 'rocket': Navigator.pushNamed(c, '/rocket'); break;
      case 'roulette': Navigator.pushNamed(c, '/roulette'); break;
      case 'dragon_tiger': Navigator.pushNamed(c, '/dragon-tiger'); break;
      case 'teen_patti': Navigator.pushNamed(c, '/teen-patti'); break;
      case 'football': Navigator.pushNamed(c, '/football'); break;
      case 'lucky_fruit': Navigator.pushNamed(c, '/lucky-fruit'); break;
      case 'greedy_pro': Navigator.pushNamed(c, '/greedy-pro'); break;
      case 'golden_fortune': Navigator.pushNamed(c, '/golden-fortune'); break;
      case 'lucky_pro': Navigator.pushNamed(c, '/lucky-pro'); break;
      case 'slot_food': Navigator.pushNamed(c, '/slot-food'); break;
      case 'jackpot_eagle': Navigator.pushNamed(c, '/jackpot-eagle'); break;
      default: Navigator.pushNamed(c, '/slot', arguments: {'theme': key});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(child: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          _header(),
          _sectionTitle('Casual Oyunlar'),
          _grid(context, casual, 3, 0.9),
          _sectionTitle('Sansli Oyun'),
          _grid(context, lucky, 4, 0.82),
        ],
      )),
    );
  }

  Widget _header() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.goldGradient,
        borderRadius: BorderRadius.circular(AppRadius.xl)),
      child: Row(children: [
        const Icon(Icons.casino, color: Colors.black, size: 40),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Oyun Merkezi', style: TextStyle(
              color: Colors.black, fontSize: 20,
              fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('20+ oyun secenegi', style: TextStyle(
              color: Colors.black.withOpacity(0.65), fontSize: 12)),
          ])),
        const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 20),
      ]),
    );
  }

  Widget _sectionTitle(String t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Row(children: [
        Container(width: 4, height: 20, decoration: BoxDecoration(
          gradient: AppColors.goldGradient,
          borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(t, style: const TextStyle(color: Colors.white,
          fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ]),
    );
  }

  Widget _grid(BuildContext ctx, List<Map<String, String>> list,
      int cols, double ratio) {
    return GridView.count(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: cols,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: ratio,
      children: list.map((g) => _tile(ctx, g)).toList(),
    );
  }

  Widget _tile(BuildContext ctx, Map<String, String> g) {
    return GestureDetector(
      onTap: () => _open(ctx, g['key']!),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.darkGradient,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.gold.withOpacity(0.25)),
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6, offset: const Offset(0, 3))]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Image.asset(g['img']!, width: 56, height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 56, height: 56,
                  decoration: const BoxDecoration(
                    gradient: AppColors.goldGradient,
                    shape: BoxShape.circle),
                  child: const Icon(Icons.casino, color: Colors.white)))),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(g['name']!, textAlign: TextAlign.center,
                maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white,
                  fontSize: 10, fontWeight: FontWeight.bold))),
          ]),
      ),
    );
  }
}
