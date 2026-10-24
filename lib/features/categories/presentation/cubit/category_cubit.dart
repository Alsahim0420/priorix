import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/category_local_datasource.dart';
import '../../domain/task_category.dart';
import 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  CategoryCubit(this.localDataSource) : super(const CategoryState());

  final CategoryLocalDataSource localDataSource;

  Future<void> loadCategories() async {
    emit(CategoryState(categories: localDataSource.getCategories()));
  }

  Future<void> addCategory({
    required String name,
    required String iconKey,
    required int colorValue,
  }) async {
    final category = name.trim();
    if (category.isEmpty) return;
    final categories = [...state.categories];
    final exists = categories.any(
      (item) => item.name.toLowerCase() == category.toLowerCase(),
    );
    if (!exists) {
      categories.add(
        TaskCategory(name: category, iconKey: iconKey, colorValue: colorValue),
      );
    }
    await _save(categories);
  }

  Future<void> updateCategory({
    required String oldName,
    required TaskCategory category,
  }) async {
    final name = category.name.trim();
    if (name.isEmpty) return;
    final categories = state.categories
        .map(
          (item) => item.name == oldName ? category.copyWith(name: name) : item,
        )
        .fold(<String, TaskCategory>{}, (map, item) {
          map[item.name.toLowerCase()] = item;
          return map;
        })
        .values
        .toList();
    await _save(categories);
  }

  Future<void> renameCategory(String oldName, String newName) async {
    final category = newName.trim();
    if (category.isEmpty) return;
    final categories = state.categories
        .map((item) {
          if (item.name == oldName) return item.copyWith(name: category);
          return item;
        })
        .fold(<String, TaskCategory>{}, (map, item) {
          map[item.name.toLowerCase()] = item;
          return map;
        })
        .values
        .toList();
    await _save(categories);
  }

  Future<void> deleteCategory(String name) async {
    final categories = state.categories
        .where((item) => item.name != name)
        .toList();
    await _save(categories);
  }

  Future<void> resetDefaults() async {
    await _save(CategoryLocalDataSource.defaultCategories);
  }

  Future<void> replaceCategories(List<TaskCategory> categories) async {
    await _save(categories);
  }

  Future<void> _save(List<TaskCategory> categories) async {
    await localDataSource.saveCategories(categories);
    emit(state.copyWith(categories: localDataSource.getCategories()));
  }
}
