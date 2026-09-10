import 'package:flutter/material.dart';
import '../services/api.dart';
import 'voice_room_screen.dart';

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});
  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  List _rooms = [];
  int _tab = 0;
  final _tabs = ['Populer', 'Turkiye', 'Almanya', 'Turkmenistan'];
  final _search = TextEditingController();

  @override
  void initState() { super.initState(); _load(); _search.addListener(_filter); }

  Future<void> _load() async {
    try {
      final r = await Api.dio.get('/rooms');
      setState(() => _rooms = r.data);
    } catch (_) {}
  }

  void _filter() {}

  void _create() {
    final ctrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1A0F3E),
      title: const Text('Oda Olustur', style: TextStyle(color: Colors.white)),
      content: TextField(
        controller: ctrl,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: 'Oda adi',
          hintStyle: TextStyle(color: Colors.white38),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx),
          child: const Text('Iptal')),
        TextButton(onPressed: () async {
          if (ctrl.text.isEmpty) return;
          try {
            await Api.dio.post('/rooms/create', data: {'name': ctrl.text});
          } catch (_) {}
          if (ctx.mounted) Navigator.pop(ctx);
          _load();
        }, child: const Text('OLUSTUR')),
      ],
    ));
  }

  @override
  void dispose() { _search.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final filtered = _search.text.isEmpty
      ? _rooms
      : _rooms.where((r) =>
          (r['name'] ?? '').toString().toLowerCase()
            .contains(_search.text.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(24),
          ),
          child: TextField(
            controller: _search,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Oda ara...',
              hintStyle: TextStyle(color: Colors.white38),
              border: InputBorder.none,
              icon: Icon(Icons.search, color: Color(0xFFFFC107)),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFFFFC107)),
            onPressed: _create,
          ),
        ],
      ),
      body: Column(children: [
        // Tab chips
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _tabs.length,
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => setState(() => _tab = i),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: _tab == i
                    ? const LinearGradient(colors: [Color(0xFFFFC107), Color(0xFFFF6B35)])
                    : null,
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
        const SizedBox(height: 12),
        // Oda grid
        Expanded(child: filtered.isEmpty
          ? const Center(child: Text('Oda yok',
              style: TextStyle(color: Colors.white54)))
          : GridView.count(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.85,
              children: filtered.map((r) => _roomCard(r)).toList(),
            ),
        ),
      ]),
    );
  }

  Widget _roomCard(Map<String, dynamic> r) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => VoiceRoomScreen(
          roomId: r['id'] ?? 0,
          roomName: r['name']?.toString() ?? 'Oda'))),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF2A1F5E), Color(0xFF1A0F3E)]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFC107).withOpacity(0.3)),
        ),
        child: Stack(children: [
          // Arka plan
          Positioned(top: 10, right: 10,
            child: Icon(Icons.mic,
              color: const Color(0xFFFFC107).withOpacity(0.3), size: 40)),
          Positioned(top: 8, left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(8)),
              child: const Text('CANLI',
                style: TextStyle(color: Colors.white, fontSize: 8,
                  fontWeight: FontWeight.bold)))),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r['name']?.toString() ?? 'Oda',
                  style: const TextStyle(color: Colors.white,
                    fontSize: 13, fontWeight: FontWeight.bold),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.person, color: Colors.white54, size: 12),
                  const SizedBox(width: 2),
                  Expanded(child: Text(r['owner']?.toString() ?? '?',
                    style: const TextStyle(color: Colors.white54, fontSize: 10),
                    overflow: TextOverflow.ellipsis)),
                ]),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
