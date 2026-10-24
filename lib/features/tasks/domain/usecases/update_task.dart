import '../entities/task.dart';
import '../repositories/task_repository.dart';

class UpdateTask {
  UpdateTask(this.repository);
  final TaskRepository repository;
  Future<void> call(Task task) => repository.updateTask(task);
}
