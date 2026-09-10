
import 'package:flutter/material.dart';
import '../services/api.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});
  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  List _stories = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await Api.dio.get('/stories');
      setState(() => _stories = r.data);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        title: const Text('Hikayeler'),
        backgroundColor: Colors.transparent,
      ),
      body: _stories.isEmpty
          ? const Center(
              child: Text(
                'Hikaye yok',
                style: TextStyle(color: Colors.white54),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.7,
              ),
              itemCount: _stories.length,
              itemBuilder: (_, i) => _storyCard(_stories[i]),
            ),
    );
  }

  Widget _storyCard(Map s) {
    final user = (s['username'] ?? '?').toString();
    final img = s['image'];
    final hasImg = img != null && img.toString().isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF4A148C), Color(0xFF0F0A2E)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFC107).withOpacity(0.4),
        ),
      ),
      child: Stack(
        children: [
          if (hasImg)
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                img.toString(),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),
          Positioned(
            top: 10,
            left: 10,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFFFC107),
              child: Text(
                user[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Text(
              user,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
