
import 'package:flutter/material.dart';
import '../services/api.dart';

class ClanScreen extends StatefulWidget {
  const ClanScreen({super.key});
  @override
  State<ClanScreen> createState() => _ClanScreenState();
}

class _ClanScreenState extends State<ClanScreen> {
  List _clans = [];
  Map? _myClan;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r1 = await Api.dio.get('/clans');
      final r2 = await Api.dio.get('/clans/my');
      setState(() {
        _clans = r1.data;
        _myClan = r2.data is Map ? r2.data : null;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _join(int id) async {
    try {
      await Api.dio.post('/clans/' + id.toString() + '/join');
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _create() async {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A0F3E),
        title: const Text('Klan Kur', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Klan adi',
            hintStyle: TextStyle(color: Colors.white38),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Iptal'),
          ),
          TextButton(
            onPressed: () async {
              if (ctrl.text.isEmpty) return;
              try {
                await Api.dio.post('/clans/create', data: {'name': ctrl.text});
              } catch (_) {}
              if (ctx.mounted) Navigator.pop(ctx);
              _load();
            },
            child: const Text('OLUSTUR'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0E27),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFFFC107))),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        title: const Text('Klanlar'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFFFFC107)),
            onPressed: _create,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_myClan != null) _myClanCard(),
          const SizedBox(height: 16),
          const Text(
            'Tum Klanlar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ..._clans.map((c) => _clanCard(c)),
        ],
      ),
    );
  }

  Widget _myClanCard() {
    final name = (_myClan?['name'] ?? 'Klan').toString();
    final members = (_myClan?['members'] ?? 0).toString();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFF6B35)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFC107).withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'KLANIM',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            members + ' uye',
            style: const TextStyle(color: Colors.black87, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _clanCard(Map c) {
    final id = c['id'] ?? 0;
    final name = (c['name'] ?? 'Klan').toString();
    final members = (c['members'] ?? 0).toString();
    final max = (c['max'] ?? 50).toString();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A0F3E), Color(0xFF0F0A2E)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFFC107).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFC107), Color(0xFFFF6B35)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.shield, color: Colors.black),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  members + '/' + max + ' uye',
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _join(id is int ? id : 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'KATIL',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
