import 'package:hive/hive.dart';
import '../../../app/theme/app_colors.dart';
import '../domain/task_category.dart';

class CategoryLocalDataSource {
  CategoryLocalDataSource(this.box);

  static const boxName = 'priorix_settings';
  static const _categoriesKey = 'categories';

  static final defaultCategories = [
    TaskCategory(
      name: 'Trabajo',
      iconKey: 'briefcase',
      colorValue: AppColors.gold.toARGB32(),
    ),
    TaskCategory(
      name: 'Personal',
      iconKey: 'person',
      colorValue: AppColors.jade.toARGB32(),
    ),
    TaskCategory(
      name: 'Finanzas',
      iconKey: 'finance',
      colorValue: AppColors.amber.toARGB32(),
    ),
    TaskCategory(
      name: 'Salud',
      iconKey: 'health',
      colorValue: AppColors.success.toARGB32(),
    ),
    TaskCategory(
      name: 'Aprendizaje',
      iconKey: 'learning',
      colorValue: AppColors.iris.toARGB32(),
    ),
    TaskCategory(
      name: 'Recados',
      iconKey: 'errands',
      colorValue: AppColors.rose.toARGB32(),
    ),
    TaskCategory(
      name: 'Ideas',
      iconKey: 'ideas',
      colorValue: AppColors.violet.toARGB32(),
    ),
  ];

  final Box<dynamic> box;

  List<TaskCategory> getCategories() {
    final stored = box.get(_categoriesKey);
    if (stored is List) {
      final categories = stored
          .map(_categoryFromStoredValue)
          .where((category) => category.name.isNotEmpty)
          .fold(<String, TaskCategory>{}, (map, category) {
            map[category.name.toLowerCase()] = category;
            return map;
          })
          .values
          .toList();
      if (categories.isNotEmpty) return categories;
    }
    return defaultCategories;
  }

  Future<void> saveCategories(List<TaskCategory> categories) {
    final normalized = categories
        .where((category) => category.name.trim().isNotEmpty)
        .fold(<String, TaskCategory>{}, (map, category) {
          map[category.name.trim().toLowerCase()] = category.copyWith(
            name: category.name.trim(),
          );
          return map;
        })
        .values
        .map((category) => category.toMap())
        .toList();
    return box.put(_categoriesKey, normalized);
  }

  TaskCategory _categoryFromStoredValue(dynamic value) {
    if (value is String) return _categoryFromName(value);
    if (value is Map) return TaskCategory.fromMap(value);
    return const TaskCategory(name: '', iconKey: 'folder', colorValue: 0);
  }

  TaskCategory _categoryFromName(String name) {
    final trimmed = name.trim();
    return defaultCategories.firstWhere(
      (category) => category.name.toLowerCase() == trimmed.toLowerCase(),
      orElse: () => TaskCategory(
        name: trimmed,
        iconKey: 'folder',
        colorValue: AppColors.gold.toARGB32(),
      ),
    );
  }
}
