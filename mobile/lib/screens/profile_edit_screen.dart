import 'package:flutter/material.dart';
import '../services/api.dart';
import '../services/local_db.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});
  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late TextEditingController _username, _bio;
  String _gender = 'male';
  int _age = 20;
  String _country = 'TR';
  String _avatarFrame = 'gold';
  bool _saving = false;

  final _frames = ['none', 'gold', 'purple', 'neon', 'fire', 'ice', 'rainbow'];
  final _countries = ['TR', 'AZ', 'DE', 'US', 'RU', 'TM'];

  @override
  void initState() {
    super.initState();
    _username = TextEditingController(text: LocalDB.getUser()['username'] ?? '');
    _bio = TextEditingController(text: '');
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await Api.dio.get('/user/me');
      setState(() {
        _username.text = r.data['username'] ?? _username.text;
        _bio.text = r.data['bio'] ?? '';
        _gender = r.data['gender'] ?? 'male';
        _age = r.data['age'] ?? 20;
        _country = r.data['country'] ?? 'TR';
        _avatarFrame = r.data['avatarFrame'] ?? 'gold';
      });
    } catch (_) {}
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await Api.dio.put('/user/me', data: {
        'username': _username.text, 'bio': _bio.text,
        'gender': _gender, 'age': _age,
        'country': _country, 'avatarFrame': _avatarFrame});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Profil guncellendi'), backgroundColor: Colors.green));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e'), backgroundColor: Colors.red));
    } finally { if (mounted) setState(() => _saving = false); }
  }

  @override
  void dispose() { _username.dispose(); _bio.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(title: const Text('Profili Duzenle'),
        backgroundColor: Colors.transparent),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Center(child: Stack(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: _frameColors(_avatarFrame)),
              boxShadow: [BoxShadow(color: _frameColors(_avatarFrame)[0],
                blurRadius: 20, spreadRadius: 2)]),
            child: CircleAvatar(radius: 54,
              backgroundColor: const Color(0xFF1A0F3E),
              child: Text(_username.text.isEmpty ? '?' : _username.text[0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 48,
                  fontWeight: FontWeight.bold)))),
          Positioned(bottom: 0, right: 0, child: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Color(0xFFFFC107),
              shape: BoxShape.circle),
            child: const Icon(Icons.camera_alt, color: Colors.black, size: 18))),
        ])),
        const SizedBox(height: 20),
        _label('Avatar Cercevesi'),
        SizedBox(height: 60, child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _frames.length,
          itemBuilder: (_, i) {
            final f = _frames[i];
            final sel = _avatarFrame == f;
            return GestureDetector(
              onTap: () => setState(() => _avatarFrame = f),
              child: Container(
                width: 56, margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: _frameColors(f)),
                  border: Border.all(color: sel ? Colors.white : Colors.transparent,
                    width: sel ? 3 : 0)),
                child: sel ? const Icon(Icons.check, color: Colors.white) : null));
          })),
        const SizedBox(height: 16),
        _label('Kullanici Adi'),
        _field(_username, Icons.person),
        const SizedBox(height: 16),
        _label('Biyografi'),
        _field(_bio, Icons.description, maxLines: 3),
        const SizedBox(height: 16),
        _label('Cinsiyet'),
        Row(children: [
          Expanded(child: _genderBtn('Erkek', 'male', Icons.male)),
          const SizedBox(width: 8),
          Expanded(child: _genderBtn('Kadin', 'female', Icons.female)),
          const SizedBox(width: 8),
          Expanded(child: _genderBtn('Diger', 'other', Icons.transgender)),
        ]),
        const SizedBox(height: 16),
        _label('Yas: $_age'),
        Container(decoration: _boxDeco(), child: Slider(
          value: _age.toDouble(), min: 13, max: 99, divisions: 86,
          activeColor: const Color(0xFFFFC107), label: '$_age',
          onChanged: (v) => setState(() => _age = v.round()))),
        const SizedBox(height: 16),
        _label('Ulke'),
        SizedBox(height: 50, child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _countries.length,
          itemBuilder: (_, i) {
            final c = _countries[i];
            final sel = _country == c;
            return GestureDetector(
              onTap: () => setState(() => _country = c),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: sel ? const Color(0xFFFFC107) : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: sel ? Colors.white : Colors.white24)),
                child: Center(child: Text(c, style: TextStyle(
                  color: sel ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold)))));
          })),
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

  List<Color> _frameColors(String f) {
    final m = {
      'none': [Colors.grey, Colors.grey],
      'gold': [const Color(0xFFFFD700), const Color(0xFFFF8C00)],
      'purple': [const Color(0xFF9C27B0), const Color(0xFF6A1B9A)],
      'neon': [const Color(0xFF00E5FF), const Color(0xFF00B8D4)],
      'fire': [const Color(0xFFFF6B35), const Color(0xFFD32F2F)],
      'ice': [const Color(0xFF80DEEA), const Color(0xFF0277BD)],
      'rainbow': [const Color(0xFFFF1744), const Color(0xFFFFC107)],
    };
    return m[f] ?? [Colors.grey, Colors.grey];
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
      decoration: InputDecoration(border: InputBorder.none,
        contentPadding: const EdgeInsets.all(16),
        prefixIcon: Icon(i, color: const Color(0xFFFFC107)))));

  BoxDecoration _boxDeco() => BoxDecoration(
    color: Colors.white.withOpacity(0.05),
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: Colors.white.withOpacity(0.1)));

  Widget _genderBtn(String t, String v, IconData i) {
    final sel = _gender == v;
    return GestureDetector(
      onTap: () => setState(() => _gender = v),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: sel ? const Color(0xFFFFC107) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: sel ? Colors.white : Colors.white24)),
        child: Column(children: [
          Icon(i, color: sel ? Colors.black : Colors.white, size: 22),
          const SizedBox(height: 4),
          Text(t, style: TextStyle(color: sel ? Colors.black : Colors.white,
            fontSize: 11, fontWeight: FontWeight.bold))])));
  }
}
