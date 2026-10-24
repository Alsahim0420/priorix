import 'package:flutter/material.dart';
import '../../app/theme/app_palette.dart';
import 'pressable.dart';

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 24,
    this.tint,
    this.onTap,
    this.onLongPress,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  /// Washes the card with a color (e.g. the quadrant color).
  final Color? tint;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final tint = this.tint;
    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: p.surface,
        gradient: tint == null
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.alphaBlend(
                    tint.withValues(alpha: p.isLight ? 0.09 : 0.13),
                    p.surface,
                  ),
                  p.surface,
                ],
              ),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: tint == null ? p.hairline : tint.withValues(alpha: 0.22),
        ),
        boxShadow: p.isLight
            ? const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Padding(padding: padding, child: child),
    );
    if (onTap == null && onLongPress == null) return card;
    return Pressable(onTap: onTap, onLongPress: onLongPress, child: card);
  }
}
