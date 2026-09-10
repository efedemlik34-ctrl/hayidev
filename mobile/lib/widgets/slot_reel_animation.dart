import 'package:flutter/material.dart';

class SlotReel extends StatefulWidget {
  final List<String> symbols;
  final bool spinning;
  final String? finalSymbol;
  final double size;
  const SlotReel({super.key, required this.symbols, this.spinning = false, this.finalSymbol, this.size = 80});
  @override
  State<SlotReel> createState() => _SlotReelState();
}

class _SlotReelState extends State<SlotReel> with SingleTickerProviderStateMixin {
  late AnimationController _spin;
  int _idx = 0;
  @override
  void initState() {
    super.initState();
    _spin = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _spin.addListener(() {
      if (widget.spinning && mounted) setState(() => _idx = (_idx + 1) % widget.symbols.length);
    });
    if (widget.spinning) _spin.repeat();
  }
  @override
  void didUpdateWidget(SlotReel old) {
    super.didUpdateWidget(old);
    if (widget.spinning && !old.spinning) _spin.repeat();
    else if (!widget.spinning && old.spinning) {
      _spin.stop();
      if (widget.finalSymbol != null) {
        final i = widget.symbols.indexOf(widget.finalSymbol!);
        if (i >= 0) _idx = i;
      }
    }
  }
  @override
  void dispose() { _spin.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final sym = widget.spinning ? widget.symbols[_idx] : (widget.finalSymbol ?? widget.symbols[_idx]);
    return Container(
      width: widget.size, height: widget.size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1A0F3E), Color(0xFF0A0E27)]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFC107).withOpacity(0.4), width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 8)]),
      child: Center(child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 80),
        child: Text(sym, key: ValueKey(sym), style: TextStyle(fontSize: widget.size * 0.55))),
      ),
    );
  }
}

class SlotMachineAnimation extends StatelessWidget {
  final List<List<String>> reels;
  final bool spinning;
  const SlotMachineAnimation({super.key, required this.reels, this.spinning = false});
  @override
  Widget build(BuildContext context) {
    final symbols = ['🍒', '🍋', '🍇', '💎', '⭐', '7️⃣', '👑', '🔔', '🪙'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(5, (col) {
        final finalSym = col < reels.length && reels[col].isNotEmpty ? reels[col][0] : null;
        return SlotReel(
          symbols: symbols, spinning: spinning,
          finalSymbol: spinning ? null : finalSym, size: 64,
        );
      }),
    );
  }
}
