import '../entities/task.dart';

abstract class TaskRepository {
  Future<List<Task>> getTasks();
  Future<void> createTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> replaceTasks(List<Task> tasks);
  Future<void> deleteTask(String id);
  Future<void> toggleTaskCompleted(String id);
}
