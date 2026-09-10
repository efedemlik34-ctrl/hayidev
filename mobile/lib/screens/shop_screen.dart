import 'package:flutter/material.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  final List<Map<String, dynamic>> _items = const [
    {'name': '100K Coin', 'price': '₺29,99', 'icon': '🪙', 'color': Color(0xFFCD7F32)},
    {'name': '500K Coin', 'price': '₺99,99', 'icon': '💰', 'color': Color(0xFFC0C0C0)},
    {'name': '1M Coin', 'price': '₺149,99', 'icon': '💎', 'color': Color(0xFFFFD700)},
    {'name': '5M Coin', 'price': '₺499,99', 'icon': '🏆', 'color': Color(0xFFE91E63)},
    {'name': '10M Coin', 'price': '₺799,99', 'icon': '👑', 'color': Color(0xFF9C27B0)},
    {'name': '50M Coin', 'price': '₺2499,99', 'icon': '🚀', 'color': Color(0xFFFF5722)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(title: const Text('Magaza'),
        backgroundColor: Colors.transparent, elevation: 0),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFB8860B), Color(0xFFDAA520)]),
            borderRadius: BorderRadius.circular(20)),
          child: Row(children: [
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Bakiyen', style: TextStyle(color: Colors.white70, fontSize: 12)),
              SizedBox(height: 6),
              Text('69,644 🪙', style: TextStyle(color: Colors.white,
                fontSize: 26, fontWeight: FontWeight.bold)),
            ])),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle),
              child: const Text('🪙', style: TextStyle(fontSize: 28)),
            ),
          ]),
        ),
        const SizedBox(height: 20),
        const Text('Coin Paketleri', style: TextStyle(color: Colors.white,
          fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: _items.map((it) {
            final c = it['color'] as Color;
            return GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('${it['name']} satin alindi!'))),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [c.withOpacity(0.3), c.withOpacity(0.05)]),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: c, width: 2),
                  boxShadow: [BoxShadow(color: c.withOpacity(0.3), blurRadius: 16)],
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(it['icon'] as String, style: const TextStyle(fontSize: 42)),
                  const SizedBox(height: 8),
                  Text(it['name'] as String,
                    style: const TextStyle(color: Colors.white,
                      fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(it['price'] as String,
                    style: TextStyle(color: c,
                      fontSize: 13, fontWeight: FontWeight.bold)),
                ]),
              ),
            );
          }).toList(),
        ),
      ]),
    );
  }
}
