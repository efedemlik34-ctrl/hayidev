
import 'package:flutter/material.dart';
import '../services/api.dart';
import '../services/local_db.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});
  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  List _posts = [];
  final _text = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await Api.dio.get('/posts');
      setState(() => _posts = r.data);
    } catch (_) {}
  }

  Future<void> _post() async {
    if (_text.text.trim().isEmpty) return;
    try {
      await Api.dio.post('/posts', data: {'text': _text.text});
      _text.clear();
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _like(int id) async {
    try {
      await Api.dio.post('/posts/' + id.toString() + '/like');
      _load();
    } catch (_) {}
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myName = LocalDB.getUser()['username'] ?? 'Sen';
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        title: const Text('Sosyal Akis'),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              controller: _text,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Ne dusunuyorsun?',
                hintStyle: const TextStyle(color: Colors.white38),
                border: InputBorder.none,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFFFFC107)),
                  onPressed: _post,
                ),
              ),
            ),
          ),
          Expanded(
            child: _posts.isEmpty
                ? const Center(
                    child: Text(
                      'Paylasim yok',
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _posts.length,
                    itemBuilder: (_, i) => _postCard(_posts[i], myName),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _postCard(Map p, String myName) {
    final user = (p['username'] ?? '?').toString();
    final text = (p['text'] ?? '').toString();
    final likes = (p['likes'] ?? 0).toString();
    final id = p['id'] ?? 0;
    final isMe = user == myName;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A0F3E), Color(0xFF0F0A2E)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMe
              ? const Color(0xFFFFC107).withOpacity(0.5)
              : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF2A1F5E),
                child: Text(
                  user[0].toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFFFFC107),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  user,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              GestureDetector(
                onTap: () => _like(id is int ? id : 0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.favorite_border,
                      color: Color(0xFFFFC107),
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      likes,
                      style: const TextStyle(
                        color: Color(0xFFFFC107),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
