import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

enum TaskQuadrant { doNow, schedule, delegate, later }

extension TaskQuadrantX on TaskQuadrant {
  String get title => switch (this) {
    TaskQuadrant.doNow => 'Do Now',
    TaskQuadrant.schedule => 'Schedule',
    TaskQuadrant.delegate => 'Delegate',
    TaskQuadrant.later => 'Later',
  };

  String get subtitle => switch (this) {
    TaskQuadrant.doNow => 'Urgent + important',
    TaskQuadrant.schedule => 'Important, not urgent',
    TaskQuadrant.delegate => 'Urgent, less important',
    TaskQuadrant.later => 'Not urgent, not important',
  };

  IconData get icon => switch (this) {
    TaskQuadrant.doNow => Icons.bolt_rounded,
    TaskQuadrant.schedule => Icons.event_available_rounded,
    TaskQuadrant.delegate => Icons.outbound_rounded,
    TaskQuadrant.later => Icons.bookmark_added_rounded,
  };

  Color get color => switch (this) {
    TaskQuadrant.doNow => AppColors.primaryGold,
    TaskQuadrant.schedule => AppColors.emerald,
    TaskQuadrant.delegate => AppColors.royalBlue,
    TaskQuadrant.later => AppColors.textSecondary,
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
  });

  final String id;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final DateTime? reminderAt;
  final String? category;
  final bool isUrgent;
  final bool isImportant;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  TaskQuadrant get quadrant {
    if (isUrgent && isImportant) return TaskQuadrant.doNow;
    if (!isUrgent && isImportant) return TaskQuadrant.schedule;
    if (isUrgent && !isImportant) return TaskQuadrant.delegate;
    return TaskQuadrant.later;
  }

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
  ];
}
