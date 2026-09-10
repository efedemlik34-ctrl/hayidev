import 'package:flutter/material.dart';
import '../services/api.dart';
import 'friend_chat_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});
  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  int _tab = 0;
  List _friends = [], _requests = [], _search = [];
  final _searchCtrl = TextEditingController();
  final _tabs = ['Arkadaslar', 'Istekler', 'Ara'];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final r1 = await Api.dio.get('/friends');
      final r2 = await Api.dio.get('/friends/requests');
      setState(() { _friends = r1.data; _requests = r2.data; });
    } catch (_) {}
  }

  Future<void> _searchUsers() async {
    if (_searchCtrl.text.isEmpty) return;
    try {
      final r = await Api.dio.get('/users/search?q=${_searchCtrl.text}');
      setState(() => _search = r.data);
    } catch (_) {}
  }

  Future<void> _add(int id) async {
    try { await Api.dio.post('/friends/add', data: {'userId': id}); _load(); }
    catch (_) {}
  }

  Future<void> _accept(int id) async {
    try { await Api.dio.post('/friends/accept', data: {'userId': id}); _load(); }
    catch (_) {}
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(title: const Text('Arkadaslar'),
        backgroundColor: Colors.transparent),
      body: Column(children: [
        Container(margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(14)),
          child: Row(children: List.generate(_tabs.length, (i) {
            final sel = _tab == i;
            return Expanded(child: GestureDetector(
              onTap: () => setState(() => _tab = i),
              child: Container(padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: sel ? const LinearGradient(colors: [
                    Color(0xFFFFC107), Color(0xFFFF6B35)]) : null,
                  borderRadius: BorderRadius.circular(10)),
                child: Center(child: Text(_tabs[i], style: TextStyle(
                  color: sel ? Colors.black : Colors.white60,
                  fontWeight: FontWeight.bold, fontSize: 12))))));
          }))),
        if (_tab == 2) Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14)),
            child: TextField(controller: _searchCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Kullanici adi...',
                hintStyle: const TextStyle(color: Colors.white38),
                border: InputBorder.none,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Color(0xFFFFC107)),
                  onPressed: _searchUsers))))),
        Expanded(child: _buildList()),
      ]));
  }

  Widget _buildList() {
    final list = _tab == 0 ? _friends : _tab == 1 ? _requests : _search;
    if (list.isEmpty) return const Center(child: Text('Bos',
      style: TextStyle(color: Colors.white54)));
    return ListView.builder(padding: const EdgeInsets.all(16),
      itemCount: list.length, itemBuilder: (_, i) {
        final u = list[i];
        return Container(margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [
              Color(0xFF1A0F3E), Color(0xFF0F0A2E)]),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFFFC107).withOpacity(0.2))),
          child: Row(children: [
            CircleAvatar(radius: 22, backgroundColor: const Color(0xFF2A1F5E),
              child: Text((u['username']?.toString() ?? '?')[0].toUpperCase(),
                style: const TextStyle(color: Color(0xFFFFC107),
                  fontWeight: FontWeight.bold, fontSize: 18))),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(u['username']?.toString() ?? '',
                  style: const TextStyle(color: Colors.white,
                    fontWeight: FontWeight.bold, fontSize: 14)),
                Text('Lv ${u['level'] ?? 0}',
                  style: const TextStyle(color: Colors.white54, fontSize: 11)),
              ])),
            if (_tab == 0) IconButton(
              icon: const Icon(Icons.chat, color: Color(0xFFFFC107)),
              onPressed: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => FriendChatScreen(
                  userId: u['id'] ?? 0,
                  username: u['username']?.toString() ?? '?'))))
            else if (_tab == 1) IconButton(
              icon: const Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
              onPressed: () => _accept(u['id'] ?? 0))
            else IconButton(
              icon: const Icon(Icons.person_add, color: Color(0xFFFFC107)),
              onPressed: () => _add(u['id'] ?? 0)),
          ]));
      });
  }
}
