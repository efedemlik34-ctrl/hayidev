import 'package:flutter/material.dart';
import '../services/api.dart';
import '../services/local_db.dart';

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

  int _fmt(dynamic n) {
    try { return int.parse(n.toString()); } catch (_) { return 0; }
  }

  Widget _tile(IconData icon, String label, Color color, String route) {
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
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0E27),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFFFC107))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: SafeArea(child: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          // Profil karti
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(0xFF1A0F3E), Color(0xFF4A148C)]),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFFFC107).withOpacity(0.4)),
            ),
            child: Column(children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFC107), Color(0xFFFF6B35)]),
                  boxShadow: [
                    BoxShadow(color: Color(0xFFFFC107), blurRadius: 20),
                  ],
                ),
                child: CircleAvatar(
                  radius: 46,
                  backgroundColor: const Color(0xFF0A0E27),
                  child: Text(
                    (_user!['username'] as String)[0].toUpperCase(),
                    style: const TextStyle(color: Color(0xFFFFC107),
                      fontSize: 42, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 14),
              Text(_user!['username']?.toString() ?? '',
                maxLines: 1, overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white,
                  fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(_user!['email']?.toString() ?? '-',
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _chip(Icons.workspace_premium, 'VIP ${_user!['vip'] ?? 0}'),
                const SizedBox(width: 8),
                _chip(Icons.star, 'Lv. ${_user!['level'] ?? 0}'),
                const SizedBox(width: 8),
                _chip(Icons.people, '$_followers'),
              ]),
            ]),
          ),
          // Menu
          _tile(Icons.edit, 'Profili Duzenle', const Color(0xFF4CAF50), '/edit-profile'),
          _tile(Icons.card_giftcard, 'Hediye Katalogu', const Color(0xFFE91E63), '/gifts'),
          _tile(Icons.people_outline, 'Davet Et', const Color(0xFF9C27B0), '/invite'),
          _tile(Icons.shield, 'Klanlar', const Color(0xFF3F51B5), '/clans'),
          _tile(Icons.workspace_premium, 'VIP', const Color(0xFFFFC107), '/vip'),
          _tile(Icons.people, 'Arkadaslar', const Color(0xFF2196F3), '/friends'),
          _tile(Icons.notifications, 'Bildirimler', const Color(0xFFFF9800), '/notifications'),
          _tile(Icons.emoji_events, 'Turnuvalar', const Color(0xFFFF6B35), '/tournaments'),
          _tile(Icons.image, 'Sosyal Akis', const Color(0xFF00BCD4), '/posts'),
          _tile(Icons.account_balance_wallet, 'Cuzdan', const Color(0xFF009688), '/wallet'),
          _tile(Icons.shopping_cart, 'Magaza', const Color(0xFF8BC34A), '/shop'),
          _tile(Icons.leaderboard, 'Liderlik', const Color(0xFF673AB7), '/leaderboard'),
          _tile(Icons.visibility, 'Ziyaretciler', const Color(0xFF3F51B5), '/profile-visitors'),
          _tile(Icons.settings, 'Ayarlar', const Color(0xFF607D8B), '/settings'),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(width: double.infinity, height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF44336).withOpacity(0.2),
                  side: const BorderSide(color: Color(0xFFF44336)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
        ],
      )),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: const Color(0xFFFFC107), size: 14),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white,
          fontSize: 11, fontWeight: FontWeight.bold)),
      ]),
    );
  }
}
