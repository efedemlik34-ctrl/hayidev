import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/api.dart';
import 'games_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _user;
  List _gifts = [], _quests = [], _lb = [], _followers = [];
  int _tab = 0;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _load();
  }

  @override
  void dispose() { _pulseCtrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    try {
      final u = await Api.dio.get('/user/me');
      final g = await Api.dio.get('/gifts');
      final q = await Api.dio.get('/quests');
      final l = await Api.dio.get('/leaderboard');
      List f = [];
      try { final fr = await Api.dio.get('/follow/followers'); f = fr.data; } catch (_) {}
      setState(() {
        _user = u.data; _gifts = g.data; _quests = q.data;
        _lb = l.data; _followers = f;
      });
    } catch (e) { debugPrint(e.toString()); }
  }

  Future<void> _post(String path, [Map<String, dynamic>? body]) async {
    try {
      final r = await Api.dio.post(path, data: body ?? {});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(r.data is Map && r.data['reward'] != null
          ? '+' + r.data['reward'].toString() + ' coin!' : 'Basarili'),
        backgroundColor: const Color(0xFF4CAF50)));
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Hata: ' + e.toString()), backgroundColor: Colors.redAccent));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) return const Scaffold(
      body: Center(child: CircularProgressIndicator(color: Color(0xFFFFC107))));
    return Scaffold(
      extendBody: true,
      body: Stack(children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Color(0xFF0A0E27), Color(0xFF1A0F3E), Color(0xFF0A0E27)],
            ),
          ),
        ),
        SafeArea(
          child: IndexedStack(index: _tab, children: [
            _anaTab(), const GamesScreen(), _gorevTab(), _liderTab(), _benTab(),
          ]),
        ),
      ]),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A0F3E), Color(0xFF0F1430)]),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFFFC107).withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFC107).withOpacity(0.15),
              blurRadius: 24, offset: const Offset(0, 8)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BottomNavigationBar(
            currentIndex: _tab,
            onTap: (i) => setState(() => _tab = i),
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: const Color(0xFFFFC107),
            unselectedItemColor: Colors.white38,
            selectedFontSize: 11,
            unselectedFontSize: 10,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Ana'),
              BottomNavigationBarItem(icon: Icon(Icons.casino), label: 'Oyun'),
              BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Gorev'),
              BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'Lider'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Ben'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _anaTab() => ListView(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
    children: [
      // Ust bakiye karti
      Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFFFFC107), Color(0xFFFF6B35)]),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFC107).withOpacity(0.4),
              blurRadius: 24, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.black.withOpacity(0.2),
              child: Text((_user!['username'] as String)[0].toUpperCase(),
                style: const TextStyle(color: Colors.white,
                  fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Merhaba,',
                style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 12)),
              Text(_user!['username'].toString(),
                style: const TextStyle(color: Colors.black,
                  fontSize: 18, fontWeight: FontWeight.bold)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('VIP ' + _user!['vip'].toString(),
                style: const TextStyle(color: Colors.white,
                  fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ]),
          const SizedBox(height: 20),
          const Text('BAKIYE',
            style: TextStyle(color: Colors.black54,
              fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('🪙 ' + _user!['balance'].toString(),
              style: const TextStyle(color: Colors.black,
                fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('💎 ' + _user!['diamonds'].toString(),
                style: TextStyle(color: Colors.black.withOpacity(0.7),
                  fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ]),
          const SizedBox(height: 12),
          // XP bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (_user!['xp'] % 100) / 100,
              minHeight: 6,
              backgroundColor: Colors.black.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: 4),
          Text('Seviye ' + _user!['level'].toString() + ' • XP ' + _user!['xp'].toString(),
            style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 11)),
        ]),
      ),
      const SizedBox(height: 18),
      // Hizli aksiyonlar
      Row(children: [
        Expanded(child: _quickAction(
          icon: Icons.card_giftcard,
          label: 'Gunluk Odul',
          colors: [const Color(0xFF4CAF50), const Color(0xFF2E7D32)],
          onTap: () => _post('/daily/claim'),
        )),
        const SizedBox(width: 10),
        Expanded(child: _quickAction(
          icon: Icons.rotate_right,
          label: 'Carkifelek',
          colors: [const Color(0xFF9C27B0), const Color(0xFF6A1B9A)],
          onTap: () => _post('/wheel/spin', {'paid': false}),
        )),
      ]),
      const SizedBox(height: 24),
      // Hediyeler baslik
      Row(children: [
        const Text('🎁 Populer Hediyeler',
          style: TextStyle(color: Colors.white,
            fontSize: 17, fontWeight: FontWeight.bold)),
        const Spacer(),
        Text('Tumu >', style: TextStyle(
          color: const Color(0xFFFFC107).withOpacity(0.8), fontSize: 12)),
      ]),
      const SizedBox(height: 12),
      SizedBox(
        height: 130,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _gifts.length,
          itemBuilder: (_, i) => _giftCard(_gifts[i]),
        ),
      ),
      const SizedBox(height: 24),
      // En iyi 5
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('🏆 En Iyi 5',
            style: TextStyle(color: Colors.white,
              fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ..._lb.take(5).toList().asMap().entries.map((e) {
            final i = e.key; final u = e.value;
            final medals = ['🥇', '🥈', '🥉'];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(children: [
                Text(i < 3 ? medals[i] : (i + 1).toString(),
                  style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(child: Text(u['username'] ?? '',
                  style: const TextStyle(color: Colors.white, fontSize: 13))),
                Text('🪙 ' + (u['balance'] ?? 0).toString(),
                  style: const TextStyle(color: Color(0xFFFFC107),
                    fontWeight: FontWeight.bold, fontSize: 12)),
              ]),
            );
          }),
        ]),
      ),
    ],
  );

  Widget _quickAction({required IconData icon, required String label,
      required List<Color> colors, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: colors),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: colors[0].withOpacity(0.4),
              blurRadius: 16, offset: const Offset(0, 6)),
          ],
        ),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(label,
            style: const TextStyle(color: Colors.white,
              fontWeight: FontWeight.bold, fontSize: 12))),
        ]),
      ),
    );
  }

  Widget _giftCard(Map<String, dynamic> g) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFC107).withOpacity(0.15)),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(g['icon'] ?? '?', style: const TextStyle(fontSize: 38)),
        const SizedBox(height: 6),
        Text(g['name'] ?? '',
          style: const TextStyle(color: Colors.white70, fontSize: 11),
          maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 2),
        Text('🪙 ' + (g['price'] ?? 0).toString(),
          style: const TextStyle(color: Color(0xFFFFC107),
            fontSize: 10, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _gorevTab() => ListView(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
    children: [
      const Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: Text('🏆 Gunluk Gorevler',
          style: TextStyle(color: Colors.white,
            fontSize: 22, fontWeight: FontWeight.bold)),
      ),
      ..._quests.map((q) {
        final progress = q['progress'] ?? 0;
        final target = q['target'] ?? 1;
        final pct = target > 0 ? (progress / target).clamp(0.0, 1.0) : 0.0;
        final completed = q['completed'] == true;
        final claimed = q['claimed'] == true;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: completed && !claimed
                ? [const Color(0xFF4CAF50).withOpacity(0.2),
                   const Color(0xFF2E7D32).withOpacity(0.1)]
                : [Colors.white.withOpacity(0.06), Colors.white.withOpacity(0.02)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: completed && !claimed
                ? Colors.greenAccent.withOpacity(0.5)
                : Colors.white.withOpacity(0.08)),
          ),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(q['title'] ?? '',
                style: const TextStyle(color: Colors.white,
                  fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: pct.toDouble(),
                  minHeight: 8,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation(
                    completed ? Colors.greenAccent : const Color(0xFFFFC107)),
                ),
              ),
              const SizedBox(height: 4),
              Text(progress.toString() + ' / ' + target.toString(),
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
            ])),
            const SizedBox(width: 14),
            claimed
              ? Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withOpacity(0.2),
                    shape: BoxShape.circle),
                  child: const Icon(Icons.check, color: Colors.greenAccent, size: 20),
                )
              : completed
                ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC107),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    onPressed: () => _post('/quests/' + q['key'].toString() + '/claim'),
                    child: Text('+' + q['reward'].toString(),
                      style: const TextStyle(color: Colors.black,
                        fontWeight: FontWeight.bold, fontSize: 12)),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC107).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10)),
                    child: Text('+' + q['reward'].toString(),
                      style: const TextStyle(color: Color(0xFFFFC107),
                        fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
          ]),
        );
      }),
    ],
  );

  Widget _liderTab() => ListView(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
    children: [
      const Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: Text('👑 Liderlik Tablosu',
          style: TextStyle(color: Colors.white,
            fontSize: 22, fontWeight: FontWeight.bold)),
      ),
      ..._lb.asMap().entries.map((e) {
        final i = e.key; final u = e.value;
        final top3 = i < 3;
        final colors = [
          [const Color(0xFFFFD700), const Color(0xFFFFA000)],
          [const Color(0xFFC0C0C0), const Color(0xFF9E9E9E)],
          [const Color(0xFFCD7F32), const Color(0xFF8B4513)],
        ];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: top3 ? LinearGradient(colors: colors[i]) : null,
            color: top3 ? null : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(14),
            border: top3 ? null : Border.all(
              color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: top3 ? Colors.black.withOpacity(0.15) : Colors.white.withOpacity(0.1),
                shape: BoxShape.circle),
              child: Center(child: Text((i + 1).toString(),
                style: TextStyle(color: top3 ? Colors.black : Colors.white70,
                  fontWeight: FontWeight.bold, fontSize: 14))),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(u['username'] ?? '',
              style: TextStyle(color: top3 ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold, fontSize: 14))),
            Text('🪙 ' + (u['balance'] ?? 0).toString(),
              style: TextStyle(color: top3 ? Colors.black : const Color(0xFFFFC107),
                fontWeight: FontWeight.bold, fontSize: 13)),
          ]),
        );
      }),
    ],
  );

  Widget _benTab() => ListView(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
    children: [
      const SizedBox(height: 20),
      // Profil karti
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFFC107).withOpacity(0.15),
              const Color(0xFF9C27B0).withOpacity(0.1),
            ]),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFFFC107).withOpacity(0.3)),
        ),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFFC107), Color(0xFFFF6B35)]),
              boxShadow: [
                BoxShadow(color: const Color(0xFFFFC107).withOpacity(0.5),
                  blurRadius: 20),
              ],
            ),
            child: CircleAvatar(
              radius: 46,
              backgroundColor: const Color(0xFF0A0E27),
              child: Text((_user!['username'] as String)[0].toUpperCase(),
                style: const TextStyle(color: Color(0xFFFFC107),
                  fontSize: 42, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 14),
          Text(_user!['username'].toString(),
            style: const TextStyle(color: Colors.white,
              fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(_user!['email']?.toString() ?? '-',
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
          const SizedBox(height: 14),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _statChip('👑', 'VIP ' + _user!['vip'].toString()),
            const SizedBox(width: 10),
            _statChip('⭐', 'Lvl ' + _user!['level'].toString()),
            const SizedBox(width: 10),
            _statChip('👥', _followers.length.toString()),
          ]),
        ]),
      ),
      const SizedBox(height: 20),
      // Menu
      _menuItem(Icons.edit, 'Profili Duzenle', const Color(0xFF4CAF50), () => Navigator.pushNamed(context, '/edit-profile')),
      _menuItem(Icons.card_giftcard, 'Hediye Katalogu', const Color(0xFFE91E63), () => Navigator.pushNamed(context, '/gifts')),
      _menuItem(Icons.people_outline, 'Davet Et', const Color(0xFF9C27B0), () => Navigator.pushNamed(context, '/invite')),
      _menuItem(Icons.shield, 'Klanlar', const Color(0xFF3F51B5), () => Navigator.pushNamed(context, '/clans')),
      _menuItem(Icons.workspace_premium, 'VIP', const Color(0xFFFFC107), () => Navigator.pushNamed(context, '/vip')),
      _menuItem(Icons.people, 'Arkadaslar', const Color(0xFF2196F3), () => Navigator.pushNamed(context, '/friends')),
      _menuItem(Icons.notifications, 'Bildirimler', const Color(0xFFFF6B35), () => Navigator.pushNamed(context, '/notifications')),
      _menuItem(Icons.emoji_events, 'Turnuvalar', const Color(0xFFFF9800), () => Navigator.pushNamed(context, '/tournaments')),
      _menuItem(Icons.photo_library, 'Sosyal Akis', const Color(0xFF00BCD4), () => Navigator.pushNamed(context, '/posts')),
      _menuItem(Icons.settings, 'Ayarlar', const Color(0xFF607D8B), () => Navigator.pushNamed(context, '/settings')),
      const SizedBox(height: 20),
      TextButton.icon(
        onPressed: () async {
          await Api.logout();
          if (mounted) Navigator.pushReplacementNamed(context, '/');
        },
        icon: const Icon(Icons.logout, color: Colors.redAccent),
        label: const Text('CIKIS YAP',
          style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
      ),
    ],
  );

  Widget _statChip(String icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(icon, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white,
          fontSize: 11, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _menuItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: ListTile(
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(label, style: const TextStyle(color: Colors.white,
          fontSize: 14, fontWeight: FontWeight.w500)),
        trailing: Icon(Icons.chevron_right,
          color: Colors.white.withOpacity(0.3), size: 20),
        onTap: onTap,
      ),
    );
  }
}
