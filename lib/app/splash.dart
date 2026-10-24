import 'package:flutter/material.dart';
import '../core/widgets/priorix_mark.dart';

/// Picks up exactly where the native splash leaves off (same color, same mark
/// at the same size and position). The mark never moves: a gold light sweeps
/// once around the four quadrants, settles back on the first — what matters —
/// with a soft pulse, and the wordmark is unveiled beneath it.
class PriorixSplash extends StatefulWidget {
  const PriorixSplash({super.key, required this.onFinished});

  final VoidCallback onFinished;

  /// Must match the native splash: 400 px mark in a 4x image → 100 dp.
  static const markSize = 100.0;

  /// The native splash logo is rendered with this halo strength.
  static const nativeGlow = 0.7;

  @override
  State<PriorixSplash> createState() => _PriorixSplashState();
}

class _PriorixSplashState extends State<PriorixSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2300),
  );

  late final Animation<double> _light = Tween<double>(
    begin: 0,
    end: 4,
  ).animate(_interval(0.06, 0.62, Curves.easeInOutCubic));

  // Halo: native strength while sweeping, a soft bloom as the light lands
  // back on the first quadrant, then rest.
  late final Animation<double> _glow = TweenSequence<double>([
    TweenSequenceItem(
      tween: ConstantTween(PriorixSplash.nativeGlow),
      weight: 56,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: PriorixSplash.nativeGlow,
        end: 1.6,
      ).chain(CurveTween(curve: Curves.easeOutCubic)),
      weight: 10,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.6,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.easeInOutSine)),
      weight: 20,
    ),
    TweenSequenceItem(tween: ConstantTween(1.0), weight: 14),
  ]).animate(_controller);

  late final Animation<double> _ambient = _interval(0.56, 0.8);
  late final Animation<double> _word = _interval(0.6, 0.86);
  late final Animation<double> _rule = _interval(
    0.66,
    0.9,
    Curves.easeInOutCubic,
  );
  late final Animation<double> _tagline = _interval(0.72, 0.96);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller.isAnimating || _controller.isCompleted) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
      Future.delayed(const Duration(milliseconds: 500), widget.onFinished);
      return;
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
    // Material (not a bare ColoredBox) so text gets proper defaults.
    return Material(
      color: BrandColors.ink,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final markBottom =
              MediaQuery.sizeOf(context).height / 2 +
              PriorixSplash.markSize / 2;
          return Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      radius: 0.7,
                      colors: [
                        BrandColors.gold.withValues(
                          alpha: 0.08 * _ambient.value,
                        ),
                        BrandColors.gold.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              PriorixMark(
                size: PriorixSplash.markSize,
                light: _light.value,
                glow: _glow.value,
              ),
              Positioned(
                left: 0,
                right: 0,
                top: markBottom + 40 + 10 * (1 - _word.value),
                child: Opacity(
                  opacity: _word.value,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'PRIORIX',
                        style: TextStyle(
                          color: BrandColors.ivory,
                          fontSize: 21,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 13 - 4 * _word.value,
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: 32 * _rule.value,
                        height: 1,
                        child: const ColoredBox(color: BrandColors.gold),
                      ),
                      const SizedBox(height: 14),
                      Opacity(
                        opacity: _tagline.value,
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
