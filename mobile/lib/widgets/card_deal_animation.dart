import 'package:flutter/material.dart';

class CardDealAnimation extends StatefulWidget {
  final List<Widget> cards;
  final Duration delayBetween;
  const CardDealAnimation({super.key, required this.cards, this.delayBetween = const Duration(milliseconds: 150)});
  @override
  State<CardDealAnimation> createState() => _CardDealAnimationState();
}

class _CardDealAnimationState extends State<CardDealAnimation> with TickerProviderStateMixin {
  final List<AnimationController> _ctrls = [];
  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.cards.length; i++) {
      final c = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
      _ctrls.add(c);
      Future.delayed(widget.delayBetween * i, () { if (mounted) c.forward(); });
    }
  }
  @override
  void dispose() { for (final c in _ctrls) c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.cards.length, (i) {
        if (i >= _ctrls.length) return widget.cards[i];
        return AnimatedBuilder(
          animation: _ctrls[i],
          builder: (_, __) {
            final t = Curves.easeOutBack.transform(_ctrls[i].value);
            return Transform.translate(
              offset: Offset(0, (1 - t) * -200),
              child: Transform.rotate(
                angle: (1 - t) * 0.5 * (i.isEven ? 1 : -1),
                child: Transform.scale(scale: 0.5 + t * 0.5,
                  child: Opacity(opacity: _ctrls[i].value.clamp(0.0, 1.0), child: widget.cards[i])),
              ),
            );
          },
        );
      }),
    );
  }
}
