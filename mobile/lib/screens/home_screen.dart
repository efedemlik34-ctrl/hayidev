import 'package:flutter/material.dart';
import '../services/api.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _user;
  List _gifts = [];
  List _quests = [];
  int _tab = 0;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final u = await Api.dio.get('/user/me');
      final g = await Api.dio.get('/gifts');
      final q = await Api.dio.get('/quests');
      setState(() { _user = u.data; _gifts = g.data; _quests = q.data; });
    } catch (e) { debugPrint(e.toString()); }
  }

  Future<void> _daily() async {
    try {
      final r = await Api.dio.post('/daily/claim');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('+' + r.data['reward'].toString())));
      _load();
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
  }

  Future<void> _wheel() async {
    try {
      final r = await Api.dio.post('/wheel/spin', data: {'paid': false});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Carkifelek: +' + r.data['reward'].toString())));
      _load();
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
  }

  Future<void> _playRocket() async {
    try {
      final r = await Api.dio.post('/games/rocket/start', data: {'bet': 1000});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Roket basladi!')));
      _load();
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
  }

  Future<void> _playRoulette() async {
    try {
      final r = await Api.dio.post('/games/roulette/spin', data: {'bet': 1000, 'type': 'red'});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Kazanan: ' + r.data['winning'].toString())));
      _load();
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
  }

  Future<void> _playSlot() async {
    try {
      final r = await Api.dio.post('/games/slot/spin', data: {'bet': 1000});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Slot: ' + r.data['reels'].toString() + ' Kazanc: ' + r.data['payout'].toString())));
      _load();
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
  }

  Future<void> _claimQuest(String k) async {
    try {
      final r = await Api.dio.post('/quests/' + k + '/claim');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('+' + r.data['reward'].toString())));
      _load();
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFFFFC107))));
    return Scaffold(
      appBar: AppBar(title: const Text('HayiDev'), backgroundColor: Colors.transparent,
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () async { await Api.logout(); if (mounted) Navigator.pushReplacementNamed(context, '/'); })]),
      body: IndexedStack(index: _tab, children: [_homeTab(), _gamesTab(), _questsTab(), _profileTab()]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab, onTap: (i) => setState(() => _tab = i),
        backgroundColor: const Color(0xFF0F1430), selectedItemColor: const Color(0xFFFFC107),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ana'),
          BottomNavigationBarItem(icon: Icon(Icons.casino), label: 'Oyun'),
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Gorev'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Ben'),
        ]),
    );
  }

  Widget _homeTab() => ListView(padding: const EdgeInsets.all(16), children: [
    Container(padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFFC107), Color(0xFFFF6B35)]), borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Merhaba, ' + (_user!['username'] ?? ''), style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Bakiye: ' + _user!['balance'].toString(), style: const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
        Text('VIP ' + _user!['vip'].toString() + ' - Seviye ' + _user!['level'].toString(), style: const TextStyle(color: Colors.black54, fontSize: 12)),
      ])),
    const SizedBox(height: 16),
    ElevatedButton.icon(
      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), padding: const EdgeInsets.all(16)),
      onPressed: _daily, icon: const Icon(Icons.card_giftcard, color: Colors.white),
      label: const Text('GUNLUK ODUL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
    const SizedBox(height: 8),
    ElevatedButton.icon(
      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9C27B0), padding: const EdgeInsets.all(16)),
      onPressed: _wheel, icon: const Icon(Icons.rotate_right, color: Colors.white),
      label: const Text('CARKIFELEK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
    const SizedBox(height: 24),
    const Text('Hediyeler', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
    SizedBox(height: 100, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: _gifts.length,
      itemBuilder: (_, i) => Container(margin: const EdgeInsets.only(right: 8), width: 80,
        decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(_gifts[i]['icon'].toString(), style: const TextStyle(fontSize: 32)),
          Text(_gifts[i]['price'].toString(), style: const TextStyle(color: Color(0xFFFFC107), fontSize: 10)),
        ])))),
  ]);

  Widget _gamesTab() => ListView(padding: const EdgeInsets.all(16), children: [
    const Text('Oyunlar', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
    const SizedBox(height: 16),
    GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.2,
      children: [
        _gc('Roket', Colors.purple, _playRocket),
        _gc('Rulet', Colors.red, _playRoulette),
        _gc('Slot', Colors.orange, _playSlot),
      ]),
  ]);

  Widget _gc(String n, Color c, VoidCallback onTap) => GestureDetector(onTap: onTap,
    child: Container(decoration: BoxDecoration(color: c.withOpacity(0.3), borderRadius: BorderRadius.circular(16), border: Border.all(color: c)),
      child: Center(child: Text(n, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)))));

  Widget _questsTab() => ListView(padding: const EdgeInsets.all(16), children: [
    const Text('Gorevler', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
    const SizedBox(height: 16),
    ..._quests.map((q) {
      final pct = q['target'] > 0 ? (q['progress'] / q['target']).clamp(0.0, 1.0) : 0.0;
      return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(q['title'].toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            LinearProgressIndicator(value: pct.toDouble(), minHeight: 6, backgroundColor: Colors.white12, valueColor: const AlwaysStoppedAnimation(Color(0xFFFFC107))),
            Text(q['progress'].toString() + '/' + q['target'].toString(), style: const TextStyle(color: Colors.white54, fontSize: 11)),
          ])),
          q['claimed'] == true
            ? const Icon(Icons.check_circle, color: Colors.greenAccent)
            : q['completed'] == true
              ? ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFC107)), onPressed: () => _claimQuest(q['key'].toString()), child: Text('+' + q['reward'].toString(), style: const TextStyle(color: Colors.black)))
              : Text('+' + q['reward'].toString(), style: const TextStyle(color: Color(0xFFFFC107))),
        ]));
    }),
  ]);

  Widget _profileTab() => ListView(padding: const EdgeInsets.all(16), children: [
    Center(child: Column(children: [
      CircleAvatar(radius: 50, backgroundColor: const Color(0xFFFFC107), child: Text((_user!['username'] as String)[0].toUpperCase(), style: const TextStyle(color: Colors.black, fontSize: 40, fontWeight: FontWeight.bold))),
      const SizedBox(height: 12),
      Text(_user!['username'].toString(), style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
      Text(_user!['email']?.toString() ?? '-', style: const TextStyle(color: Colors.white54, fontSize: 13)),
    ])),
  ]);
}
