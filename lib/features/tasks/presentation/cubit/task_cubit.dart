import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../settings/data/notification_service.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../../domain/entities/task.dart';
import '../../domain/services/deadline_alert_planner.dart';
import '../../domain/usecases/create_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/toggle_task_completed.dart';
import '../../domain/usecases/update_task.dart';
import 'task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  TaskCubit({
    required this.getTasksUseCase,
    required this.createTaskUseCase,
    required this.updateTaskUseCase,
    required this.deleteTaskUseCase,
    required this.toggleTaskCompletedUseCase,
    required this.notificationService,
    required this.settingsCubit,
  }) : super(const TaskState());

  final GetTasks getTasksUseCase;
  final CreateTask createTaskUseCase;
  final UpdateTask updateTaskUseCase;
  final DeleteTask deleteTaskUseCase;
  final ToggleTaskCompleted toggleTaskCompletedUseCase;
  final NotificationService notificationService;
  final SettingsCubit settingsCubit;
  final _uuid = const Uuid();

  bool get _notificationsEnabled =>
      settingsCubit.state.settings.notificationsEnabled;

  Future<void> loadTasks() async {
    if (state.status == TaskStatus.initial) {
      emit(state.copyWith(status: TaskStatus.loading));
    }
    try {
      emit(
        TaskState(status: TaskStatus.success, tasks: await getTasksUseCase()),
      );
    } catch (error) {
      emit(state.copyWith(status: TaskStatus.failure, error: error.toString()));
    }
  }

  Future<void> createTask({
    required String title,
    String? description,
    DateTime? dueDate,
    DateTime? reminderAt,
    String? category,
    required bool isUrgent,
    required bool isImportant,
    List<int> alertThresholds = const [],
    bool notifyAtDeadline = true,
    List<String> links = const [],
    DateTime? createdAt,
  }) async {
    final now = DateTime.now();
    final task = Task(
      id: _uuid.v4(),
      title: title.trim(),
      description: _blankToNull(description),
      dueDate: dueDate,
      reminderAt: reminderAt,
      category: _blankToNull(category),
      isUrgent: isUrgent,
      isImportant: isImportant,
      isCompleted: false,
      createdAt: createdAt ?? now,
      updatedAt: now,
      alertThresholds: DeadlineAlertPlanner.normalize(alertThresholds),
      notifyAtDeadline: notifyAtDeadline,
      links: links,
    );
    await createTaskUseCase(task);
    await _syncAlerts(task);
    await loadTasks();
  }

  Future<void> updateTask(Task task) async {
    final updated = task.copyWith(
      updatedAt: DateTime.now(),
      alertThresholds: DeadlineAlertPlanner.normalize(task.alertThresholds),
    );
    await updateTaskUseCase(updated);
    await _syncAlerts(updated);
    await loadTasks();
  }

  Future<void> moveToQuadrant(Task task, TaskQuadrant quadrant) {
    if (task.quadrant == quadrant) return Future.value();
    return updateTask(
      task.copyWith(
        isUrgent: quadrant.isUrgent,
        isImportant: quadrant.isImportant,
      ),
    );
  }

  Future<void> replaceTasks(List<Task> tasks) async {
    await updateTaskUseCase.repository.replaceTasks(tasks);
    await loadTasks();
    await syncAllReminders();
  }

  Future<void> deleteTask(String id) async {
    await deleteTaskUseCase(id);
    await notificationService.cancelTaskAlerts(id);
    await loadTasks();
  }

  Future<void> toggleCompleted(String id) async {
    await toggleTaskCompletedUseCase(id);
    await loadTasks();
    final task = state.tasks.where((task) => task.id == id).firstOrNull;
    if (task != null) await _syncAlerts(task);
  }

  Future<void> syncAllReminders() {
    return notificationService.rescheduleAll(
      tasks: state.tasks,
      enabled: _notificationsEnabled,
    );
  }

  Future<void> _syncAlerts(Task task) {
    return notificationService.scheduleTaskAlerts(
      task: task,
      enabled: _notificationsEnabled,
    );
  }

  static String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}
