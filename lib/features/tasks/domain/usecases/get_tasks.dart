import '../entities/task.dart';
import '../repositories/task_repository.dart';

class GetTasks {
  GetTasks(this.repository);
  final TaskRepository repository;
  Future<List<Task>> call() => repository.getTasks();
}
