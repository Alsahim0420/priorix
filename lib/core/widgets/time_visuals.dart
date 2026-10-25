import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_palette.dart';

/// Color that escalates as the deadline approaches.
Color urgencyColor({
  required Color base,
  required double? elapsed,
  bool overdue = false,
}) {
  if (overdue) return AppColors.danger;
  if (elapsed != null && elapsed >= 0.8) return AppColors.ember;
  return base;
}

/// Thin progress bar of consumed time with dots where alerts fire (dim once
/// sent, bright while pending).
class TimeProgressBar extends StatelessWidget {
  const TimeProgressBar({
    super.key,
    required this.elapsed,
    required this.color,
    this.marks = const [],
    this.thickness = 4,
  });

  /// 0–1 fraction of time consumed.
  final double elapsed;
  final Color color;

  /// Positions (0–1 of elapsed time) at which alerts fire.
  final List<double> marks;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SizedBox(
      height: math.max(thickness * 2.4, 10),
      width: double.infinity,
      child: CustomPaint(
        painter: _BarPainter(
          elapsed: elapsed.clamp(0, 1),
          color: color,
          track: p.textPrimary.withValues(alpha: 0.08),
          markSent: p.textTertiary,
          markPending: p.textPrimary,
          ring: p.surface,
          marks: marks,
          thickness: thickness,
        ),
      ),
    );
  }
}

class _BarPainter extends CustomPainter {
  _BarPainter({
    required this.elapsed,
    required this.color,
    required this.track,
    required this.markSent,
    required this.markPending,
    required this.ring,
    required this.marks,
    required this.thickness,
  });

  final double elapsed;
  final Color color;
  final Color track;
  final Color markSent;
  final Color markPending;
  final Color ring;
  final List<double> marks;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    final radius = Radius.circular(thickness);
    final trackRect = RRect.fromLTRBR(
      0,
      cy - thickness / 2,
      size.width,
      cy + thickness / 2,
      radius,
    );
    canvas.drawRRect(trackRect, Paint()..color = track);
    if (elapsed > 0) {
      final fill = RRect.fromLTRBR(
        0,
        cy - thickness / 2,
        math.max(size.width * elapsed, thickness),
        cy + thickness / 2,
        radius,
      );
      canvas.drawRRect(
        fill,
        Paint()
          ..shader = LinearGradient(
            colors: [color.withValues(alpha: 0.55), color],
          ).createShader(fill.outerRect),
      );
    }
    final dot = thickness * 0.95 + 1;
    for (final mark in marks) {
      final x = (size.width * mark).clamp(dot, size.width - dot);
      // Same language as the ring: dim = already sent, bright = pending.
      final sent = mark <= elapsed;
      canvas.drawCircle(Offset(x, cy), dot + 1.6, Paint()..color = ring);
      canvas.drawCircle(
        Offset(x, cy),
        dot,
        Paint()..color = sent ? markSent : markPending,
      );
    }
  }

  @override
  bool shouldRepaint(_BarPainter old) =>
      old.elapsed != elapsed ||
      old.color != color ||
      old.track != track ||
      old.thickness != thickness ||
      !_listEquals(old.marks, marks);
}

/// Circular gauge. [value] is the filled fraction (0–1), drawn clockwise from
/// the top; [marks] are fractions on the same scale.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    required this.color,
    this.size = 120,
    this.stroke = 9,
    this.marks = const [],
    this.child,
  });

  final double value;
  final Color color;
  final double size;
  final double stroke;
  final List<double> marks;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value.clamp(0, 1)),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, animated, child) => SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _RingPainter(
            value: animated,
            color: color,
            track: p.textPrimary.withValues(alpha: 0.08),
            markIdle: p.textTertiary,
            ring: p.surface,
            stroke: stroke,
            marks: marks,
          ),
          child: Center(child: child),
        ),
      ),
      child: child,
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.value,
    required this.color,
    required this.track,
    required this.markIdle,
    required this.ring,
    required this.stroke,
    required this.marks,
  });

  final double value;
  final Color color;
  final Color track;
  final Color markIdle;
  final Color ring;
  final double stroke;
  final List<double> marks;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = track,
    );
    if (value > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        math.pi * 2 * value,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..shader = SweepGradient(
            startAngle: -math.pi / 2,
            endAngle: math.pi * 1.5,
            colors: [color.withValues(alpha: 0.5), color],
            transform: const GradientRotation(-math.pi / 2),
          ).createShader(rect),
      );
    }
    for (final mark in marks) {
      final angle = -math.pi / 2 + math.pi * 2 * mark;
      final offset =
          center + Offset(math.cos(angle) * radius, math.sin(angle) * radius);
      final reached = mark <= value;
      canvas.drawCircle(offset, stroke * 0.42 + 1.8, Paint()..color = ring);
      canvas.drawCircle(
        offset,
        stroke * 0.42,
        Paint()..color = reached ? color : markIdle,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value ||
      old.color != color ||
      old.track != track ||
      !_listEquals(old.marks, marks);
}

bool _listEquals(List<double> a, List<double> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
