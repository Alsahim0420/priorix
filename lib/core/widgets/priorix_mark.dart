import 'package:flutter/material.dart';

/// Brand colors for the mark and splash. Fixed across themes so the native
/// splash, the Flutter splash and the launcher icon match exactly.
class BrandColors {
  const BrandColors._();

  static const ink = Color(0xFF08090E);
  static const inkTop = Color(0xFF15161D);
  static const goldLight = Color(0xFFEBD3A0);
  static const gold = Color(0xFFD2AC6A);
  static const goldDeep = Color(0xFFB08A4C);
  static const ivory = Color(0xFFF4F1EA);
}

/// The Priorix mark: a 2×2 matrix where only the first quadrant — urgent and
/// important — is lit. The other three step down in presence.
class PriorixMark extends StatelessWidget {
  const PriorixMark({
    super.key,
    this.size = 120,
    this.reveal = 1,
    this.glow = 1,
  });

  final double size;

  /// 0–1: staggers the three secondary quadrants in (used by the splash).
  final double reveal;

  /// 0–1: strength of the soft halo behind the lit quadrant.
  final double glow;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: PriorixMarkPainter(reveal: reveal, glow: glow),
      ),
    );
  }
}

class PriorixMarkPainter extends CustomPainter {
  const PriorixMarkPainter({
    this.reveal = 1,
    this.glow = 1,
    this.monochrome = false,
  });

  final double reveal;
  final double glow;

  /// White silhouette on transparent, as Android requires for the
  /// notification (status bar) icon.
  final bool monochrome;

  // Presence of the secondary quadrants, by Eisenhower order.
  static const _secondaryAlpha = [0.17, 0.11, 0.065];

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final gap = s * 0.06;
    final cell = (s - gap) / 2;
    // Large outer corners, tight inner ones: together the four pieces read
    // as a single rounded form split into a matrix.
    final outer = Radius.circular(cell * 0.46);
    final inner = Radius.circular(cell * 0.14);
    RRect piece(int col, int row) {
      final rect = Rect.fromLTWH(
        col * (cell + gap),
        row * (cell + gap),
        cell,
        cell,
      );
      return RRect.fromRectAndCorners(
        rect,
        topLeft: col == 0 && row == 0 ? outer : inner,
        topRight: col == 1 && row == 0 ? outer : inner,
        bottomLeft: col == 0 && row == 1 ? outer : inner,
        bottomRight: col == 1 && row == 1 ? outer : inner,
      );
    }

    final lit = piece(0, 0);
    final secondary = [piece(1, 0), piece(0, 1), piece(1, 1)];
    if (monochrome) {
      canvas.drawRRect(lit, Paint()..color = Colors.white);
      for (final rrect in secondary) {
        canvas.drawRRect(
          rrect,
          Paint()..color = Colors.white.withValues(alpha: 0.42),
        );
      }
      return;
    }

    if (glow > 0) {
      canvas.drawRRect(
        lit.inflate(s * 0.01),
        Paint()
          ..color = BrandColors.gold.withValues(alpha: 0.3 * glow)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.07),
      );
    }

    for (var i = 0; i < secondary.length; i++) {
      final t = ((reveal * 3) - i).clamp(0.0, 1.0);
      if (t == 0) continue;
      canvas.drawRRect(
        secondary[i],
        Paint()
          ..color = BrandColors.ivory.withValues(alpha: _secondaryAlpha[i] * t),
      );
    }

    final bounds = lit.outerRect;
    canvas.drawRRect(
      lit,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            BrandColors.goldLight,
            BrandColors.gold,
            BrandColors.goldDeep,
          ],
          stops: [0, 0.55, 1],
        ).createShader(bounds),
    );
    // Soft sheen fading out by mid-height — reads as a machined surface.
    canvas.drawRRect(
      lit,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.center,
          colors: [
            Colors.white.withValues(alpha: 0.2),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(bounds),
    );
  }

  @override
  bool shouldRepaint(PriorixMarkPainter old) =>
      old.reveal != reveal || old.glow != glow || old.monochrome != monochrome;
}
