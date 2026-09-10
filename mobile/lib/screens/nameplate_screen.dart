import 'package:flutter/material.dart';

class NameplateScreen extends StatelessWidget {
  const NameplateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final plates = [
      {'name': 'Varsayilan', 'color': Colors.white, 'price': 0},
      {'name': 'Altin', 'color': const Color(0xFFFFD700), 'price': 10000},
      {'name': 'Gokkusagi', 'color': const Color(0xFFFF6B35), 'price': 50000},
      {'name': 'Ates', 'color': const Color(0xFFFF4500), 'price': 75000},
      {'name': 'Buz', 'color': const Color(0xFF00FFFF), 'price': 75000},
      {'name': 'VIP', 'color': const Color(0xFFE91E63), 'price': 200000},
    ];
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(title: const Text('Isim Plakasi'), backgroundColor: Colors.transparent),
      body: GridView.count(
        padding: const EdgeInsets.all(16), crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.2,
        children: plates.map((p) => Container(
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF2A1F5E), Color(0xFF1A0F3E)]), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFFFC107).withOpacity(0.3))),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: p['color'] as Color, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: (p['color'] as Color).withOpacity(0.6), blurRadius: 20)]), child: const Text('KullaniciAdi', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13))),
            const SizedBox(height: 12),
            Text(p['name'] as String, style: const TextStyle(color: Colors.white, fontSize: 14)),
            const SizedBox(height: 4),
            Text('🪙 ${p['price']}', style: const TextStyle(color: Color(0xFFFFC107), fontSize: 12)),
          ]),
        )).toList(),
      ),
    );
  }
}
