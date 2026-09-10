import 'package:flutter/material.dart';

class SvipDetailScreen extends StatelessWidget {
  const SvipDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(title: const Text('SVIP Ayricaliklari'),
        backgroundColor: Colors.transparent, elevation: 0),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6D4C41), Color(0xFF3E2723), Color(0xFFFFD700)]),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Color(0xFFFFD700).withOpacity(0.5), blurRadius: 24)],
          ),
          child: Column(children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.3),
                border: Border.all(color: Colors.white, width: 3)),
              child: const Center(child: Text('S', style: TextStyle(
                color: Color(0xFFFFD700), fontSize: 42, fontWeight: FontWeight.bold))),
            ),
            const SizedBox(height: 12),
            const Text('SVIP Uyelik', style: TextStyle(color: Colors.white,
              fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Tum ayricaliklardan yararlan',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: _package('1 Ay', '500,000', Color(0xFFC0C0C0))),
              const SizedBox(width: 10),
              Expanded(child: _package('3 Ay', '1,200,000', Color(0xFFFFD700))),
              const SizedBox(width: 10),
              Expanded(child: _package('1 Yil', '3,500,000', Color(0xFFE91E63))),
            ]),
          ]),
        ),
        const SizedBox(height: 24),
        const Text('Ayricaliklar', style: TextStyle(color: Colors.white,
          fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...[
          {'icon': Icons.local_fire_department, 'title': 'Isminde Ates Efekti', 'color': Color(0xFFFF5722)},
          {'icon': Icons.workspace_premium, 'title': 'Altin Isim Plakasi', 'color': Color(0xFFFFD700)},
          {'icon': Icons.verified, 'title': 'Mavi Tik Dogrulama', 'color': Color(0xFF2196F3)},
          {'icon': Icons.card_giftcard, 'title': 'Gunluk %50 Ekstra Odul', 'color': Color(0xFFE91E63)},
          {'icon': Icons.diamond, 'title': 'Ozel Oda Sistemi', 'color': Color(0xFF9C27B0)},
          {'icon': Icons.priority_high, 'title': 'Mikrofon Oncelik', 'color': Color(0xFF4CAF50)},
          {'icon': Icons.block, 'title': 'Reklamsiz Deneyim', 'color': Color(0xFF607D8B)},
          {'icon': Icons.support_agent, 'title': 'Oncelikli Destek', 'color': Color(0xFF00BCD4)},
        ].map((p) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: (p['color'] as Color).withOpacity(0.3))),
          child: Row(children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: (p['color'] as Color).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12)),
              child: Icon(p['icon'] as IconData, color: p['color'] as Color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(p['title'] as String,
              style: const TextStyle(color: Colors.white,
                fontSize: 14, fontWeight: FontWeight.w500))),
            const Icon(Icons.check, color: Color(0xFF4CAF50), size: 20),
          ]),
        )),
      ]),
    );
  }

  Widget _package(String label, String price, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2)),
      child: Column(children: [
        Text(label, style: TextStyle(color: color,
          fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('🪙 $price', style: const TextStyle(color: Colors.white,
          fontSize: 11, fontWeight: FontWeight.bold)),
      ]),
    );
  }
}
