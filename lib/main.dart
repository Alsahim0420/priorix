import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'app/app.dart';
import 'features/categories/data/category_local_datasource.dart';
import 'features/categories/presentation/cubit/category_cubit.dart';
import 'features/settings/data/notification_service.dart';
import 'features/settings/data/settings_local_datasource.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';
import 'features/tasks/data/datasources/task_local_datasource.dart';
import 'features/tasks/data/models/task_model.dart';
import 'features/tasks/data/repositories/task_repository_impl.dart';
import 'features/tasks/domain/usecases/create_task.dart';
import 'features/tasks/domain/usecases/delete_task.dart';
import 'features/tasks/domain/usecases/get_tasks.dart';
import 'features/tasks/domain/usecases/toggle_task_completed.dart';
import 'features/tasks/domain/usecases/update_task.dart';
import 'features/tasks/presentation/cubit/task_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'es';
  await initializeDateFormatting('es');
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(TaskModelAdapter());
  }
  final taskBox = await Hive.openBox<TaskModel>(
    HiveTaskLocalDataSource.boxName,
  );
  final settingsBox = await Hive.openBox<dynamic>(
    CategoryLocalDataSource.boxName,
  );
  final repository = TaskRepositoryImpl(HiveTaskLocalDataSource(taskBox));
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Load state before the first frame so the right screen and theme show
  // immediately (no onboarding flash).
  final settingsCubit = SettingsCubit(
    localDataSource: SettingsLocalDataSource(settingsBox),
    notificationService: notificationService,
  )..loadSettings();
  final categoryCubit = CategoryCubit(CategoryLocalDataSource(settingsBox));
  await categoryCubit.loadCategories();
  final taskCubit = TaskCubit(
    getTasksUseCase: GetTasks(repository),
    createTaskUseCase: CreateTask(repository),
    updateTaskUseCase: UpdateTask(repository),
    deleteTaskUseCase: DeleteTask(repository),
    toggleTaskCompletedUseCase: ToggleTaskCompleted(repository),
    notificationService: notificationService,
    settingsCubit: settingsCubit,
  );
  await taskCubit.loadTasks();

  runApp(
    PriorixApp(
      categoryCubit: categoryCubit,
      settingsCubit: settingsCubit,
      taskCubit: taskCubit,
    ),
  );

  // Re-plan every alert on launch: migrates ids from older versions and
  // drops alerts for tasks edited elsewhere (e.g. via backup import).
  unawaited(taskCubit.syncAllReminders());
}
