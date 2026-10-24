import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:priorix/core/widgets/priorix_mark.dart';

/// Renders the brand PNGs in assets/brand from PriorixMark. After changing
/// the mark: flutter test test/brand_assets_test.dart --update-goldens,
/// then regenerate icons and splash (see pubspec.yaml).
Widget _iconFull(double s) => Container(
  width: s,
  height: s,
  decoration: const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [BrandColors.inkTop, BrandColors.ink],
    ),
  ),
  child: Stack(
    children: [
      Positioned.fill(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-0.55, -0.6),
              radius: 0.9,
              colors: [
                BrandColors.gold.withValues(alpha: 0.10),
                BrandColors.gold.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
      Center(child: PriorixMark(size: s * 0.52)),
    ],
  ),
);

Future<void> _render(
  WidgetTester tester,
  Widget child,
  double w,
  String name,
) async {
  tester.view.physicalSize = Size(w, w);
  tester.view.devicePixelRatio = 1;
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: RepaintBoundary(
          child: SizedBox.square(dimension: w, child: child),
        ),
      ),
    ),
  );
  await expectLater(
    find.byType(RepaintBoundary).first,
    matchesGoldenFile('../assets/brand/$name.png'),
  );
}

void main() {
  testWidgets('brand assets', (tester) async {
    addTearDown(tester.view.reset);
    await _render(tester, _iconFull(1024), 1024, 'icon');
    // Android adaptive foreground: motif inside the 66% safe zone.
    await _render(
      tester,
      const Center(child: PriorixMark(size: 1024 * 0.36)),
      1024,
      'icon_foreground',
    );
    // Native splash logo (treated as 4x → 120dp).
    await _render(
      tester,
      const Center(child: PriorixMark(size: 400, glow: 0.7)),
      480,
      'splash_logo',
    );
    // Android 12 splash icon: 1152px canvas, content within the 768px circle.
    await _render(
      tester,
      const Center(child: PriorixMark(size: 400, glow: 0.7)),
      1152,
      'splash_android12',
    );
  });
}
