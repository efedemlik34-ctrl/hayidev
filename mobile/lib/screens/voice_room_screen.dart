import 'package:flutter/material.dart';
import '../services/api.dart';

class VoiceRoomScreen extends StatefulWidget {
  final int roomId;
  final String roomName;
  const VoiceRoomScreen({super.key, required this.roomId, required this.roomName});
  @override
  State<VoiceRoomScreen> createState() => _VoiceRoomScreenState();
}

class _VoiceRoomScreenState extends State<VoiceRoomScreen> {
  List _seats = [];
  List _messages = [];
  final _msgCtrl = TextEditingController();

  @override
  void initState() { super.initState(); _loadSeats(); _loadMessages(); }

  Future<void> _loadSeats() async {
    try {
      final r = await Api.dio.get('/rooms/' + widget.roomId.toString() + '/seats');
      setState(() => _seats = r.data);
    } catch (e) { debugPrint(e.toString()); }
  }

  Future<void> _loadMessages() async {
    try {
      final r = await Api.dio.get('/rooms/' + widget.roomId.toString() + '/messages');
      setState(() => _messages = r.data);
    } catch (e) { debugPrint(e.toString()); }
  }

  Future<void> _sit(int index) async {
    try { await Api.dio.post('/rooms/' + widget.roomId.toString() + '/seat/' + index.toString()); _loadSeats(); } catch (e) {}
  }

  Future<void> _send() async {
    if (_msgCtrl.text.trim().isEmpty) return;
    try {
      await Api.dio.post('/ai/moderate', data: {'text': _msgCtrl.text});
      _msgCtrl.clear();
      _loadMessages();
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(title: Text(widget.roomName), backgroundColor: Colors.transparent),
      body: Column(children: [
        SizedBox(height: 220, child: GridView.count(
          padding: const EdgeInsets.all(12),
          crossAxisCount: 4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.8,
          children: List.generate(8, (i) {
            final seat = _seats.firstWhere((s) => s['seat_index'] == i, orElse: () => {});
            final occupied = seat.isNotEmpty && seat['username'] != null;
            return GestureDetector(
              onTap: () => _sit(i),
              child: Column(children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: occupied ? const LinearGradient(colors: [Color(0xFFFFC107), Color(0xFFFF6B35)]) : null,
                    color: occupied ? null : Colors.white10,
                  ),
                  child: Icon(occupied ? Icons.person : Icons.add, color: occupied ? Colors.black : Colors.white54),
                ),
                Text(occupied ? (seat['username'] ?? '') : 'Bos', style: const TextStyle(color: Colors.white70, fontSize: 9), overflow: TextOverflow.ellipsis),
              ]),
            );
          }),
        )),
        const Divider(color: Colors.white12),
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: _messages.length,
          itemBuilder: (_, i) {
            final m = _messages[i];
            return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: RichText(text: TextSpan(
              style: const TextStyle(color: Colors.white70, fontSize: 13),
              children: [
                TextSpan(text: (m['username'] ?? '') + ': ', style: const TextStyle(color: Color(0xFFFFC107), fontWeight: FontWeight.bold)),
                TextSpan(text: m['text'] ?? ''),
              ],
            )));
          },
        )),
        Container(
          padding: const EdgeInsets.all(8),
          color: Colors.black26,
          child: Row(children: [
            Expanded(child: TextField(controller: _msgCtrl, style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(hintText: 'Mesaj yaz...', hintStyle: const TextStyle(color: Colors.white38), border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none), filled: true, fillColor: Colors.white10, contentPadding: const EdgeInsets.symmetric(horizontal: 16)),
              onSubmitted: (_) => _send())),
            IconButton(icon: const Icon(Icons.send, color: Color(0xFFFFC107)), onPressed: _send),
          ]),
        ),
      ]),
    );
  }
}
