import 'package:flutter/material.dart';
import '../services/api.dart';
import 'dm_chat_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final int userId;
  const UserProfileScreen({super.key, required this.userId});
  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  Map<String, dynamic>? _user;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final r = await Api.dio.get('/user/${widget.userId}');
      setState(() => _user = r.data);
    } catch (e) {}
  }

  Future<void> _follow() async {
    try {
      await Api.dio.post('/follow/${widget.userId}');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Takip edildi!')));
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFFFFC107))));
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(title: const Text('Profil'), backgroundColor: Colors.transparent),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Center(child: Column(children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [Color(0xFFFFC107), Color(0xFFFF6B35)]),
            ),
            child: CircleAvatar(
              radius: 50, backgroundColor: const Color(0xFF0A0E27),
              child: Text((_user!['username'] as String)[0].toUpperCase(),
                style: const TextStyle(color: Color(0xFFFFC107), fontSize: 42, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 12),
          Text(_user!['username'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC107).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('VIP ${_user!['vip']}', style: const TextStyle(color: Color(0xFFFFC107), fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('Lv.${_user!['level']}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ),
          ]),
        ])),
        const SizedBox(height: 24),
        Row(children: [
          Expanded(child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), padding: const EdgeInsets.symmetric(vertical: 14)),
            onPressed: _follow,
            icon: const Icon(Icons.person_add, color: Colors.white),
            label: const Text('TAKIP ET', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )),
          const SizedBox(width: 10),
          Expanded(child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFC107), padding: const EdgeInsets.symmetric(vertical: 14)),
            onPressed: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => DmChatScreen(otherId: widget.userId, otherUsername: _user!['username']))),
            icon: const Icon(Icons.message, color: Colors.black),
            label: const Text('MESAJ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          )),
        ]),
        const SizedBox(height: 24),
        if (_user!['bio'] != null && (_user!['bio'] as String).isNotEmpty) ...[
          const Text('Hakkinda', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
            child: Text(_user!['bio'], style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ),
        ],
      ]),
    );
  }
}
