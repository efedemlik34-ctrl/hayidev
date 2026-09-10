
import 'package:flutter/material.dart';
import '../services/api.dart';

class QuestsScreen extends StatefulWidget {
  const QuestsScreen({super.key});
  @override
  State<QuestsScreen> createState() => _QuestsScreenState();
}

class _QuestsScreenState extends State<QuestsScreen> {
  List _daily = [];
  List _weekly = [];
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await Api.dio.get('/quests');
      final data = r.data;
      if (data is Map) {
        setState(() {
          _daily = data['daily'] ?? [];
          _weekly = data['weekly'] ?? [];
        });
      }
    } catch (_) {}
  }

  Future<void> _claim(int id) async {
    try {
      await Api.dio.post('/quests/' + id.toString() + '/claim');
      _load();
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
    final list = _tab == 0 ? _daily : _weekly;
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        title: const Text('Gorevler'),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                _tabBtn('Gunluk', 0),
                _tabBtn('Haftalik', 1),
              ],
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? const Center(
                    child: Text(
                      'Gorev yok',
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: list.length,
                    itemBuilder: (_, i) => _questCard(list[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _tabBtn(String t, int idx) {
    final sel = _tab == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = idx),
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
              t,
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
  }

  Widget _questCard(Map q) {
    final title = (q['title'] ?? 'Gorev').toString();
    final progress = (q['progress'] ?? 0) as int;
    final target = (q['target'] ?? 10) as int;
    final reward = (q['reward'] ?? 0).toString();
    final claimed = q['claimed'] == true;
    final done = progress >= target;
    final id = q['id'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A0F3E), Color(0xFF0F0A2E)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: done
              ? const Color(0xFF4CAF50)
              : const Color(0xFFFFC107).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                '+' + reward,
                style: const TextStyle(
                  color: Color(0xFFFFC107),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: target > 0 ? (progress / target).clamp(0.0, 1.0) : 0.0,
              minHeight: 8,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation(Color(0xFFFFC107)),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                progress.toString() + '/' + target.toString(),
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
              const Spacer(),
              if (done && !claimed)
                GestureDetector(
                  onTap: () => _claim(id is int ? id : 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'AL',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                )
              else if (claimed)
                const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 20),
            ],
          ),
        ],
      ),
    );
  }
}
