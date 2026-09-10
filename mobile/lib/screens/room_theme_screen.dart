import 'package:flutter/material.dart';
import '../services/api.dart';

class RoomThemeScreen extends StatefulWidget {
  final int roomId;
  const RoomThemeScreen({super.key, required this.roomId});
  @override
  State<RoomThemeScreen> createState() => _RoomThemeScreenState();
}

class _RoomThemeScreenState extends State<RoomThemeScreen> {
  List _themes = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final r = await Api.dio.get('/themes');
      setState(() => _themes = r.data);
    } catch (e) {}
  }

  Future<void> _apply(String key) async {
    try {
      await Api.dio.post('/rooms/${widget.roomId}/theme', data: {'theme': key});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tema uygulandi!')));
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(title: const Text('Oda Temalari'), backgroundColor: Colors.transparent),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.4,
        children: _themes.map((t) => GestureDetector(
          onTap: () => _apply(t['key']),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF2A1F5E), Color(0xFF1A0F3E)]),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFFC107).withOpacity(0.3)),
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(t['name'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('🪙 ${t['price'] ?? 0}', style: const TextStyle(color: Color(0xFFFFC107), fontSize: 12)),
            ]),
          ),
        )).toList(),
      ),
    );
  }
}
