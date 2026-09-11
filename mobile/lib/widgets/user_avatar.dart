import 'package:flutter/material.dart';
import 'app_theme.dart';

class UserAvatar extends StatelessWidget {
  final String name;
  final double size;
  final String frame;
  final bool isVip;

  const UserAvatar({
    super.key,
    required this.name,
    this.size = 48,
    this.frame = 'gold',
    this.isVip = false,
  });

  List<Color> _frameColors() {
    switch (frame) {
      case 'purple':
        return [AppColors.purple, AppColors.deepPurple];
      case 'neon':
        return [AppColors.cyan, AppColors.blue];
      case 'fire':
        return [AppColors.orange, AppColors.red];
      case 'ice':
        return [const Color(0xFF80DEEA), AppColors.blue];
      default:
        return [AppColors.gold, AppColors.goldDark];
    }
  }

  @override
  Widget build(BuildContext context) {
    final first = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: _frameColors()),
        boxShadow: [
          BoxShadow(
            color: _frameColors()[0].withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.bgDark,
        ),
        child: Center(
          child: Text(
            first,
            style: TextStyle(
              color: _frameColors()[0],
              fontSize: size * 0.4,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
