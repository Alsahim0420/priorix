import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_datasource.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl(this.localDataSource);

  final TaskLocalDataSource localDataSource;

  @override
  Future<List<Task>> getTasks() => localDataSource.getTasks();

  @override
  Future<void> createTask(Task task) {
    return localDataSource.saveTask(TaskModel.fromEntity(task));
  }

  @override
  Future<void> updateTask(Task task) {
    return localDataSource.saveTask(TaskModel.fromEntity(task));
  }

  @override
  Future<void> replaceTasks(List<Task> tasks) {
    return localDataSource.replaceTasks(
      tasks.map(TaskModel.fromEntity).toList(),
    );
  }

  @override
  Future<void> deleteTask(String id) => localDataSource.deleteTask(id);

  @override
  Future<void> toggleTaskCompleted(String id) async {
    final tasks = await localDataSource.getTasks();
    final task = tasks.firstWhere((item) => item.id == id);
    await localDataSource.saveTask(
      TaskModel.fromEntity(
        task.copyWith(
          isCompleted: !task.isCompleted,
          updatedAt: DateTime.now(),
        ),
      ),
    );
  }
}
