import 'package:flutter/material.dart';
import '../services/api.dart';
import '../widgets/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/user_avatar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;
  int _followers = 0;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final u = await Api.dio.get('/user/me');
      final f = await Api.dio.get('/follow/followers');
      setState(() {
        _user = u.data;
        _followers = (f.data as List).length;
      });
    } catch (_) {}
  }

  int _i(dynamic n) {
    try { return int.parse(n.toString()); } catch (_) { return 0; }
  }

  String _short(int n) {
    if (n >= 1e9) return (n / 1e9).toStringAsFixed(1) + 'B';
    if (n >= 1e6) return (n / 1e6).toStringAsFixed(1) + 'M';
    if (n >= 1e3) return (n / 1e3).toStringAsFixed(1) + 'K';
    return n.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Scaffold(
        backgroundColor: AppColors.bgDark,
        body: Center(child: CircularProgressIndicator(color: AppColors.gold)));
    }
    final name = _user!['username']?.toString() ?? '?';
    final frame = _user!['avatarFrame']?.toString() ?? 'gold';

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(child: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          _header(name, frame),
          const SizedBox(height: 8),
          _menuTile(Icons.edit, 'Profili Duzenle', AppColors.green, '/edit-profile'),
          _menuTile(Icons.card_giftcard, 'Hediye Katalogu', AppColors.pink, '/gifts'),
          _menuTile(Icons.people_outline, 'Davet Et', AppColors.purple, '/invite'),
          _menuTile(Icons.shield, 'Klanlar', AppColors.blue, '/clans'),
          _menuTile(Icons.workspace_premium, 'VIP', AppColors.gold, '/vip'),
          _menuTile(Icons.people, 'Arkadaslar', AppColors.cyan, '/friends'),
          _menuTile(Icons.notifications, 'Bildirimler', AppColors.orange, '/notifications'),
          _menuTile(Icons.emoji_events, 'Turnuvalar', AppColors.goldDark, '/tournaments'),
          _menuTile(Icons.image, 'Sosyal Akis', AppColors.cyan, '/posts'),
          _menuTile(Icons.account_balance_wallet, 'Cuzdan', AppColors.green, '/wallet'),
          _menuTile(Icons.shopping_cart, 'Magaza', const Color(0xFF8BC34A), '/shop'),
          _menuTile(Icons.leaderboard, 'Liderlik', AppColors.purple, '/leaderboard'),
          _menuTile(Icons.visibility, 'Ziyaretciler', AppColors.blue, '/profile-visitors'),
          _menuTile(Icons.settings, 'Ayarlar', Colors.blueGrey, '/settings'),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(width: double.infinity, height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red.withOpacity(0.2),
                  side: const BorderSide(color: AppColors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg))),
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
        ],
      )),
    );
  }

  Widget _header(String name, String frame) {
    final bal = _i(_user!['balance']);
    final dia = _i(_user!['diamonds']);
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [AppColors.bgCard, AppColors.deepPurple]),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.gold.withOpacity(0.4))),
      child: Column(children: [
        UserAvatar(name: name, size: 96, frame: frame, isVip: true),
        const SizedBox(height: 14),
        Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white,
            fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(_user!['email']?.toString() ?? '-', maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _statChip(Icons.monetization_on, _short(bal), AppColors.gold),
          _statChip(Icons.diamond, _short(dia), AppColors.cyan),
          _statChip(Icons.star, 'Lv ${_user!['level'] ?? 0}', AppColors.purple),
          _statChip(Icons.people, '$_followers', AppColors.green),
        ]),
      ]),
    );
  }

  Widget _statChip(IconData icon, String label, Color c) {
    return Column(children: [
      Icon(icon, color: c, size: 22),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(color: Colors.white,
        fontSize: 12, fontWeight: FontWeight.bold)),
    ]);
  }

  Widget _menuTile(IconData icon, String label, Color color, String route) {
    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: () => Navigator.pushNamed(context, route),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(AppRadius.md)),
          child: Icon(icon, color: color, size: 22)),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: const TextStyle(
          color: Colors.white, fontSize: 14))),
        const Icon(Icons.chevron_right, color: Colors.white38),
      ]),
    );
  }
}
