import 'package:flutter/material.dart';
import '../services/api.dart';

class LiveStreamScreen extends StatefulWidget {
  const LiveStreamScreen({super.key});
  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> {
  List _streams = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final r = await Api.dio.get('/live/active');
      setState(() => _streams = r.data);
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(title: const Text('Canli Yayinlar'), backgroundColor: Colors.transparent),
      body: _streams.isEmpty
        ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.videocam_off, size: 80, color: Colors.white24),
            SizedBox(height: 12),
            Text('Aktif yayin yok', style: TextStyle(color: Colors.white54)),
          ]))
        : GridView.count(
            padding: const EdgeInsets.all(12),
            crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.75,
            children: _streams.map((s) => Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF8B0000), Color(0xFF4A0000)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(children: [
                const Center(child: Icon(Icons.videocam, size: 60, color: Colors.white38)),
                Positioned(top: 10, left: 10, child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(8)),
                  child: const Text('CANLI', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                )),
                Positioned(bottom: 10, left: 10, right: 10, child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s['title'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text('👤 ${s['username']} • 👁 ${s['viewers'] ?? 0}', style: const TextStyle(color: Colors.white70, fontSize: 10)),
                  ],
                )),
              ]),
            )).toList(),
          ),
    );
  }
}
