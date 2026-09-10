import 'package:flutter/material.dart';
import '../services/api.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _bioCtrl = TextEditingController();
  List _frames = [];
  List _myFrames = [];
  String _selectedFrame = 'default';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final u = await Api.dio.get('/user/me');
      _bioCtrl.text = u.data['bio'] ?? '';
      _selectedFrame = u.data['frame'] ?? 'default';
      final f = await Api.dio.get('/frames');
      final mf = await Api.dio.get('/frames/my');
      setState(() { _frames = f.data; _myFrames = mf.data; });
    } catch (e) { debugPrint(e.toString()); }
  }

  Future<void> _save() async {
    try {
      await Api.dio.post('/user/update', data: {'bio': _bioCtrl.text, 'frame': _selectedFrame});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kaydedildi!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: ' + e.toString())));
    }
  }

  Future<void> _buyFrame(String key) async {
    try { await Api.dio.post('/frames/buy', data: {'key': key}); _load(); } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: ' + e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(title: const Text('Profili Duzenle'), backgroundColor: Colors.transparent,
        actions: [TextButton(onPressed: _save, child: const Text('KAYDET', style: TextStyle(color: Color(0xFFFFC107), fontWeight: FontWeight.bold)))]),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const Text('Bio', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(controller: _bioCtrl, maxLines: 3, style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(hintText: 'Kendinden bahset...', hintStyle: const TextStyle(color: Colors.white38), filled: true, fillColor: Colors.white10, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
        const SizedBox(height: 24),
        const Text('Cerceve', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: _frames.map((f) {
          final owned = _myFrames.contains(f['key']);
          final selected = _selectedFrame == f['key'];
          return GestureDetector(
            onTap: () { if (owned) setState(() => _selectedFrame = f['key']); else _buyFrame(f['key']); },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFFFC107).withOpacity(0.3) : Colors.white10,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: selected ? const Color(0xFFFFC107) : Colors.transparent),
              ),
              child: Column(children: [
                Text(f['name'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 12)),
                Text(owned ? 'Sahipsin' : (f['price'] ?? 0).toString(), style: const TextStyle(color: Color(0xFFFFC107), fontSize: 10)),
              ]),
            ),
          );
        }).toList()),
      ]),
    );
  }
}
