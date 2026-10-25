import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

class TaskCategory extends Equatable {
  const TaskCategory({
    required this.name,
    required this.iconKey,
    required this.colorValue,
  });

  final String name;
  final String iconKey;
  final int colorValue;

  Color get color => Color(colorValue);
  IconData get icon => CategoryVisuals.iconFor(iconKey);

  TaskCategory copyWith({String? name, String? iconKey, int? colorValue}) {
    return TaskCategory(
      name: name ?? this.name,
      iconKey: iconKey ?? this.iconKey,
      colorValue: colorValue ?? this.colorValue,
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'iconKey': iconKey, 'colorValue': colorValue};
  }

  factory TaskCategory.fromMap(Map<dynamic, dynamic> map) {
    return TaskCategory(
      name: (map['name'] as String? ?? '').trim(),
      iconKey: map['iconKey'] as String? ?? 'folder',
      colorValue: map['colorValue'] as int? ?? AppColors.gold.toARGB32(),
    );
  }

  @override
  List<Object> get props => [name, iconKey, colorValue];
}

class CategoryVisuals {
  const CategoryVisuals._();

  static const icons = <String, IconData>{
    'briefcase': Icons.business_center_rounded,
    'person': Icons.person_rounded,
    'finance': Icons.account_balance_wallet_rounded,
    'health': Icons.favorite_rounded,
    'learning': Icons.school_rounded,
    'errands': Icons.local_mall_rounded,
    'ideas': Icons.lightbulb_rounded,
    'travel': Icons.flight_takeoff_rounded,
    'home': Icons.home_rounded,
    'family': Icons.diversity_3_rounded,
    'fitness': Icons.fitness_center_rounded,
    'folder': Icons.folder_rounded,
  };

  static const palette = <Color>[
    AppColors.gold,
    AppColors.jade,
    AppColors.iris,
    AppColors.violet,
    AppColors.rose,
    AppColors.ember,
    AppColors.amber,
    AppColors.success,
    AppColors.sky,
    AppColors.stone,
  ];

  static IconData iconFor(String key) => icons[key] ?? Icons.folder_rounded;
}
