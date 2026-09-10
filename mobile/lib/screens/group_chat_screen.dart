import 'package:flutter/material.dart';
import '../services/api.dart';

class GroupChatScreen extends StatefulWidget {
  const GroupChatScreen({super.key});
  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  List _groups = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final r = await Api.dio.get('/groups/my');
      setState(() => _groups = r.data);
    } catch (_) {}
  }

  void _create() {
    final c = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1A0F3E),
      title: const Text('Grup Olustur', style: TextStyle(color: Colors.white)),
      content: TextField(controller: c, style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(hintText: 'Grup adi', hintStyle: TextStyle(color: Colors.white38))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Iptal')),
        TextButton(onPressed: () async {
          if (c.text.isEmpty) return;
          try { await Api.dio.post('/groups/create', data: {'name': c.text}); } catch (_) {}
          if (ctx.mounted) Navigator.pop(ctx);
          _load();
        }, child: const Text('OLUSTUR')),
      ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(title: const Text('Gruplar'), backgroundColor: Colors.transparent,
        actions: [IconButton(icon: const Icon(Icons.add, color: Color(0xFFFFC107)), onPressed: _create)]),
      body: _groups.isEmpty ? const Center(child: Text('Grup yok', style: TextStyle(color: Colors.white54)))
        : ListView.builder(itemCount: _groups.length, itemBuilder: (_, i) {
            final g = _groups[i];
            return ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFFFFC107), child: Icon(Icons.group, color: Colors.black)),
              title: Text(g['name'] ?? '', style: const TextStyle(color: Colors.white)),
              subtitle: Text('${g['member_count']} uye • ${g['last_msg'] ?? 'Mesaj yok'}', style: const TextStyle(color: Colors.white54), maxLines: 1, overflow: TextOverflow.ellipsis),
            );
          }),
    );
  }
}
