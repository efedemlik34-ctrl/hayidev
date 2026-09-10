import 'package:flutter/material.dart';
import '../services/api.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _user = TextEditingController();
  final _pass = TextEditingController();
  final _invite = TextEditingController();
  bool _register = false;
  bool _loading = false;

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      final url = _register ? '/auth/register' : '/auth/login';
      final data = _register
        ? {'email': _email.text, 'username': _user.text, 'password': _pass.text}
        : {'identifier': _user.text, 'password': _pass.text};
      final r = await Api.dio.post(url, data: data);
      await Api.setToken(r.data['token']);
      if (_register && _invite.text.isNotEmpty) {
        try { await Api.dio.post('/invite/apply', data: {'code': _invite.text}); } catch (_) {}
      }
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: ' + e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration dec(String l) => InputDecoration(
    labelText: l,
    labelStyle: const TextStyle(color: Colors.white70),
    filled: true,
    fillColor: Colors.white10,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(children: [
        const SizedBox(height: 60),
        const Text('HayiDev', style: TextStyle(color: Color(0xFFFFC107), fontSize: 48, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text('25 SISTEM', style: TextStyle(color: Color(0xFFFFC107), fontSize: 11, letterSpacing: 3)),
        const SizedBox(height: 40),
        if (_register) TextField(controller: _email, decoration: dec('E-posta'), style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 12),
        TextField(controller: _user, decoration: dec(_register ? 'Kullanici Adi' : 'E-posta / Kullanici Adi'), style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 12),
        TextField(controller: _pass, obscureText: true, decoration: dec('Sifre'), style: const TextStyle(color: Colors.white)),
        if (_register) ...[
          const SizedBox(height: 12),
          TextField(controller: _invite, decoration: dec('Davet Kodu'), style: const TextStyle(color: Colors.white)),
        ],
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, height: 52, child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFC107), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          onPressed: _loading ? null : _submit,
          child: Text(_register ? 'KAYIT OL' : 'GIRIS YAP', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
        )),
        TextButton(onPressed: () => setState(() => _register = !_register),
          child: Text(_register ? 'Hesabin var mi?' : 'Kayit ol', style: const TextStyle(color: Colors.white70))),
      ]))),
    );
  }
}
