import 'package:flutter_test/flutter_test.dart';
import 'package:priorix/features/tasks/data/models/task_model.dart';
import 'package:priorix/features/tasks/domain/entities/task_link.dart';

void main() {
  group('TaskLinkKind', () {
    test('detects Notes, Freeform and web links', () {
      expect(
        TaskLinkKindX.of('https://www.icloud.com/notes/0abcDEF#Lista'),
        TaskLinkKind.notes,
      );
      expect(TaskLinkKindX.of('mobilenotes://'), TaskLinkKind.notes);
      expect(
        TaskLinkKindX.of('https://www.icloud.com/freeform/0xyz#Tablero'),
        TaskLinkKind.freeform,
      );
      expect(TaskLinkKindX.of('https://example.com/a'), TaskLinkKind.web);
    });
  });

  test('reads the item name from iCloud links', () {
    expect(
      taskLinkName('https://www.icloud.com/freeform/0xyz#Plan_Q4_2026'),
      'Plan Q4 2026',
    );
    expect(taskLinkName('https://www.icloud.com/notes/0abc'), isNull);
  });

  group('normalizeTaskLink', () {
    test('adds https to bare links', () {
      expect(
        normalizeTaskLink('  www.icloud.com/notes/0abc '),
        'https://www.icloud.com/notes/0abc',
      );
    });

    test('keeps app schemes', () {
      expect(normalizeTaskLink('mobilenotes://'), 'mobilenotes://');
    });

    test('rejects text that is not a link', () {
      expect(normalizeTaskLink(''), isNull);
      expect(normalizeTaskLink('comprar leche'), isNull);
    });
  });

  test('links survive a backup round-trip, old backups have none', () {
    final now = DateTime(2026, 10, 29, 12);
    final task = TaskModel(
      id: '1',
      title: 'Plan',
      isUrgent: false,
      isImportant: true,
      isCompleted: false,
      createdAt: now,
      updatedAt: now,
      links: const ['https://www.icloud.com/freeform/0xyz'],
    );
    expect(TaskModel.fromMap(task.toMap()).links, task.links);
    expect(TaskModel.fromMap(task.toMap()..remove('links')).links, isEmpty);
  });
}
