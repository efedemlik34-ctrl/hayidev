import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'gift_data.dart';

class PremiumGiftAnimation extends StatefulWidget {
  final GiftItem gift;
  final String senderName;
  final String receiverName;
  final int quantity;
  final VoidCallback onComplete;

  const PremiumGiftAnimation({
    super.key,
    required this.gift,
    required this.senderName,
    required this.receiverName,
    required this.quantity,
    required this.onComplete,
  });

  @override
  State<PremiumGiftAnimation> createState() => _PremiumGiftAnimationState();
}

class _PremiumGiftAnimationState extends State<PremiumGiftAnimation>
    with TickerProviderStateMixin {
  late AnimationController _enterCtrl;
  late AnimationController _particleCtrl;
  late AnimationController _fadeCtrl;
  late AnimationController _shineCtrl;
  final rand = math.Random();
  late List<_P> particles;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 900));
    _particleCtrl = AnimationController(vsync: this,
      duration: const Duration(seconds: 4))..repeat();
    _fadeCtrl = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 700));
    _shineCtrl = AnimationController(vsync: this,
      duration: const Duration(seconds: 2))..repeat();

    final count = widget.gift.tier >= 4 ? 80 : widget.gift.tier >= 3 ? 50 : 30;
    particles = List.generate(count, (_) => _P(
      x: rand.nextDouble(), y: rand.nextDouble(),
      dx: (rand.nextDouble() - 0.5) * 2,
      dy: -0.5 - rand.nextDouble() * 2,
      size: 4 + rand.nextDouble() * 12,
      color: _pickColor(),
      rot: rand.nextDouble() * math.pi * 2,
    ));

    _run();
  }

  Color _pickColor() {
    final palettes = {
      1: [Colors.pink, Colors.red, Colors.amber],
      2: [Colors.amber, Colors.orange, Colors.deepOrange],
      3: [Colors.amber, Colors.orange, Colors.purple, Colors.pink],
      4: [Colors.amber, Colors.orange, Colors.purple, Colors.pink, Colors.cyanAccent],
      5: [Color(0xFFFFD700), Color(0xFFFF6B35), Color(0xFFE91E63),
          Color(0xFF9C27B0), Color(0xFF00E5FF), Color(0xFFFFFFFF)],
    };
    final p = palettes[widget.gift.tier] ?? palettes[1]!;
    return p[rand.nextInt(p.length)];
  }

  Future<void> _run() async {
    await _enterCtrl.forward();
    await Future.delayed(Duration(milliseconds: widget.gift.tier >= 4 ? 3200 : 2200));
    if (mounted) await _fadeCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    widget.onComplete();
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _particleCtrl.dispose();
    _fadeCtrl.dispose();
    _shineCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = widget.gift.tier >= 4;
    final isMedium = widget.gift.tier >= 3;

    return IgnorePointer(child: AnimatedBuilder(
      animation: Listenable.merge([_enterCtrl, _particleCtrl, _fadeCtrl]),
      builder: (_, __) {
        final t = Curves.elasticOut.transform(_enterCtrl.value);
        final opacity = (1 - _fadeCtrl.value).clamp(0.0, 1.0);

        return Opacity(
          opacity: opacity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (isPremium)
                Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.black.withOpacity(0.4 * t),
                        Colors.black.withOpacity(0.85 * t),
                      ],
                      radius: 0.7,
                    ),
                  ),
                ),
              if (isMedium)
                ...particles.map((p) {
                  final pt = _particleCtrl.value;
                  final px = p.x * MediaQuery.of(context).size.width + p.dx * pt * 300;
                  final py = p.y * MediaQuery.of(context).size.height + p.dy * pt * 400;
                  final scale = isPremium ? 1.3 : 1.0;
                  return Positioned(
                    left: px, top: py,
                    child: Transform.rotate(
                      angle: p.rot + pt * math.pi * 6,
                      child: Opacity(
                        opacity: (1 - pt).clamp(0.0, 1.0),
                        child: Container(
                          width: p.size * scale,
                          height: p.size * scale,
                          decoration: BoxDecoration(
                            color: p.color,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: p.color, blurRadius: 12)],
                          ),
                        ),
                      ),
                    ),
                  );
                }),

              Center(
                child: Transform.scale(
                  scale: 0.2 + t * 0.85,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.gift.isJackpot)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFC107), Color(0xFFFF5252)],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(color: Colors.amber.withOpacity(0.7),
                                blurRadius: 30, spreadRadius: 3),
                            ],
                          ),
                          child: const Text('🎰 JACKPOT',
                            style: TextStyle(color: Colors.black,
                              fontSize: 22, fontWeight: FontWeight.bold,
                              letterSpacing: 2)),
                        ),

                      if (isPremium)
                        Container(
                          width: 220, height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFFFFD700).withOpacity(0.3),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Center(child: Text(_emojiFor(widget.gift.key),
                            style: const TextStyle(
                              fontSize: 160,
                              shadows: [
                                Shadow(color: Color(0xFFFFD700), blurRadius: 40),
                                Shadow(color: Color(0xFFFF6B35), blurRadius: 80),
                              ],
                            )),
                          ),
                        )
                      else
                        Text(_emojiFor(widget.gift.key),
                          style: TextStyle(
                            fontSize: widget.gift.tier >= 3 ? 130 : 100,
                            shadows: isMedium ? const [
                              Shadow(color: Colors.amber, blurRadius: 30),
                            ] : null,
                          )),

                      const SizedBox(height: 20),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isPremium
                              ? [const Color(0xFFFFD700), const Color(0xFFFF6B35)]
                              : [Colors.purple, Colors.deepPurple],
                          ),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.5),
                              blurRadius: 16, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(widget.senderName,
                              style: const TextStyle(color: Colors.white,
                                fontSize: 18, fontWeight: FontWeight.bold)),
                            const Text('hediye gonderdi',
                              style: TextStyle(color: Colors.white70, fontSize: 11)),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text('${widget.gift.name} x${widget.quantity}',
                        style: TextStyle(
                          color: isPremium ? const Color(0xFFFFD700) : Colors.white,
                          fontSize: isPremium ? 24 : 20,
                          fontWeight: FontWeight.bold,
                          shadows: isPremium ? const [
                            Shadow(color: Color(0xFFFF6B35), blurRadius: 20),
                          ] : null,
                        )),

                      const SizedBox(height: 6),
                      Text('🪙 ${widget.gift.price * widget.quantity}',
                        style: const TextStyle(color: Color(0xFFFFC107),
                          fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),

              if (isPremium)
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _shineCtrl,
                    builder: (_, __) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(-1 + _shineCtrl.value * 2, -1),
                          end: const Alignment(1, 1),
                          colors: [
                            Colors.transparent,
                            Colors.white.withOpacity(0.08),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    ));
  }

  String _emojiFor(String key) {
    if (key.contains('pasta')) return '🎂';
    if (key.contains('yildiz')) return '⭐';
    if (key.contains('can')) return '🔔';
    if (key.contains('sandik')) return '🎁';
    if (key.contains('araba')) return '🏎️';
    if (key.contains('balloon')) return '🎈';
    if (key.contains('rose')) return '🌹';
    if (key.contains('heart')) return '❤️';
    if (key.contains('ring')) return '💍';
    if (key.contains('teddy')) return '🧸';
    if (key.contains('love_letter')) return '💌';
    if (key.contains('bayragi')) return '🇹🇷';
    if (key.contains('bozkurt')) return '🐺';
    if (key.contains('hilal')) return '🌙';
    if (key.contains('crown') || key.contains('king')) return '👑';
    if (key.contains('castle')) return '🏰';
    if (key.contains('throne')) return '🪑';
    if (key.contains('dragon')) return '🐉';
    if (key.contains('phoenix')) return '🔥';
    if (key.contains('lion')) return '🦁';
    if (key.contains('galaxy') || key.contains('universe')) return '🌌';
    if (key.contains('clover')) return '🍀';
    if (key.contains('777')) return '7️⃣';
    if (key.contains('rainbow')) return '🌈';
    if (key.contains('fire')) return '🔥';
    if (key.contains('ice')) return '❄️';
    if (key.contains('lucky')) return '🐤';
    return '🎁';
  }
}

class _P {
  final double x, y, dx, dy, size, rot;
  final Color color;
  _P({required this.x, required this.y, required this.dx, required this.dy,
    required this.size, required this.color, required this.rot});
}
