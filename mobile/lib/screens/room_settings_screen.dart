import 'package:flutter/material.dart';
import '../services/api.dart';

class RoomSettingsScreen extends StatefulWidget {
  final int roomId;
  const RoomSettingsScreen({super.key, required this.roomId});
  @override
  State<RoomSettingsScreen> createState() => _RoomSettingsScreenState();
}

class _RoomSettingsScreenState extends State<RoomSettingsScreen> {
  bool _welcomeMsg = true;
  bool _newUserWelcome = true;
  bool _sensitiveWords = true;
  bool _micApproval = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        title: const Text('Oda ayarlari'),
        backgroundColor: const Color(0xFF0F1430),
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(children: [
        const SizedBox(height: 8),
        _tile('Odadaki karsilama mesaji', trailing: _redDot(), onTap: () {}),
        _tile('Yeni Kullanici Hos Geldiniz Mesaji', trailing: _redDot(), onTap: () {}),
        _tile('Genek erkan ayarlari', trailing: const Icon(Icons.chevron_right, color: Colors.white38), onTap: () {}),
        _tile('Hassas kelimeler ayari', trailing: _redDot(), onTap: () {}),
        _tile('Oda tipi', value: 'Sohbet odasi', onTap: () {}),
        _tile('Mikrofon modu', value: 'Acik mod', onTap: () {}),
        _switchTile('Oda uyesinin onaylanmasi gerekiyor', _micApproval, (v) => setState(() => _micApproval = v)),
        _tile('Mikrofon modu', value: '9 Kisi', onTap: () {}),
        _tile('Super Mikrofon Koltugu', onTap: () {}),
        _tile('Kara liste', onTap: () {}),
        _tile('Efekt anahtari', onTap: () {}),
      ]),
    );
  }

  Widget _redDot() {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 10, height: 10,
        decoration: const BoxDecoration(color: Color(0xFFE91E63), shape: BoxShape.circle)),
      const SizedBox(width: 8),
      const Icon(Icons.chevron_right, color: Colors.white38),
    ]);
  }

  Widget _tile(String title, {String? value, Widget? trailing, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        child: Row(children: [
          Expanded(child: Text(title,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500))),
          if (value != null) ...[
            Text(value, style: const TextStyle(color: Colors.white54, fontSize: 14)),
            const SizedBox(width: 8),
          ],
          if (trailing != null) trailing
          else const Icon(Icons.chevron_right, color: Colors.white38),
        ]),
      ),
    );
  }

  Widget _switchTile(String title, bool value, Function(bool) onChange) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(children: [
        Expanded(child: Text(title,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500))),
        Switch(
          value: value,
          onChanged: onChange,
          activeColor: Colors.white,
          activeTrackColor: const Color(0xFFFFC107),
        ),
      ]),
    );
  }
}
