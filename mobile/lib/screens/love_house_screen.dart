import 'package:flutter/material.dart';

class LoveHouseScreen extends StatelessWidget {
  const LoveHouseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(title: const Text('Ask Evi'), backgroundColor: Colors.transparent, elevation: 0),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // Banner
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFFE91E63), Color(0xFF9C27B0)]),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Color(0xFFE91E63).withOpacity(0.5), blurRadius: 20)],
          ),
          child: Column(children: [
            const Text('💕', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 10),
            const Text('Ask Evi', style: TextStyle(color: Colors.white,
              fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('Sevgilini bul, birlikte puan kazan',
              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20)),
              child: const Text('ESLESMEYE BASLA', style: TextStyle(
                color: Color(0xFFE91E63), fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ]),
        ),
        const SizedBox(height: 20),
        // Sevgili eslestirme
        const Text('CP Leveli', style: TextStyle(color: Colors.white,
          fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.pink.withOpacity(0.3))),
          child: Column(children: [
            Row(children: [
              CircleAvatar(radius: 30, backgroundColor: Color(0xFFFFC107),
                child: Text('A', style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold))),
              const SizedBox(width: 12),
              const Text('❤️', style: TextStyle(fontSize: 30)),
              const SizedBox(width: 12),
              CircleAvatar(radius: 30, backgroundColor: Colors.white24,
                child: Icon(Icons.add, color: Colors.white70, size: 30)),
            ]),
            const SizedBox(height: 12),
            const Text('Eslesme bekleniyor...',
              style: TextStyle(color: Colors.white54, fontSize: 13)),
          ]),
        ),
        const SizedBox(height: 20),
        const Text('Lider CP Ciftler', style: TextStyle(color: Colors.white,
          fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...List.generate(5, (i) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: i < 3 ? LinearGradient(
              colors: [Color(0xFFE91E63).withOpacity(0.3), Color(0xFF9C27B0).withOpacity(0.1)]) : null,
            color: i >= 3 ? Colors.white10 : null,
            borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            const Text('💑', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Text('Cift ${i + 1}', style: const TextStyle(color: Colors.white,
              fontSize: 14, fontWeight: FontWeight.bold)),
            const Spacer(),
            Text('${(5 - i) * 1000} CP',
              style: const TextStyle(color: Color(0xFFFFC107),
                fontWeight: FontWeight.bold, fontSize: 13)),
          ]),
        )),
      ]),
    );
  }
}
