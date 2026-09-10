import 'package:flutter/material.dart';
import '../services/api.dart';
import '../services/socket.dart';

class DmChatScreen extends StatefulWidget {
  final int otherId;
  final String otherUsername;
  const DmChatScreen({super.key, required this.otherId, required this.otherUsername});
  @override
  State<DmChatScreen> createState() => _DmChatScreenState();
}

class _DmChatScreenState extends State<DmChatScreen> {
  List _messages = [];
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
    SocketService.socket?.on('dm:new', (d) {
      if (d['fromId'] == widget.otherId || d['fromId'] == null) _load();
    });
  }

  Future<void> _load() async {
    try {
      final r = await Api.dio.get('/dm/messages/${widget.otherId}');
      setState(() => _messages = r.data);
    } catch (e) {}
  }

  Future<void> _send() async {
    if (_ctrl.text.trim().isEmpty) return;
    final text = _ctrl.text.trim();
    _ctrl.clear();
    try {
      await Api.dio.post('/dm/send', data: {'toId': widget.otherId, 'text': text});
      _load();
    } catch (e) {}
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        title: Text(widget.otherUsername),
        backgroundColor: const Color(0xFF1A0F3E),
      ),
      body: Column(children: [
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: _messages.length,
          itemBuilder: (_, i) {
            final m = _messages[i];
            final isMe = m['from_id'] == null ? false : true;
            return Align(
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                decoration: BoxDecoration(
                  gradient: isMe ? const LinearGradient(colors: [Color(0xFFFFC107), Color(0xFFFF6B35)]) : null,
                  color: isMe ? null : Colors.white10,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(m['text'] ?? '', style: TextStyle(color: isMe ? Colors.black : Colors.white, fontSize: 14)),
              ),
            );
          },
        )),
        Container(
          padding: const EdgeInsets.all(8),
          color: const Color(0xFF1A0F3E),
          child: Row(children: [
            Expanded(child: TextField(
              controller: _ctrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Mesaj yaz...',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true, fillColor: Colors.white10,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
              ),
              onSubmitted: (_) => _send(),
            )),
            IconButton(icon: const Icon(Icons.send, color: Color(0xFFFFC107)), onPressed: _send),
          ]),
        ),
      ]),
    );
  }
}
