import 'package:flutter/material.dart';
import '../widgets/carrom_board.dart';
import '../widgets/feedback_service.dart';

class CarromScreen extends StatefulWidget {
  const CarromScreen({super.key});
  @override
  State<CarromScreen> createState() => _CarromScreenState();
}

class _CarromScreenState extends State<CarromScreen> {
  double _aimAngle = 0;
  double _power = 0.5;

  void _shoot() {
    FeedbackService.medium();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Vurus! Aci: ${(_aimAngle * 180 / 3.14).toStringAsFixed(0)}° Güç: ${(_power*100).toStringAsFixed(0)}%')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0F0A),
      appBar: AppBar(
        title: const Text('Carrom'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(children: [
        const SizedBox(height: 16),
        // Tahta
        Padding(
          padding: const EdgeInsets.all(16),
          child: CarromBoard(onTap: _shoot),
        ),
        // Kontroller
        Expanded(child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Row(children: [
              const Icon(Icons.rotate_right, color: Color(0xFFFFC107)),
              const SizedBox(width: 8),
              Text('Aci: ${(_aimAngle * 180 / 3.14).toStringAsFixed(0)}°',
                style: const TextStyle(color: Colors.white70)),
            ]),
            Slider(
              value: _aimAngle, min: -3.14, max: 3.14,
              onChanged: (v) => setState(() => _aimAngle = v),
              activeColor: const Color(0xFFFFC107),
            ),
            Row(children: [
              const Icon(Icons.speed, color: Color(0xFFFF5252)),
              const SizedBox(width: 8),
              Text('Guc: ${(_power * 100).toStringAsFixed(0)}%',
                style: const TextStyle(color: Colors.white70)),
            ]),
            Slider(
              value: _power, min: 0, max: 1,
              onChanged: (v) => setState(() => _power = v),
              activeColor: const Color(0xFFFF5252),
            ),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                onPressed: _shoot,
                child: const Text('VUR',
                  style: TextStyle(color: Colors.white, fontSize: 18,
                    fontWeight: FontWeight.bold, letterSpacing: 2)),
              )),
          ]),
        )),
      ]),
    );
  }
}
