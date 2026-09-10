import 'package:flutter/material.dart';
import '../services/api.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List _items = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final r = await Api.dio.get('/notifications');
      setState(() => _items = r.data);
      await Api.dio.post('/notifications/read');
    } catch (e) { debugPrint(e.toString()); }
  }

  IconData _icon(String type) {
    if (type == 'follow') return Icons.person_add;
    if (type == 'friend_request') return Icons.people;
    if (type == 'push') return Icons.notifications;
    return Icons.info;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(title: const Text('Bildirimler'), backgroundColor: Colors.transparent),
      body: _items.isEmpty
        ? const Center(child: Text('Bildirim yok', style: TextStyle(color: Colors.white54)))
        : ListView.builder(padding: const EdgeInsets.all(12),
            itemCount: _items.length,
            itemBuilder: (_, i) {
              final n = _items[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: n['is_read'] == 0 ? const Color(0xFFFFC107).withOpacity(0.1) : Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  Icon(_icon(n['type'] ?? ''), color: const Color(0xFFFFC107), size: 26),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(n['title'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    if (n['body'] != null) Text(n['body'], style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ])),
                ]),
              );
            }),
    );
  }
}
