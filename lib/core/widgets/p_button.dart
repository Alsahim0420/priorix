import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_palette.dart';
import 'pressable.dart';

enum PButtonVariant { primary, secondary, ghost, danger }

class PButton extends StatelessWidget {
  const PButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = PButtonVariant.primary,
    this.expanded = true,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final PButtonVariant variant;
  final bool expanded;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final (
      Color? background,
      Color foreground,
      Color? border,
    ) = switch (variant) {
      PButtonVariant.primary => (null, p.onAccent, null),
      PButtonVariant.secondary => (p.surfaceHigh, p.textPrimary, p.hairline),
      PButtonVariant.ghost => (Colors.transparent, p.accent, null),
      PButtonVariant.danger => (
        AppColors.danger.withValues(alpha: 0.1),
        AppColors.danger,
        AppColors.danger.withValues(alpha: 0.2),
      ),
    };
    final isPrimary = variant == PButtonVariant.primary;
    final height = compact ? 44.0 : 56.0;

    final content = Row(
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: compact ? 17 : 19, color: foreground),
          const SizedBox(width: 9),
        ],
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: foreground,
              fontSize: compact ? 14 : 15.5,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.1,
            ),
          ),
        ),
      ],
    );

    return Opacity(
      opacity: onPressed == null ? 0.4 : 1,
      child: Pressable(
        onTap: onPressed,
        child: Container(
          height: height,
          padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 22),
          decoration: BoxDecoration(
            color: background,
            gradient: isPrimary
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(p.accent, Colors.white, 0.12)!,
                      p.accent,
                      Color.lerp(p.accent, Colors.black, 0.14)!,
                    ],
                  )
                : null,
            borderRadius: BorderRadius.circular(compact ? 14 : 18),
            border: border == null ? null : Border.all(color: border),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: p.accent.withValues(
                        alpha: p.isLight ? 0.22 : 0.26,
                      ),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : null,
          ),
          child: content,
        ),
      ),
    );
  }
}

/// Round 40pt icon button used in top bars.
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.color,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final button = Pressable(
      onTap: onPressed,
      scale: 0.9,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: p.surface,
          shape: BoxShape.circle,
          border: Border.all(color: p.hairline),
        ),
        child: Icon(icon, size: 20, color: color ?? p.textPrimary),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip, child: button);
  }
}
