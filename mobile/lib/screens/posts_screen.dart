import 'package:flutter/material.dart';
import '../services/api.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});
  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  List _posts = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final r = await Api.dio.get('/posts');
      setState(() => _posts = r.data);
    } catch (e) { debugPrint(e.toString()); }
  }

  void _create() {
    final ctrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1A0F3E),
      title: const Text('Yeni Post', style: TextStyle(color: Colors.white)),
      content: TextField(controller: ctrl, maxLines: 4, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: 'Ne dusunuyorsun?', hintStyle: TextStyle(color: Colors.white38))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Iptal')),
        TextButton(onPressed: () async {
          if (ctrl.text.trim().isEmpty) return;
          try { await Api.dio.post('/posts', data: {'text': ctrl.text}); if (ctx.mounted) Navigator.pop(ctx); _load(); } catch (e) {}
        }, child: const Text('PAYLAS')),
      ],
    ));
  }

  Future<void> _like(int id) async {
    try { await Api.dio.post('/posts/' + id.toString() + '/like'); _load(); } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(title: const Text('Sosyal Akis'), backgroundColor: Colors.transparent,
        actions: [IconButton(icon: const Icon(Icons.add, color: Color(0xFFFFC107)), onPressed: _create)]),
      body: _posts.isEmpty
        ? const Center(child: Text('Post yok. Ilk paylasani sen ol!', style: TextStyle(color: Colors.white54)))
        : ListView.builder(padding: const EdgeInsets.all(12),
            itemCount: _posts.length,
            itemBuilder: (_, i) {
              final p = _posts[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(14)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    CircleAvatar(radius: 16, backgroundColor: const Color(0xFFFFC107), child: Text((p['username'] ?? '?')[0].toUpperCase(), style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold))),
                    const SizedBox(width: 8),
                    Text(p['username'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ]),
                  const SizedBox(height: 10),
                  Text(p['text'] ?? '', style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 10),
                  Row(children: [
                    IconButton(icon: const Icon(Icons.favorite_border, color: Color(0xFFFFC107), size: 20), onPressed: () => _like(p['id'])),
                    Text((p['likes'] ?? 0).toString(), style: const TextStyle(color: Colors.white54)),
                  ]),
                ]),
              );
            }),
    );
  }
}
