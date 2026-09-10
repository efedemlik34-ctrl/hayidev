import 'package:flutter/material.dart';
import '../services/api.dart';
import 'games_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _user;
  List _gifts = [];
  List _quests = [];
  List _lb = [];
  List _followers = [];
  int _tab = 0;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final u = await Api.dio.get('/user/me');
      final g = await Api.dio.get('/gifts');
      final q = await Api.dio.get('/quests');
      final l = await Api.dio.get('/leaderboard');
      List f = [];
      try { final fr = await Api.dio.get('/follow/followers'); f = fr.data; } catch (_) {}
      setState(() {
        _user = u.data;
        _gifts = g.data;
        _quests = q.data;
        _lb = l.data;
        _followers = f;
      });
    } catch (e) { debugPrint(e.toString()); }
  }

  Future<void> _post(String path, [Map<String, dynamic>? body]) async {
    try {
      final r = await Api.dio.post(path, data: body ?? {});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Basarili')));
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: ' + e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFFFFC107))));
    return Scaffold(
      appBar: AppBar(
        title: const Text('HayiDev'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Api.logout();
              if (mounted) Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: IndexedStack(index: _tab, children: [_anaTab(), const GamesScreen(), _gorevTab(), _liderTab(), _benTab()]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        backgroundColor: const Color(0xFF0F1430),
        selectedItemColor: const Color(0xFFFFC107),
        unselectedItemColor: Colors.white38,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ana'),
          BottomNavigationBarItem(icon: Icon(Icons.casino), label: 'Oyun'),
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Gorev'),
          BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: 'Lider'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Ben'),
        ],
      ),
    );
  }

  Widget _anaTab() => ListView(padding: const EdgeInsets.all(16), children: [
    Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFFC107), Color(0xFFFF6B35)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Merhaba, ' + (_user!['username'] ?? ''), style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Bakiye: ' + _user!['balance'].toString(), style: const TextStyle(color: Colors.black, fontSize: 26, fontWeight: FontWeight.bold)),
        Text('VIP ' + _user!['vip'].toString() + ' • Lvl ' + _user!['level'].toString(), style: const TextStyle(color: Colors.black54, fontSize: 12)),
      ]),
    ),
    const SizedBox(height: 16),
    Row(children: [
      Expanded(child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), padding: const EdgeInsets.symmetric(vertical: 14)),
        onPressed: () => _post('/daily/claim'),
        icon: const Icon(Icons.card_giftcard, color: Colors.white, size: 18),
        label: const Text('GUNLUK', style: TextStyle(color: Colors.white, fontSize: 12)),
      )),
      const SizedBox(width: 8),
      Expanded(child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9C27B0), padding: const EdgeInsets.symmetric(vertical: 14)),
        onPressed: () => _post('/wheel/spin', {'paid': false}),
        icon: const Icon(Icons.rotate_right, color: Colors.white, size: 18),
        label: const Text('CARK', style: TextStyle(color: Colors.white, fontSize: 12)),
      )),
    ]),
    const SizedBox(height: 24),
    const Text('Hediyeler', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    SizedBox(height: 110, child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _gifts.length,
      itemBuilder: (_, i) => Container(
        margin: const EdgeInsets.only(right: 8),
        width: 90,
        decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(_gifts[i]['icon'] ?? '?', style: const TextStyle(fontSize: 36)),
          const SizedBox(height: 4),
          Text(_gifts[i]['name'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 10)),
          Text(_gifts[i]['price'].toString(), style: const TextStyle(color: Color(0xFFFFC107), fontSize: 10)),
        ]),
      ),
    )),
  ]);

  Widget _gorevTab() => ListView(padding: const EdgeInsets.all(16), children: [
    const Text('Gorevler', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
    const SizedBox(height: 16),
    ..._quests.map((q) {
      final progress = q['progress'] ?? 0;
      final target = q['target'] ?? 1;
      final pct = target > 0 ? (progress / target).clamp(0.0, 1.0) : 0.0;
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(q['title'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: pct.toDouble(),
              minHeight: 6,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation(Color(0xFFFFC107)),
            ),
            const SizedBox(height: 4),
            Text(progress.toString() + '/' + target.toString(), style: const TextStyle(color: Colors.white54, fontSize: 11)),
          ])),
          q['claimed'] == true
            ? const Icon(Icons.check_circle, color: Colors.greenAccent)
            : q['completed'] == true
              ? ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFC107)),
                  onPressed: () => _post('/quests/' + q['key'].toString() + '/claim'),
                  child: Text('+' + q['reward'].toString(), style: const TextStyle(color: Colors.black)),
                )
              : Text('+' + q['reward'].toString(), style: const TextStyle(color: Color(0xFFFFC107))),
        ]),
      );
    }),
  ]);

  Widget _liderTab() => ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: _lb.length + 1,
    itemBuilder: (_, i) {
      if (i == 0) return const Padding(padding: EdgeInsets.only(bottom: 16), child: Text('Liderlik', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)));
      final u = _lb[i - 1];
      final top = i <= 3;
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: top ? const Color(0xFFFFC107).withOpacity(0.2) : Colors.white10,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          SizedBox(width: 30, child: Text(i.toString(), style: TextStyle(color: top ? const Color(0xFFFFC107) : Colors.white70, fontWeight: FontWeight.bold))),
          Expanded(child: Text(u['username'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          Text(u['balance'].toString(), style: const TextStyle(color: Color(0xFFFFC107), fontWeight: FontWeight.bold)),
        ]),
      );
    },
  );

  Widget _benTab() => ListView(padding: const EdgeInsets.all(16), children: [
    const SizedBox(height: 20),
    Center(child: Column(children: [
      CircleAvatar(
        radius: 50,
        backgroundColor: const Color(0xFFFFC107),
        child: Text((_user!['username'] as String)[0].toUpperCase(), style: const TextStyle(color: Colors.black, fontSize: 40, fontWeight: FontWeight.bold)),
      ),
      const SizedBox(height: 12),
      Text(_user!['username'].toString(), style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
      Text(_user!['email']?.toString() ?? '-', style: const TextStyle(color: Colors.white54, fontSize: 13)),
      const SizedBox(height: 12),
      Text(_followers.length.toString() + ' takipci', style: const TextStyle(color: Colors.white70, fontSize: 12)),
    ])),
    const SizedBox(height: 24),
    ListTile(
      leading: const Icon(Icons.card_giftcard, color: Color(0xFFFFC107)),
      title: const Text('Hediye Gecmisi', style: TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
      onTap: () => _post('/gifts/history'),
    ),
    ListTile(
      leading: const Icon(Icons.people, color: Color(0xFFFFC107)),
      title: const Text('Davet Et', style: TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
      onTap: () => _post('/invite/me'),
    ),
    ListTile(
      leading: const Icon(Icons.workspace_premium, color: Color(0xFFFFC107)),
      title: const Text('VIP', style: TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
      onTap: () => _post('/vip'),
    ),
    ListTile(
      leading: const Icon(Icons.notifications, color: Color(0xFFFFC107)),
      title: const Text('Bildirimler', style: TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
      onTap: () => _post('/notifications'),
    ),
  ]);
}
