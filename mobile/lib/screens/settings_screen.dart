import 'package:flutter/material.dart';
import '../services/api.dart';
import '../widgets/app_theme.dart';
import '../widgets/app_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Widget _tile(BuildContext c, IconData i, String label, Color color,
      String? route) {
    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: () {
        if (route != null) Navigator.pushNamed(c, route);
        else ScaffoldMessenger.of(c).showSnackBar(
          SnackBar(content: Text(label + ' yakinda')));
      },
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(AppRadius.md)),
          child: Icon(i, color: color, size: 22)),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: const TextStyle(
          color: Colors.white, fontSize: 14))),
        const Icon(Icons.chevron_right, color: Colors.white38),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(children: [
        const SizedBox(height: 8),
        _tile(context, Icons.edit, 'Profili Duzenle', AppColors.green, '/edit-profile'),
        _tile(context, Icons.notifications, 'Bildirimler', AppColors.orange, '/notifications'),
        _tile(context, Icons.people, 'Arkadaslar', AppColors.blue, '/friends'),
        _tile(context, Icons.card_giftcard, 'Hediye Katalogu', AppColors.pink, '/gifts'),
        _tile(context, Icons.workspace_premium, 'VIP', AppColors.gold, '/vip'),
        _tile(context, Icons.people_outline, 'Davet Et', AppColors.purple, '/invite'),
        _tile(context, Icons.shield, 'Klanlar', AppColors.blue, '/clans'),
        _tile(context, Icons.casino, 'Carkifelek', AppColors.red, '/wheel'),
        _tile(context, Icons.emoji_events, 'Turnuvalar', AppColors.orange, '/tournaments'),
        _tile(context, Icons.image, 'Sosyal Akis', AppColors.cyan, '/posts'),
        _tile(context, Icons.shopping_cart, 'Magaza', const Color(0xFF8BC34A), '/shop'),
        _tile(context, Icons.account_balance_wallet, 'Cuzdan', AppColors.green, '/wallet'),
        _tile(context, Icons.star, 'Gorevler', AppColors.purple, '/quests'),
        _tile(context, Icons.search, 'Kullanici Ara', Colors.blueGrey, '/search-users'),
        _tile(context, Icons.confirmation_number, 'Kupon Kullan', Colors.brown, '/coupon'),
        _tile(context, Icons.visibility, 'Ziyaretciler', AppColors.blue, '/profile-visitors'),
        _tile(context, Icons.auto_awesome, 'Hikayeler', AppColors.pink, '/story'),
        _tile(context, Icons.group, 'Gruplar', AppColors.green, '/groups'),
        _tile(context, Icons.emoji_events, 'Sezon', AppColors.orange, '/season'),
        _tile(context, Icons.videocam, 'Canli Yayin', AppColors.red, '/live'),
        const Divider(color: Colors.white12, height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(width: double.infinity, height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg)),
                side: const BorderSide(color: AppColors.red)),
              onPressed: () async {
                await Api.logout();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
                }
              },
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              label: const Text('CIKIS YAP', style: TextStyle(
                color: Colors.redAccent, fontWeight: FontWeight.bold,
                letterSpacing: 2)))),
        ),
        const SizedBox(height: 12),
        const Center(child: Text('HayiDev v1.9.2',
          style: TextStyle(color: Colors.white38, fontSize: 11))),
        const SizedBox(height: 30),
      ]),
    );
  }
}
