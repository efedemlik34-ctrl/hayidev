import 'package:flutter/material.dart';
import '../services/api.dart';

class GiftBottomSheet extends StatefulWidget {
  final int roomId;
  final List seats;
  final int? preselectedReceiverId;
  final Function(Map<String, dynamic> gift) onSent;
  const GiftBottomSheet({
    super.key,
    required this.roomId,
    required this.seats,
    this.preselectedReceiverId,
    required this.onSent,
  });
  @override
  State<GiftBottomSheet> createState() => _GiftBottomSheetState();
}

class _GiftBottomSheetState extends State<GiftBottomSheet> {
  List _gifts = [];
  int? _receiverId;
  String _category = 'all';
  int _qty = 1;
  bool _loading = true;
  bool _sending = false;

  final _categories = const [
    {'key': 'all', 'name': 'Tumu', 'icon': '🎁'},
    {'key': 'classic', 'name': 'Klasik', 'icon': '🌹'},
    {'key': 'cute', 'name': 'Sevimli', 'icon': '🧸'},
    {'key': 'food', 'name': 'Yemek', 'icon': '🎂'},
    {'key': 'animal', 'name': 'Hayvan', 'icon': '🦁'},
    {'key': 'vehicle', 'name': 'Arac', 'icon': '🚗'},
    {'key': 'fantasy', 'name': 'Fantastik', 'icon': '🐉'},
    {'key': 'luxury', 'name': 'Luks', 'icon': '💎'},
    {'key': 'royal', 'name': 'Kraliyet', 'icon': '👑'},
  ];

  @override
  void initState() {
    super.initState();
    _receiverId = widget.preselectedReceiverId;
    _loadGifts();
  }

  Future<void> _loadGifts() async {
    try {
      final r = await Api.dio.get('/gifts');
      setState(() => _gifts = r.data);
    } catch (e) {}
    setState(() => _loading = false);
  }

  List get _filtered {
    if (_category == 'all') return _gifts;
    return _gifts.where((g) => g['cat'] == _category).toList();
  }

  List get _receiverOptions {
    final list = <Map<String, dynamic>>[];
    for (final s in widget.seats) {
      if (s['user_id'] != null && s['username'] != null) {
        list.add({'id': s['user_id'], 'username': s['username'], 'seat': s['seat_index']});
      }
    }
    return list;
  }

  Future<void> _send(Map<String, dynamic> gift) async {
    if (_receiverId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alici sec'), backgroundColor: Colors.orange));
      return;
    }
    setState(() => _sending = true);
    try {
      await Api.dio.post('/gifts/send', data: {
        'receiverId': _receiverId,
        'giftKey': gift['key'],
        'quantity': _qty,
        'roomId': widget.roomId,
      });
      widget.onSent(gift);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${gift['name']} x$_qty gonderildi!'),
            backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Color(0xFF1A0F3E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(children: [
        const SizedBox(height: 10),
        Container(width: 44, height: 4,
          decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 12),
        const Text('HEDIYE GONDER',
          style: TextStyle(color: Color(0xFFFFC107), fontSize: 16,
            fontWeight: FontWeight.bold, letterSpacing: 2)),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFC107).withOpacity(0.3)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _receiverId,
                hint: const Text('Alici sec', style: TextStyle(color: Colors.white54)),
                dropdownColor: const Color(0xFF1A0F3E),
                style: const TextStyle(color: Colors.white),
                isExpanded: true,
                items: _receiverOptions.map((r) => DropdownMenuItem<int>(
                  value: r['id'] as int,
                  child: Text('${r['username']} (Koltuk ${r['seat']})',
                    style: const TextStyle(color: Colors.white)),
                )).toList(),
                onChanged: (v) => setState(() => _receiverId = v),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _categories.length,
            itemBuilder: (_, i) {
              final c = _categories[i];
              final sel = _category == c['key'];
              return GestureDetector(
                onTap: () => setState(() => _category = c['key'] as String),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: sel ? const LinearGradient(
                      colors: [Color(0xFFFFC107), Color(0xFFFF6B35)]) : null,
                    color: sel ? null : Colors.white10,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(children: [
                    Text(c['icon'] as String, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text(c['name'] as String, style: TextStyle(
                      color: sel ? Colors.black : Colors.white,
                      fontSize: 11, fontWeight: FontWeight.bold)),
                  ]),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _loading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFC107)))
            : _filtered.isEmpty
              ? const Center(child: Text('Hediye yok', style: TextStyle(color: Colors.white54)))
              : GridView.count(
                  padding: const EdgeInsets.all(12),
                  crossAxisCount: 4,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.8,
                  children: _filtered.map((g) => GestureDetector(
                    onTap: _sending ? null : () => _send(g),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFC107).withOpacity(0.2)),
                      ),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(g['icon'] ?? '?', style: const TextStyle(fontSize: 28)),
                        const SizedBox(height: 4),
                        Text(g['name'] ?? '', style: const TextStyle(
                          color: Colors.white, fontSize: 9),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text('${g['price'] ?? 0}', style: const TextStyle(
                          color: Color(0xFFFFC107), fontSize: 9, fontWeight: FontWeight.bold)),
                      ]),
                    ),
                  )).toList(),
                ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Color(0xFF0F1430),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.white70),
              onPressed: () => setState(() => _qty = _qty > 1 ? _qty - 1 : 1),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white10, borderRadius: BorderRadius.circular(8)),
              child: Text('x$_qty', style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.white70),
              onPressed: () => setState(() => _qty = _qty < 99 ? _qty + 1 : 99),
            ),
          ]),
        ),
      ]),
    );
  }
}
