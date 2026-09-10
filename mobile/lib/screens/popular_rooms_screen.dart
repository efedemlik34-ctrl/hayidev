import 'package:flutter/material.dart';
import '../services/api.dart';
import 'voice_room_screen.dart';

class PopularRoomsScreen extends StatefulWidget {
  const PopularRoomsScreen({super.key});
  @override
  State<PopularRoomsScreen> createState() => _PopularRoomsScreenState();
}

class _PopularRoomsScreenState extends State<PopularRoomsScreen> {
  List _rooms = [];
  int _tab = 0;
  final List<String> _tabs = ['Populer', 'Turkiye', 'Almanya', 'Turkmenistan'];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final r = await Api.dio.get('/rooms');
      setState(() => _rooms = r.data);
    } catch (e) { debugPrint(e.toString()); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          children: [
            const SizedBox(height: 12),
            // Ust bar
            Row(children: [
              const Text('Populer', style: TextStyle(color: Colors.white,
                fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              const Text('Takip', style: TextStyle(color: Colors.white38, fontSize: 16)),
              const SizedBox(width: 16),
              const Text('Gecenlerde', style: TextStyle(color: Colors.white38, fontSize: 16)),
              const Spacer(),
              Icon(Icons.emoji_events, color: Color(0xFFFFC107)),
              const SizedBox(width: 12),
              Icon(Icons.search, color: Colors.white70),
              const SizedBox(width: 12),
              Icon(Icons.add_circle_outline, color: Color(0xFFFFC107)),
            ]),
            const SizedBox(height: 16),
            // Hayi Ailesi banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A0F3E), Color(0xFF4A148C), Color(0xFF1A0F3E)]),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Color(0xFFFFC107), width: 2),
                boxShadow: [BoxShadow(color: Color(0xFFFFC107).withOpacity(0.3), blurRadius: 20)],
              ),
              child: Column(children: [
                Row(children: [
                  Icon(Icons.workspace_premium, color: Color(0xFFFFC107), size: 40),
                  const SizedBox(width: 12),
                  const Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hayi Ailesi', style: TextStyle(color: Colors.white,
                        fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('Buyuyor, Kazaniyor!', style: TextStyle(
                        color: Color(0xFFFFC107), fontSize: 14, fontWeight: FontWeight.bold)),
                    ]),
                  ),
                ]),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFFE91E63), Color(0xFF9C27B0)]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(children: [
                    Text('BUYUK AILELER BUYUK ODULLER KAZANIYOR!',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ]),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFC107),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('HEMEN AILENE KATIL!',
                    style: TextStyle(color: Colors.black,
                      fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            // Tab chips
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _tabs.length,
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => setState(() => _tab = i),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: _tab == i ? LinearGradient(
                        colors: [Color(0xFFFFC107), Color(0xFFFF6B35)]) : null,
                      color: _tab == i ? null : Colors.white10,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(_tabs[i],
                      style: TextStyle(
                        color: _tab == i ? Colors.black : Colors.white70,
                        fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Oda grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.85,
              children: _rooms.map((r) => _roomCard(r)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roomCard(Map<String, dynamic> r) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => VoiceRoomScreen(roomId: r['id'], roomName: r['name'] ?? 'Oda'))),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF2A1F5E), Color(0xFF1A0F3E)]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFC107).withOpacity(0.3)),
        ),
        child: Stack(children: [
          // Yildiz dekorasyonu
          Positioned(top: 10, right: 10,
            child: Icon(Icons.mic, color: const Color(0xFFFFC107).withOpacity(0.3), size: 40)),
          // Icerik
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r['name'] ?? 'Oda',
                  style: const TextStyle(color: Colors.white,
                    fontSize: 13, fontWeight: FontWeight.bold),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.person, color: Colors.white54, size: 12),
                  const SizedBox(width: 2),
                  Text('${r['owner'] ?? '?'}',
                    style: const TextStyle(color: Colors.white54, fontSize: 10),
                    overflow: TextOverflow.ellipsis),
                ]),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
