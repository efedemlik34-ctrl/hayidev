import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../services/api.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});
  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> with TickerProviderStateMixin {
  Map<String, dynamic>? _data;
  int _tab = 0;
  String _category = 'coins';
  bool _loading = true;
  final _iap = InAppPurchase.instance;
  Map<String, ProductDetails> _iapProducts = {};
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  int _balance = 0;
  int _diamonds = 0;

  final List<Map<String, dynamic>> _categories = const [
    {'key': 'coins', 'name': 'Coin', 'icon': '🪙'},
    {'key': 'diamonds', 'name': 'Elmas', 'icon': '💠'},
    {'key': 'vip', 'name': 'VIP', 'icon': '👑'},
    {'key': 'frames', 'name': 'Cerceve', 'icon': '🥇'},
    {'key': 'starter', 'name': 'Baslangic', 'icon': '🎁'},
    {'key': 'battle_pass', 'name': 'Sezon', 'icon': '🎫'},
  ];

  @override
  void initState() {
    super.initState();
    _load();
    _initIAP();
  }

  @override
  void dispose() {
    _purchaseSub?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final r = await Api.dio.get('/shop/products');
      final u = await Api.dio.get('/user/me');
      setState(() {
        _data = r.data;
        _balance = u.data['balance'] ?? 0;
        _diamonds = u.data['diamonds'] ?? 0;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
    }
  }

  Future<void> _initIAP() async {
    try {
      final available = await _iap.isAvailable();
      if (!available) return;

      _purchaseSub = _iap.purchaseStream.listen(_onPurchase);
      await _loadStoreProducts();
    } catch (e) {
      debugPrint('IAP init: $e');
    }
  }

  Future<void> _loadStoreProducts() async {
    try {
      final r = await Api.dio.get('/shop/products');
      final all = <String>[];
      final cats = r.data['categories'] as Map;
      cats.forEach((_, list) {
        for (final p in list) all.add(p['key']);
      });

      final response = await _iap.queryProductDetails(all.toSet());
      final map = <String, ProductDetails>{};
      for (final p in response.productDetails) map[p.id] = p;
      setState(() => _iapProducts = map);
    } catch (e) {
      debugPrint('Query products: $e');
    }
  }

  Future<void> _onPurchase(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      try {
        if (p.status == PurchaseStatus.purchased || p.status == PurchaseStatus.restored) {
          final order = await Api.dio.post('/shop/create-order',
            data: {'productKey': p.productID, 'platform': p.verificationData.source});
          final verifyPath = p.verificationData.source == 'app_store'
            ? '/shop/verify/apple' : '/shop/verify/google';
          await Api.dio.post(verifyPath, data: {
            'productKey': p.productID,
            if (p.verificationData.source == 'app_store')
              'receiptData': p.verificationData.serverVerificationData
            else
              'purchaseToken': p.verificationData.serverVerificationData,
            'orderId': order.data['orderId'],
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Satin alma basarili!'), backgroundColor: Colors.green));
          }
          _load();
        }
        if (p.status == PurchaseStatus.error) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hata: ${p.error?.message}'), backgroundColor: Colors.red));
        }
        if (p.pendingCompletePurchase) await _iap.completePurchase(p);
      } catch (e) {
        debugPrint('Purchase error: $e');
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dogrulama hatasi: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _buy(Map<String, dynamic> product) async {
    final key = product['key'] as String;
    final pd = _iapProducts[key];
    if (pd == null) {
      // IAP urunu bulunamadi — devam et mock
      try {
        final order = await Api.dio.post('/shop/create-order', data: {'productKey': key});
        await Api.dio.post('/shop/verify/google', data: {
          'productKey': key,
          'purchaseToken': 'mock_${DateTime.now().millisecondsSinceEpoch}',
          'orderId': order.data['orderId'],
        });
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Test modu: urun verildi!'), backgroundColor: Colors.green));
        _load();
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red));
      }
      return;
    }
    final param = PurchaseParam(productDetails: pd);
    await _iap.buyConsumable(purchaseParam: param, autoConsume: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFC107)))
        : SafeArea(child: Column(children: [
          _header(),
          _tabBar(),
          Expanded(child: ListView(children: [
            _balanceCard(),
            const SizedBox(height: 12),
            _campaignBanner(),
            const SizedBox(height: 12),
            _productGrid(),
            const SizedBox(height: 30),
          ])),
        ])),
    );
  }

  Widget _header() => Padding(
    padding: const EdgeInsets.all(16),
    child: Row(children: [
      const Text('Magaza', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
      const Spacer(),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white10, borderRadius: BorderRadius.circular(20)),
        child: Row(children: [
          const Text('🪙 ', style: TextStyle(fontSize: 14)),
          Text('$_balance', style: const TextStyle(color: Color(0xFFFFC107), fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(width: 10),
          const Text('💠 ', style: TextStyle(fontSize: 14)),
          Text('$_diamonds', style: const TextStyle(color: Color(0xFF4FC3F7), fontWeight: FontWeight.bold, fontSize: 13)),
        ]),
      ),
    ]),
  );

  Widget _tabBar() => SizedBox(
    height: 50,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: _categories.length,
      itemBuilder: (_, i) {
        final c = _categories[i];
        final selected = _category == c['key'];
        return GestureDetector(
          onTap: () => setState(() => _category = c['key'] as String),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: selected ? const LinearGradient(colors: [Color(0xFFFFC107), Color(0xFFFF6B35)]) : null,
              color: selected ? null : Colors.white10,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(children: [
              Text(c['icon'] as String, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(c['name'] as String,
                style: TextStyle(color: selected ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold, fontSize: 12)),
            ]),
          ),
        );
      },
    ),
  );

  Widget _balanceCard() => Container(
    margin: const EdgeInsets.all(16),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFFB8860B), Color(0xFFDAA520), Color(0xFFFFD700)]),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: const Color(0xFFFFC107).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
    ),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('TOPLAM BAKIYE', style: TextStyle(color: Colors.black54, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text('🪙 $_balance', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        Text('💠 $_diamonds elmas', style: const TextStyle(color: Colors.black54, fontSize: 13)),
      ])),
      const Text('💰', style: TextStyle(fontSize: 64)),
    ]),
  );

  Widget _campaignBanner() {
    final campaigns = _data?['campaigns'] as List? ?? [];
    if (campaigns.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFE91E63), Color(0xFF9C27B0)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        const Text('🎉', style: TextStyle(fontSize: 32)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(campaigns[0]['name'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          Text('+${campaigns[0]['bonus_percent'] ?? 0}% bonus', style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ])),
      ]),
    );
  }

  Widget _productGrid() {
    final categories = _data?['categories'] as Map? ?? {};
    final products = categories[_category] as List? ?? [];
    if (products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: Text('Bu kategoride urun yok', style: TextStyle(color: Colors.white54))),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
        children: products.map((p) => _productCard(p)).toList(),
      ),
    );
  }

  Widget _productCard(Map<String, dynamic> p) {
    final badge = p['badge'];
    final colors = _colorForCategory(p['category'] as String? ?? 'coins');
    return GestureDetector(
      onTap: () => _buy(p),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [colors[0].withOpacity(0.3), colors[1].withOpacity(0.1)]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors[0].withOpacity(0.6), width: 2),
          boxShadow: [BoxShadow(color: colors[0].withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Stack(children: [
          if (badge != null)
            Positioned(top: 8, right: 8, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFFC107), Color(0xFFFF6B35)]),
                borderRadius: BorderRadius.circular(8)),
              child: Text(badge, style: const TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold)),
            )),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(p['icon'] ?? '🪙', style: const TextStyle(fontSize: 48)),
                const SizedBox(height: 8),
                Text(p['name'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const SizedBox(height: 4),
                if ((p['coins'] ?? 0) > 0)
                  Text('🪙 ${_fmt(p['coins'])}', style: const TextStyle(color: Color(0xFFFFC107), fontSize: 12, fontWeight: FontWeight.bold)),
                if ((p['diamonds'] ?? 0) > 0)
                  Text('💠 ${p['diamonds']}', style: const TextStyle(color: Color(0xFF4FC3F7), fontSize: 12, fontWeight: FontWeight.bold)),
                if ((p['vip_days'] ?? 0) > 0)
                  Text('${p['vip_days']} gun VIP', style: const TextStyle(color: Color(0xFF9C27B0), fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colors[0])),
                  child: Text('₺${(p['price_tl'] as num).toStringAsFixed(2)}',
                    style: TextStyle(color: colors[0], fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  List<Color> _colorForCategory(String cat) {
    switch (cat) {
      case 'coins': return [const Color(0xFFFFC107), const Color(0xFFFF6B35)];
      case 'diamonds': return [const Color(0xFF4FC3F7), const Color(0xFF2196F3)];
      case 'vip': return [const Color(0xFF9C27B0), const Color(0xFFE91E63)];
      case 'frames': return [const Color(0xFF4CAF50), const Color(0xFF8BC34A)];
      case 'starter': return [const Color(0xFFFF6B35), const Color(0xFFE91E63)];
      case 'battle_pass': return [const Color(0xFF3F51B5), const Color(0xFF673AB7)];
      default: return [const Color(0xFFFFC107), const Color(0xFFFF6B35)];
    }
  }

  String _fmt(dynamic n) {
    final v = int.parse(n.toString());
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toString();
  }
}
