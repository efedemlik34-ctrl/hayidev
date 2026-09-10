import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/api.dart';

class RouletteScreen extends StatefulWidget {
  const RouletteScreen({super.key});
  @override
  State<RouletteScreen> createState() => _RouletteScreenState();
}

class _RouletteScreenState extends State<RouletteScreen> with SingleTickerProviderStateMixin {
  int? winning;
  bool spinning = false;
  int bet = 1000;
  late AnimationController ctrl;

  @override
  void initState() { super.initState(); ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 4)); }
  @override
  void dispose() { ctrl.dispose(); super.dispose(); }

  Future<void> _spin(String type) async {
    setState(() => spinning = true);
    ctrl.repeat();
    try {
      final r = await Api.dio.post('/games/roulette/spin', data: {'bet': bet, 'type': type});
      await Future.delayed(const Duration(seconds: 4));
      ctrl.stop();
      setState(() { winning = r.data['winning']; spinning = false; });
    } catch (e) {
      ctrl.stop();
      setState(() => spinning = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Color _c(int n) {
    const reds = [1,3,5,7,9,12,14,16,18,19,21,23,25,27,30,32,34,36];
    if (n == 0) return Colors.green.shade700;
    return reds.contains(n) ? Colors.red.shade700 : Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A3D1E),
      appBar: AppBar(title: const Text('Rulet'), backgroundColor: Colors.transparent),
      body: Column(children: [
        SizedBox(height: 200, child: Center(child: spinning
          ? AnimatedBuilder(animation: ctrl, builder: (_, __) => Transform.rotate(angle: ctrl.value * 2 * math.pi * 5, child: Container(width: 180, height: 180, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: SweepGradient(colors: [Color(0xFFB71C1C), Colors.black, Color(0xFFB71C1C), Colors.black]),), child: const Center(child: Icon(Icons.casino, color: Colors.white, size: 40)))))
          : winning == null
            ? Container(width: 180, height: 180, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF8B4513)), child: const Center(child: Icon(Icons.casino, color: Colors.white, size: 60)))
            : Container(width: 140, height: 140, decoration: BoxDecoration(color: _c(winning!), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 4)), child: Center(child: Text('$winning', style: const TextStyle(color: Colors.white, fontSize: 60, fontWeight: FontWeight.bold)))),
        )),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          for (final b in [100, 1000, 5000, 10000, 50000]) GestureDetector(
            onTap: spinning ? null : () => setState(() => bet = b),
            child: Container(margin: const EdgeInsets.symmetric(horizontal: 3), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: bet == b ? const Color(0xFFFFC107) : Colors.white10, borderRadius: BorderRadius.circular(16)), child: Text('${b >= 1000 ? '${b ~/ 1000}K' : b}', style: TextStyle(color: bet == b ? Colors.black : Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
          ),
        ])),
        const SizedBox(height: 12),
        Expanded(child: GridView.count(padding: const EdgeInsets.all(12), crossAxisCount: 3, mainAxisSpacing: 6, crossAxisSpacing: 6, childAspectRatio: 1.6, children: [
          _btn('KIRMIZI', Colors.red.shade700, 'red'),
          _btn('SIYAH', Colors.black, 'black'),
          _btn('CIFT', Colors.green.shade700, 'even'),
          _btn('TEK', Colors.orange.shade700, 'odd'),
          _btn('1-12', Colors.blue.shade700, 'low'),
          _btn('19-36', Colors.purple.shade700, 'high'),
        ])),
      ]),
    );
  }

  Widget _btn(String l, Color c, String t) => GestureDetector(onTap: spinning ? null : () => _spin(t),
    child: Container(decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white24)),
      child: Center(child: Text(l, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)))));
}
