import 'package:flutter/material.dart';
import '../services/api.dart';
import '../services/local_db.dart';

class FriendChatScreen extends StatefulWidget {
  final int userId;
  final String username;
  const FriendChatScreen({super.key, required this.userId,
    required this.username});
  @override
  State<FriendChatScreen> createState() => _FriendChatScreenState();
}

class _FriendChatScreenState extends State<FriendChatScreen> {
  final _msg = TextEditingController();
  final _scroll = ScrollController();
  List _messages = [];

  @override
  void initState() { super.initState(); _load(); _poll(); }

  Future<void> _load() async {
    try {
      final r = await Api.dio.get('/dm/${widget.userId}');
      setState(() => _messages = r.data);
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scroll.hasClients) _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut);
      });
    } catch (_) {}
  }

  void _poll() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) { _load(); _poll(); }
    });
  }

  Future<void> _send() async {
    final t = _msg.text.trim();
    if (t.isEmpty) return;
    _msg.clear();
    try { await Api.dio.post('/dm/${widget.userId}', data: {'text': t}); _load(); }
    catch (_) {}
  }

  @override
  void dispose() { _msg.dispose(); _scroll.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final myName = LocalDB.getUser()['username'] ?? 'Sen';
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(backgroundColor: Colors.transparent,
        title: Row(children: [
          CircleAvatar(radius: 16, backgroundColor: const Color(0xFF2A1F5E),
            child: Text(widget.username[0].toUpperCase(),
              style: const TextStyle(color: Color(0xFFFFC107),
                fontWeight: FontWeight.bold, fontSize: 14))),
          const SizedBox(width: 10),
          Text(widget.username, style: const TextStyle(color: Colors.white,
            fontSize: 16, fontWeight: FontWeight.bold)),
        ])),
      body: Column(children: [
        Expanded(child: _messages.isEmpty
          ? const Center(child: Text('Mesaj yok',
              style: TextStyle(color: Colors.white54)))
          : ListView.builder(controller: _scroll,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length, itemBuilder: (_, i) {
                final m = _messages[i];
                final isMe = m['sender'] == myName;
                return Align(alignment: isMe ? Alignment.centerRight
                    : Alignment.centerLeft,
                  child: Container(margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      gradient: isMe ? const LinearGradient(colors: [
                        Color(0xFFFFC107), Color(0xFFFF8C00)]) : null,
                      color: isMe ? null : Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14)),
                    child: Text(m['text']?.toString() ?? '',
                      style: TextStyle(color: isMe ? Colors.black
                        : Colors.white, fontSize: 14))));
              })),
        Container(padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05),
            border: const Border(top: BorderSide(color: Colors.white12))),
          child: SafeArea(top: false, child: Row(children: [
            Expanded(child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(24)),
              child: TextField(controller: _msg,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Mesaj yaz...',
                  hintStyle: TextStyle(color: Colors.white38),
                  border: InputBorder.none),
                onSubmitted: (_) => _send()))),
            const SizedBox(width: 8),
            GestureDetector(onTap: _send,
              child: Container(width: 44, height: 44,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Color(0xFFFFC107), Color(0xFFFF8C00)]),
                  shape: BoxShape.circle),
                child: const Icon(Icons.send, color: Colors.black, size: 20))),
          ]))),
      ]));
  }
}
