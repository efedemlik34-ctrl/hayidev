import 'package:flutter/material.dart';
import '../services/api.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  final _code = TextEditingController();
  final _pass = TextEditingController();
  int _step = 0;
  bool _loading = false;

  Future<void> _sendCode() async {
    if (_email.text.isEmpty) return;
    setState(() => _loading = true);
    try {
      await Api.dio.post('/auth/forgot-password', data: {'email': _email.text});
      setState(() => _step = 1);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kod gonderildi')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally { setState(() => _loading = false); }
  }

  Future<void> _reset() async {
    setState(() => _loading = true);
    try {
      await Api.dio.post('/auth/reset-password', data: {
        'email': _email.text, 'code': _code.text, 'newPassword': _pass.text,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sifre degistirildi')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally { setState(() => _loading = false); }
  }

  InputDecoration _deco(String l) => InputDecoration(
    labelText: l, labelStyle: const TextStyle(color: Colors.white70),
    filled: true, fillColor: Colors.white10,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(title: const Text('Sifremi Unuttum'), backgroundColor: Colors.transparent),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          const SizedBox(height: 40),
          const Icon(Icons.lock_reset, color: Color(0xFFFFC107), size: 80),
          const SizedBox(height: 20),
          TextField(controller: _email, style: const TextStyle(color: Colors.white),
            decoration: _deco('E-posta'), keyboardType: TextInputType.emailAddress),
          if (_step == 1) ...[
            const SizedBox(height: 12),
            TextField(controller: _code, style: const TextStyle(color: Colors.white),
              decoration: _deco('Kod'), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            TextField(controller: _pass, obscureText: true, style: const TextStyle(color: Colors.white),
              decoration: _deco('Yeni Sifre')),
          ],
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFC107)),
              onPressed: _loading ? null : (_step == 0 ? _sendCode : _reset),
              child: Text(_step == 0 ? 'KOD GONDER' : 'SIFREYI DEGISTIR',
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)),
            )),
        ]),
      ),
    );
  }
}
