import 'package:flutter/material.dart';
import 'app_theme.dart';

class AppButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final List<Color>? colors;
  final bool outline;
  final double height;
  final double? width;

  const AppButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.colors,
    this.outline = false,
    this.height = 52,
    this.width,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _c, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cols = widget.colors ?? [AppColors.gold, AppColors.goldDark];
    final disabled = widget.onTap == null;

    return GestureDetector(
      onTapDown: disabled ? null : (_) => _c.forward(),
      onTapUp: disabled
          ? null
          : (_) {
              _c.reverse();
              widget.onTap?.call();
            },
      onTapCancel: disabled ? null : () => _c.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: widget.width ?? double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: widget.outline
                ? null
                : LinearGradient(
                    colors: disabled
                        ? [Colors.grey.shade800, Colors.grey.shade900]
                        : cols,
                  ),
            color: widget.outline ? Colors.transparent : null,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: widget.outline
                ? Border.all(color: cols[0], width: 2)
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  color: widget.outline ? cols[0] : Colors.black,
                  size: 20,
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: widget.outline ? cols[0] : Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
