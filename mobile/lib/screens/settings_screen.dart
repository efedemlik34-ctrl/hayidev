import 'package:flutter/material.dart';
import '../services/api.dart';
import '../services/local_db.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Widget _tile(BuildContext ctx, IconData icon, String label, Color color, {String? route}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A0F3E), Color(0xFF0F0A2E)]),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: ListTile(
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(label,
          style: const TextStyle(color: Colors.white, fontSize: 14)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white38),
        onTap: () {
          if (route != null) {
            Navigator.pushNamed(ctx, route);
          } else {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(content: Text('$label yakinda')));
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        title: const Text('Ayarlar'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(children: [
        const SizedBox(height: 8),
        _tile(context, Icons.edit, 'Profili Duzenle', const Color(0xFF4CAF50),
          route: '/edit-profile'),
        _tile(context, Icons.notifications, 'Bildirimler', const Color(0xFFFF9800),
          route: '/notifications'),
        _tile(context, Icons.people, 'Arkadaslar', const Color(0xFF2196F3),
          route: '/friends'),
        _tile(context, Icons.card_giftcard, 'Hediye Katalogu', const Color(0xFFE91E63),
          route: '/gifts'),
        _tile(context, Icons.workspace_premium, 'VIP', const Color(0xFFFFC107),
          route: '/vip'),
        _tile(context, Icons.people_outline, 'Davet Et', const Color(0xFF9C27B0),
          route: '/invite'),
        _tile(context, Icons.shield, 'Klanlar', const Color(0xFF3F51B5),
          route: '/clans'),
        _tile(context, Icons.casino, 'Carkifelek', const Color(0xFFF44336),
          route: '/wheel'),
        _tile(context, Icons.emoji_events, 'Turnuvalar', const Color(0xFFFF6B35),
          route: '/tournaments'),
        _tile(context, Icons.image, 'Sosyal Akis', const Color(0xFF00BCD4),
          route: '/posts'),
        _tile(context, Icons.shopping_cart, 'Magaza', const Color(0xFF8BC34A),
          route: '/shop'),
        _tile(context, Icons.account_balance_wallet, 'Cuzdan', const Color(0xFF009688),
          route: '/wallet'),
        _tile(context, Icons.star, 'Gorevler', const Color(0xFF673AB7),
          route: '/quests'),
        _tile(context, Icons.search, 'Kullanici Ara', const Color(0xFF607D8B),
          route: '/search-users'),
        _tile(context, Icons.card_giftcard, 'Kupon Kullan', const Color(0xFF795548),
          route: '/coupon'),
        _tile(context, Icons.visibility, 'Profil Ziyaretcileri', const Color(0xFF3F51B5),
          route: '/profile-visitors'),
        _tile(context, Icons.auto_awesome, 'Hikayeler', const Color(0xFFE91E63),
          route: '/story'),
        _tile(context, Icons.group, 'Gruplar', const Color(0xFF009688),
          route: '/groups'),
        _tile(context, Icons.emoji_events, 'Sezon', const Color(0xFFFF9800),
          route: '/season'),
        _tile(context, Icons.videocam, 'Canli Yayin', const Color(0xFFF44336),
          route: '/live'),
        const Divider(color: Colors.white12, height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(width: double.infinity, height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF44336).withOpacity(0.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                side: const BorderSide(color: Color(0xFFF44336)),
              ),
              onPressed: () async {
                await Api.logout();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
                }
              },
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              label: const Text('CIKIS YAP',
                style: TextStyle(color: Colors.redAccent,
                  fontWeight: FontWeight.bold, letterSpacing: 2)),
            )),
        ),
        const SizedBox(height: 30),
      ]),
    );
  }
}
