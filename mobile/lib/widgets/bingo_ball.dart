import 'dart:math' as math;
import 'package:flutter/material.dart';

class BingoBall extends StatefulWidget {
  final int? number;
  final String? letter;
  final double size;
  const BingoBall({super.key, this.number, this.letter, this.size = 120});
  @override
  State<BingoBall> createState() => _BingoBallState();
}

class _BingoBallState extends State<BingoBall> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..forward();
  }
  @override
  void didUpdateWidget(BingoBall old) {
    super.didUpdateWidget(old);
    if (widget.number != old.number) _ctrl.forward(from: 0);
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Color _getColor(int n) {
    if (n <= 15) return const Color(0xFF2196F3);
    if (n <= 30) return const Color(0xFF4CAF50);
    if (n <= 45) return const Color(0xFFFF9800);
    if (n <= 60) return const Color(0xFFE91E63);
    return const Color(0xFF9C27B0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final bounce = Curves.elasticOut.transform(_ctrl.value);
        final rotate = _ctrl.value * 2 * math.pi;
        return Transform.scale(
          scale: 0.3 + bounce * 0.7,
          child: Transform.rotate(
            angle: rotate * (1 - _ctrl.value),
            child: Container(
              width: widget.size, height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: widget.number != null
                    ? [Colors.white, _getColor(widget.number!).withOpacity(0.7), _getColor(widget.number!)]
                    : [Colors.white54, Colors.white24],
                  stops: const [0.0, 0.3, 1.0],
                  center: const Alignment(-0.3, -0.3)),
                boxShadow: [
                  BoxShadow(color: widget.number != null
                    ? _getColor(widget.number!).withOpacity(0.6) : Colors.black26,
                    blurRadius: 30, spreadRadius: 5),
                ]),
              child: widget.number != null ? _buildContent() : _buildEmpty(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() => Center(child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      if (widget.letter != null)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10)),
          child: Text(widget.letter!, style: TextStyle(color: Colors.white,
            fontSize: widget.size * 0.15, fontWeight: FontWeight.bold, letterSpacing: 2)),
        ),
      Text('${widget.number}', style: TextStyle(color: Colors.white,
        fontSize: widget.size * 0.4, fontWeight: FontWeight.bold)),
    ]));

  Widget _buildEmpty() => Center(child: Text('?',
    style: TextStyle(color: Colors.white, fontSize: widget.size * 0.5, fontWeight: FontWeight.bold)));
}
