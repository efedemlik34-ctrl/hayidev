import 'package:flutter/material.dart';
import '../services/api.dart';
import 'user_profile_screen.dart';

class ProfileVisitorsScreen extends StatefulWidget {
  const ProfileVisitorsScreen({super.key});
  @override
  State<ProfileVisitorsScreen> createState() => _ProfileVisitorsScreenState();
}

class _ProfileVisitorsScreenState extends State<ProfileVisitorsScreen> {
  List _visitors = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final r = await Api.dio.get('/profile/visitors');
      setState(() => _visitors = r.data);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(title: const Text('Ziyaretciler'), backgroundColor: Colors.transparent),
      body: _visitors.isEmpty ? const Center(child: Text('Ziyaretci yok', style: TextStyle(color: Colors.white54)))
        : ListView.builder(itemCount: _visitors.length, itemBuilder: (_, i) {
            final v = _visitors[i];
            return ListTile(
              leading: CircleAvatar(backgroundColor: const Color(0xFFFFC107),
                child: Text((v['username'] as String)[0].toUpperCase(), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
              title: Text(v['username'] ?? '', style: const TextStyle(color: Colors.white)),
              subtitle: Text('VIP ${v['vip']} • Lv.${v['level']}', style: const TextStyle(color: Colors.white54)),
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => UserProfileScreen(userId: v['id']))),
            );
          }),
    );
  }
}
