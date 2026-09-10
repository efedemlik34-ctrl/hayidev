import 'package:flutter/material.dart';

class SvipScreen extends StatelessWidget {
  const SvipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: SafeArea(
        child: ListView(children: [
          const SizedBox(height: 12),
          // SVIP banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6D4C41), Color(0xFF3E2723)]),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFFFC107).withOpacity(0.5)),
            ),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('SVIP', style: TextStyle(color: Colors.white,
                  fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Daha Fazla Ayricalik Ac',
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
              ])),
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFB8860B)]),
                  boxShadow: [BoxShadow(color: const Color(0xFFFFD700).withOpacity(0.5), blurRadius: 20)],
                ),
                child: const Center(child: Text('S', style: TextStyle(color: Colors.white,
                  fontSize: 28, fontWeight: FontWeight.bold))),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          // Seviye banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF0F172A)]),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF60A5FA).withOpacity(0.5)),
            ),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Seviye', style: TextStyle(color: Colors.white,
                  fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Daha Fazla Ayricalik Ac',
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
              ])),
              Icon(Icons.verified, color: const Color(0xFF60A5FA), size: 56),
            ]),
          ),
          const SizedBox(height: 20),
          _menuItem(Icons.person_add, 'Arkadasinizi davet et', Colors.orange, context),
          _menuItem(Icons.card_giftcard, 'Sirt canta', Colors.teal, context),
          _menuItem(Icons.home, 'Ask Evi', Colors.purple, context),
          _menuItem(Icons.favorite, 'CP Leveli', Colors.pink, context),
          _menuItem(Icons.shield, 'Aile', Colors.orange, context),
          _menuItem(Icons.museum, 'Koleksiyon Salonu', Colors.amber, context),
          _menuItem(Icons.workspace_premium, 'Isim plakasi', Colors.indigo, context),
          const SizedBox(height: 8),
          _menuItem(Icons.headset_mic, 'Musteri Servisi', Colors.grey, context, badge: 'Cevrimdisi'),
          _menuItem(Icons.language, 'Dil', Colors.grey, context),
          _menuItem(Icons.feedback, 'Geri bildirim', Colors.grey, context),
          _menuItem(Icons.settings, 'Ayarlar', Colors.grey, context),
          const SizedBox(height: 30),
        ]),
      ),
    );
  }

  Widget _menuItem(IconData icon, String label, Color color, BuildContext ctx, {String? badge}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      child: ListTile(
        leading: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 15)),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          if (badge != null) Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10)),
            child: Text(badge, style: const TextStyle(color: Colors.white54, fontSize: 10)),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right, color: Colors.white38, size: 20),
        ]),
        onTap: () {},
      ),
    );
  }
}
