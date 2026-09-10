import 'package:flutter/material.dart';
import '../services/api.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _post(BuildContext context, String path) async {
    try {
      final r = await Api.dio.post(path);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(r.data.toString())));
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: ' + e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(title: const Text('Ayarlar'), backgroundColor: Colors.transparent),
      body: ListView(children: [
        _tile(Icons.person, 'Profili Duzenle', () => Navigator.push(context, MaterialPageRoute(builder: (_) => _getEditProfile()))),
        _tile(Icons.notifications, 'Bildirimler', () => Navigator.push(context, MaterialPageRoute(builder: (_) => _getNotifications()))),
        _tile(Icons.people, 'Arkadaslar', () => Navigator.push(context, MaterialPageRoute(builder: (_) => _getFriends()))),
        _tile(Icons.card_giftcard, 'Hediye Katalogu', () => Navigator.push(context, MaterialPageRoute(builder: (_) => _getGifts()))),
        _tile(Icons.workspace_premium, 'VIP', () => Navigator.push(context, MaterialPageRoute(builder: (_) => _getVip()))),
        _tile(Icons.people_outline, 'Davet Et', () => Navigator.push(context, MaterialPageRoute(builder: (_) => _getInvite()))),
        _tile(Icons.shield, 'Klanlar', () => Navigator.push(context, MaterialPageRoute(builder: (_) => _getClans()))),
        _tile(Icons.casino, 'Carkifelek', () => Navigator.push(context, MaterialPageRoute(builder: (_) => _getWheel()))),
        _tile(Icons.emoji_events, 'Turnuvalar', () => Navigator.push(context, MaterialPageRoute(builder: (_) => _getTournaments()))),
        _tile(Icons.photo_library, 'Sosyal Akis', () => Navigator.push(context, MaterialPageRoute(builder: (_) => _getPosts()))),
        _tile(Icons.info, 'Hakkinda', () => showAboutDialog(context: context, applicationName: 'HayiDev', applicationVersion: '1.0.0')),
      ]),
    );
  }

  Widget _tile(IconData icon, String title, VoidCallback onTap) => ListTile(
    leading: Icon(icon, color: const Color(0xFFFFC107)),
    title: Text(title, style: const TextStyle(color: Colors.white)),
    trailing: const Icon(Icons.chevron_right, color: Colors.white54),
    onTap: onTap,
  );

  Widget _getEditProfile() => const Text('');
  Widget _getNotifications() => const Text('');
  Widget _getFriends() => const Text('');
  Widget _getGifts() => const Text('');
  Widget _getVip() => const Text('');
  Widget _getInvite() => const Text('');
  Widget _getClans() => const Text('');
  Widget _getWheel() => const Text('');
  Widget _getTournaments() => const Text('');
  Widget _getPosts() => const Text('');
}
