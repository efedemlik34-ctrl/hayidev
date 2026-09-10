import 'package:flutter/material.dart';
import 'feedback_service.dart';

class AnimatedButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final List<Color>? colors;
  final bool loading;
  const AnimatedButton({super.key, required this.label, this.icon, required this.onTap,
    this.colors, this.loading = false});
  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors ?? [const Color(0xFFFFC107), const Color(0xFFFF6B35)];
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        FeedbackService.medium();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: colors[0].withOpacity(0.4),
              blurRadius: _pressed ? 8 : 16, offset: const Offset(0, 4))]),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
            if (widget.loading) ...[
              const SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5)),
              const SizedBox(width: 10),
            ] else if (widget.icon != null) ...[
              Icon(widget.icon, color: Colors.black, size: 20),
              const SizedBox(width: 8),
            ],
            Text(widget.label, style: const TextStyle(color: Colors.black,
              fontSize: 15, fontWeight: FontWeight.bold)),
          ]),
        ),
      ),
    );
  }
}
