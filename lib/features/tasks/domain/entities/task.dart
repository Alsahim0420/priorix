import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

enum TaskQuadrant { doNow, schedule, delegate, eliminate }

extension TaskQuadrantX on TaskQuadrant {
  static TaskQuadrant from({required bool urgent, required bool important}) {
    if (urgent && important) return TaskQuadrant.doNow;
    if (important) return TaskQuadrant.schedule;
    if (urgent) return TaskQuadrant.delegate;
    return TaskQuadrant.eliminate;
  }

  bool get isUrgent =>
      this == TaskQuadrant.doNow || this == TaskQuadrant.delegate;

  bool get isImportant =>
      this == TaskQuadrant.doNow || this == TaskQuadrant.schedule;

  String get title => switch (this) {
    TaskQuadrant.doNow => 'Hacer ya',
    TaskQuadrant.schedule => 'Planificar',
    TaskQuadrant.delegate => 'Delegar',
    TaskQuadrant.eliminate => 'Eliminar',
  };

  String get subtitle => switch (this) {
    TaskQuadrant.doNow => 'Urgente e importante',
    TaskQuadrant.schedule => 'Importante, no urgente',
    TaskQuadrant.delegate => 'Urgente, no importante',
    TaskQuadrant.eliminate => 'Ni urgente ni importante',
  };

  String get guidance => switch (this) {
    TaskQuadrant.doNow => 'Hazlo hoy. Es lo que más impacto tiene ahora mismo.',
    TaskQuadrant.schedule =>
      'Reserva un bloque en tu agenda y protégelo. Aquí vive el trabajo que te hace avanzar.',
    TaskQuadrant.delegate =>
      'Encuentra a alguien que pueda resolverlo por ti y haz seguimiento.',
    TaskQuadrant.eliminate =>
      'Suéltalo o déjalo para cuando sobre tiempo. Menos ruido, más foco.',
  };

  String get code => 'Q${index + 1}';

  IconData get icon => switch (this) {
    TaskQuadrant.doNow => Icons.bolt_rounded,
    TaskQuadrant.schedule => Icons.event_available_rounded,
    TaskQuadrant.delegate => Icons.people_alt_rounded,
    TaskQuadrant.eliminate => Icons.remove_circle_outline_rounded,
  };

  Color get color => switch (this) {
    TaskQuadrant.doNow => AppColors.ember,
    TaskQuadrant.schedule => AppColors.jade,
    TaskQuadrant.delegate => AppColors.iris,
    TaskQuadrant.eliminate => AppColors.stone,
  };
}

class Task extends Equatable {
  const Task({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.reminderAt,
    this.category,
    required this.isUrgent,
    required this.isImportant,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
    this.alertThresholds = const [],
    this.notifyAtDeadline = true,
    this.links = const [],
  });

  final String id;
  final String title;
  final String? description;

  /// Deadline (date and time).
  final DateTime? dueDate;

  /// Optional one-off reminder at an exact moment.
  final DateTime? reminderAt;
  final String? category;
  final bool isUrgent;
  final bool isImportant;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Percentages of time remaining (between [createdAt] and [dueDate]) at
  /// which to notify, e.g. `[50, 20]`.
  final List<int> alertThresholds;
  final bool notifyAtDeadline;

  /// URLs of related Notes, Freeform boards or web pages.
  final List<String> links;

  TaskQuadrant get quadrant =>
      TaskQuadrantX.from(urgent: isUrgent, important: isImportant);

  /// Fraction of the time window already consumed (0–1), or null without a
  /// deadline.
  double? elapsedFraction(DateTime now) {
    final due = dueDate;
    if (due == null) return null;
    final total = due.difference(createdAt).inSeconds;
    if (total <= 0) return now.isBefore(due) ? 0 : 1;
    return (now.difference(createdAt).inSeconds / total).clamp(0.0, 1.0);
  }

  bool isOverdue(DateTime now) =>
      !isCompleted && dueDate != null && now.isAfter(dueDate!);

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    DateTime? reminderAt,
    String? category,
    bool? isUrgent,
    bool? isImportant,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<int>? alertThresholds,
    bool? notifyAtDeadline,
    List<String>? links,
    bool clearDescription = false,
    bool clearDueDate = false,
    bool clearReminder = false,
    bool clearCategory = false,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: clearDescription ? null : description ?? this.description,
      dueDate: clearDueDate ? null : dueDate ?? this.dueDate,
      reminderAt: clearReminder ? null : reminderAt ?? this.reminderAt,
      category: clearCategory ? null : category ?? this.category,
      isUrgent: isUrgent ?? this.isUrgent,
      isImportant: isImportant ?? this.isImportant,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      alertThresholds: alertThresholds ?? this.alertThresholds,
      notifyAtDeadline: notifyAtDeadline ?? this.notifyAtDeadline,
      links: links ?? this.links,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    dueDate,
    reminderAt,
    category,
    isUrgent,
    isImportant,
    isCompleted,
    createdAt,
    updatedAt,
    alertThresholds,
    notifyAtDeadline,
    links,
  ];
}
