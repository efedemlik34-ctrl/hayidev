import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const OnboardingScreen({super.key, required this.onComplete});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = PageController();
  int _page = 0;

  final pages = [
    {'icon': '🎙️', 'title': 'Sesli Odalarda Bulus',
     'subtitle': 'Arkadaslarinla oda ac, muzik dinle, sohbet et.',
     'colors': [Color(0xFF4A148C), Color(0xFF7B1FA2)]},
    {'icon': '🎮', 'title': 'Oyunlarla Kazan',
     'subtitle': 'Rulet, Roket, Slot, Dragon Tiger ve 12+ oyun.',
     'colors': [Color(0xFF8B0000), Color(0xFFFF6B35)]},
    {'icon': '🎁', 'title': 'Hediye Gonder',
     'subtitle': '800+ hediye. Sansli hediyelerle 50x katla.',
     'colors': [Color(0xFFFF6B35), Color(0xFFFFC107)]},
    {'icon': '💰', 'title': 'Davet Et, Kazan',
     'subtitle': 'Her davetten 5000 coin. Kademe atla, milyon kazan.',
     'colors': [Color(0xFF0D47A1), Color(0xFF00BFFF)]},
  ];

  Future<void> _next() async {
    if (_page < pages.length - 1) {
      _ctrl.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
    } else {
      final p = await SharedPreferences.getInstance();
      await p.setBool('onboarding_done', true);
      widget.onComplete();
    }
  }

  Future<void> _skip() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('onboarding_done', true);
    widget.onComplete();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final p = pages[_page];
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: p['colors'] as List<Color>,
            begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: SafeArea(child: Column(children: [
          Align(alignment: Alignment.topRight, child: TextButton(
            onPressed: _skip,
            child: const Text('Atla', style: TextStyle(color: Colors.white70)))),
          Expanded(child: PageView.builder(
            controller: _ctrl,
            onPageChanged: (i) => setState(() => _page = i),
            itemCount: pages.length,
            itemBuilder: (_, i) {
              final pg = pages[i];
              return Padding(padding: const EdgeInsets.all(32), child: Column(
                mainAxisAlignment: MainAxisAlignment.center, children: [
                  TweenAnimationBuilder<double>(
                    key: ValueKey('icon_$i'), tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 600), curve: Curves.elasticOut,
                    builder: (_, v, child) => Transform.scale(scale: v, child: child),
                    child: Container(
                      width: 160, height: 160,
                      decoration: BoxDecoration(shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.15),
                        boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.3),
                          blurRadius: 40, spreadRadius: 4)]),
                      child: Center(child: Text(pg['icon'] as String,
                        style: const TextStyle(fontSize: 80))))),
                  const SizedBox(height: 48),
                  Text(pg['title'] as String, textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Text(pg['subtitle'] as String, textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.5)),
                ]));
            },
          )),
          Row(mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(pages.length, (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _page == i ? 28 : 8, height: 8,
              decoration: BoxDecoration(
                color: _page == i ? Colors.white : Colors.white38,
                borderRadius: BorderRadius.circular(4))))),
          const SizedBox(height: 32),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 32),
            child: SizedBox(width: double.infinity, height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                onPressed: _next,
                child: Text(_page == pages.length - 1 ? 'BASLA' : 'DEVAM',
                  style: const TextStyle(color: Colors.black, fontSize: 16,
                    fontWeight: FontWeight.bold, letterSpacing: 1))))),
          const SizedBox(height: 32),
        ])),
      ),
    );
  }
}
