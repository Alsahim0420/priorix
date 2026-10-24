import 'package:equatable/equatable.dart';
import '../../domain/entities/task.dart';

enum TaskStatus { initial, loading, success, failure }

class TaskState extends Equatable {
  const TaskState({
    this.status = TaskStatus.initial,
    this.tasks = const [],
    this.error,
  });

  final TaskStatus status;
  final List<Task> tasks;
  final String? error;

  TaskState copyWith({TaskStatus? status, List<Task>? tasks, String? error}) {
    return TaskState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, tasks, error];
}
