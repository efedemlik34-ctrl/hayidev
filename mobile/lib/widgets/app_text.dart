import 'package:flutter/material.dart';

/// Metinleri otomatik sigdiran helper widget'lar
class AppText extends StatelessWidget {
  final String text;
  final double? size;
  final Color? color;
  final FontWeight? weight;
  final TextAlign? align;
  final int? maxLines;
  final bool fitted;

  const AppText(
    this.text, {
    super.key,
    this.size,
    this.color,
    this.weight,
    this.align,
    this.maxLines,
    this.fitted = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: size,
      color: color,
      fontWeight: weight,
    );

    if (fitted) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        alignment: align == TextAlign.center
            ? Alignment.center
            : align == TextAlign.right
                ? Alignment.centerRight
                : Alignment.centerLeft,
        child: Text(
          text,
          style: style,
          textAlign: align,
          maxLines: maxLines ?? 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        ),
      );
    }

    return Text(
      text,
      style: style,
      textAlign: align,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Buyuk rakamlar icin - her zaman sigar
class BalanceText extends StatelessWidget {
  final int amount;
  final double size;
  final Color? color;
  final IconData? icon;

  const BalanceText(
    this.amount, {
    super.key,
    this.size = 14,
    this.color,
    this.icon,
  });

  String _fmt(int n) {
    if (n >= 1000000000) return (n / 1000000000).toStringAsFixed(1) + 'B';
    if (n >= 1000000) return (n / 1000000).toStringAsFixed(1) + 'M';
    if (n >= 1000) return (n / 1000).toStringAsFixed(1) + 'K';
    return n.toString();
  }

  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xFFFFC107);
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: c, size: size),
          const SizedBox(width: 4),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                _fmt(amount),
                style: TextStyle(
                  color: c,
                  fontSize: size,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
              ),
            ),
          ),
        ],
      );
    }
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(
        _fmt(amount),
        style: TextStyle(
          color: c,
          fontSize: size,
          fontWeight: FontWeight.bold,
        ),
        maxLines: 1,
      ),
    );
  }
}
