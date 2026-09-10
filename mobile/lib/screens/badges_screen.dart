import 'package:flutter/material.dart';
import '../services/api.dart';

class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});
  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  List _badges = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final r = await Api.dio.get('/badges');
      setState(() => _badges = r.data);
    } catch (e) { debugPrint(e.toString()); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(title: const Text('Madalyalar'),
        backgroundColor: Colors.transparent, elevation: 0),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 12, crossAxisSpacing: 12,
        childAspectRatio: 1.3,
        children: _badges.map((b) {
          final owned = b['owned'] == true;
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: owned
                  ? [Color(0xFFFFC107).withOpacity(0.4), Color(0xFFFF6B35).withOpacity(0.2)]
                  : [Colors.white.withOpacity(0.06), Colors.white.withOpacity(0.02)]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: owned ? Color(0xFFFFC107) : Colors.white24,
                width: owned ? 2 : 1),
              boxShadow: owned ? [BoxShadow(
                color: Color(0xFFFFC107).withOpacity(0.4), blurRadius: 20)] : null,
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(owned ? '🏆' : '🔒', style: const TextStyle(fontSize: 44)),
              const SizedBox(height: 8),
              Text(b['name'] ?? '',
                style: TextStyle(color: owned ? Colors.white : Colors.white54,
                  fontSize: 13, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            ]),
          );
        }).toList(),
      ),
    );
  }
}
