import 'package:equatable/equatable.dart';
import '../../domain/task_category.dart';

class CategoryState extends Equatable {
  const CategoryState({this.categories = const []});

  final List<TaskCategory> categories;

  CategoryState copyWith({List<TaskCategory>? categories}) {
    return CategoryState(categories: categories ?? this.categories);
  }

  @override
  List<Object> get props => [categories];
}
