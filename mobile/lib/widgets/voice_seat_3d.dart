import 'dart:math' as math;
import 'package:flutter/material.dart';

class VoiceSeat3D extends StatefulWidget {
  final String? username;
  final bool isMuted;
  final bool isSpeaking;
  final bool isHost;
  final int level;
  final VoidCallback? onTap;
  const VoiceSeat3D({super.key, this.username, this.isMuted = false,
    this.isSpeaking = false, this.isHost = false, this.level = 0, this.onTap});
  @override
  State<VoiceSeat3D> createState() => _VoiceSeat3DState();
}

class _VoiceSeat3DState extends State<VoiceSeat3D>
    with TickerProviderStateMixin {
  late AnimationController _pulse, _rotate;
  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _rotate = AnimationController(vsync: this,
      duration: const Duration(seconds: 8))..repeat();
  }
  @override
  void dispose() { _pulse.dispose(); _rotate.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final empty = widget.username == null || widget.username!.isEmpty;
    return GestureDetector(onTap: widget.onTap, child: AnimatedBuilder(
      animation: Listenable.merge([_pulse, _rotate]),
      builder: (_, __) {
        final pv = widget.isSpeaking ? _pulse.value : 0.0;
        return Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(width: 90, height: 90,
            child: Stack(alignment: Alignment.center, children: [
              if (widget.isSpeaking) Transform.rotate(
                angle: _rotate.value * 2 * math.pi,
                child: Container(width: 86, height: 86,
                  decoration: const BoxDecoration(shape: BoxShape.circle,
                    gradient: SweepGradient(colors: [
                      Colors.transparent, Color(0xFFFFC107), Colors.transparent])))),
              if (widget.isSpeaking) Container(
                width: 70 + pv * 12, height: 70 + pv * 12,
                decoration: BoxDecoration(shape: BoxShape.circle,
                  boxShadow: [BoxShadow(
                    color: Color(0xFFFFC107).withOpacity(0.6 - pv * 0.4),
                    blurRadius: 20 + pv * 20, spreadRadius: 2)])),
              Container(width: 64, height: 64,
                decoration: BoxDecoration(shape: BoxShape.circle,
                  gradient: LinearGradient(colors: empty
                    ? [Colors.grey.shade800, Colors.grey.shade900]
                    : widget.isHost
                      ? [Color(0xFFFFD700), Color(0xFFFF8C00)]
                      : [Color(0xFF9C27B0), Color(0xFF6A1B9A)]),
                  border: Border.all(
                    color: widget.isSpeaking ? Color(0xFFFFC107) : Colors.white24,
                    width: widget.isSpeaking ? 3 : 2),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4),
                    blurRadius: 10, offset: Offset(0, 4))]),
                child: Center(child: empty
                  ? const Icon(Icons.add, color: Colors.white38, size: 26)
                  : Text((widget.username ?? '?')[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white,
                        fontSize: 26, fontWeight: FontWeight.bold)))),
              if (widget.isHost && !empty) Positioned(top: 0,
                child: const Text('👑', style: TextStyle(fontSize: 18))),
              if (widget.isMuted && !empty) Positioned(bottom: 2, right: 2,
                child: Container(padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(color: Colors.red,
                    shape: BoxShape.circle),
                  child: const Icon(Icons.mic_off, color: Colors.white, size: 12))),
              if (!empty && widget.level > 0) Positioned(bottom: 0, left: 2,
                child: Container(padding: const EdgeInsets.symmetric(
                    horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [
                      Color(0xFFFFC107), Color(0xFFFF6B35)]),
                    borderRadius: BorderRadius.circular(8)),
                  child: Text('Lv${widget.level}',
                    style: const TextStyle(color: Colors.black,
                      fontSize: 8, fontWeight: FontWeight.bold)))),
            ])),
          const SizedBox(height: 6),
          SizedBox(width: 84, child: Text(empty ? 'Bos' : (widget.username ?? ''),
            textAlign: TextAlign.center, maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: empty ? Colors.white38 : Colors.white,
              fontSize: 11, fontWeight: FontWeight.bold))),
        ]);
      }));
  }
}
