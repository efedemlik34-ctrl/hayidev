import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/api.dart';
import '../services/agora_service.dart';
import '../widgets/campfire_scene.dart';
import '../widgets/seat_widget.dart';
import '../widgets/room_banner.dart';
import 'gift_bottom_sheet.dart';
import 'gift_animation.dart';
import 'room_settings_screen.dart';

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
  final _scrollCtrl = ScrollController();
  int? _mySeat;
  bool _inVoice = false;
  bool _muted = false;
  int _wealth = 193000000;
  int _userCount = 1;
  int _speakingSeat = -1;
  late AnimationController _bgCtrl;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
    _loadSeats();
    _loadMessages();
    _simulateSpeaking();
  }

  void _simulateSpeaking() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() => _speakingSeat = 5);
      Future.delayed(const Duration(seconds: 4), () {
        if (!mounted) return;
        setState(() => _speakingSeat = -1);
        _simulateSpeaking();
      });
    });
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    AgoraService.instance.release();
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSeats() async {
    try {
      final r = await Api.dio.get('/rooms/${widget.roomId}/seats');
      final seats = List.from(r.data);
      while (seats.length < 8) seats.add({'seat_index': seats.length, 'username': null});
      setState(() {
        _seats = seats;
        _userCount = seats.where((s) => s['username'] != null).length;
      });
    } catch (e) {
      final seats = List.generate(8, (i) => {'seat_index': i, 'username': null, 'is_locked': i == 1 || i == 7});
      setState(() => _seats = seats);
    }
  }

  Future<void> _loadMessages() async {
    try {
      final r = await Api.dio.get('/rooms/${widget.roomId}/messages');
      setState(() => _messages = r.data);
    } catch (e) {}
  }

  Future<void> _sit(int i) async {
    try {
      await Api.dio.post('/rooms/${widget.roomId}/seat/$i');
      final t = await Api.dio.get('/rooms/${widget.roomId}/agora-token');
      if (t.data['appId'] != null && t.data['appId'].toString().isNotEmpty) {
        await AgoraService.instance.initEngine(t.data['appId']);
        await AgoraService.instance.joinChannel(
          token: t.data['token'], channelName: t.data['channel'], uid: 0);
      }
      setState(() { _mySeat = i; _inVoice = true; });
      _loadSeats();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _leaveSeat() async {
    try {
      await Api.dio.delete('/rooms/${widget.roomId}/seat');
      await AgoraService.instance.leaveChannel();
      setState(() { _mySeat = null; _inVoice = false; });
      _loadSeats();
    } catch (e) {}
  }

  Future<void> _toggleMute() async {
    if (!_inVoice) return;
    await AgoraService.instance.toggleMute();
    setState(() => _muted = AgoraService.instance.isMuted);
  }

  Future<void> _send() async {
    if (_msgCtrl.text.trim().isEmpty) return;
    final text = _msgCtrl.text.trim();
    _msgCtrl.clear();
    try {
      await Api.dio.post('/ai/moderate', data: {'text': text});
      _loadMessages();
      await Future.delayed(const Duration(milliseconds: 300));
      _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } catch (e) {}
  }

  void _onSeatTap(int i) {
    final seat = _seats[i];
    if (seat['username'] != null) {
      _showUserProfile(seat);
    } else {
      _sit(i);
    }
  }

  void _showUserProfile(Map seat) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A0F3E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [Color(0xFFFFC107), Color(0xFFFF6B35)]),
              boxShadow: [BoxShadow(color: Color(0xFFFFC107), blurRadius: 24, spreadRadius: 2)],
            ),
            child: CircleAvatar(
              radius: 42, backgroundColor: const Color(0xFF0A0E27),
              child: Text((seat['username'] as String)[0].toUpperCase(),
                style: const TextStyle(color: Color(0xFFFFC107), fontSize: 36, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 12),
          Text(seat['username'], style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Koltuk ${seat['seat_index'] + 1}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC107),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () { Navigator.pop(context); _openGiftSheet(seat['user_id'] ?? 1); },
              icon: const Icon(Icons.card_giftcard, color: Colors.black),
              label: const Text('HEDIYE GONDER', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            )),
        ]),
      ),
    );
  }

  void _openGiftSheet(int receiverId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => GiftBottomSheet(
        roomId: widget.roomId, seats: _seats, preselectedReceiverId: receiverId,
        onSent: (gift) => _showGiftAnim(gift),
      ),
    );
  }

  void _showGiftAnim(Map<String, dynamic> gift) {
    showDialog(context: context, barrierDismissible: false, barrierColor: Colors.black54,
      builder: (_) => GiftAnimation(gift: gift, senderName: 'Sen', quantity: 1));
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        // Arka plan - 3D gradient
        AnimatedBuilder(
          animation: _bgCtrl,
          builder: (_, __) => Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.3 - _bgCtrl.value * 0.6, -0.5),
                radius: 1.5,
                colors: const [Color(0xFF1A1F4E), Color(0xFF0F1430), Color(0xFF0A0E27)],
              ),
            ),
          ),
        ),
        // Yildizlar
        ..._buildStars(),
        SafeArea(child: Column(children: [
          // ═══ HEADER ═══
          _header(),
          // ═══ BANNER ═══
          const RoomBanner(),
          // ═══ WEALTH BAR ═══
          _wealthBar(),
          // ═══ SEATS (2 rows of 4) ═══
          _seatsGrid(),
          const SizedBox(height: 8),
          // ═══ CHAT ═══
          Expanded(child: _chatArea()),
          // ═══ CAMPFIRE + ACTION BAR ═══
          Stack(children: [
            const CampfireScene(height: 160),
            Positioned(bottom: 0, left: 0, right: 0, child: _actionBar()),
          ]),
        ])),
      ]),
    );
  }

  List<Widget> _buildStars() {
    final rand = math.Random(42);
    return List.generate(40, (i) {
      final x = rand.nextDouble();
      final y = rand.nextDouble() * 0.7;
      final size = 1.0 + rand.nextDouble() * 2;
      return Positioned(
        left: x * MediaQuery.of(context).size.width,
        top: y * MediaQuery.of(context).size.height,
        child: AnimatedBuilder(
          animation: _bgCtrl,
          builder: (_, __) => Opacity(
            opacity: (0.3 + 0.7 * ((math.sin(_bgCtrl.value * 2 * math.pi + i) + 1) / 2)).clamp(0.0, 1.0),
            child: Container(width: size, height: size,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
          ),
        ),
      );
    });
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(children: [
        // Avatar + sovalye
        Stack(children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFF8A00)]),
              boxShadow: [BoxShadow(color: const Color(0xFFFF8A00).withOpacity(0.6), blurRadius: 12)],
            ),
            child: const CircleAvatar(
              radius: 22, backgroundColor: Color(0xFF1A1F3A),
              child: Icon(Icons.person, color: Colors.white70, size: 24),
            ),
          ),
          Positioned(right: -2, bottom: -2, child: Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(color: Color(0xFFFFC107), shape: BoxShape.circle),
            child: const Text('🛡️', style: TextStyle(fontSize: 12)),
          )),
        ]),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Text('👑', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 2),
            Expanded(child: Text(widget.roomName,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis)),
          ]),
          Row(children: [
            Text('ID:${widget.roomId}282438', style: const TextStyle(color: Colors.white54, fontSize: 10)),
            const SizedBox(width: 8),
            const Icon(Icons.people, color: Colors.white54, size: 10),
            const SizedBox(width: 2),
            Text('$_userCount', style: const TextStyle(color: Colors.white54, fontSize: 10)),
          ]),
        ])),
        // Ust ikonlar
        _glassIcon(Icons.shield_moon, () {}),
        const SizedBox(width: 6),
        _glassIcon(Icons.share, () {}),
        const SizedBox(width: 6),
        _glassIcon(Icons.power_settings_new, () async {
          if (_inVoice) await _leaveSeat();
          if (mounted) Navigator.pop(context);
        }),
      ]),
    );
  }

  Widget _glassIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.08),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Icon(icon, color: Colors.white70, size: 18),
      ),
    );
  }

  Widget _wealthBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFF8A00)]),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: const Color(0xFFFF8A00).withOpacity(0.5), blurRadius: 8)],
          ),
          child: Row(children: [
            const Icon(Icons.emoji_events, color: Colors.black, size: 12),
            const SizedBox(width: 3),
            Text('${(_wealth / 1000000).toStringAsFixed(1)}M',
              style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(width: 2),
            const Icon(Icons.chevron_right, color: Colors.black, size: 12),
          ]),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF9C27B0).withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF9C27B0).withOpacity(0.6)),
          ),
          child: const Row(children: [
            Icon(Icons.music_note, color: Color(0xFFE1BEE7), size: 12),
            SizedBox(width: 3),
            Text('Müzik', style: TextStyle(color: Color(0xFFE1BEE7), fontSize: 11, fontWeight: FontWeight.bold)),
          ]),
        ),
        const Spacer(),
        const Text('🧞', style: TextStyle(fontSize: 24)),
      ]),
    );
  }

  Widget _seatsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(4, (i) => SeatWidget(
            index: i,
            seat: _seats.length > i ? _seats[i] : null,
            isMe: _mySeat == i,
            isSpeaking: _speakingSeat == i,
            onTap: () => _onSeatTap(i),
          ))),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(4, (i) => SeatWidget(
            index: i + 4,
            seat: _seats.length > i + 4 ? _seats[i + 4] : null,
            isMe: _mySeat == i + 4,
            isSpeaking: _speakingSeat == i + 4,
            onTap: () => _onSeatTap(i + 4),
          ))),
      ]),
    );
  }

  Widget _chatArea() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView(
        controller: _scrollCtrl,
        padding: const EdgeInsets.all(10),
        children: [
          _sysMsg('Hayi\'ya hoş geldiniz. Lütfen birbirinize saygı gösterin ve kibarca sohbet edin.'),
          _sysMsg('Duyuru:\nOdaya katıldığınız için teşekkürler', isAnnouncement: true),
          ..._messages.map((m) => _userMsg(m)),
          _joinMsg('Efe Demir'),
        ],
      ),
    );
  }

  Widget _sysMsg(String text, {bool isAnnouncement = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isAnnouncement ? const Color(0xFF1A1F3A).withOpacity(0.6) : Colors.black26,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text, style: const TextStyle(
        color: Color(0xFFFFEB3B), fontSize: 12, height: 1.4)),
    );
  }

  Widget _userMsg(Map m) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFFFC107), Color(0xFFFF6B35)]),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(m['username'] ?? '', style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(m['text'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 13))),
      ]),
    );
  }

  Widget _joinMsg(String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        const CircleAvatar(radius: 10, backgroundColor: Color(0xFF1A1F3A),
          child: Icon(Icons.person, color: Colors.white70, size: 12)),
        const SizedBox(width: 6),
        Text(name, style: const TextStyle(color: Color(0xFFFFEB3B), fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(width: 6),
        const Text('odaya gir', style: TextStyle(color: Colors.white70, fontSize: 12)),
      ]),
    );
  }

  Widget _actionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withOpacity(0.85)]),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _barIcon(Icons.chat_bubble_outline, () {
          showModalBottomSheet(context: context, backgroundColor: const Color(0xFF1A0F3E),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            builder: (_) => Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  Expanded(child: TextField(
                    controller: _msgCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Mesaj yaz...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true, fillColor: Colors.white10,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                    ),
                    onSubmitted: (_) { Navigator.pop(context); _send(); },
                  )),
                  IconButton(icon: const Icon(Icons.send, color: Color(0xFFFFC107)),
                    onPressed: () { Navigator.pop(context); _send(); }),
                ]),
              ),
            ));
        }),
        _barIcon(Icons.mail_outline, () {}),
        _barIcon(Icons.volume_up, () {}),
        GestureDetector(
          onTap: _toggleMute,
          child: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: _muted
                ? [Colors.red.shade700, Colors.red.shade900]
                : [const Color(0xFFFFC107), const Color(0xFFFF8A00)]),
              boxShadow: [BoxShadow(color: (_muted ? Colors.red : const Color(0xFFFF8A00)).withOpacity(0.6), blurRadius: 14)],
            ),
            child: Icon(_muted ? Icons.mic_off : Icons.mic, color: _muted ? Colors.white : Colors.black, size: 22),
          ),
        ),
        _barIcon(Icons.emoji_emotions_outlined, () {}),
        _barIcon(Icons.grid_view, () {}),
        _barIcon(Icons.add_circle_outline, () {}),
        // Hediye - buyuk
        GestureDetector(
          onTap: () => _openGiftSheet(_seats.where((s) => s['username'] != null && s['user_id'] != null).isNotEmpty
            ? _seats.firstWhere((s) => s['username'] != null && s['user_id'] != null)['user_id']
            : 1),
          child: Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(0xFFFFD700), Color(0xFFFF8A00), Color(0xFFE65100)]),
              boxShadow: [
                BoxShadow(color: const Color(0xFFFF8A00).withOpacity(0.8), blurRadius: 18, spreadRadius: 2),
              ],
            ),
            child: const Center(child: Text('🎁', style: TextStyle(fontSize: 24))),
          ),
        ),
      ]),
    );
  }

  Widget _barIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.08),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Icon(icon, color: Colors.white70, size: 20),
      ),
    );
  }
}
