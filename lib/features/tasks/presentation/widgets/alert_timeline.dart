import 'package:flutter/material.dart';
import '../../../../app/theme/app_palette.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../domain/services/deadline_alert_planner.dart';

/// Vertical list of planned alerts: past ones dimmed, the next one
/// highlighted.
class AlertTimeline extends StatelessWidget {
  const AlertTimeline({
    super.key,
    required this.alerts,
    required this.now,
    this.muted = false,
  });

  final List<PlannedAlert> alerts;
  final DateTime now;

  /// When notifications are off, nothing will actually fire.
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final nextIndex = alerts.indexWhere((alert) => alert.at.isAfter(now));
    return Column(
      children: [
        for (var i = 0; i < alerts.length; i++)
          _TimelineRow(
            alert: alerts[i],
            now: now,
            isNext: i == nextIndex && !muted,
            isLast: i == alerts.length - 1,
            lineColor: p.hairline,
          ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.alert,
    required this.now,
    required this.isNext,
    required this.isLast,
    required this.lineColor,
  });

  final PlannedAlert alert;
  final DateTime now;
  final bool isNext;
  final bool isLast;
  final Color lineColor;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final past = !alert.at.isAfter(now);
    final dotColor = isNext
        ? p.accent
        : past
        ? p.textTertiary
        : p.textSecondary;
    final icon = switch (alert.kind) {
      AlertKind.threshold => Icons.hourglass_bottom_rounded,
      AlertKind.deadline => Icons.flag_rounded,
      AlertKind.reminder => Icons.alarm_rounded,
    };

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isNext
                        ? p.accent.withValues(alpha: 0.16)
                        : p.surfaceHigh,
                    border: Border.all(
                      color: isNext
                          ? p.accent.withValues(alpha: 0.5)
                          : Colors.transparent,
                    ),
                  ),
                  child: Icon(icon, size: 13, color: dotColor),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1,
                      margin: const EdgeInsets.only(top: 4),
                      color: lineColor,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.label,
                          style: context.text.titleSmall?.copyWith(
                            color: past ? p.textTertiary : null,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          past
                              ? 'Ya pasó'
                              : isNext
                              ? 'Próximo aviso · ${alert.at.relativeTo(now)}'
                              : alert.at.relativeTo(now),
                          style: context.text.bodySmall?.copyWith(
                            color: isNext ? p.accent : p.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    alert.at.smartLabel(now),
                    style: context.text.labelMedium?.copyWith(
                      color: past ? p.textTertiary : p.textSecondary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
