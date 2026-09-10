import 'package:flutter/material.dart';
import '../widgets/app_text.dart';
import '../services/api.dart';
import '../services/offline_cache.dart';
import '../widgets/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _user;
  List _rooms = [];
  List _gifts = [];
  List _lb = [];
  bool _loading = true;
  int _tab = 0;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        Api.getWithCache('/user/me'),
        Api.getWithCache('/rooms'),
        Api.getWithCache('/gifts'),
        Api.getWithCache('/leaderboard'),
      ]);
      setState(() {
        final r0 = results[0];
        final r1 = results[1];
        final r2 = results[2];
        final r3 = results[3];
        _user = (r0 is Map) ? Map<String, dynamic>.from(r0) : null;
        _rooms = (r1 is List) ? List<dynamic>.from(r1) : <dynamic>[];
        _gifts = (r2 is List) ? List<dynamic>.from(r2) : <dynamic>[];
        _lb = (r3 is List) ? List<dynamic>.from(r3) : <dynamic>[];
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _post(String path, [Map<String, dynamic>? body]) async {
    try {
      final r = await Api.dio.post(path, data: body ?? {});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(r.data is Map && r.data['reward'] != null
          ? '+${r.data['reward']} coin!' : 'Basarili'),
        backgroundColor: Colors.green));
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$e'), backgroundColor: Colors.red));
    }
  }

  int _fmt(dynamic n) {
    try { return int.parse(n.toString()); } catch (_) { return 0; }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _user == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0E27),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFFFC107))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: SafeArea(child: RefreshIndicator(
        onRefresh: _load,
        color: const Color(0xFFFFC107),
        child: ListView(
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            // ═══ 1. BAKIYE KARTI ═══
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [Color(0xFFFFC107), Color(0xFFFF8C00), Color(0xFFFF6B35)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Color(0xFFFFC107).withOpacity(0.4),
                    blurRadius: 24, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.black.withOpacity(0.15),
                    child: Text(
                      (_user?['username'] as String? ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white,
                        fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Merhaba,',
                        style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 12)),
                      Flexible(child: Text(_user?['username']?.toString() ?? 'Kullanici',
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.black,
                          fontSize: 18, fontWeight: FontWeight.bold))),
                    ],
                  )),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('VIP ${_user?['vip'] ?? 0}',
                      style: const TextStyle(color: Colors.white,
                        fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ]),
                const SizedBox(height: 20),
                Text('BAKIYE',
                  style: TextStyle(color: Colors.black.withOpacity(0.6),
                    fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
                    child: Text('🪙 ${_fmt(_user?['balance'])}',
                      style: const TextStyle(color: Colors.black,
                        fontSize: 32, fontWeight: FontWeight.bold)))
                  const SizedBox(width: 12),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('💎 ${_fmt(_user?['diamonds'])}',
                      style: TextStyle(color: Colors.black.withOpacity(0.7),
                        fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ]),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: ((_fmt(_user?['xp']) % 100) / 100).clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: Colors.black.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
                const SizedBox(height: 4),
                Text('Seviye ${_user?['level'] ?? 0} • XP ${_user?['xp'] ?? 0}',
                  style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 11)),
              ]),
            ),

            // ═══ 2. HIZLI AKSIYONLAR ═══
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                Expanded(child: _quickAction(
                  icon: Icons.card_giftcard,
                  label: 'Gunluk Odul',
                  colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                  onTap: () => _post('/daily/claim'),
                )),
                const SizedBox(width: 10),
                Expanded(child: _quickAction(
                  icon: Icons.rotate_right,
                  label: 'Carkifelek',
                  colors: [Color(0xFF9C27B0), Color(0xFF6A1B9A)],
                  onTap: () => _post('/wheel/spin', {'paid': false}),
                )),
              ]),
            ),

            // ═══ 3. POPULER ODALAR ═══
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Row(children: [
                const Text('🎙️  Populer Odalar',
                  style: TextStyle(color: Colors.white, fontSize: 17,
                    fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/home'),
                  child: const Text('Tumu >',
                    style: TextStyle(color: Color(0xFFFFC107), fontSize: 12)),
                ),
              ]),
            ),
            SizedBox(
              height: 140,
              child: _rooms.isEmpty
                ? const Center(child: Text('Oda yok',
                    style: TextStyle(color: Colors.white38)))
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _rooms.length,
                    itemBuilder: (_, i) => _roomCard(_rooms[i]),
                  ),
            ),

            // ═══ 4. POPULER HEDIYELER ═══
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text('🎁  Populer Hediyeler',
                style: TextStyle(color: Colors.white, fontSize: 17,
                  fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 130,
              child: _gifts.isEmpty
                ? const Center(child: Text('Hediye yok',
                    style: TextStyle(color: Colors.white38)))
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _gifts.length,
                    itemBuilder: (_, i) => _giftCard(_gifts[i]),
                  ),
            ),

            // ═══ 5. EN IYI 5 ═══
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A0F3E), Color(0xFF0F0A2E)]),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFC107).withOpacity(0.3)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('🏆  En Iyi 5',
                  style: TextStyle(color: Colors.white, fontSize: 16,
                    fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ..._lb.take(5).toList().asMap().entries.map((e) {
                  final i = e.key;
                  final u = e.value;
                  final medals = ['🥇', '🥈', '🥉'];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(children: [
                      SizedBox(width: 30,
                        child: Text(i < 3 ? medals[i] : '${i + 1}',
                          style: const TextStyle(fontSize: 18))),
                      const SizedBox(width: 10),
                      Expanded(child: Text(u['username']?.toString() ?? '',
                        style: const TextStyle(color: Colors.white, fontSize: 13))),
                      Text('🪙 ${_fmt(u['balance'])}',
                        style: const TextStyle(color: Color(0xFFFFC107),
                          fontWeight: FontWeight.bold, fontSize: 12)),
                    ]),
                  );
                }),
              ]),
            ),
          ],
        ),
      )),
    );
  }

  Widget _quickAction({
    required IconData icon, required String label,
    required List<Color> colors, required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
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

  Widget _roomCard(Map<String, dynamic> r) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/voice-room',
        arguments: {'roomId': r['id'], 'roomName': r['name']}),
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF4A148C), Color(0xFF1A0F3E)]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFC107).withOpacity(0.3)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.3),
              blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: Stack(children: [
          Positioned(top: 8, right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(8)),
              child: const Text('CANLI',
                style: TextStyle(color: Colors.white, fontSize: 8,
                  fontWeight: FontWeight.bold)))),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.mic, color: Color(0xFFFFC107), size: 32),
                const SizedBox(height: 8),
                Text(r['name']?.toString() ?? 'Oda',
                  style: const TextStyle(color: Colors.white,
                    fontSize: 13, fontWeight: FontWeight.bold),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.person, color: Colors.white54, size: 12),
                  const SizedBox(width: 2),
                  Expanded(child: Text(r['owner']?.toString() ?? '?',
                    style: const TextStyle(color: Colors.white54, fontSize: 10),
                    overflow: TextOverflow.ellipsis)),
                ]),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _giftCard(Map<String, dynamic> g) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A1F5E), Color(0xFF1A0F3E)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFC107).withOpacity(0.2)),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(g['icon']?.toString() ?? '?',
          style: const TextStyle(fontSize: 38)),
        const SizedBox(height: 6),
        Text(g['name']?.toString() ?? '',
          style: const TextStyle(color: Colors.white70, fontSize: 11),
          maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 2),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.monetization_on, color: Color(0xFFFFC107), size: 12),
          Text(' ${_fmt(g['price'])}',
            style: const TextStyle(color: Color(0xFFFFC107),
              fontSize: 10, fontWeight: FontWeight.bold)),
        ]),
      ]),
    );
  }
}
