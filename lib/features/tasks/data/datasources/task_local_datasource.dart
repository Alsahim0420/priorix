import 'package:hive/hive.dart';
import '../models/task_model.dart';

abstract class TaskLocalDataSource {
  Future<List<TaskModel>> getTasks();
  Future<void> saveTask(TaskModel task);
  Future<void> replaceTasks(List<TaskModel> tasks);
  Future<void> deleteTask(String id);
}

class HiveTaskLocalDataSource implements TaskLocalDataSource {
  HiveTaskLocalDataSource(this.box);

  static const boxName = 'priorix_tasks';
  final Box<TaskModel> box;

  @override
  Future<List<TaskModel>> getTasks() async {
    final tasks = box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return tasks;
  }

  @override
  Future<void> saveTask(TaskModel task) => box.put(task.id, task);

  @override
  Future<void> replaceTasks(List<TaskModel> tasks) async {
    await box.clear();
    await box.putAll({for (final task in tasks) task.id: task});
  }

  @override
  Future<void> deleteTask(String id) => box.delete(id);
}
