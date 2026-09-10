import 'package:flutter/material.dart';
import '../services/api.dart';

class StoryScreen extends StatefulWidget {
  const StoryScreen({super.key});
  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  List _feed = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final r = await Api.dio.get('/story/feed');
      setState(() => _feed = r.data);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(title: const Text('Hikayeler'), backgroundColor: Colors.transparent),
      body: _feed.isEmpty
        ? const Center(child: Text('Hikaye yok', style: TextStyle(color: Colors.white54)))
        : GridView.count(padding: const EdgeInsets.all(12), crossAxisCount: 3,
          mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 0.7,
          children: _feed.map((s) => GestureDetector(
            onTap: () async {
              try { await Api.dio.post('/story/${s['id']}/view'); } catch (_) {}
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF4A148C), Color(0xFFE91E63)]),
                borderRadius: BorderRadius.circular(12)),
              child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                Expanded(child: Center(child: Text('📷', style: const TextStyle(fontSize: 48)))),
                Padding(padding: const EdgeInsets.all(8), child: Column(children: [
                  Text(s['username'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  Text('${s['view_count'] ?? 0} 👁', style: const TextStyle(color: Colors.white70, fontSize: 9)),
                ])),
              ])),
          )).toList(),
        ),
    );
  }
}
