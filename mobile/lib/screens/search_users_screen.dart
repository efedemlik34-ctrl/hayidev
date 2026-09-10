import 'package:flutter/material.dart';
import '../services/api.dart';
import 'user_profile_screen.dart';

class SearchUsersScreen extends StatefulWidget {
  const SearchUsersScreen({super.key});
  @override
  State<SearchUsersScreen> createState() => _SearchUsersScreenState();
}

class _SearchUsersScreenState extends State<SearchUsersScreen> {
  final _q = TextEditingController();
  List _results = [];

  Future<void> _search() async {
    try {
      final r = await Api.dio.get('/search/users', queryParameters: {'q': _q.text});
      setState(() => _results = r.data);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(title: const Text('Kullanici Ara'), backgroundColor: Colors.transparent),
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(12), child: TextField(
          controller: _q, onChanged: (_) => _search(),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Kullanici adi...', hintStyle: const TextStyle(color: Colors.white38),
            prefixIcon: const Icon(Icons.search, color: Color(0xFFFFC107)),
            filled: true, fillColor: Colors.white10,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
          ),
        )),
        Expanded(child: ListView.builder(
          itemCount: _results.length,
          itemBuilder: (_, i) {
            final u = _results[i];
            return ListTile(
              leading: CircleAvatar(backgroundColor: const Color(0xFFFFC107),
                child: Text((u['username'] as String)[0].toUpperCase(),
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
              title: Text(u['username'] ?? '', style: const TextStyle(color: Colors.white)),
              subtitle: Text('VIP ${u['vip']} • Lv.${u['level']}', style: const TextStyle(color: Colors.white54)),
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => UserProfileScreen(userId: u['id']))),
            );
          },
        )),
      ]),
    );
  }
}
