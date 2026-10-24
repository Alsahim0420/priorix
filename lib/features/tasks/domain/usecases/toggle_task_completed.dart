import '../repositories/task_repository.dart';

class ToggleTaskCompleted {
  ToggleTaskCompleted(this.repository);
  final TaskRepository repository;
  Future<void> call(String id) => repository.toggleTaskCompleted(id);
}
