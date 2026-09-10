
import 'package:flutter/material.dart';

class MicControl extends StatefulWidget {
  final bool initialMuted;
  final Function(bool) onChanged;
  const MicControl({
    super.key,
    this.initialMuted = false,
    required this.onChanged,
  });
  @override
  State<MicControl> createState() => _MicControlState();
}

class _MicControlState extends State<MicControl> {
  late bool _muted;

  @override
  void initState() {
    super.initState();
    _muted = widget.initialMuted;
  }

  void _toggle() {
    setState(() => _muted = !_muted);
    widget.onChanged(_muted);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: _muted
                ? [const Color(0xFFF44336), const Color(0xFFB71C1C)]
                : [const Color(0xFF4CAF50), const Color(0xFF2E7D32)],
          ),
          boxShadow: [
            BoxShadow(
              color: _muted
                  ? const Color(0xFFF44336).withOpacity(0.5)
                  : const Color(0xFF4CAF50).withOpacity(0.5),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          _muted ? Icons.mic_off : Icons.mic,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}
