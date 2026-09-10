import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/api.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _email = TextEditingController();
  final _user = TextEditingController();
  final _pass = TextEditingController();
  final _invite = TextEditingController();
  bool _register = false;
  bool _loading = false;
  bool _showPass = false;
  late AnimationController _floatCtrl;
  late AnimationController _glowCtrl;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
    _glowCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _glowCtrl.dispose();
    _email.dispose(); _user.dispose(); _pass.dispose(); _invite.dispose();
    super.dispose();
  }

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
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Hata: ' + e.toString()),
        backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _deco(String label, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
      prefixIcon: Icon(icon, color: const Color(0xFFFFC107), size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFFFC107), width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
      ),
    );
  }

  Widget _decorCircle(double size, Color color, double opacity) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [
          color.withOpacity(opacity),
          color.withOpacity(0),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        // Arka plan gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0A0E27), Color(0xFF1A0F3E), Color(0xFF0A0E27)],
            ),
          ),
        ),
        // Dekoratif daireler
        AnimatedBuilder(
          animation: _floatCtrl,
          builder: (_, __) {
            final t = _floatCtrl.value * 2 * math.pi;
            return Stack(children: [
              Positioned(
                left: -80 + 20 * math.sin(t),
                top: -60 + 15 * math.cos(t),
                child: _decorCircle(240, const Color(0xFFFFC107), 0.15),
              ),
              Positioned(
                right: -100 + 25 * math.cos(t),
                top: 200 + 20 * math.sin(t),
                child: _decorCircle(280, const Color(0xFFE91E63), 0.12),
              ),
              Positioned(
                left: 100 + 15 * math.cos(t * 1.3),
                bottom: -100 + 20 * math.sin(t),
                child: _decorCircle(220, const Color(0xFF9C27B0), 0.15),
              ),
            ]);
          },
        ),
        // Icerik
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              const SizedBox(height: 40),
              // Glow logo
              AnimatedBuilder(
                animation: _glowCtrl,
                builder: (_, __) {
                  final glow = 20 + _glowCtrl.value * 25;
                  return Container(
                    width: 110, height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFFFC107), Color(0xFFFF6B35)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFC107).withOpacity(0.5),
                          blurRadius: glow,
                          spreadRadius: glow / 8,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('H',
                        style: TextStyle(color: Colors.black,
                          fontSize: 60, fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              // Baslik
              ShaderMask(
                shaderCallback: (r) => const LinearGradient(
                  colors: [Color(0xFFFFC107), Color(0xFFFF6B35), Color(0xFFFFC107)],
                ).createShader(r),
                child: const Text('HayiDev',
                  style: TextStyle(color: Colors.white,
                    fontSize: 46, fontWeight: FontWeight.bold, letterSpacing: -1)),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFFFC107).withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('SESLI SOHBET & OYUN',
                  style: TextStyle(color: Color(0xFFFFC107),
                    fontSize: 10, letterSpacing: 3, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 36),
              // Tab secici
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(children: [
                  Expanded(child: GestureDetector(
                    onTap: () => setState(() => _register = false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: !_register ? const LinearGradient(
                          colors: [Color(0xFFFFC107), Color(0xFFFF6B35)]) : null,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(child: Text('GIRIS YAP',
                        style: TextStyle(
                          color: !_register ? Colors.black : Colors.white60,
                          fontWeight: FontWeight.bold, fontSize: 13))),
                    ),
                  )),
                  Expanded(child: GestureDetector(
                    onTap: () => setState(() => _register = true),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: _register ? const LinearGradient(
                          colors: [Color(0xFFFFC107), Color(0xFFFF6B35)]) : null,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(child: Text('KAYIT OL',
                        style: TextStyle(
                          color: _register ? Colors.black : Colors.white60,
                          fontWeight: FontWeight.bold, fontSize: 13))),
                    ),
                  )),
                ]),
              ),
              const SizedBox(height: 24),
              // Form
              if (_register) ...[
                TextField(controller: _email, style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                  decoration: _deco('E-posta', Icons.email_outlined)),
                const SizedBox(height: 14),
              ],
              TextField(controller: _user, style: const TextStyle(color: Colors.white),
                decoration: _deco(_register ? 'Kullanici Adi' : 'E-posta / Kullanici Adi', Icons.person_outline)),
              const SizedBox(height: 14),
              TextField(controller: _pass, obscureText: !_showPass,
                style: const TextStyle(color: Colors.white),
                decoration: _deco('Sifre', Icons.lock_outline,
                  suffix: IconButton(
                    icon: Icon(_showPass ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white54, size: 20),
                    onPressed: () => setState(() => _showPass = !_showPass),
                  ))),
              if (_register) ...[
                const SizedBox(height: 14),
                TextField(controller: _invite, style: const TextStyle(color: Colors.white),
                  decoration: _deco('Davet Kodu (opsiyonel)', Icons.card_giftcard)),
              ],
              const SizedBox(height: 28),
              // Submit butonu
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFC107).withOpacity(0.4),
                      blurRadius: 20, offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: SizedBox(width: double.infinity, height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: _loading ? null : _submit,
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFC107), Color(0xFFFF6B35)]),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: _loading
                          ? const SizedBox(width: 24, height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.black, strokeWidth: 2.5))
                          : Text(_register ? 'KAYIT OL' : 'GIRIS YAP',
                              style: const TextStyle(color: Colors.black,
                                fontWeight: FontWeight.bold, fontSize: 16,
                                letterSpacing: 1.5)),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Alt yazi
              TextButton(
                onPressed: () => setState(() => _register = !_register),
                child: Text(
                  _register ? 'Hesabin var mi? Giris yap' : 'Hesabin yok mu? Kayit ol',
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ),
              const SizedBox(height: 40),
            ]),
          ),
        ),
      ]),
    );
  }
}
