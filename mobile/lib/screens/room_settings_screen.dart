import 'package:flutter/material.dart';
import '../services/api.dart';

class RoomSettingsScreen extends StatefulWidget {
  const RoomSettingsScreen({
    super.key,
    required this.roomId,
    required this.roomName,
  });

  final int roomId;
  final String roomName;
  @override
  State<RoomSettingsScreen> createState() => _RoomSettingsScreenState();
}

class _RoomSettingsScreenState extends State<RoomSettingsScreen> {
  bool _welcomeMsg = true;
  bool _newUserWelcome = true;
  bool _sensitiveFilter = true;
  bool _memberApproval = true;
  String _roomType = 'Sohbet odası';
  String _micMode = 'Açık mod';
  String _seatCount = '9 Kişi';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: SafeArea(child: Column(children: [
        // Ust bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(children: [
            IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
            const Spacer(),
            const Text('Oda ayarları',
              style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
            const Spacer(),
            const SizedBox(width: 40),
          ]),
        ),
        Expanded(child: ListView(children: [
          const SizedBox(height: 12),
          // Oda basligi
          _sectionLabel('Oda başlığı'),
          _textField('👑 SOHBET MUHABBET BABALAR 👑'),
          const SizedBox(height: 16),
          // Oda duyurusu
          _sectionLabel('Oda duyurusu'),
          _textField('Odaya katıldığınız için teşekkürler'),
          const SizedBox(height: 24),
          _menuItem('Odadaki karşılama mesajı', _welcomeMsg, () => setState(() => _welcomeMsg = !_welcomeMsg)),
          _menuItem('Yeni Kullanıcı Hoş Geldiniz Mesajı', _newUserWelcome, () => setState(() => _newUserWelcome = !_newUserWelcome)),
          _arrowItem('Genek erkran ayarları', null, () {}),
          _menuItem('Hassas kelimeler ayarı', _sensitiveFilter, () => setState(() => _sensitiveFilter = !_sensitiveFilter)),
          _valueItem('Oda tipi', _roomType, () {}),
          _valueItem('Mikrofon modu', _micMode, () {}),
          _toggleItem('Oda üyesinin onaylanması\ngerekiyor', _memberApproval, (v) => setState(() => _memberApproval = v)),
          _valueItem('Mikrofon modu', _seatCount, () {}),
          _arrowItem('Süper Mikrofon Koltuğu', null, () {}),
          _arrowItem('Kara liste', null, () {}),
          _arrowItem('Efekt anahtarı', null, () {}),
          const SizedBox(height: 40),
        ])),
        // Alt bar
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: const BoxDecoration(
            color: Color(0xFF0F1430),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _bottomIcon(Icons.cleaning_services, 'Ekranı Temizle', () {}),
            _bottomIcon(Icons.palette, 'Tema', () {}),
            _bottomIcon(Icons.music_note, 'Müzik', () {}),
            _bottomIcon(Icons.lock_outline, 'Kilitle', () {}),
            _bottomIcon(Icons.admin_panel_settings, 'Yönetici', () {}),
          ]),
        ),
      ])),
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
    child: Text(text, style: const TextStyle(color: Colors.white54, fontSize: 12)),
  );

  Widget _textField(String value) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.06),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white.withOpacity(0.1)),
    ),
    child: Text(value, style: const TextStyle(color: Colors.white70, fontSize: 13)),
  );

  Widget _menuItem(String title, bool showDot, VoidCallback onTap) => InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(children: [
        Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500))),
        if (showDot) Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFE91E63), shape: BoxShape.circle)),
        const SizedBox(width: 10),
        const Icon(Icons.chevron_right, color: Colors.white38, size: 20),
      ]),
    ),
  );

  Widget _arrowItem(String title, String? value, VoidCallback onTap) => InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(children: [
        Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500))),
        if (value != null) Text(value, style: const TextStyle(color: Colors.white54, fontSize: 13)),
        const SizedBox(width: 8),
        const Icon(Icons.chevron_right, color: Colors.white38, size: 20),
      ]),
    ),
  );

  Widget _valueItem(String title, String value, VoidCallback onTap) => InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(children: [
        Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500))),
        Text(value, style: const TextStyle(color: Colors.white54, fontSize: 14)),
        const SizedBox(width: 8),
        Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFE91E63), shape: BoxShape.circle)),
        const SizedBox(width: 8),
        const Icon(Icons.chevron_right, color: Colors.white38, size: 20),
      ]),
    ),
  );

  Widget _toggleItem(String title, bool value, Function(bool) onChange) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    child: Row(children: [
      Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500))),
      Switch(
        value: value,
        onChanged: onChange,
        activeColor: Colors.white,
        activeTrackColor: const Color(0xFFFFC107),
      ),
    ]),
  );

  Widget _bottomIcon(IconData icon, String label, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 48, height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(colors: [Color(0xFF2A1F5E), Color(0xFF1A0F3E)]),
          border: Border.all(color: const Color(0xFFFFC107).withOpacity(0.4)),
        ),
        child: Icon(icon, color: const Color(0xFFFFC107), size: 22),
      ),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
    ]),
  );
}
