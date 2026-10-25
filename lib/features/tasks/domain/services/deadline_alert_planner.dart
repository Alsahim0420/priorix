import 'package:equatable/equatable.dart';
import '../entities/task.dart';

enum AlertKind { threshold, deadline, reminder }

class PlannedAlert extends Equatable {
  const PlannedAlert({
    required this.at,
    required this.kind,
    required this.slot,
    this.percentRemaining,
  });

  final DateTime at;
  final AlertKind kind;

  /// Stable per-task position, used to derive the notification id.
  final int slot;
  final int? percentRemaining;

  String get label => switch (kind) {
    AlertKind.threshold => 'Queda el $percentRemaining %',
    AlertKind.deadline => 'Al vencer',
    AlertKind.reminder => 'Recordatorio',
  };

  @override
  List<Object?> get props => [at, kind, slot, percentRemaining];
}

class AlertPreset {
  const AlertPreset(this.name, this.thresholds);

  final String name;
  final List<int> thresholds;
}

/// Turns "notify me when X % of the time is left" into concrete moments.
///
/// The time window runs from the task's creation to its deadline, so a 50 %
/// threshold on a task created Monday 09:00 and due Wednesday 09:00 fires on
/// Tuesday 09:00.
class DeadlineAlertPlanner {
  const DeadlineAlertPlanner._();

  static const maxThresholds = 8;
  static const reminderSlot = 0;
  static const deadlineSlot = 1;
  static const firstThresholdSlot = 2;
  static const slotCount = firstThresholdSlot + maxThresholds;

  static const suggested = [90, 75, 50, 25, 20, 10, 5];

  static const presets = [
    AlertPreset('Esencial', [50, 20]),
    AlertPreset('Intenso', [75, 50, 25, 10]),
    AlertPreset('Con margen', [90, 75, 50]),
    AlertPreset('Última hora', [10, 5]),
  ];

  /// Unique values in (0, 100), highest first, capped at [maxThresholds].
  static List<int> normalize(Iterable<int> values) {
    final unique = values.where((v) => v > 0 && v < 100).toSet().toList()
      ..sort((a, b) => b.compareTo(a));
    return unique.take(maxThresholds).toList();
  }

  static DateTime thresholdTime({
    required DateTime start,
    required DateTime deadline,
    required int percentRemaining,
  }) {
    final total = deadline.difference(start).inMicroseconds;
    final offset = (total * (100 - percentRemaining) / 100).round();
    return start.add(Duration(microseconds: offset));
  }

  static List<PlannedAlert> plan({
    required DateTime start,
    DateTime? deadline,
    List<int> thresholds = const [],
    bool notifyAtDeadline = false,
    DateTime? reminderAt,
  }) {
    final alerts = <PlannedAlert>[
      if (reminderAt != null)
        PlannedAlert(
          at: reminderAt,
          kind: AlertKind.reminder,
          slot: reminderSlot,
        ),
    ];
    if (deadline != null) {
      if (deadline.isAfter(start)) {
        final normalized = normalize(thresholds);
        for (var i = 0; i < normalized.length; i++) {
          alerts.add(
            PlannedAlert(
              at: thresholdTime(
                start: start,
                deadline: deadline,
                percentRemaining: normalized[i],
              ),
              kind: AlertKind.threshold,
              slot: firstThresholdSlot + i,
              percentRemaining: normalized[i],
            ),
          );
        }
      }
      if (notifyAtDeadline) {
        alerts.add(
          PlannedAlert(
            at: deadline,
            kind: AlertKind.deadline,
            slot: deadlineSlot,
          ),
        );
      }
    }
    alerts.sort((a, b) => a.at.compareTo(b.at));
    return alerts;
  }

  static List<PlannedAlert> forTask(Task task) {
    return plan(
      start: task.createdAt,
      deadline: task.dueDate,
      thresholds: task.alertThresholds,
      notifyAtDeadline: task.notifyAtDeadline,
      reminderAt: task.reminderAt,
    );
  }
}
