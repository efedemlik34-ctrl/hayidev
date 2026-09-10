import 'package:flutter/material.dart';

class DragonTigerCard extends StatefulWidget {
  final String? value;
  final String? suit;
  final bool isDragon;
  final bool visible;
  const DragonTigerCard({super.key, this.value, this.suit, this.isDragon = true, this.visible = true});
  @override
  State<DragonTigerCard> createState() => _DragonTigerCardState();
}

class _DragonTigerCardState extends State<DragonTigerCard> with SingleTickerProviderStateMixin {
  late AnimationController _flip;
  @override
  void initState() {
    super.initState();
    _flip = AnimationController(vsync: this, duration: const Duration(milliseconds: 600), value: widget.visible ? 1.0 : 0.0);
  }
  @override
  void didUpdateWidget(DragonTigerCard old) {
    super.didUpdateWidget(old);
    if (widget.visible != old.visible) {
      widget.visible ? _flip.forward() : _flip.reverse();
    }
  }
  @override
  void dispose() { _flip.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _flip,
      builder: (_, __) {
        final angle = _flip.value * 3.14159;
        final showFront = angle < 3.14159 / 2;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY(angle),
          child: showFront ? _front() : _back(),
        );
      },
    );
  }

  Widget _front() {
    final isRed = widget.suit == '♥' || widget.suit == '♦';
    final fc = widget.isDragon ? const Color(0xFFFF4500) : const Color(0xFF4FC3F7);
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(3.14159),
      child: Container(
        width: 110, height: 160,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Colors.white, Color(0xFFF5F5F5)]),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: fc, width: 3),
          boxShadow: [BoxShadow(color: fc.withOpacity(0.6), blurRadius: 20, spreadRadius: 2)],
        ),
        child: Stack(children: [
          Positioned(top: 6, left: 6, child: Text(widget.value ?? '?',
            style: TextStyle(color: isRed ? Colors.red : Colors.black, fontSize: 24, fontWeight: FontWeight.bold))),
          Positioned(top: 32, left: 8, child: Text(widget.suit ?? '',
            style: TextStyle(color: isRed ? Colors.red : Colors.black, fontSize: 20))),
          Center(child: Text(widget.suit ?? '?', style: TextStyle(
            color: isRed ? Colors.red : Colors.black, fontSize: 50))),
        ]),
      ),
    );
  }

  Widget _back() {
    final fc = widget.isDragon ? const Color(0xFFFF4500) : const Color(0xFF4FC3F7);
    return Container(
      width: 110, height: 160,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [fc.withOpacity(0.8), fc.withOpacity(0.4)]),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [BoxShadow(color: fc.withOpacity(0.5), blurRadius: 16)],
      ),
      child: Center(child: Icon(
        widget.isDragon ? Icons.local_fire_department : Icons.whatshot,
        color: Colors.white, size: 60)),
    );
  }
}
