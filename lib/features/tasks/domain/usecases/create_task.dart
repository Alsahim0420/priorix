import '../entities/task.dart';
import '../repositories/task_repository.dart';

class CreateTask {
  CreateTask(this.repository);
  final TaskRepository repository;
  Future<void> call(Task task) => repository.createTask(task);
}
