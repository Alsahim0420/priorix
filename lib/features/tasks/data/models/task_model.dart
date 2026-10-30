import 'package:hive/hive.dart';
import '../../domain/entities/task.dart';

class TaskModel extends Task {
  const TaskModel({
    required super.id,
    required super.title,
    super.description,
    super.dueDate,
    super.reminderAt,
    super.category,
    required super.isUrgent,
    required super.isImportant,
    required super.isCompleted,
    required super.createdAt,
    required super.updatedAt,
    super.alertThresholds,
    super.notifyAtDeadline,
    super.links,
  });

  factory TaskModel.fromEntity(Task task) => TaskModel(
    id: task.id,
    title: task.title,
    description: task.description,
    dueDate: task.dueDate,
    reminderAt: task.reminderAt,
    category: task.category,
    isUrgent: task.isUrgent,
    isImportant: task.isImportant,
    isCompleted: task.isCompleted,
    createdAt: task.createdAt,
    updatedAt: task.updatedAt,
    alertThresholds: task.alertThresholds,
    notifyAtDeadline: task.notifyAtDeadline,
    links: task.links,
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate?.toIso8601String(),
      'reminderAt': reminderAt?.toIso8601String(),
      'category': category,
      'isUrgent': isUrgent,
      'isImportant': isImportant,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'alertThresholds': alertThresholds,
      'notifyAtDeadline': notifyAtDeadline,
      'links': links,
    };
  }

  factory TaskModel.fromMap(Map<dynamic, dynamic> map) {
    final legacy = !map.containsKey('alertThresholds');
    final dueDate = map['dueDate'] == null
        ? null
        : DateTime.parse(map['dueDate'] as String);
    return TaskModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      dueDate: legacy ? _legacyDeadline(dueDate) : dueDate,
      reminderAt: map['reminderAt'] == null
          ? null
          : DateTime.parse(map['reminderAt'] as String),
      category: map['category'] as String?,
      isUrgent: map['isUrgent'] as bool? ?? false,
      isImportant: map['isImportant'] as bool? ?? false,
      isCompleted: map['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      alertThresholds: _intList(map['alertThresholds']),
      notifyAtDeadline: map['notifyAtDeadline'] as bool? ?? !legacy,
      links: _stringList(map['links']),
    );
  }

  /// Older versions stored date-only deadlines at midnight, which would make
  /// "due today" tasks overdue the moment the day starts. Treat them as end
  /// of day instead.
  static DateTime? _legacyDeadline(DateTime? due) {
    if (due == null) return null;
    if (due.hour != 0 || due.minute != 0 || due.second != 0) return due;
    return DateTime(due.year, due.month, due.day, 23, 59);
  }

  static List<int> _intList(dynamic value) {
    if (value is! List) return const [];
    return value.whereType<num>().map((v) => v.toInt()).toList();
  }

  static List<String> _stringList(dynamic value) {
    if (value is! List) return const [];
    return value.whereType<String>().toList();
  }
}

class TaskModelAdapter extends TypeAdapter<TaskModel> {
  @override
  final int typeId = 1;

  @override
  TaskModel read(BinaryReader reader) {
    final fields = <int, dynamic>{};
    final count = reader.readByte();
    for (var i = 0; i < count; i++) {
      fields[reader.readByte()] = reader.read();
    }
    final legacy = !fields.containsKey(11);
    final dueDate = fields[3] as DateTime?;
    return TaskModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      dueDate: legacy ? TaskModel._legacyDeadline(dueDate) : dueDate,
      reminderAt: fields[10] as DateTime?,
      category: fields[4] as String?,
      isUrgent: fields[5] as bool,
      isImportant: fields[6] as bool,
      isCompleted: fields[7] as bool,
      createdAt: fields[8] as DateTime,
      updatedAt: fields[9] as DateTime,
      alertThresholds: TaskModel._intList(fields[11]),
      notifyAtDeadline: fields[12] as bool? ?? !legacy,
      links: TaskModel._stringList(fields[13]),
    );
  }

  @override
  void write(BinaryWriter writer, TaskModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.dueDate)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.isUrgent)
      ..writeByte(6)
      ..write(obj.isImportant)
      ..writeByte(7)
      ..write(obj.isCompleted)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt)
      ..writeByte(10)
      ..write(obj.reminderAt)
      ..writeByte(11)
      ..write(obj.alertThresholds)
      ..writeByte(12)
      ..write(obj.notifyAtDeadline)
      ..writeByte(13)
      ..write(obj.links);
  }
}
