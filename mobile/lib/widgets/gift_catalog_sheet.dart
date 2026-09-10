import 'package:flutter/material.dart';
import '../services/api.dart';
import '../services/local_db.dart';
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
  String _category = 'hediye';
  GiftItem? _selected;
  int _quantity = 1;
  int _myBalance = 0;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: GiftCategories.categories.length, vsync: this);
    _tabs.addListener(_onTab);
    _myBalance = LocalDB.getBalance() > 0 ? LocalDB.getBalance() : widget.balance;
  }

  void _onTab() {
    if (_tabs.indexIsChanging) return;
    setState(() {
      _category = GiftCategories.categories[_tabs.index]['key']!;
      _selected = null;
    });
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  int get _total => _selected == null ? 0 : _selected!.price * _quantity;

  Future<void> _send() async {
    if (_selected == null) return;
    if (_total > _myBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yetersiz bakiye'), backgroundColor: Colors.red));
      return;
    }
    setState(() => _sending = true);
    try {
      await Api.dio.post('/gifts/send', data: {
        'receiverId': widget.receiverId ?? 1,
        'giftKey': _selected!.key,
        'quantity': _quantity,
        'roomId': widget.roomId,
      });
      if (mounted) {
        Navigator.pop(context);
        _showGiftAnimation();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e'), backgroundColor: Colors.red));
    } finally { if (mounted) setState(() => _sending = false); }
  }

  void _showGiftAnimation() {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(builder: (_) => PremiumGiftAnimation(
      gift: _selected!,
      senderName: LocalDB.getUser()['username'] ?? 'Sen',
      receiverName: widget.receiverName ?? 'Oda',
      quantity: _quantity,
      onComplete: () => entry.remove()));
    overlay.insert(entry);
  }

  @override
  Widget build(BuildContext context) {
    final gifts = GiftCategories.byCategory(_category);
    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFF1A0F3E), Color(0xFF0A0E27)]),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(children: [
        Container(margin: const EdgeInsets.only(top: 10),
          width: 40, height: 4,
          decoration: BoxDecoration(color: Colors.white24,
            borderRadius: BorderRadius.circular(2))),
        Container(margin: const EdgeInsets.symmetric(vertical: 12),
          child: TabBar(controller: _tabs, isScrollable: true,
            labelColor: Colors.white, unselectedLabelColor: Colors.white54,
            indicatorColor: const Color(0xFFFFC107), indicatorWeight: 3,
            tabs: GiftCategories.categories.map((c) =>
              Tab(text: c['name'])).toList())),
        Expanded(child: GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, mainAxisSpacing: 8, crossAxisSpacing: 8,
            childAspectRatio: 0.78),
          itemCount: gifts.length,
          itemBuilder: (_, i) => _giftTile(gifts[i]))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: const BoxDecoration(
            color: Color(0xFF0F0A2E),
            border: Border(top: BorderSide(color: Colors.white12))),
          child: SafeArea(top: false, child: Row(children: [
            Container(padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [
                  Color(0xFFFFC107), Color(0xFFFF8C00)]),
                borderRadius: BorderRadius.circular(20)),
              child: Row(children: [
                const Icon(Icons.monetization_on, color: Colors.black, size: 14),
                const SizedBox(width: 4),
                Text('$_myBalance', style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, color: Colors.black, size: 14),
              ])),
            const SizedBox(width: 8),
            Container(padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC107).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFFFC107).withOpacity(0.4))),
              child: const Row(children: [
                Icon(Icons.workspace_premium, color: Color(0xFFFFC107), size: 12),
                SizedBox(width: 4),
                Text('Join', style: TextStyle(color: Color(0xFFFFC107),
                  fontWeight: FontWeight.bold, fontSize: 11)),
              ])),
            const Spacer(),
            Container(decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24)),
              child: Row(children: [
                IconButton(icon: const Icon(Icons.remove, color: Colors.white70, size: 16),
                  onPressed: () => setState(() => _quantity = _quantity > 1 ? _quantity - 1 : 1),
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: EdgeInsets.zero),
                Container(padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('$_quantity', style: const TextStyle(
                    color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))),
                IconButton(icon: const Icon(Icons.add, color: Colors.white70, size: 16),
                  onPressed: () => setState(() => _quantity = _quantity < 99 ? _quantity + 1 : 99),
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: EdgeInsets.zero),
              ])),
            const SizedBox(width: 8),
            GestureDetector(onTap: _selected == null || _sending ? null : _send,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: _selected == null
                    ? LinearGradient(colors: [Colors.grey.shade800, Colors.grey.shade900])
                    : const LinearGradient(colors: [
                        Color(0xFFFFC107), Color(0xFFFF8C00)]),
                  borderRadius: BorderRadius.circular(20)),
                child: Text(_sending ? '...' : 'Gonder',
                  style: TextStyle(
                    color: _selected == null ? Colors.white38 : Colors.black,
                    fontWeight: FontWeight.bold, fontSize: 13)))),
          ]))),
      ]));
  }

  Widget _giftTile(GiftItem g) {
    final isSel = _selected?.key == g.key;
    return GestureDetector(
      onTap: () => setState(() => _selected = g),
      child: AnimatedContainer(duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: isSel
            ? const LinearGradient(colors: [
                Color(0xFFFFC107), Color(0xFFFF8C00)],
                begin: Alignment.topLeft, end: Alignment.bottomRight)
            : const LinearGradient(colors: [
                Color(0xFF1A0F3E), Color(0xFF0F0A2E)]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSel ? Colors.white : const Color(0xFFFFC107).withOpacity(0.2),
            width: isSel ? 2 : 1),
          boxShadow: isSel ? [BoxShadow(
            color: const Color(0xFFFFC107).withOpacity(0.6),
            blurRadius: 12, spreadRadius: 1)] : null),
        child: Stack(children: [
          if (g.isJackpot) Positioned(top: 2, left: 2,
            child: Container(padding: const EdgeInsets.symmetric(
                horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [
                  Color(0xFFFF5252), Color(0xFFFF1744)]),
                borderRadius: BorderRadius.circular(4)),
              child: const Text('JACKPOT', style: TextStyle(
                color: Colors.white, fontSize: 6,
                fontWeight: FontWeight.bold, letterSpacing: 0.5)))),
          if (g.isJackpot) Positioned(top: 2, right: 2,
            child: Container(width: 12, height: 12,
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50), shape: BoxShape.circle),
              child: const Center(child: Text('+',
                style: TextStyle(color: Colors.white, fontSize: 9,
                  fontWeight: FontWeight.bold))))),
          Padding(padding: const EdgeInsets.all(6),
            child: Column(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: Center(child: Image.asset(g.imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Text(
                    _fallbackEmoji(g.key),
                    style: const TextStyle(fontSize: 36))))),
                const SizedBox(height: 4),
                Text(g.name, textAlign: TextAlign.center,
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSel ? Colors.black : Colors.white,
                    fontSize: 8, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                if (g.isFree) Text('Ucretsiz',
                  style: TextStyle(
                    color: isSel ? Colors.black87 : const Color(0xFF4CAF50),
                    fontSize: 8, fontWeight: FontWeight.bold))
                else Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.monetization_on,
                    color: isSel ? Colors.black : const Color(0xFFFFC107), size: 9),
                  const SizedBox(width: 2),
                  Text('${g.price}', style: TextStyle(
                    color: isSel ? Colors.black : const Color(0xFFFFC107),
                    fontSize: 9, fontWeight: FontWeight.bold)),
                ]),
              ])),
        ]));
  }

  String _fallbackEmoji(String key) {
    if (key.contains('pasta')) return '🎂';
    if (key.contains('yildiz')) return '⭐';
    if (key.contains('can')) return '🔔';
    if (key.contains('sandik')) return '🎁';
    if (key.contains('araba')) return '🚗';
    if (key.contains('balloon')) return '🎈';
    if (key.contains('rose')) return '🌹';
    if (key.contains('heart')) return '❤️';
    if (key.contains('crown') || key.contains('king')) return '👑';
    if (key.contains('castle')) return '🏰';
    if (key.contains('dragon')) return '🐉';
    if (key.contains('phoenix')) return '🔥';
    if (key.contains('lion')) return '🦁';
    if (key.contains('galaxy') || key.contains('universe')) return '🌌';
    if (key.contains('ring')) return '💍';
    if (key.contains('teddy')) return '🧸';
    return '🎁';
  }
}
