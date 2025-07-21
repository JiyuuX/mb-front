import 'package:flutter/material.dart';

class ColoredUsername extends StatelessWidget {
  final String text;
  final String? colorHex;
  final bool isPremium;
  final TextStyle? style;
  final double? fontSize;
  final TextAlign? textAlign;
  final bool showStar;

  const ColoredUsername({
    super.key,
    required this.text,
    this.colorHex,
    this.isPremium = false,
    this.style,
    this.fontSize,
    this.textAlign,
    this.showStar = true,
  });

  @override
  Widget build(BuildContext context) {
    Color? color;
    if (isPremium) {
      if (colorHex != null && colorHex!.isNotEmpty) {
        try {
          color = Color(int.parse(colorHex!.replaceAll('#', '0xFF')));
        } catch (_) {
          color = Theme.of(context).colorScheme.primary;
        }
      } else {
        color = Theme.of(context).colorScheme.primary;
      }
    } else {
      // Normal kullanıcı: tema moduna göre siyah/beyaz
      final brightness = Theme.of(context).brightness;
      color = brightness == Brightness.dark ? Colors.white : Colors.black;
    }

    final textWidget = Text(
      text,
      textAlign: textAlign,
      style: style?.copyWith(
            color: color,
            fontWeight: isPremium ? FontWeight.bold : FontWeight.w600,
            fontSize: fontSize,
          ) ??
          TextStyle(
            color: color,
            fontWeight: isPremium ? FontWeight.bold : FontWeight.w600,
            fontSize: fontSize,
          ),
    );

    if (isPremium && showStar) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          textWidget,
          const SizedBox(width: 4),
          Icon(Icons.star, color: Colors.amber, size: fontSize != null ? fontSize! * 0.8 : 16),
        ],
      );
    } else {
      return textWidget;
    }
  }
} 