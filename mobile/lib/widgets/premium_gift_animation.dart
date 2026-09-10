import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'gift_data.dart';

class PremiumGiftAnimation extends StatefulWidget {
  final GiftItem gift;
  final String senderName;
  final String receiverName;
  final int quantity;
  final VoidCallback onComplete;
  const PremiumGiftAnimation({super.key, required this.gift,
    required this.senderName, required this.receiverName,
    required this.quantity, required this.onComplete});
  @override
  State<PremiumGiftAnimation> createState() => _PremiumGiftAnimationState();
}

class _PremiumGiftAnimationState extends State<PremiumGiftAnimation>
    with TickerProviderStateMixin {
  late AnimationController _enter, _part, _fade, _shine, _fly;
  final rand = math.Random();
  late List<_P> parts;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _part = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    _fade = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _shine = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat();
    _fly = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000));
    final count = widget.gift.tier >= 4 ? 100 : widget.gift.tier >= 3 ? 60 : 30;
    parts = List.generate(count, (_) => _P(
      x: rand.nextDouble(), y: rand.nextDouble(),
      dx: (rand.nextDouble()-0.5)*2, dy: -0.5-rand.nextDouble()*2,
      size: 4+rand.nextDouble()*14, color: _pick(), rot: rand.nextDouble()*math.pi*2));
    _run();
  }

  Color _pick() {
    final p = {
      1: [Colors.pink, Colors.red, Colors.amber],
      2: [Colors.amber, Colors.orange, Colors.deepOrange],
      3: [Colors.amber, Colors.orange, Colors.purple, Colors.pink],
      4: [Colors.amber, Colors.orange, Colors.purple, Colors.pink, Colors.cyanAccent],
      5: [Color(0xFFFFD700), Color(0xFFFF6B35), Color(0xFFE91E63),
          Color(0xFF9C27B0), Color(0xFF00E5FF), Colors.white],
    }[widget.gift.tier] ?? [Colors.amber];
    return p[rand.nextInt(p.length)];
  }

  Future<void> _run() async {
    await _enter.forward();
    if (widget.gift.tier >= 4) _fly.forward();
    await Future.delayed(Duration(milliseconds: widget.gift.tier >= 4 ? 3500 : 2200));
    await _fade.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    widget.onComplete();
  }

  @override
  void dispose() {
    _enter.dispose(); _part.dispose(); _fade.dispose();
    _shine.dispose(); _fly.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isP = widget.gift.tier >= 4;
    final isM = widget.gift.tier >= 3;
    return IgnorePointer(child: AnimatedBuilder(
      animation: Listenable.merge([_enter, _part, _fade, _shine, _fly]),
      builder: (_, __) {
        final t = Curves.elasticOut.transform(_enter.value);
        final op = (1 - _fade.value).clamp(0.0, 1.0);
        return Opacity(opacity: op, child: Stack(
          fit: StackFit.expand,
          children: [
            if (isP) Container(decoration: BoxDecoration(
              gradient: RadialGradient(radius: 0.7,
                colors: [Colors.black.withOpacity(0.4*t), Colors.black.withOpacity(0.9*t)]))),
            if (isM) ...parts.map((p) {
              final pt = _part.value;
              final px = p.x * MediaQuery.of(context).size.width + p.dx*pt*300;
              final py = p.y * MediaQuery.of(context).size.height + p.dy*pt*400;
              return Positioned(left: px, top: py, child: Transform.rotate(
                angle: p.rot + pt*math.pi*6,
                child: Opacity(opacity: (1-pt).clamp(0.0,1.0), child: Container(
                  width: p.size, height: p.size,
                  decoration: BoxDecoration(color: p.color, shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: p.color, blurRadius: 12)])))));
            }),
            // Shine sweep
            if (isP) Positioned.fill(child: Container(decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-1 + _shine.value*2, -1), end: const Alignment(1,1),
                colors: [Colors.transparent, Colors.white.withOpacity(0.1), Colors.transparent])))),
            // Fly effect for tier 5
            if (widget.gift.tier >= 5) Positioned(
              left: -100 + _fly.value * (MediaQuery.of(context).size.width + 200),
              top: MediaQuery.of(context).size.height * 0.25,
              child: Opacity(opacity: (1-_fly.value).clamp(0.0,1.0),
                child: Transform.rotate(angle: _fly.value * math.pi * 2,
                  child: Text(_emojiFor(widget.gift.key),
                    style: TextStyle(fontSize: 80, shadows: [
                      Shadow(color: const Color(0xFFFFD700), blurRadius: 40)]))))),
            Center(child: Transform.scale(scale: 0.2 + t*0.85, child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.gift.isJackpot) Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFFFC107), Color(0xFFFF5252)]),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.7),
                      blurRadius: 30, spreadRadius: 3)]),
                  child: const Text('🎰 JACKPOT', style: TextStyle(
                    color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2))),
                if (isP) Container(width: 220, height: 220,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      const Color(0xFFFFD700).withOpacity(0.3), Colors.transparent])),
                  child: Center(child: Text(_emojiFor(widget.gift.key),
                    style: const TextStyle(fontSize: 160, shadows: [
                      Shadow(color: Color(0xFFFFD700), blurRadius: 40),
                      Shadow(color: Color(0xFFFF6B35), blurRadius: 80)]))))
                else Text(_emojiFor(widget.gift.key),
                  style: TextStyle(fontSize: widget.gift.tier >= 3 ? 130 : 100,
                    shadows: isM ? [const Shadow(color: Colors.amber, blurRadius: 30)] : null)),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: isP
                      ? [const Color(0xFFFFD700), const Color(0xFFFF6B35)]
                      : [Colors.purple, Colors.deepPurple]),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5),
                      blurRadius: 16, offset: const Offset(0, 4))]),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(widget.senderName, style: const TextStyle(
                      color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const Text('hediye gonderdi', style: TextStyle(
                      color: Colors.white70, fontSize: 11))])),
                const SizedBox(height: 10),
                Text('${widget.gift.name} x${widget.quantity}',
                  style: TextStyle(
                    color: isP ? const Color(0xFFFFD700) : Colors.white,
                    fontSize: isP ? 24 : 20, fontWeight: FontWeight.bold,
                    shadows: isP ? [const Shadow(color: Color(0xFFFF6B35), blurRadius: 20)] : null)),
                const SizedBox(height: 6),
                Text('🪙 ${widget.gift.price * widget.quantity}',
                  style: const TextStyle(color: Color(0xFFFFC107),
                    fontSize: 14, fontWeight: FontWeight.bold)),
              ]))),
          ]));
      }));
  }

  String _emojiFor(String k) {
    if (k.contains('pasta')) return '🎂';
    if (k.contains('yildiz')) return '⭐';
    if (k.contains('can')) return '🔔';
    if (k.contains('sandik')) return '🎁';
    if (k.contains('araba')) return '🏎️';
    if (k.contains('balloon')) return '🎈';
    if (k.contains('rose')) return '🌹';
    if (k.contains('heart')) return '❤️';
    if (k.contains('ring')) return '💍';
    if (k.contains('teddy')) return '🧸';
    if (k.contains('love_letter')) return '💌';
    if (k.contains('bayragi')) return '🇹🇷';
    if (k.contains('bozkurt')) return '🐺';
    if (k.contains('hilal')) return '🌙';
    if (k.contains('crown') || k.contains('king')) return '👑';
    if (k.contains('castle')) return '🏰';
    if (k.contains('throne')) return '🪑';
    if (k.contains('dragon')) return '🐉';
    if (k.contains('phoenix')) return '🔥';
    if (k.contains('lion')) return '🦁';
    if (k.contains('galaxy') || k.contains('universe')) return '🌌';
    if (k.contains('clover')) return '🍀';
    if (k.contains('777')) return '7️⃣';
    if (k.contains('rainbow')) return '🌈';
    if (k.contains('fire')) return '🔥';
    if (k.contains('ice')) return '❄️';
    if (k.contains('lucky')) return '🐤';
    if (k.contains('sansli')) return '⭐';
    return '🎁';
  }
}

class _P {
  final double x, y, dx, dy, size, rot;
  final Color color;
  _P({required this.x, required this.y, required this.dx, required this.dy,
    required this.size, required this.color, required this.rot});
}
