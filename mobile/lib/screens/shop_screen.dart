import 'package:flutter/material.dart';
import '../services/api.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});
  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  int _tab = 0;
  final List<String> _tabs = ['Coin', 'Elmas', 'VIP'];

  final List<Map<String, dynamic>> _coins = [
    {'c': 1000, 'p': '10 TL', 'i': '🪙', 't': ''},
    {'c': 5500, 'p': '50 TL', 'i': '💰', 't': '+10%'},
    {'c': 12000, 'p': '100 TL', 'i': '💎', 't': '+20%'},
    {'c': 30000, 'p': '250 TL', 'i': '👑', 't': '+30%'},
    {'c': 70000, 'p': '500 TL', 'i': '🏆', 't': '+40%'},
    {'c': 200000, 'p': '1000 TL', 'i': '🌟', 't': 'EN IYI'},
  ];

  final List<Map<String, dynamic>> _diamonds = [
    {'d': 100, 'p': '15 TL', 'i': '💠'},
    {'d': 600, 'p': '80 TL', 'i': '💠'},
    {'d': 1500, 'p': '150 TL', 'i': '💠'},
    {'d': 5000, 'p': '400 TL', 'i': '💠'},
  ];

  final List<Map<String, dynamic>> _vips = [
    {
      'n': 'VIP 1 Ay', 'p': '99 TL', 'i': '🥉',
      'c1': const Color(0xFF4CAF50), 'c2': const Color(0xFF2E7D32)
    },
    {
      'n': 'VIP 3 Ay', 'p': '249 TL', 'i': '🥈',
      'c1': const Color(0xFF2196F3), 'c2': const Color(0xFF1565C0)
    },
    {
      'n': 'VIP 12 Ay', 'p': '799 TL', 'i': '🥇',
      'c1': const Color(0xFFFFC107), 'c2': const Color(0xFFFF6B35)
    },
  ];

  Future<void> _buy(String id) async {
    try {
      await Api.dio.post('/shop/purchase', data: {'id': id});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Satin alindi!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        title: const Text('Magaza'),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          _buildWelcomeCard(),
          _buildTabRow(),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF4A148C),
            Color(0xFF9C27B0),
            Color(0xFFE91E63),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9C27B0).withOpacity(0.5),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hos Geldin!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Coin ve elmas satin al',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const Text('🎁', style: TextStyle(fontSize: 50)),
        ],
      ),
    );
  }

  Widget _buildTabRow() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final sel = _tab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _tab = i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: sel
                      ? const LinearGradient(
                          colors: [Color(0xFFFFC107), Color(0xFFFF6B35)],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    _tabs[i],
                    style: TextStyle(
                      color: sel ? Colors.black : Colors.white60,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildContent() {
    if (_tab == 0) return _buildCoins();
    if (_tab == 1) return _buildDiamonds();
    return _buildVips();
  }

  Widget _buildCoins() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.95,
      ),
      itemCount: _coins.length,
      itemBuilder: (_, i) => _coinCard(_coins[i]),
    );
  }

  Widget _coinCard(Map<String, dynamic> p) {
    final String tag = (p['t'] as String?) ?? '';
    final String coinStr = p['c'].toString();
    final String priceStr = (p['p'] as String?) ?? '';
    final String iconStr = (p['i'] as String?) ?? '🪙';

    return GestureDetector(
      onTap: () => _buy('coin_' + coinStr),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A0F3E), Color(0xFF2A1F5E)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFFFC107).withOpacity(0.3),
          ),
        ),
        child: Stack(
          children: [
            if (tag.isNotEmpty)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF5252), Color(0xFFFF1744)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(iconStr, style: const TextStyle(fontSize: 44)),
                  const SizedBox(height: 8),
                  Text(
                    coinStr,
                    style: const TextStyle(
                      color: Color(0xFFFFC107),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'coin',
                    style: TextStyle(color: Colors.white60, fontSize: 10),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      priceStr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiamonds() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _diamonds.length,
      itemBuilder: (_, i) => _diamondCard(_diamonds[i]),
    );
  }

  Widget _diamondCard(Map<String, dynamic> p) {
    final String dStr = p['d'].toString();
    final String priceStr = (p['p'] as String?) ?? '';
    final String iconStr = (p['i'] as String?) ?? '💠';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F1E5E), Color(0xFF1A0F3E)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF4FC3F7).withOpacity(0.4),
        ),
      ),
      child: Row(
        children: [
          Text(iconStr, style: const TextStyle(fontSize: 36)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dStr + ' Elmas',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Hediye ve ozel icin',
                  style: TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _buy('dia_' + dStr),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4FC3F7), Color(0xFF0277BD)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                priceStr,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVips() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _vips.length,
      itemBuilder: (_, i) => _vipCard(_vips[i]),
    );
  }

  Widget _vipCard(Map<String, dynamic> p) {
    final String nameStr = (p['n'] as String?) ?? '';
    final String priceStr = (p['p'] as String?) ?? '';
    final String iconStr = (p['i'] as String?) ?? '🥉';
    final Color c1 = (p['c1'] as Color?) ?? const Color(0xFF4CAF50);
    final Color c2 = (p['c2'] as Color?) ?? const Color(0xFF2E7D32);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c1, c2],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: c1.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(iconStr, style: const TextStyle(fontSize: 46)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nameStr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Reklamsiz • Ozel rozet • 2x XP',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _buy(nameStr),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                priceStr,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
