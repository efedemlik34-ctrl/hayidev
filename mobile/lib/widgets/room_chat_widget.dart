import 'package:flutter/material.dart';
import '../services/api.dart';
import '../services/local_db.dart';

class RoomChatWidget extends StatefulWidget {
  final int roomId;
  const RoomChatWidget({super.key, required this.roomId});
  @override
  State<RoomChatWidget> createState() => _RoomChatWidgetState();
}

class _RoomChatWidgetState extends State<RoomChatWidget> {
  final _msg = TextEditingController();
  final _scroll = ScrollController();
  List _messages = [];
  List _emojis = ['😀','😂','🥰','😎','🤩','😭','🔥','💎','👑','🎁',
    '🌟','💯','🎉','👍','❤️','💀','🤔','🥳'];

  @override
  void initState() { super.initState(); _load(); _poll(); }

  Future<void> _load() async {
    try {
      final r = await Api.dio.get('/rooms/${widget.roomId}/messages');
      setState(() => _messages = r.data);
      _scrollDown();
    } catch (_) {}
  }

  void _poll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) { _load(); _poll(); }
    });
  }

  void _scrollDown() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _send([String? txt]) async {
    final t = txt ?? _msg.text.trim();
    if (t.isEmpty) return;
    _msg.clear();
    try {
      await Api.dio.post('/rooms/${widget.roomId}/messages', data: {'text': t});
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e'), backgroundColor: Colors.red));
    }
  }

  @override
  void dispose() { _msg.dispose(); _scroll.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final myName = LocalDB.getUser()['username'] ?? 'Sen';
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0A0E27),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(children: [
        Container(margin: const EdgeInsets.only(top: 10),
          width: 40, height: 4,
          decoration: BoxDecoration(color: Colors.white24,
            borderRadius: BorderRadius.circular(2))),
        const Padding(padding: EdgeInsets.all(10),
          child: Text('Sohbet', style: TextStyle(color: Colors.white,
            fontSize: 16, fontWeight: FontWeight.bold))),
        Expanded(child: _messages.isEmpty
          ? const Center(child: Text('Henuz mesaj yok',
              style: TextStyle(color: Colors.white54)))
          : ListView.builder(controller: _scroll,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _messages.length, itemBuilder: (_, i) {
                final m = _messages[i];
                final isMe = m['username'] == myName;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    constraints: BoxConstraints(maxWidth:
                      MediaQuery.of(context).size.width * 0.7),
                    decoration: BoxDecoration(
                      gradient: isMe ? const LinearGradient(colors: [
                        Color(0xFFFFC107), Color(0xFFFF8C00)]) : null,
                      color: isMe ? null : Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14)),
                    child: Column(
                      crossAxisAlignment: isMe ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start, children: [
                        if (!isMe) Text(m['username']?.toString() ?? '?',
                          style: const TextStyle(color: Color(0xFFFFC107),
                            fontSize: 10, fontWeight: FontWeight.bold)),
                        Text(m['text']?.toString() ?? '',
                          style: TextStyle(color: isMe ? Colors.black : Colors.white,
                            fontSize: 13)),
                      ])));
              })),
        SizedBox(height: 44, child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: _emojis.length,
          itemBuilder: (_, i) => GestureDetector(
            onTap: () => _send(_emojis[i]),
            child: Container(margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10)),
              child: Center(child: Text(_emojis[i],
                style: const TextStyle(fontSize: 22))))))),
        Container(padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
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
            GestureDetector(onTap: () => _send(),
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
