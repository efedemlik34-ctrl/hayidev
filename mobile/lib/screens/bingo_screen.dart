import 'package:flutter/material.dart';
import '../services/api.dart';
import '../widgets/bingo_ball.dart';

class BingoScreen extends StatefulWidget {
  const BingoScreen({super.key});
  @override
  State<BingoScreen> createState() => _BingoScreenState();
}

class _BingoScreenState extends State<BingoScreen> {
  int? _lastNumber;
  String? _lastLetter;
  int _bet = 500;
  bool _loading = false;

  String _letterFor(int n) {
    if (n <= 15) return 'B';
    if (n <= 30) return 'I';
    if (n <= 45) return 'N';
    if (n <= 60) return 'G';
    return 'O';
  }

  Future<void> _play() async {
    setState(() => _loading = true);
    try {
      final r = await Api.dio.post('/games/bingo/play', data: {'bet': _bet});
      final n = r.data['drawn'][0] as int;
      setState(() {
        _lastNumber = n;
        _lastLetter = _letterFor(n);
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        title: const Text('Bingo'),
        backgroundColor: Colors.transparent,
        elevation: 0),
      body: Column(children: [
        const SizedBox(height: 20),
        // Top goster
        BingoBall(number: _lastNumber, letter: _lastLetter, size: 180),
        const SizedBox(height: 30),
        // Bahis sec
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            for (final b in [100, 500, 1000, 5000])
              GestureDetector(
                onTap: _loading ? null : () => setState(() => _bet = b),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: _bet == b ? const Color(0xFFFFC107) : Colors.white10,
                    borderRadius: BorderRadius.circular(16)),
                  child: Text('$b', style: TextStyle(
                    color: _bet == b ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold)),
                ),
              ),
          ]),
        ),
        const SizedBox(height: 20),
        // Play button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(width: double.infinity, height: 60,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              onPressed: _loading ? null : _play,
              child: Text(_loading ? 'CEKILIYOR...' : 'TOP CEK',
                style: const TextStyle(color: Colors.white, fontSize: 18,
                  fontWeight: FontWeight.bold, letterSpacing: 2)),
            )),
        ),
      ]),
    );
  }
}
