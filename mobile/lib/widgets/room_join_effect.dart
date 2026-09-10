import 'dart:math' as math;
import 'package:flutter/material.dart';

class RoomJoinEffect extends StatefulWidget {
  final String username;
  final String? frame;
  final VoidCallback onComplete;
  const RoomJoinEffect({super.key, required this.username, this.frame, required this.onComplete});
  @override
  State<RoomJoinEffect> createState() => _RoomJoinEffectState();
}

class _RoomJoinEffectState extends State<RoomJoinEffect> with TickerProviderStateMixin {
  late AnimationController _slideCtrl;
  late AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _run();
  }

  Future<void> _run() async {
    await _slideCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 1500));
    await _fadeCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    widget.onComplete();
  }

  @override
  void dispose() { _slideCtrl.dispose(); _fadeCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(child: AnimatedBuilder(
      animation: Listenable.merge([_slideCtrl, _fadeCtrl]),
      builder: (_, __) {
        final slide = Curves.easeOutBack.transform(_slideCtrl.value);
        return Opacity(
          opacity: (1 - _fadeCtrl.value).clamp(0.0, 1.0),
          child: Align(
            alignment: Alignment(0, -0.7 + slide * 0.3),
            child: Transform.scale(
              scale: 0.5 + slide * 0.5,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFFC107), Color(0xFFFF6B35)]),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.8),
                    blurRadius: 30, spreadRadius: 4)]),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.emoji_emotions, color: Colors.black, size: 22),
                  const SizedBox(width: 8),
                  Text('${widget.username} katildi!', style: const TextStyle(
                    color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)),
                ]),
              ),
            ),
          ),
        );
      },
    ));
  }
}
