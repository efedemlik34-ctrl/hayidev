import 'package:flutter/material.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final collections = [
      {'name': 'Cerceveler', 'items': ['🥇','🌟','💫','👑','🎖️','🏆']},
      {'name': 'Isim Plakalari', 'items': ['🔷','🔶','💠','❇️']},
      {'name': 'Arabalar', 'items': ['🚗','🏎️','🚙','🚕','🚓']},
      {'name': 'Hayvanlar', 'items': ['🦁','🐯','🐺','🦅','🐉']},
      {'name': 'Taclar', 'items': ['👑','💎','🏆','🎩']},
      {'name': 'Roketler', 'items': ['🚀','🛸','✈️']},
    ];
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(title: const Text('Koleksiyon Salonu'), backgroundColor: Colors.transparent),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: collections.length,
        itemBuilder: (_, i) {
          final c = collections[i];
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(c['name'] as String, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(spacing: 12, runSpacing: 12, children: (c['items'] as List).map((it) => Container(
              width: 64, height: 64,
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF2A1F5E), Color(0xFF1A0F3E)]), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFFFC107).withOpacity(0.4))),
              child: Center(child: Text(it as String, style: const TextStyle(fontSize: 32))),
            )).toList()),
            const SizedBox(height: 24),
          ]);
        },
      ),
    );
  }
}
