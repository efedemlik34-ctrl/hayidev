
import 'package:flutter/material.dart';
import '../services/api.dart';

class VisitorsScreen extends StatefulWidget {
  const VisitorsScreen({super.key});
  @override
  State<VisitorsScreen> createState() => _VisitorsScreenState();
}

class _VisitorsScreenState extends State<VisitorsScreen> {
  List _visitors = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

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
      appBar: AppBar(
        title: const Text('Profil Ziyaretcileri'),
        backgroundColor: Colors.transparent,
      ),
      body: _visitors.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.visibility_off, color: Colors.white24, size: 60),
                  SizedBox(height: 12),
                  Text(
                    'Henuz kimse bakmadi',
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _visitors.length,
              itemBuilder: (_, i) => _card(_visitors[i]),
            ),
    );
  }

  Widget _card(Map v) {
    final user = (v['username'] ?? '?').toString();
    final time = (v['time'] ?? 'az once').toString();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A0F3E), Color(0xFF0F0A2E)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFFC107).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFF2A1F5E),
            child: Text(
              user[0].toUpperCase(),
              style: const TextStyle(
                color: Color(0xFFFFC107),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
          const Icon(Icons.visibility, color: Color(0xFFFFC107), size: 18),
        ],
      ),
    );
  }
}
