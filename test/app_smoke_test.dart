import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:priorix/app/app.dart';
import 'package:priorix/features/categories/data/category_local_datasource.dart';
import 'package:priorix/features/categories/presentation/cubit/category_cubit.dart';
import 'package:priorix/features/settings/data/notification_service.dart';
import 'package:priorix/features/settings/data/settings_local_datasource.dart';
import 'package:priorix/features/settings/domain/app_settings.dart';
import 'package:priorix/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:priorix/features/tasks/data/datasources/task_local_datasource.dart';
import 'package:priorix/features/tasks/data/models/task_model.dart';
import 'package:priorix/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:priorix/features/tasks/domain/usecases/create_task.dart';
import 'package:priorix/features/tasks/domain/usecases/delete_task.dart';
import 'package:priorix/features/tasks/domain/usecases/get_tasks.dart';
import 'package:priorix/features/tasks/domain/usecases/toggle_task_completed.dart';
import 'package:priorix/features/tasks/domain/usecases/update_task.dart';
import 'package:priorix/features/tasks/presentation/cubit/task_cubit.dart';

class _MemoryTasks implements TaskLocalDataSource {
  final _tasks = <String, TaskModel>{};

  @override
  Future<List<TaskModel>> getTasks() async => _tasks.values.toList();

  @override
  Future<void> saveTask(TaskModel task) async => _tasks[task.id] = task;

  @override
  Future<void> replaceTasks(List<TaskModel> tasks) async {
    _tasks
      ..clear()
      ..addAll({for (final t in tasks) t.id: t});
  }

  @override
  Future<void> deleteTask(String id) async => _tasks.remove(id);
}

void main() {
  late Directory dir;

  setUpAll(() async {
    Intl.defaultLocale = 'es';
    await initializeDateFormatting('es');
    dir = await Directory.systemTemp.createTemp('priorix_test');
    Hive.init(dir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    await dir.delete(recursive: true);
  });

  for (final (preset, device, size) in [
    (AppThemePreset.midnight, 'phone', const Size(390, 844)),
    (AppThemePreset.porcelainLight, 'phone', const Size(390, 844)),
    (AppThemePreset.midnight, 'iPad landscape', const Size(1194, 834)),
  ]) {
    testWidgets('every screen renders without errors '
        '(${preset.name}, $device)', (tester) async {
      tester.view.physicalSize = size * 2;
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);

      final box = await tester.runAsync(
        () => Hive.openBox<dynamic>('settings_${preset.name}_${size.width}'),
      );
      final settingsData = SettingsLocalDataSource(box!);
      await tester.runAsync(
        () => settingsData.saveSettings(
          AppSettings(
            themePreset: preset,
            onboardingCompleted: true,
            userName: 'Pablo',
          ),
        ),
      );
      final notifications = NotificationService(); // not initialized: no-op
      final settings = SettingsCubit(
        localDataSource: settingsData,
        notificationService: notifications,
      )..loadSettings();
      final categories = CategoryCubit(CategoryLocalDataSource(box));
      await categories.loadCategories();
      final repo = TaskRepositoryImpl(_MemoryTasks());
      final tasks = TaskCubit(
        getTasksUseCase: GetTasks(repo),
        createTaskUseCase: CreateTask(repo),
        updateTaskUseCase: UpdateTask(repo),
        deleteTaskUseCase: DeleteTask(repo),
        toggleTaskCompletedUseCase: ToggleTaskCompleted(repo),
        notificationService: notifications,
        settingsCubit: settings,
      );
      final now = DateTime.now();
      await tester.runAsync(() async {
        await tasks.createTask(
          title: 'Preparar propuesta para el comité de dirección',
          links: ['https://www.icloud.com/notes/0abc#Cifras_comité'],
          description: 'Revisar números con finanzas',
          category: 'Trabajo',
          isUrgent: true,
          isImportant: true,
          dueDate: now.add(const Duration(hours: 5)),
          alertThresholds: [50, 20],
          createdAt: now.subtract(const Duration(hours: 5)),
        );
        await tasks.createTask(
          title: 'Plan trimestral',
          isUrgent: false,
          isImportant: true,
          dueDate: now.add(const Duration(days: 3)),
          alertThresholds: [75, 50, 25, 10],
          links: [
            'https://www.icloud.com/freeform/0xyz#Roadmap_Q4',
            'https://www.icloud.com/notes/0abc#Ideas',
          ],
        );
        await tasks.createTask(
          title: 'Responder correos',
          isUrgent: true,
          isImportant: false,
          dueDate: now.subtract(const Duration(hours: 2)),
          createdAt: now.subtract(const Duration(days: 1)),
        );
        await tasks.createTask(
          title: 'Ordenar escritorio',
          isUrgent: false,
          isImportant: false,
        );
      });

      await tester.pumpWidget(
        PriorixApp(
          taskCubit: tasks,
          categoryCubit: categories,
          settingsCubit: settings,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Pablo'), findsOneWidget);

      for (final tab in ['Matriz', 'Agenda', 'Ajustes', 'Inicio']) {
        await tester.tap(find.text(tab).last);
        await tester.pumpAndSettle();
      }

      // Task detail.
      await tester.scrollUntilVisible(
        find.text('Plan trimestral'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Plan trimestral').first);
      await tester.pumpAndSettle();
      expect(find.text('Alertas'), findsOneWidget);
      expect(find.text('Queda el 50 %'), findsOneWidget);
      expect(find.text('Roadmap Q4'), findsOneWidget);

      // Editor from detail.
      await tester.tap(find.byTooltip('Editar'));
      await tester.pumpAndSettle();
      expect(find.text('Editar tarea'), findsOneWidget);
      await tester.drag(find.byType(ListView).last, const Offset(0, -1600));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Cerrar'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Volver'));
      await tester.pumpAndSettle();

      // New task editor from the nav.
      await tester.tap(find.bySemanticsLabel('Nueva tarea'));
      await tester.pumpAndSettle();
      expect(find.text('¿Qué hay que hacer?'), findsOneWidget);
      await tester.tap(find.text('Mañana 09:00'));
      await tester.pumpAndSettle();
      await tester.dragUntilVisible(
        find.text('Vista previa'),
        find.byType(ListView).last,
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();
      expect(find.text('Vista previa'), findsOneWidget);
      expect(find.text('Queda el 20 %'), findsOneWidget);
    });
  }
}
