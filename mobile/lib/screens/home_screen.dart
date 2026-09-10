import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        Api.getWithCache('/user/me'),
        Api.getWithCache('/rooms'),
        Api.getWithCache('/gifts'),
        Api.getWithCache('/leaderboard'),
      ]);
      if (!mounted) return;
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
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _post(String path, [Map<String, dynamic>? body]) async {
    try {
      final r = await Api.dio.post(path, data: body ?? {});
      if (mounted) {
        final msg = (r.data is Map && r.data['reward'] != null)
            ? '+${r.data['reward']} coin!'
            : 'Basarili';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(msg),
          backgroundColor: Colors.green,
        ));
      }
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$e'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  int _fmt(dynamic n) {
    try {
      return int.parse(n.toString());
    } catch (_) {
      return 0;
    }
  }

  String _fmtShort(int n) {
    if (n >= 1000000000) return (n / 1000000000).toStringAsFixed(1) + 'B';
    if (n >= 1000000) return (n / 1000000).toStringAsFixed(1) + 'M';
    if (n >= 1000) return (n / 1000).toStringAsFixed(1) + 'K';
    return n.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _user == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0E27),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFFFC107)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          color: const Color(0xFFFFC107),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              _buildBalanceCard(),
              const SizedBox(height: 16),
              _buildQuickActions(),
              const SizedBox(height: 24),
              _buildRoomsSection(),
              const SizedBox(height: 24),
              _buildGiftsSection(),
              const SizedBox(height: 16),
              _buildLeaderboard(),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  //  1. BAKIYE KARTI
  // ═══════════════════════════════════════════════════
  Widget _buildBalanceCard() {
    final username = _user?['username']?.toString() ?? 'Kullanici';
    final balance = _fmt(_user?['balance']);
    final diamonds = _fmt(_user?['diamonds']);
    final vip = _user?['vip'] ?? 0;
    final level = _user?['level'] ?? 0;
    final xp = _fmt(_user?['xp']);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFC107),
            Color(0xFFFF8C00),
            Color(0xFFFF6B35),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFC107).withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ust satir — avatar + isim + VIP
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.black.withOpacity(0.15),
                child: Text(
                  username.isNotEmpty ? username[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Merhaba,',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.55),
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'VIP $vip',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // BAKIYE basligi
          Text(
            'BAKIYE',
            style: TextStyle(
              color: Colors.black.withOpacity(0.55),
              fontSize: 10,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          // Bakiye + elmas
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '🪙 $balance',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    '💎 ${_fmtShort(diamonds)}',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.7),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // XP progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ((xp % 100) / 100).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: Colors.black.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Seviye $level • XP $xp',
            style: TextStyle(
              color: Colors.black.withOpacity(0.55),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  //  2. HIZLI AKSIYONLAR
  // ═══════════════════════════════════════════════════
  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _quickAction(
              icon: Icons.card_giftcard,
              label: 'Gunluk Odul',
              colors: const [Color(0xFF4CAF50), Color(0xFF2E7D32)],
              onTap: () => _post('/daily/claim'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _quickAction(
              icon: Icons.rotate_right,
              label: 'Carkifelek',
              colors: const [Color(0xFF9C27B0), Color(0xFF6A1B9A)],
              onTap: () => _post('/wheel/spin'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String label,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: colors[0].withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  //  3. POPULER ODALAR
  // ═══════════════════════════════════════════════════
  Widget _buildRoomsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            children: [
              const Text(
                '🎙️  Populer Odalar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/rooms'),
                child: const Text(
                  'Tumu >',
                  style: TextStyle(color: Color(0xFFFFC107), fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 140,
          child: _rooms.isEmpty
              ? const Center(
                  child: Text(
                    'Oda yok',
                    style: TextStyle(color: Colors.white38),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _rooms.length,
                  itemBuilder: (_, i) => _roomCard(_rooms[i]),
                ),
        ),
      ],
    );
  }

  Widget _roomCard(Map<String, dynamic> r) {
    final name = r['name']?.toString() ?? 'Oda';
    final owner = r['owner']?.toString() ?? '?';
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/voice-room',
        arguments: {'roomId': r['id'], 'roomName': name},
      ),
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4A148C), Color(0xFF1A0F3E)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFFFC107).withOpacity(0.3),
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'CANLI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.mic,
                    color: Color(0xFFFFC107),
                    size: 28,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.person,
                        color: Colors.white54,
                        size: 11,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          owner,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  //  4. HEDIYELER
  // ═══════════════════════════════════════════════════
  Widget _buildGiftsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text(
            '🎁  Populer Hediyeler',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 120,
          child: _gifts.isEmpty
              ? const Center(
                  child: Text(
                    'Hediye yok',
                    style: TextStyle(color: Colors.white38),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _gifts.length,
                  itemBuilder: (_, i) => _giftCard(_gifts[i]),
                ),
        ),
      ],
    );
  }

  Widget _giftCard(Map<String, dynamic> g) {
    final icon = g['icon']?.toString() ?? '🎁';
    final name = g['name']?.toString() ?? 'Hediye';
    final price = _fmt(g['price']);
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A1F5E), Color(0xFF1A0F3E)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFC107).withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 36)),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.monetization_on,
                color: Color(0xFFFFC107),
                size: 11,
              ),
              const SizedBox(width: 2),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _fmtShort(price),
                    style: const TextStyle(
                      color: Color(0xFFFFC107),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  //  5. EN IYI 5
  // ═══════════════════════════════════════════════════
  Widget _buildLeaderboard() {
    final list = _lb.take(5).toList();
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A0F3E), Color(0xFF0F0A2E)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFC107).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🏆  En Iyi 5',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (list.isEmpty)
            const Text(
              'Henuz siralama yok',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            )
          else
            ...list.asMap().entries.map((e) {
              final i = e.key;
              final u = e.value;
              final medals = ['🥇', '🥈', '🥉'];
              final bal = _fmt(u['balance']);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    SizedBox(
                      width: 28,
                      child: Text(
                        i < 3 ? medals[i] : '${i + 1}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        u['username']?.toString() ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          '🪙 ${_fmtShort(bal)}',
                          style: const TextStyle(
                            color: Color(0xFFFFC107),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
