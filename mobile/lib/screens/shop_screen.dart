import 'package:flutter/material.dart';
import '../services/api.dart';
import '../widgets/app_theme.dart';
import '../widgets/app_button.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});
  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  int _tab = 0;
  final _tabs = ['Coin', 'Elmas', 'VIP'];

  static const _coins = [
    {'c': 1000, 'p': '10 TL', 'i': '🪙', 't': ''},
    {'c': 5500, 'p': '50 TL', 'i': '💰', 't': '+10%'},
    {'c': 12000, 'p': '100 TL', 'i': '💎', 't': '+20%'},
    {'c': 30000, 'p': '250 TL', 'i': '👑', 't': '+30%'},
    {'c': 70000, 'p': '500 TL', 'i': '🏆', 't': '+40%'},
    {'c': 200000, 'p': '1000 TL', 'i': '🌟', 't': 'EN IYI'},
  ];

  static const _dias = [
    {'d': 100, 'p': '15 TL'}, {'d': 600, 'p': '80 TL'},
    {'d': 1500, 'p': '150 TL'}, {'d': 5000, 'p': '400 TL'},
  ];

  static const _vips = [
    {'n': 'VIP 1 Ay', 'p': '99 TL', 'i': '🥉', 'c1': Color(0xFF4CAF50), 'c2': Color(0xFF2E7D32)},
    {'n': 'VIP 3 Ay', 'p': '249 TL', 'i': '🥈', 'c1': Color(0xFF2196F3), 'c2': Color(0xFF1565C0)},
    {'n': 'VIP 12 Ay', 'p': '799 TL', 'i': '🥇', 'c1': Color(0xFFFFC107), 'c2': Color(0xFFFF6B35)},
  ];

  Future<void> _buy(String id) async {
    try {
      await Api.dio.post('/shop/purchase', data: {'id': id});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Satin alindi!'),
          backgroundColor: AppColors.green));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e'), backgroundColor: AppColors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(title: const Text('Magaza')),
      body: Column(children: [
        _hero(),
        _tabBar(),
        Expanded(child: _content()),
      ]),
    );
  }

  Widget _hero() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppColors.purple, AppColors.pink, AppColors.orange]),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [BoxShadow(
          color: AppColors.purple.withOpacity(0.5),
          blurRadius: 24, offset: const Offset(0, 8))]),
      child: const Row(children: [
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hos Geldin!', style: TextStyle(color: Colors.white,
              fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('Coin ve elmas satin al', style: TextStyle(
              color: Colors.white70, fontSize: 12)),
          ])),
        Text('🎁', style: TextStyle(fontSize: 60)),
      ]),
    );
  }

  Widget _tabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppRadius.lg)),
      child: Row(children: List.generate(_tabs.length, (i) {
        final sel = _tab == i;
        return Expanded(child: GestureDetector(
          onTap: () => setState(() => _tab = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              gradient: sel ? AppColors.goldGradient : null,
              borderRadius: BorderRadius.circular(AppRadius.md)),
            child: Center(child: Text(_tabs[i], style: TextStyle(
              color: sel ? Colors.black : Colors.white60,
              fontWeight: FontWeight.bold, fontSize: 12))))));
      })),
    );
  }

  Widget _content() {
    if (_tab == 0) return _coinsList();
    if (_tab == 1) return _diasList();
    return _vipsList();
  }

  Widget _coinsList() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10,
        childAspectRatio: 0.85),
      itemCount: _coins.length,
      itemBuilder: (_, i) {
        final p = _coins[i];
        final c = p['c'].toString();
        final pr = p['p'] as String;
        final ic = p['i'] as String;
        final tg = p['t'] as String;
        return GestureDetector(
          onTap: () => _buy('coin_' + c),
          child: Container(
            decoration: BoxDecoration(
              gradient: AppColors.darkGradient,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.gold.withOpacity(0.3))),
            child: Stack(children: [
              if (tg.isNotEmpty) Positioned(top: 8, right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [
                      Color(0xFFFF5252), Color(0xFFFF1744)]),
                    borderRadius: BorderRadius.circular(AppRadius.sm)),
                  child: Text(tg, style: const TextStyle(
                    color: Colors.white, fontSize: 9,
                    fontWeight: FontWeight.bold)))),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(ic, style: const TextStyle(fontSize: 48)),
                    const SizedBox(height: 6),
                    FittedBox(child: Text(c, style: const TextStyle(
                      color: AppColors.gold, fontSize: 20,
                      fontWeight: FontWeight.bold))),
                    const Text('coin', style: TextStyle(
                      color: Colors.white54, fontSize: 10)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [
                          AppColors.green, Color(0xFF2E7D32)]),
                        borderRadius: BorderRadius.circular(AppRadius.md)),
                      child: Text(pr, style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold,
                        fontSize: 12))),
                  ]),
              ),
            ]),
          ),
        );
      },
    );
  }

  Widget _diasList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _dias.length,
      itemBuilder: (_, i) {
        final p = _dias[i];
        final d = p['d'].toString();
        final pr = p['p'] as String;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              const Color(0xFF0F1E5E), AppColors.bgCard]),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.cyan.withOpacity(0.4))),
          child: Row(children: [
            const Text('💠', style: TextStyle(fontSize: 40)),
            const SizedBox(width: 16),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(d + ' Elmas', style: const TextStyle(
                  color: Colors.white, fontSize: 18,
                  fontWeight: FontWeight.bold)),
                const Text('Hediye ve ozel icin', style: TextStyle(
                  color: Colors.white54, fontSize: 11)),
              ])),
            GestureDetector(
              onTap: () => _buy('dia_' + d),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [
                    AppColors.cyan, AppColors.blue]),
                  borderRadius: BorderRadius.circular(AppRadius.md)),
                child: Text(pr, style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold,
                  fontSize: 12)))),
          ]),
        );
      },
    );
  }

  Widget _vipsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _vips.length,
      itemBuilder: (_, i) {
        final p = _vips[i];
        final n = p['n'] as String;
        final pr = p['p'] as String;
        final ic = p['i'] as String;
        final c1 = p['c1'] as Color;
        final c2 = p['c2'] as Color;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [c1, c2]),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: [BoxShadow(
              color: c1.withOpacity(0.4),
              blurRadius: 20, offset: const Offset(0, 6))]),
          child: Row(children: [
            Text(ic, style: const TextStyle(fontSize: 46)),
            const SizedBox(width: 16),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(n, style: const TextStyle(color: Colors.white,
                  fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Reklamsiz • Ozel rozet • 2x XP',
                  style: TextStyle(color: Colors.white70, fontSize: 11)),
              ])),
            AppButton(
              label: pr,
              width: 100,
              height: 44,
              colors: [Colors.black, Colors.black54],
              onTap: () => _buy(n)),
          ]),
        );
      },
    );
  }
}
