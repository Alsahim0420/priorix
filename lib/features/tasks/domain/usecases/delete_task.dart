import '../repositories/task_repository.dart';

class DeleteTask {
  DeleteTask(this.repository);
  final TaskRepository repository;
  Future<void> call(String id) => repository.deleteTask(id);
}
