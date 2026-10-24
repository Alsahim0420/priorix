import 'package:flutter/material.dart';
import '../core/widgets/priorix_mark.dart';

/// Picks up exactly where the native splash leaves off (same color, same mark
/// at the same size and position), then unveils the wordmark.
class PriorixSplash extends StatefulWidget {
  const PriorixSplash({super.key, required this.onFinished});

  final VoidCallback onFinished;

  /// Must match the native splash: 400 px mark in a 4x image → 100 dp.
  static const markSize = 100.0;

  @override
  State<PriorixSplash> createState() => _PriorixSplashState();
}

class _PriorixSplashState extends State<PriorixSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1700),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller.isAnimating || _controller.isCompleted) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.duration = const Duration(milliseconds: 400);
    }
    _controller.forward().whenComplete(widget.onFinished);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Animation<double> _interval(
    double begin,
    double end, [
    Curve curve = Curves.easeOutCubic,
  ]) {
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(begin, end, curve: curve),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lift = _interval(0.12, 0.5);
    final glow = _interval(0.0, 0.4, Curves.easeInOut);
    final word = _interval(0.3, 0.7);
    final tagline = _interval(0.45, 0.85);
    final line = _interval(0.35, 0.8, Curves.easeInOutCubic);

    // Material (not a bare ColoredBox) so text gets proper defaults.
    return Material(
      color: BrandColors.ink,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final height = MediaQuery.sizeOf(context).height;
          final markBottom =
              height / 2 + PriorixSplash.markSize / 2 - 44 * lift.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              // Warm ambient light that blooms behind the mark.
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, -0.12),
                      radius: 0.75,
                      colors: [
                        BrandColors.gold.withValues(alpha: 0.09 * glow.value),
                        BrandColors.gold.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(0, -44 * lift.value),
                child: PriorixMark(
                  size: PriorixSplash.markSize,
                  glow: 0.7 + 0.3 * glow.value,
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: markBottom + 32 + 12 * (1 - word.value),
                child: Opacity(
                  opacity: word.value,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'PRIORIX',
                        style: TextStyle(
                          color: BrandColors.ivory,
                          fontSize: 22,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 12 - 3 * word.value,
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: 36 * line.value,
                        height: 1,
                        child: const ColoredBox(color: BrandColors.gold),
                      ),
                      const SizedBox(height: 14),
                      Opacity(
                        opacity: tagline.value,
                        child: Text(
                          'Decide qué importa primero',
                          style: TextStyle(
                            color: BrandColors.ivory.withValues(alpha: 0.5),
                            fontSize: 12.5,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
