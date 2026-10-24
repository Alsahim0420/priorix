import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
  final dataSource = HiveTaskLocalDataSource(taskBox);
  final repository = TaskRepositoryImpl(dataSource);
  final categoryDataSource = CategoryLocalDataSource(settingsBox);
  final notificationService = NotificationService();
  await notificationService.initialize();
  final settingsCubit = SettingsCubit(
    localDataSource: SettingsLocalDataSource(settingsBox),
    notificationService: notificationService,
  );

  runApp(
    PriorixApp(
      categoryCubit: CategoryCubit(categoryDataSource),
      settingsCubit: settingsCubit,
      taskCubit: TaskCubit(
        getTasksUseCase: GetTasks(repository),
        createTaskUseCase: CreateTask(repository),
        updateTaskUseCase: UpdateTask(repository),
        deleteTaskUseCase: DeleteTask(repository),
        toggleTaskCompletedUseCase: ToggleTaskCompleted(repository),
        notificationService: notificationService,
        settingsCubit: settingsCubit,
      ),
    ),
  );
}
