import 'package:flutter/material.dart';
import '../services/api.dart';

class ReportScreen extends StatefulWidget {
  final int? targetUserId;
  const ReportScreen({super.key, this.targetUserId});
  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String _type = 'abuse';
  final _msg = TextEditingController();
  bool _loading = false;

  final _types = {
    'harassment': 'Taciz / Kufur',
    'spam': 'Spam / Reklam',
    'cheat': 'Hile',
    'abuse': 'Kotu Kullanim',
    'minor': '18 Yas Alti',
    'other': 'Diger',
  };

  Future<void> _submit() async {
    if (widget.targetUserId == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hedef kullanici yok')));
      return;
    }
    setState(() => _loading = true);
    try {
      await Api.dio.post('/reports', data: {
        'reported': widget.targetUserId,
        'type': _type,
        'message': _msg.text,
      });
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sikayet gonderildi')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(title: const Text('Sikayet Et'), backgroundColor: Colors.transparent),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const Text('Sikayet Sebebi', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ..._types.entries.map((e) => RadioListTile<String>(
          value: e.key,
          groupValue: _type,
          onChanged: (v) => setState(() => _type = v!),
          title: Text(e.value, style: const TextStyle(color: Colors.white)),
          activeColor: const Color(0xFFFFC107),
        )),
        const SizedBox(height: 20),
        const Text('Detay (opsiyonel)', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: _msg,
          maxLines: 4,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Ne oldu?',
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true, fillColor: Colors.white10,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(height: 54, child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          onPressed: _loading ? null : _submit,
          child: Text(_loading ? 'GONDERILIYOR...' : 'GONDER', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        )),
      ]),
    );
  }
}
