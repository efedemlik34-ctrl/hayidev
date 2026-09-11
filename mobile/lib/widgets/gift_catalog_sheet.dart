import 'package:flutter/material.dart';
import '../services/api.dart';
import '../services/local_db.dart';
import 'app_theme.dart';
import 'gift_data.dart';
import 'premium_gift_animation.dart';

class GiftCatalogSheet extends StatefulWidget {
  final int roomId;
  final int? receiverId;
  final String? receiverName;
  final int balance;
  const GiftCatalogSheet({super.key, required this.roomId,
    this.receiverId, this.receiverName, required this.balance});
  @override
  State<GiftCatalogSheet> createState() => _GiftCatalogSheetState();
}

class _GiftCatalogSheetState extends State<GiftCatalogSheet>
    with TickerProviderStateMixin {
  late TabController _tabs;
  String _cat = 'hediye';
  GiftItem? _sel;
  int _qty = 1;
  int _myBal = 0;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: GiftCategories.categories.length, vsync: this);
    _tabs.addListener(_onTab);
    _myBal = LocalDB.getBalance() > 0 ? LocalDB.getBalance() : widget.balance;
  }

  void _onTab() {
    if (_tabs.indexIsChanging) return;
    setState(() {
      _cat = GiftCategories.categories[_tabs.index]['key']!;
      _sel = null;
    });
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  Future<void> _send() async {
    if (_sel == null) return;
    final total = _sel!.price * _qty;
    if (total > _myBal) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Yetersiz bakiye'), backgroundColor: AppColors.red));
      return;
    }
    setState(() => _sending = true);
    try {
      await Api.dio.post('/gifts/send', data: {
        'receiverId': widget.receiverId ?? 1,
        'giftKey': _sel!.key,
        'quantity': _qty,
        'roomId': widget.roomId});
      if (mounted) { Navigator.pop(context); _showAnim(); }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e'), backgroundColor: AppColors.red));
    } finally { if (mounted) setState(() => _sending = false); }
  }

  void _showAnim() {
    final ov = Overlay.of(context);
    late OverlayEntry e;
    e = OverlayEntry(builder: (_) => PremiumGiftAnimation(
      gift: _sel!,
      senderName: LocalDB.getUser()['username'] ?? 'Sen',
      receiverName: widget.receiverName ?? 'Oda',
      quantity: _qty,
      onComplete: () => e.remove()));
    ov.insert(e);
  }

  String _short(int n) {
    if (n >= 1e6) return (n / 1e6).toStringAsFixed(1) + 'M';
    if (n >= 1e3) return (n / 1e3).toStringAsFixed(1) + 'K';
    return n.toString();
  }

  String _emoji(String k) {
    if (k.contains('pasta')) return '🎂';
    if (k.contains('yildiz')) return '⭐';
    if (k.contains('can')) return '🔔';
    if (k.contains('sandik')) return '🎁';
    if (k.contains('araba')) return '🏎️';
    if (k.contains('balloon')) return '🎈';
    if (k.contains('rose')) return '🌹';
    if (k.contains('heart')) return '❤️';
    if (k.contains('crown') || k.contains('king')) return '👑';
    if (k.contains('castle')) return '🏰';
    if (k.contains('dragon')) return '🐉';
    if (k.contains('phoenix')) return '🔥';
    if (k.contains('lion')) return '🦁';
    if (k.contains('galaxy') || k.contains('universe')) return '🌌';
    if (k.contains('ring')) return '💍';
    if (k.contains('teddy')) return '🧸';
    return '🎁';
  }

  @override
  Widget build(BuildContext context) {
    final gifts = GiftCategories.byCategory(_cat);
    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [AppColors.bgCard, AppColors.bgDark]),
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl))),
      child: Column(children: [
        Container(margin: const EdgeInsets.only(top: 10),
          width: 40, height: 4,
          decoration: BoxDecoration(color: Colors.white24,
            borderRadius: BorderRadius.circular(2))),
        Container(margin: const EdgeInsets.symmetric(vertical: 12),
          child: TabBar(controller: _tabs, isScrollable: true,
            labelColor: Colors.white, unselectedLabelColor: Colors.white54,
            indicatorColor: AppColors.gold, indicatorWeight: 3,
            tabs: GiftCategories.categories.map((c) =>
              Tab(text: c['name'])).toList())),
        Expanded(child: GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, mainAxisSpacing: 8, crossAxisSpacing: 8,
            childAspectRatio: 0.78),
          itemCount: gifts.length,
          itemBuilder: (_, i) => _tile(gifts[i]))),
        _bottomBar(),
      ]),
    );
  }

  Widget _tile(GiftItem g) {
    final sel = _sel?.key == g.key;
    return GestureDetector(
      onTap: () => setState(() => _sel = g),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: sel
            ? AppColors.goldGradient
            : const LinearGradient(colors: [AppColors.bgCard, AppColors.bgCard2]),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: sel ? Colors.white :
            AppColors.gold.withOpacity(0.2), width: sel ? 2 : 1),
          boxShadow: sel ? [BoxShadow(color: AppColors.gold.withOpacity(0.6),
            blurRadius: 12, spreadRadius: 1)] : null),
        child: Stack(children: [
          if (g.isJackpot) Positioned(top: 2, left: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [
                  Color(0xFFFF5252), Color(0xFFFF1744)]),
                borderRadius: BorderRadius.circular(4)),
              child: const Text('JACKPOT', style: TextStyle(
                color: Colors.white, fontSize: 6,
                fontWeight: FontWeight.bold)))),
          Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: Center(child: Image.asset(g.imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Text(_emoji(g.key),
                    style: const TextStyle(fontSize: 34))))),
                const SizedBox(height: 4),
                Text(g.name, textAlign: TextAlign.center,
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: sel ? Colors.black : Colors.white,
                    fontSize: 8, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                if (g.isFree)
                  Text('Ucretsiz', style: TextStyle(
                    color: sel ? Colors.black87 : AppColors.green,
                    fontSize: 8, fontWeight: FontWeight.bold))
                else Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.monetization_on,
                    color: sel ? Colors.black : AppColors.gold, size: 9),
                  const SizedBox(width: 2),
                  FittedBox(child: Text(_short(g.price), style: TextStyle(
                    color: sel ? Colors.black : AppColors.gold,
                    fontSize: 9, fontWeight: FontWeight.bold))),
                ]),
              ])),
        ]),
      ),
    );
  }

  Widget _bottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.bgCard2,
        border: Border(top: BorderSide(color: Colors.white12))),
      child: SafeArea(top: false, child: Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            gradient: AppColors.goldGradient,
            borderRadius: BorderRadius.circular(AppRadius.xl)),
          child: Row(children: [
            const Icon(Icons.monetization_on, color: Colors.black, size: 14),
            const SizedBox(width: 4),
            FittedBox(child: Text(_short(_myBal), style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12))),
          ])),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: Colors.white24)),
          child: Row(children: [
            IconButton(
              icon: const Icon(Icons.remove, color: Colors.white70, size: 16),
              onPressed: () => setState(() => _qty = _qty > 1 ? _qty - 1 : 1),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              padding: EdgeInsets.zero),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text('$_qty', style: const TextStyle(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white70, size: 16),
              onPressed: () => setState(() => _qty = _qty < 99 ? _qty + 1 : 99),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              padding: EdgeInsets.zero),
          ])),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _sel == null || _sending ? null : _send,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: _sel == null
                ? LinearGradient(colors: [Colors.grey.shade800, Colors.grey.shade900])
                : AppColors.goldGradient,
              borderRadius: BorderRadius.circular(AppRadius.xl)),
            child: Text(_sending ? '...' : 'Gonder', style: TextStyle(
              color: _sel == null ? Colors.white38 : Colors.black,
              fontWeight: FontWeight.bold, fontSize: 13))),
        ),
      ])),
    );
  }
}
