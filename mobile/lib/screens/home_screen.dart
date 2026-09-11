import 'package:flutter/material.dart';
import '../services/api.dart';
import '../widgets/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/app_button.dart';
import '../widgets/user_avatar.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/empty_state.dart';

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
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final r = await Future.wait([
        Api.getWithCache('/user/me'),
        Api.getWithCache('/rooms'),
        Api.getWithCache('/gifts'),
        Api.getWithCache('/leaderboard'),
      ]);
      if (!mounted) return;
      setState(() {
        _user = (r[0] is Map) ? Map<String, dynamic>.from(r[0]) : null;
        _rooms = (r[1] is List) ? List<dynamic>.from(r[1]) : [];
        _gifts = (r[2] is List) ? List<dynamic>.from(r[2]) : [];
        _lb = (r[3] is List) ? List<dynamic>.from(r[3]) : [];
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _post(String path) async {
    try {
      final r = await Api.dio.post(path, data: {});
      if (mounted) {
        final msg = (r.data is Map && r.data['reward'] != null)
            ? '+${r.data['reward']} coin!'
            : 'Basarili';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(msg), backgroundColor: AppColors.green));
      }
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e'), backgroundColor: AppColors.red));
    }
  }

  int _i(dynamic n) {
    try { return int.parse(n.toString()); } catch (_) { return 0; }
  }

  String _short(int n) {
    if (n >= 1000000000) return (n / 1e9).toStringAsFixed(1) + 'B';
    if (n >= 1000000) return (n / 1e6).toStringAsFixed(1) + 'M';
    if (n >= 1000) return (n / 1e3).toStringAsFixed(1) + 'K';
    return n.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _user == null) {
      return const Scaffold(
        backgroundColor: AppColors.bgDark,
        body: LoadingList(count: 6),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(child: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.gold,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            _balanceCard(),
            const SizedBox(height: 16),
            _quickRow(),
            const SizedBox(height: 24),
            _roomsSection(),
            const SizedBox(height: 20),
            _giftsSection(),
            const SizedBox(height: 16),
            _topSection(),
          ],
        ),
      )),
    );
  }

  Widget _balanceCard() {
    final name = _user?['username']?.toString() ?? 'Kullanici';
    final bal = _i(_user?['balance']);
    final dia = _i(_user?['diamonds']);
    final vip = _user?['vip'] ?? 0;
    final lv = _user?['level'] ?? 0;
    final xp = _i(_user?['xp']);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.goldGradient,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [BoxShadow(
          color: AppColors.gold.withOpacity(0.4),
          blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          UserAvatar(name: name, size: 46),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Merhaba,',
                style: TextStyle(color: Colors.black.withOpacity(0.55),
                  fontSize: 11)),
              Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black,
                  fontSize: 18, fontWeight: FontWeight.bold)),
            ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.25),
              borderRadius: BorderRadius.circular(AppRadius.md)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.workspace_premium,
                color: Colors.white, size: 12),
              const SizedBox(width: 4),
              Text('VIP $vip', style: const TextStyle(color: Colors.white,
                fontSize: 11, fontWeight: FontWeight.bold)),
            ])),
        ]),
        const SizedBox(height: 20),
        Text('BAKIYE',
          style: TextStyle(color: Colors.black.withOpacity(0.55),
            fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text('🪙 $bal', style: const TextStyle(
              color: Colors.black, fontSize: 30,
              fontWeight: FontWeight.bold)))),
          const SizedBox(width: 10),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('💎 ${_short(dia)}', style: TextStyle(
                color: Colors.black.withOpacity(0.7),
                fontSize: 15, fontWeight: FontWeight.bold)))),
        ]),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: ((xp % 100) / 100).clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: Colors.black.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation(Colors.white))),
        const SizedBox(height: 4),
        Text('Seviye $lv • XP $xp', style: TextStyle(
          color: Colors.black.withOpacity(0.55), fontSize: 11)),
      ]),
    );
  }

  Widget _quickRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(children: [
        Expanded(child: _quickCard(
          icon: Icons.card_giftcard,
          label: 'Gunluk Odul',
          colors: [AppColors.green, const Color(0xFF2E7D32)],
          onTap: () => _post('/daily/claim'))),
        const SizedBox(width: 10),
        Expanded(child: _quickCard(
          icon: Icons.rotate_right,
          label: 'Carkifelek',
          colors: [AppColors.purple, AppColors.deepPurple],
          onTap: () => _post('/wheel/spin'))),
      ]),
    );
  }

  Widget _quickCard({
    required IconData icon, required String label,
    required List<Color> colors, required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [BoxShadow(
            color: colors[0].withOpacity(0.4),
            blurRadius: 12, offset: const Offset(0, 5))]),
        child: Row(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppRadius.md)),
            child: Icon(icon, color: Colors.white, size: 20)),
          const SizedBox(width: 10),
          Expanded(child: Text(label, maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white,
              fontWeight: FontWeight.bold, fontSize: 12))),
        ]),
      ),
    );
  }

  Widget _roomsSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Row(children: [
          const Text('🎙️  Populer Odalar', style: TextStyle(
            color: Colors.white, fontSize: 16,
            fontWeight: FontWeight.bold)),
          const Spacer(),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/home'),
            child: const Text('Tumu >', style: TextStyle(
              color: AppColors.gold, fontSize: 12))),
        ])),
      SizedBox(height: 140, child: _rooms.isEmpty
        ? const Center(child: Text('Oda yok',
            style: TextStyle(color: Colors.white38)))
        : ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _rooms.length,
            itemBuilder: (_, i) => _roomCard(_rooms[i]))),
    ]);
  }

  Widget _roomCard(Map r) {
    final name = r['name']?.toString() ?? 'Oda';
    final owner = r['owner']?.toString() ?? '?';
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/voice-room',
        arguments: {'roomId': r['id'], 'roomName': name}),
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          gradient: AppColors.purpleGradient,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.gold.withOpacity(0.3))),
        child: Stack(children: [
          Positioned(top: 8, right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.red,
                borderRadius: BorderRadius.circular(AppRadius.sm)),
              child: const Text('CANLI', style: TextStyle(
                color: Colors.white, fontSize: 8,
                fontWeight: FontWeight.bold)))),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.mic, color: AppColors.gold, size: 28),
                const SizedBox(height: 6),
                Text(name, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white,
                    fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.person, color: Colors.white54, size: 11),
                  const SizedBox(width: 2),
                  Expanded(child: Text(owner, maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white54,
                      fontSize: 10))),
                ]),
              ]),
          ),
        ]),
      ),
    );
  }

  Widget _giftsSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Text('🎁  Populer Hediyeler', style: TextStyle(
          color: Colors.white, fontSize: 16,
          fontWeight: FontWeight.bold))),
      SizedBox(height: 120, child: _gifts.isEmpty
        ? const Center(child: Text('Hediye yok',
            style: TextStyle(color: Colors.white38)))
        : ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _gifts.length,
            itemBuilder: (_, i) => _giftCard(_gifts[i]))),
    ]);
  }

  Widget _giftCard(Map g) {
    final icon = g['icon']?.toString() ?? '🎁';
    final name = g['name']?.toString() ?? 'Hediye';
    final price = _i(g['price']);
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        gradient: AppColors.darkGradient,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.gold.withOpacity(0.2))),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(icon, style: const TextStyle(fontSize: 36)),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 10))),
        const SizedBox(height: 2),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.monetization_on, color: AppColors.gold, size: 11),
          const SizedBox(width: 2),
          Flexible(child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(_short(price), style: const TextStyle(
              color: AppColors.gold, fontSize: 10,
              fontWeight: FontWeight.bold)))),
        ]),
      ]),
    );
  }

  Widget _topSection() {
    final list = _lb.take(5).toList();
    return AppCard(
      margin: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('🏆  En Iyi 5', style: TextStyle(color: Colors.white,
          fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (list.isEmpty)
          const Text('Siralama yok', style: TextStyle(
            color: Colors.white54, fontSize: 12))
        else ...list.asMap().entries.map((e) {
          final i = e.key;
          final u = e.value;
          final medals = ['🥇', '🥈', '🥉'];
          final bal = _i(u['balance']);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(children: [
              SizedBox(width: 28, child: Text(
                i < 3 ? medals[i] : '${i + 1}',
                style: const TextStyle(fontSize: 16))),
              const SizedBox(width: 8),
              Expanded(child: Text(
                u['username']?.toString() ?? '',
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 13))),
              const SizedBox(width: 8),
              Flexible(child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('🪙 ${_short(bal)}',
                  style: const TextStyle(color: AppColors.gold,
                    fontWeight: FontWeight.bold, fontSize: 12)))),
            ]));
        }),
      ]),
    );
  }
}
