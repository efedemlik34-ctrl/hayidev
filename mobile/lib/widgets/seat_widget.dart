import 'dart:math' as math;
import 'package:flutter/material.dart';

class SeatWidget extends StatefulWidget {
  final int index;
  final Map? seat;
  final bool isMe;
  final bool isSpeaking;
  final VoidCallback onTap;
  final double size;
  const SeatWidget({
    super.key,
    required this.index,
    this.seat,
    this.isMe = false,
    this.isSpeaking = false,
    required this.onTap,
    this.size = 62,
  });
  @override
  State<SeatWidget> createState() => _SeatWidgetState();
}

class _SeatWidgetState extends State<SeatWidget> with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _rotateCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _rotateCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
  }

  @override
  void dispose() { _pulseCtrl.dispose(); _rotateCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final occupied = widget.seat != null && widget.seat!['username'] != null;
    final username = occupied ? (widget.seat!['username'] as String) : null;
    final isLocked = widget.seat != null && widget.seat!['is_locked'] == true;
    final size = widget.size;

    return GestureDetector(
      onTap: widget.onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(
          width: size + 14, height: size + 14,
          child: Stack(alignment: Alignment.center, children: [
            // Donen ring - speaking
            if (widget.isSpeaking && occupied)
              AnimatedBuilder(
                animation: _rotateCtrl,
                builder: (_, __) => Transform.rotate(
                  angle: _rotateCtrl.value * 2 * math.pi,
                  child: Container(
                    width: size + 14, height: size + 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(colors: [
                        const Color(0xFF4CAF50).withOpacity(0),
                        const Color(0xFF4CAF50),
                        const Color(0xFF4CAF50).withOpacity(0),
                      ]),
                    ),
                  ),
                ),
              ),
            // Dis glow
            if (occupied)
              AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (_, __) => Container(
                  width: size + 8 + _pulseCtrl.value * 4,
                  height: size + 8 + _pulseCtrl.value * 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFFFC107).withOpacity(0.5),
                        const Color(0xFFFFC107).withOpacity(0),
                      ],
                    ),
                  ),
                ),
              ),
            // Ana daire
            Container(
              width: size, height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: occupied
                  ? const LinearGradient(
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                      colors: [Color(0xFFFFD54F), Color(0xFFFF8A00), Color(0xFFFF4500)])
                  : null,
                color: occupied ? null : const Color(0xFF1A1F3A),
                border: Border.all(
                  color: widget.isMe
                    ? const Color(0xFF4CAF50)
                    : (occupied ? const Color(0xFFFFC107) : Colors.white24),
                  width: widget.isMe ? 3 : 2,
                ),
                boxShadow: occupied ? [
                  BoxShadow(color: const Color(0xFFFF8A00).withOpacity(0.6), blurRadius: 16, spreadRadius: 2),
                  BoxShadow(color: const Color(0xFFFF4500).withOpacity(0.3), blurRadius: 24, spreadRadius: 4),
                ] : [
                  BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4)),
                ],
              ),
              child: Center(child: occupied
                ? Text(username![0].toUpperCase(),
                    style: TextStyle(color: Colors.black, fontSize: size * 0.4, fontWeight: FontWeight.bold))
                : Icon(isLocked ? Icons.lock : Icons.mic, color: Colors.white38, size: size * 0.35)),
            ),
            // Konusuyor ikonu
            if (occupied && widget.isSpeaking)
              Positioned(right: 0, bottom: 0, child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(color: Color(0xFF4CAF50), shape: BoxShape.circle),
                child: const Icon(Icons.mic, color: Colors.white, size: 10),
              )),
          ]),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: size + 12,
          child: Text(occupied ? username! : '${widget.index + 1}',
            style: TextStyle(
              color: occupied ? Colors.white : Colors.white38,
              fontSize: 10, fontWeight: occupied ? FontWeight.bold : FontWeight.normal),
            textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
        ),
      ]),
    );
  }
}
