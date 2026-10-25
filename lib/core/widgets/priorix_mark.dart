import 'dart:math' as math;
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
    this.light = 0,
    this.glow = 1,
  });

  final double size;

  /// Where the gold light sits as it travels clockwise around the quadrants:
  /// 0 = first quadrant (rest), 1 = second, 2 = fourth, 3 = third, 4 = back to
  /// the first. Fractional values blend between neighbours.
  final double light;

  /// Strength of the soft halo behind lit quadrants (1 = default).
  final double glow;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: PriorixMarkPainter(light: light, glow: glow),
      ),
    );
  }
}

class PriorixMarkPainter extends CustomPainter {
  const PriorixMarkPainter({
    this.light = 0,
    this.glow = 1,
    this.monochrome = false,
  });

  final double light;
  final double glow;

  /// White silhouette on transparent, as Android requires for the
  /// notification (status bar) icon.
  final bool monochrome;

  /// Resting presence of each quadrant when unlit, in clockwise order
  /// (Q1, Q2, Q4, Q3) — fading with Eisenhower priority.
  static const _dimAlpha = [0.2, 0.17, 0.065, 0.11];

  /// How far (in quadrants) the light spreads into its neighbours.
  static const _spread = 0.85;

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

    // Clockwise: Q1 → Q2 → Q4 → Q3.
    final pieces = [piece(0, 0), piece(1, 0), piece(1, 1), piece(0, 1)];

    if (monochrome) {
      for (var i = 0; i < pieces.length; i++) {
        canvas.drawRRect(
          pieces[i],
          Paint()..color = Colors.white.withValues(alpha: i == 0 ? 1 : 0.42),
        );
      }
      return;
    }

    final intensity = [for (var i = 0; i < 4; i++) _intensity(i)];

    if (glow > 0) {
      for (var i = 0; i < 4; i++) {
        if (intensity[i] == 0) continue;
        canvas.drawRRect(
          pieces[i].inflate(s * 0.01),
          Paint()
            ..color = BrandColors.gold.withValues(
              alpha: (0.3 * glow * intensity[i]).clamp(0.0, 1.0),
            )
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.07),
        );
      }
    }

    for (var i = 0; i < 4; i++) {
      final lit = intensity[i];
      final rrect = pieces[i];
      if (lit < 1) {
        canvas.drawRRect(
          rrect,
          Paint()
            ..color = BrandColors.ivory.withValues(
              alpha: _dimAlpha[i] * (1 - lit),
            ),
        );
      }
      if (lit == 0) continue;
      // Gold gains presence faster than the grey loses it, so hand-offs stay
      // luminous instead of passing through a muddy half-tone.
      final gold = math.sqrt(lit);
      final bounds = rrect.outerRect;
      canvas.drawRRect(
        rrect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              BrandColors.goldLight.withValues(alpha: gold),
              BrandColors.gold.withValues(alpha: gold),
              BrandColors.goldDeep.withValues(alpha: gold),
            ],
            stops: const [0, 0.55, 1],
          ).createShader(bounds),
      );
      // Soft sheen fading out by mid-height — reads as a machined surface.
      canvas.drawRRect(
        rrect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [
              Colors.white.withValues(alpha: 0.2 * gold),
              Colors.white.withValues(alpha: 0),
            ],
          ).createShader(bounds),
      );
    }
  }

  /// 0–1 light on quadrant [index] (clockwise order), smoothstepped so the
  /// hand-off between neighbours has no visible seams.
  double _intensity(int index) {
    var distance = (light - index).abs() % 4;
    if (distance > 2) distance = 4 - distance;
    final t = (1 - distance / _spread).clamp(0.0, 1.0);
    return t * t * (3 - 2 * t);
  }

  @override
  bool shouldRepaint(PriorixMarkPainter old) =>
      old.light != light || old.glow != glow || old.monochrome != monochrome;
}
