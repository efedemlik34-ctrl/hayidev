import 'package:flutter/material.dart';
import '../services/api.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  Map<String, dynamic>? _user;
  int _tab = 0;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final r = await Api.dio.get('/user/me');
      setState(() => _user = r.data);
    } catch (e) { debugPrint(e.toString()); }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) return const Scaffold(
      body: Center(child: CircularProgressIndicator(color: Color(0xFFFFC107))));
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        title: const Text('Cuzdan'),
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: ListView(children: [
        // Tabs
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(children: [
            _tabBtn('Altin para', 0),
            _tabBtn('Elmas', 1),
            _tabBtn('Oyun Paralari', 2),
            _tabBtn('Sansli Paral...', 3),
          ]),
        ),
        const SizedBox(height: 8),
        // Bakiye karti
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFFB8860B), Color(0xFFDAA520), Color(0xFFFFD700)]),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: const Color(0xFFFFC107).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8)),
            ],
          ),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Text('Benim Param',
                  style: TextStyle(color: Colors.black54, fontSize: 13)),
                const SizedBox(width: 6),
                Icon(Icons.help_outline, color: Colors.black.withOpacity(0.5), size: 14),
              ]),
              const SizedBox(height: 8),
              Text(_user!['balance'].toString(),
                style: const TextStyle(color: Colors.white,
                  fontSize: 38, fontWeight: FontWeight.bold)),
            ])),
            Text('🪙', style: TextStyle(fontSize: 72)),
          ]),
        ),
        const SizedBox(height: 20),
        // Gunluk sarj odulleri
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Text('Gunluk Sarj Odulleri',
                style: TextStyle(color: Colors.white,
                  fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35),
                  borderRadius: BorderRadius.circular(8)),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.access_time, color: Colors.white, size: 11),
                  SizedBox(width: 4),
                  Text('12 : 17 : 20', style: TextStyle(color: Colors.white, fontSize: 10)),
                ]),
              ),
            ]),
            const SizedBox(height: 14),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _rewardStep('50K', false),
              _rewardStep('50K', false),
              _rewardStep('100K', false),
              _rewardStep('200K', false),
              _rewardStep('500K', false),
            ]),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              _progressLabel('0/1M'),
              _progressLabel('2M'),
              _progressLabel('3M'),
              _progressLabel('5M'),
              _progressLabel('10M'),
            ]),
          ]),
        ),
        const SizedBox(height: 20),
        // Yukleme yontemi
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            const Text('Yukleme yontemi',
              style: TextStyle(color: Colors.white, fontSize: 15)),
            const Spacer(),
            const Text('Turkiye', style: TextStyle(color: Colors.white70, fontSize: 13)),
            const Icon(Icons.arrow_drop_down, color: Colors.white70),
          ]),
        ),
        const SizedBox(height: 10),
        _payMethod('Tuccar gemisi', Icons.directions_boat),
        _payMethod('Visa/Master Card', Icons.credit_card, extra: 'visa_mc'),
        _payMethod('Visa/Master Card', Icons.credit_card, extra: 'visa_amex'),
        _payMethod('Google Wallet', Icons.account_balance_wallet),
        const SizedBox(height: 30),
      ]),
    );
  }

  Widget _tabBtn(String label, int index) {
    return Expanded(child: GestureDetector(
      onTap: () => setState(() => _tab = index),
      child: Column(children: [
        Text(label,
          style: TextStyle(
            color: _tab == index ? Colors.white : Colors.white38,
            fontSize: 12, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Container(height: 2,
          color: _tab == index ? const Color(0xFFFFC107) : Colors.transparent),
      ]),
    ));
  }

  Widget _rewardStep(String value, bool done) {
    return Column(children: [
      Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
          color: done ? const Color(0xFFFFC107).withOpacity(0.3) : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: done ? const Color(0xFFFFC107) : Colors.white.withOpacity(0.1)),
        ),
        child: const Center(child: Text('🪙', style: TextStyle(fontSize: 20))),
      ),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(color: done ? Colors.white : Colors.white54, fontSize: 9)),
    ]);
  }

  Widget _progressLabel(String s) => Text(s,
    style: const TextStyle(color: Colors.white54, fontSize: 9));

  Widget _payMethod(String label, IconData icon, {String? extra}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(children: [
        Icon(icon, color: const Color(0xFFFFC107), size: 22),
        const SizedBox(width: 14),
        Expanded(child: Text(label,
          style: const TextStyle(color: Colors.white, fontSize: 14))),
        const Icon(Icons.chevron_right, color: Colors.white38),
      ]),
    );
  }
}
