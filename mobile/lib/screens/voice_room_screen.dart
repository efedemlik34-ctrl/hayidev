import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/api.dart';

class VoiceRoomScreen extends StatefulWidget {
  final int roomId;
  final String roomName;
  const VoiceRoomScreen({super.key, required this.roomId, required this.roomName});
  @override
  State<VoiceRoomScreen> createState() => _VoiceRoomScreenState();
}

class _VoiceRoomScreenState extends State<VoiceRoomScreen> with TickerProviderStateMixin {
  List _seats = [];
  List _messages = [];
  final _msgCtrl = TextEditingController();
  late AnimationController _glowCtrl;
  int? _mySeat;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _loadSeats();
    _loadMessages();
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

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
    try {
      await Api.dio.post('/rooms/' + widget.roomId.toString() + '/seat/' + index.toString());
      setState(() => _mySeat = index);
      _loadSeats();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _send() async {
    if (_msgCtrl.text.trim().isEmpty) return;
    final text = _msgCtrl.text.trim();
    _msgCtrl.clear();
    try {
      await Api.dio.post('/ai/moderate', data: {'text': text});
      _loadMessages();
    } catch (e) {}
  }

  Widget _seatWidget(int i) {
    final seat = _seats.firstWhere((s) => s['seat_index'] == i, orElse: () => {});
    final occupied = seat.isNotEmpty && seat['username'] != null;
    final isMe = _mySeat == i;
    return GestureDetector(
      onTap: () => occupied ? null : _sit(i),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        AnimatedBuilder(
          animation: _glowCtrl,
          builder: (_, __) {
            final glow = occupied ? 12 + _glowCtrl.value * 8 : 0.0;
            return Container(
              width: 58, height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: occupied
                  ? const LinearGradient(colors: [Color(0xFFFFC107), Color(0xFFFF6B35)])
                  : null,
                color: occupied ? null : Colors.white.withOpacity(0.06),
                border: Border.all(
                  color: isMe ? Colors.greenAccent : (occupied ? Color(0xFFFFC107).withOpacity(0.5) : Colors.white.withOpacity(0.15)),
                  width: isMe ? 3 : 2),
                boxShadow: occupied ? [BoxShadow(color: const Color(0xFFFFC107).withOpacity(0.5), blurRadius: glow)] : null,
              ),
              child: Center(
                child: occupied
                  ? Text((seat['username'] as String)[0].toUpperCase(),
                      style: const TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold))
                  : const Icon(Icons.add, color: Colors.white38, size: 24),
              ),
            );
          },
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 70,
          child: Text(occupied ? (seat['username'] ?? '') : 'Bos',
            style: TextStyle(color: occupied ? Colors.white : Colors.white38, fontSize: 10),
            textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
        ),
        if (occupied)
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (seat['is_muted'] == 1) const Icon(Icons.mic_off, color: Colors.redAccent, size: 10),
            if (seat['is_muted'] != 1) const Icon(Icons.mic, color: Colors.greenAccent, size: 10),
          ]),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(10)),
            child: const Text('CANLI', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(widget.roomName, style: const TextStyle(fontSize: 15), overflow: TextOverflow.ellipsis)),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.settings, color: Colors.white70), onPressed: () => Navigator.pushNamed(context, '/settings')),
        ],
      ),
      body: Stack(children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Color(0xFF1A0F3E), Color(0xFF0A0E27), Color(0xFF0A0E27)]),
          ),
        ),
        Column(children: [
          const SizedBox(height: 90),
          // Koltuklar grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              mainAxisSpacing: 14,
              crossAxisSpacing: 8,
              childAspectRatio: 0.72,
              children: List.generate(8, _seatWidget),
            ),
          ),
          const SizedBox(height: 16),
          // Chat
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _messages.length,
                itemBuilder: (_, i) {
                  final m = _messages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC107).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6)),
                        child: Text(m['username'] ?? '',
                          style: const TextStyle(color: Color(0xFFFFC107), fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(m['text'] ?? '',
                        style: const TextStyle(color: Colors.white70, fontSize: 13))),
                    ]),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Alt bar
          Container(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
            child: Row(children: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE91E63).withOpacity(0.2),
                    shape: BoxShape.circle),
                  child: const Icon(Icons.card_giftcard, color: Color(0xFFE91E63), size: 20)),
                onPressed: () => Navigator.pushNamed(context, '/gifts'),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(24)),
                  child: TextField(
                    controller: _msgCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Mesaj yaz...',
                      hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                    onSubmitted: (_) => _send(),
                  ),
                ),
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFFFFC107), Color(0xFFFF6B35)]),
                    shape: BoxShape.circle),
                  child: const Icon(Icons.send, color: Colors.black, size: 20)),
                onPressed: _send,
              ),
            ]),
          ),
        ]),
      ]),
    );
  }
}
