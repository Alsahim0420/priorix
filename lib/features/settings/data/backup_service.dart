import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../../categories/domain/task_category.dart';
import '../../tasks/data/models/task_model.dart';
import '../domain/app_settings.dart';

class PriorixBackup {
  const PriorixBackup({
    required this.tasks,
    required this.categories,
    required this.settings,
  });

  final List<TaskModel> tasks;
  final List<TaskCategory> categories;
  final AppSettings settings;
}

class BackupService {
  Future<String> exportBackup({
    required List<TaskModel> tasks,
    required List<TaskCategory> categories,
    required AppSettings settings,
  }) async {
    final payload = jsonEncode({
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'tasks': tasks.map((task) => task.toMap()).toList(),
      'categories': categories.map((category) => category.toMap()).toList(),
      'settings': settings.toMap(),
    });
    final name =
        'priorix-backup-${DateFormat('yyyyMMdd-HHmm').format(DateTime.now())}.json';
    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Priorix backup',
      fileName: name,
      bytes: utf8.encode(payload),
    );
    if (path != null) return path;

    final directory = await getApplicationDocumentsDirectory();
    final fallbackPath = '${directory.path}/$name';
    await File(fallbackPath).writeAsString(payload);
    return fallbackPath;
  }

  Future<PriorixBackup?> importBackup() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Choose Priorix backup',
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    final file = result?.files.single;
    if (file == null) return null;
    final contents = file.bytes == null
        ? await File(file.path!).readAsString()
        : utf8.decode(file.bytes!);
    final decoded = jsonDecode(contents) as Map<String, dynamic>;
    return PriorixBackup(
      tasks: (decoded['tasks'] as List? ?? [])
          .whereType<Map>()
          .map(TaskModel.fromMap)
          .toList(),
      categories: (decoded['categories'] as List? ?? [])
          .whereType<Map>()
          .map(TaskCategory.fromMap)
          .toList(),
      settings: AppSettings.fromMap(decoded['settings'] as Map? ?? const {}),
    );
  }
}
