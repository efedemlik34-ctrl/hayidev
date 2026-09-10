import 'package:flutter/material.dart';
import '../services/api.dart';

class RoomSettingsScreen extends StatefulWidget {
  final int roomId;
  final String roomName;
  const RoomSettingsScreen({super.key, required this.roomId, required this.roomName});
  @override
  State<RoomSettingsScreen> createState() => _RoomSettingsScreenState();
}

class _RoomSettingsScreenState extends State<RoomSettingsScreen> {
  late TextEditingController _name;
  late TextEditingController _desc;
  bool _locked = false;
  bool _micMuted = false;
  String _bg = 'dark_purple';
  int _maxUsers = 10;
  bool _saving = false;

  final _bgs = ['dark_purple', 'fire_red', 'ocean_blue', 'emerald_green',
    'royal_purple', 'gold_casino', 'neon_pink', 'cyber_dark'];

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.roomName);
    _desc = TextEditingController();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await Api.dio.get('/rooms/${widget.roomId}');
      setState(() {
        _name.text = r.data['name'] ?? _name.text;
        _desc.text = r.data['description'] ?? '';
        _locked = r.data['locked'] ?? false;
        _bg = r.data['background'] ?? 'dark_purple';
        _maxUsers = r.data['maxUsers'] ?? 10;
      });
    } catch (_) {}
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await Api.dio.put('/rooms/${widget.roomId}', data: {
        'name': _name.text, 'description': _desc.text,
        'locked': _locked, 'background': _bg, 'maxUsers': _maxUsers});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Kaydedildi'), backgroundColor: Colors.green));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e'), backgroundColor: Colors.red));
    } finally { if (mounted) setState(() => _saving = false); }
  }

  @override
  void dispose() { _name.dispose(); _desc.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(title: const Text('Oda Ayarlari'),
        backgroundColor: Colors.transparent),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _label('Oda Adi'),
        _field(_name, Icons.edit),
        const SizedBox(height: 16),
        _label('Aciklama'),
        _field(_desc, Icons.description, maxLines: 3),
        const SizedBox(height: 16),
        _label('Maksimum Kullanici'),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: _boxDeco(),
          child: Slider(
            value: _maxUsers.toDouble(), min: 2, max: 50, divisions: 48,
            activeColor: const Color(0xFFFFC107),
            label: '$_maxUsers kisi',
            onChanged: (v) => setState(() => _maxUsers = v.round())),
        ),
        const SizedBox(height: 16),
        _label('Arka Plan'),
        SizedBox(height: 80, child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _bgs.length,
          itemBuilder: (_, i) {
            final b = _bgs[i];
            final sel = _bg == b;
            return GestureDetector(
              onTap: () => setState(() => _bg = b),
              child: Container(
                width: 80, margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: _bgColors(b)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: sel ? const Color(0xFFFFC107) : Colors.white24,
                    width: sel ? 3 : 1)),
                child: sel ? const Icon(Icons.check_circle,
                  color: Color(0xFFFFC107)) : null),
            );
          })),
        const SizedBox(height: 16),
        _switchTile('Oda Kilitli', 'Sadece davetliler girebilir',
          _locked, (v) => setState(() => _locked = v)),
        _switchTile('Mikrofonlar Kapali', 'Yeni gelenler mic kapali baslar',
          _micMuted, (v) => setState(() => _micMuted = v)),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, height: 54,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC107),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            onPressed: _saving ? null : _save,
            child: Text(_saving ? '...' : 'KAYDET',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                letterSpacing: 2)))),
      ]));
  }

  List<Color> _bgColors(String k) {
    final m = {
      'dark_purple': [const Color(0xFF1A0F3E), const Color(0xFF6A1B9A)],
      'fire_red': [const Color(0xFF3C0808), const Color(0xFFB41E0F)],
      'ocean_blue': [const Color(0xFF05193C), const Color(0xFF0F5096)],
      'emerald_green': [const Color(0xFF052312), const Color(0xFF0F5A2D)],
      'royal_purple': [const Color(0xFF280850), const Color(0xFF6E1EA0)],
      'gold_casino': [const Color(0xFF321E05), const Color(0xFFA06414)],
      'neon_pink': [const Color(0xFF320523), const Color(0xFF961964)],
      'cyber_dark': [const Color(0xFF0A0C19), const Color(0xFF232D4B)],
    };
    return m[k] ?? [Colors.black, Colors.grey];
  }

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(t.toUpperCase(), style: const TextStyle(
      color: Color(0xFFFFC107), fontSize: 11,
      fontWeight: FontWeight.bold, letterSpacing: 1.5)));

  Widget _field(TextEditingController c, IconData i, {int maxLines = 1}) =>
    Container(decoration: _boxDeco(), child: TextField(
      controller: c, maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        border: InputBorder.none,
        contentPadding: const EdgeInsets.all(16),
        prefixIcon: Icon(i, color: const Color(0xFFFFC107)))));

  BoxDecoration _boxDeco() => BoxDecoration(
    color: Colors.white.withOpacity(0.05),
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: Colors.white.withOpacity(0.1)));

  Widget _switchTile(String t, String s, bool v, Function(bool) onC) =>
    Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: _boxDeco(),
      child: SwitchListTile(
        title: Text(t, style: const TextStyle(color: Colors.white, fontSize: 14)),
        subtitle: Text(s, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        value: v, onChanged: onC,
        activeColor: const Color(0xFFFFC107)));
}
