import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../settings/data/notification_service.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../../domain/entities/task.dart';
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

  Future<void> loadTasks() async {
    emit(state.copyWith(status: TaskStatus.loading));
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
      createdAt: now,
      updatedAt: now,
    );
    await createTaskUseCase(task);
    await _syncReminder(task);
    await loadTasks();
  }

  Future<void> updateTask(Task task) async {
    final updated = task.copyWith(updatedAt: DateTime.now());
    await updateTaskUseCase(updated);
    await _syncReminder(updated);
    await loadTasks();
  }

  Future<void> replaceTasks(List<Task> tasks) async {
    await updateTaskUseCase.repository.replaceTasks(tasks);
    await notificationService.rescheduleTaskReminders(
      tasks: tasks,
      settings: settingsCubit.state.settings,
    );
    await loadTasks();
  }

  Future<void> deleteTask(String id) async {
    await deleteTaskUseCase(id);
    await notificationService.cancelTaskReminder(id);
    await loadTasks();
  }

  Future<void> toggleCompleted(String id) async {
    await toggleTaskCompletedUseCase(id);
    final task = state.tasks.where((task) => task.id == id).firstOrNull;
    if (task != null) {
      if (task.isCompleted) {
        await _syncReminder(task.copyWith(isCompleted: false));
      } else {
        await notificationService.cancelTaskReminder(id);
      }
    }
    await loadTasks();
  }

  Future<void> syncAllReminders() async {
    await notificationService.rescheduleTaskReminders(
      tasks: state.tasks,
      settings: settingsCubit.state.settings,
    );
  }

  Future<void> _syncReminder(Task task) {
    return notificationService.scheduleTaskReminder(
      task: task,
      notificationsEnabled: settingsCubit.state.settings.notificationsEnabled,
    );
  }

  static String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}
