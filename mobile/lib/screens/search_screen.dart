import 'package:flutter/material.dart';
import '../services/api.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  List _results = [];

  Future<void> _search(String q) async {
    if (q.length < 2) { setState(() => _results = []); return; }
    try {
      final r = await Api.dio.get('/users/search', queryParameters: {'q': q});
      setState(() => _results = r.data);
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(24)),
          child: TextField(
            controller: _ctrl,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Kullanici ara...',
              hintStyle: TextStyle(color: Colors.white38),
              border: InputBorder.none,
              icon: Icon(Icons.search, color: Colors.white54)),
            onChanged: _search,
          ),
        ),
      ),
      body: _results.isEmpty
        ? const Center(child: Text('Kullanici ara', style: TextStyle(color: Colors.white38)))
        : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _results.length,
            itemBuilder: (_, i) {
              final u = _results[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  CircleAvatar(
                    radius: 22, backgroundColor: const Color(0xFFFFC107),
                    child: Text((u['username'] as String)[0].toUpperCase(),
                      style: const TextStyle(color: Colors.black,
                        fontSize: 18, fontWeight: FontWeight.bold))),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(u['username'] ?? '', style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('VIP ${u['vip']} • Lv.${u['level']}',
                      style: const TextStyle(color: Colors.white54, fontSize: 11)),
                  ])),
                  IconButton(
                    icon: const Icon(Icons.person_add, color: Color(0xFFFFC107)),
                    onPressed: () async {
                      try { await Api.dio.post('/follow/${u['id']}'); } catch (_) {}
                    }),
                ]),
              );
            },
          ),
    );
  }
}
