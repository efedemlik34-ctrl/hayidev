import 'package:flutter/material.dart';
import '../services/api.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});
  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  List _friends = [];
  List _requests = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final f = await Api.dio.get('/friends/list');
      final r = await Api.dio.get('/friends/requests');
      setState(() { _friends = f.data; _requests = r.data; });
    } catch (e) { debugPrint(e.toString()); }
  }

  Future<void> _accept(int id) async {
    try { await Api.dio.post('/friends/accept/' + id.toString()); _load(); } catch (e) {}
  }

  Future<void> _reject(int id) async {
    try { await Api.dio.post('/friends/reject/' + id.toString()); _load(); } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(title: const Text('Arkadaslar'), backgroundColor: Colors.transparent),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        if (_requests.isNotEmpty) ...[
          const Text('Istekler', style: TextStyle(color: Color(0xFFFFC107), fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._requests.map((u) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              Text(u['username'] ?? '', style: const TextStyle(color: Colors.white)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.check, color: Colors.greenAccent), onPressed: () => _accept(u['from_id'])),
              IconButton(icon: const Icon(Icons.close, color: Colors.redAccent), onPressed: () => _reject(u['from_id'])),
            ]),
          )),
          const SizedBox(height: 16),
        ],
        const Text('Arkadaslar', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (_friends.isEmpty) const Text('Arkadas yok', style: TextStyle(color: Colors.white54)),
        ..._friends.map((u) => ListTile(
          leading: CircleAvatar(backgroundColor: const Color(0xFFFFC107), child: Text((u['username'] as String)[0].toUpperCase(), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
          title: Text(u['username'] ?? '', style: const TextStyle(color: Colors.white)),
          subtitle: Text('VIP ' + (u['vip'] ?? 0).toString(), style: const TextStyle(color: Colors.white54)),
        )),
      ]),
    );
  }
}
