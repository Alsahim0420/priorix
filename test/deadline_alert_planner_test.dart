import 'package:flutter_test/flutter_test.dart';
import 'package:priorix/features/tasks/data/models/task_model.dart';
import 'package:priorix/features/tasks/domain/services/deadline_alert_planner.dart';

void main() {
  final start = DateTime(2026, 10, 20, 9);
  final deadline = DateTime(2026, 10, 22, 9); // 48 h window

  group('DeadlineAlertPlanner', () {
    test('fires thresholds at the right share of remaining time', () {
      final alerts = DeadlineAlertPlanner.plan(
        start: start,
        deadline: deadline,
        thresholds: [50, 20],
        notifyAtDeadline: true,
      );
      expect(alerts.map((a) => a.at), [
        DateTime(2026, 10, 21, 9), // 50 % left → 24 h in
        DateTime(2026, 10, 21, 23, 24), // 20 % left → 38.4 h in
        deadline,
      ]);
      expect(alerts.map((a) => a.kind), [
        AlertKind.threshold,
        AlertKind.threshold,
        AlertKind.deadline,
      ]);
      expect(alerts.first.percentRemaining, 50);
    });

    test('supports thresholds above 50 %', () {
      final alerts = DeadlineAlertPlanner.plan(
        start: start,
        deadline: deadline,
        thresholds: [75],
      );
      expect(alerts.single.at, DateTime(2026, 10, 20, 21));
    });

    test('normalize dedupes, drops out-of-range and sorts high to low', () {
      expect(DeadlineAlertPlanner.normalize([20, 50, 20, 0, 100, 5, -3]), [
        50,
        20,
        5,
      ]);
    });

    test('slots are unique per task', () {
      final alerts = DeadlineAlertPlanner.plan(
        start: start,
        deadline: deadline,
        thresholds: [90, 75, 50, 25, 20, 10, 5, 1],
        notifyAtDeadline: true,
        reminderAt: start.add(const Duration(hours: 1)),
      );
      final slots = alerts.map((a) => a.slot).toSet();
      expect(slots.length, alerts.length);
      expect(slots.every((s) => s < DeadlineAlertPlanner.slotCount), isTrue);
    });

    test('no thresholds when the deadline precedes the start', () {
      final alerts = DeadlineAlertPlanner.plan(
        start: deadline,
        deadline: start,
        thresholds: [50],
        notifyAtDeadline: true,
      );
      expect(alerts.single.kind, AlertKind.deadline);
    });
  });

  group('TaskModel legacy migration', () {
    test('date-only deadlines become end of day, alerts off', () {
      final model = TaskModel.fromMap({
        'id': '1',
        'title': 'Legacy',
        'dueDate': DateTime(2026, 10, 24).toIso8601String(),
        'isUrgent': true,
        'isImportant': true,
        'isCompleted': false,
        'createdAt': start.toIso8601String(),
        'updatedAt': start.toIso8601String(),
      });
      expect(model.dueDate, DateTime(2026, 10, 24, 23, 59));
      expect(model.alertThresholds, isEmpty);
      expect(model.notifyAtDeadline, isFalse);
    });

    test('round-trips new fields', () {
      final model = TaskModel(
        id: '2',
        title: 'Nueva',
        dueDate: DateTime(2026, 10, 24),
        isUrgent: false,
        isImportant: true,
        isCompleted: false,
        createdAt: start,
        updatedAt: start,
        alertThresholds: const [50, 20],
      );
      final restored = TaskModel.fromMap(model.toMap());
      expect(restored, model);
    });
  });
}
