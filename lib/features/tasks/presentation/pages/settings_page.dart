import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../categories/domain/task_category.dart';
import '../../../categories/presentation/cubit/category_cubit.dart';
import '../../../categories/presentation/cubit/category_state.dart';
import '../../../settings/data/backup_service.dart';
import '../../../settings/domain/app_settings.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../../../settings/presentation/cubit/settings_state.dart';
import '../../data/models/task_model.dart';
import '../cubit/task_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocListener<SettingsCubit, SettingsState>(
        listenWhen: (previous, current) => current.message != null,
        listener: (context, state) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message!)));
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 96),
          children: [
            const Text('Settings', style: AppTextStyles.title),
            const SizedBox(height: 20),
            GlassCard(
              borderColor: AppColors.primaryGold.withValues(alpha: 0.32),
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.primaryGold, AppColors.goldDark],
                      ),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: AppColors.background,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pablo',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text('Executive workspace', style: AppTextStyles.body),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const _CategoryManager(),
            const SizedBox(height: 18),
            const _FunctionalSettings(),
          ],
        ),
      ),
    );
  }
}

class _FunctionalSettings extends StatelessWidget {
  const _FunctionalSettings();

  static const _viewLabels = [
    'Home',
    'Matrix',
    'Calendar',
    'Insights',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final settings = state.settings;
        final options = [
          _SettingsOption(
            icon: Icons.dark_mode_rounded,
            title: 'Theme',
            subtitle: settings.themePreset.label,
            onTap: () => _openTheme(context, settings.themePreset),
          ),
          _SettingsOption(
            icon: Icons.notifications_active_rounded,
            title: 'Notifications',
            subtitle: settings.notificationsEnabled
                ? 'Task reminders enabled'
                : 'Disabled',
            onTap: () => _openNotifications(context, settings),
          ),
          _SettingsOption(
            icon: Icons.dashboard_customize_rounded,
            title: 'Default view',
            subtitle: _viewLabels[settings.defaultViewIndex.clamp(0, 4)],
            onTap: () => _openDefaultView(context, settings.defaultViewIndex),
          ),
          _SettingsOption(
            icon: Icons.cloud_upload_rounded,
            title: 'Export backup',
            subtitle: 'Save tasks, categories and settings',
            onTap: () => _exportBackup(context),
          ),
          _SettingsOption(
            icon: Icons.cloud_download_rounded,
            title: 'Import backup',
            subtitle: 'Restore from a Priorix JSON backup',
            onTap: () => _importBackup(context),
          ),
          _SettingsOption(
            icon: Icons.info_outline_rounded,
            title: 'About Priorix',
            subtitle: 'Decide what matters first.',
            onTap: () => _openAbout(context),
          ),
        ];
        return Column(
          children: options
              .map(
                (option) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    onTap: option.onTap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    tileColor: AppColors.surface.withValues(alpha: 0.72),
                    leading: Icon(option.icon, color: AppColors.primaryGold),
                    title: Text(
                      option.title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(option.subtitle),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Future<void> _openTheme(BuildContext context, AppThemePreset current) async {
    final selected = await showModalBottomSheet<AppThemePreset>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _OptionSheet<AppThemePreset>(
        title: 'Theme',
        current: current,
        options: {
          for (final preset in AppThemePreset.values) preset: preset.label,
        },
      ),
    );
    if (selected != null && context.mounted) {
      await context.read<SettingsCubit>().setTheme(selected);
    }
  }

  Future<void> _openNotifications(
    BuildContext context,
    AppSettings settings,
  ) async {
    final enabled = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                value: settings.notificationsEnabled,
                onChanged: (value) => Navigator.pop(context, value),
                title: const Text('Task reminders'),
                subtitle: const Text(
                  'Each priority can have its own notification date and time.',
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (enabled != null && context.mounted) {
      await context.read<SettingsCubit>().setNotificationsEnabled(enabled);
      if (context.mounted) await context.read<TaskCubit>().syncAllReminders();
    }
  }

  Future<void> _openDefaultView(BuildContext context, int current) async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _OptionSheet<int>(
        title: 'Default view',
        current: current,
        options: {
          for (var i = 0; i < _viewLabels.length; i++) i: _viewLabels[i],
        },
      ),
    );
    if (selected != null && context.mounted) {
      await context.read<SettingsCubit>().setDefaultView(selected);
    }
  }

  Future<void> _exportBackup(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final taskCubit = context.read<TaskCubit>();
    final categories = context.read<CategoryCubit>().state.categories;
    final settings = context.read<SettingsCubit>().state.settings;
    final path = await BackupService().exportBackup(
      tasks: taskCubit.state.tasks.map(TaskModel.fromEntity).toList(),
      categories: categories,
      settings: settings,
    );
    messenger.showSnackBar(SnackBar(content: Text('Backup saved: $path')));
  }

  Future<void> _importBackup(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final backup = await BackupService().importBackup();
    if (backup == null || !context.mounted) return;
    await context.read<TaskCubit>().replaceTasks(backup.tasks);
    if (!context.mounted) return;
    await context.read<CategoryCubit>().replaceCategories(backup.categories);
    if (!context.mounted) return;
    await context.read<SettingsCubit>().replaceSettings(backup.settings);
    messenger.showSnackBar(const SnackBar(content: Text('Backup imported.')));
  }

  void _openAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Priorix',
      applicationVersion: '0.1.0',
      applicationLegalese: 'Decide what matters first.',
      children: const [
        Text(
          'Priorix helps you classify tasks by urgency and importance with a premium Eisenhower Matrix workflow.',
        ),
      ],
    );
  }
}

class _SettingsOption {
  const _SettingsOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}

class _OptionSheet<T> extends StatelessWidget {
  const _OptionSheet({
    required this.title,
    required this.current,
    required this.options,
  });

  final String title;
  final T current;
  final Map<T, String> options;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.72,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.section),
              const SizedBox(height: 10),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: options.entries
                      .map(
                        (entry) => ListTile(
                          onTap: () => Navigator.pop(context, entry.key),
                          title: Text(entry.value),
                          trailing: entry.key == current
                              ? const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.primaryGold,
                                )
                              : const Icon(Icons.circle_outlined),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryManager extends StatelessWidget {
  const _CategoryManager();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryCubit, CategoryState>(
      builder: (context, state) {
        return GlassCard(
          borderColor: AppColors.emerald.withValues(alpha: 0.24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Categories',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Edit the presets used when creating priorities.',
                          style: AppTextStyles.body,
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: 'Add category',
                    onPressed: () => _addCategory(context),
                    icon: const Icon(Icons.add_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (state.categories.isEmpty)
                const Text('No categories yet.', style: AppTextStyles.body)
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: state.categories.map((category) {
                    return _CategoryChip(
                      category: category,
                      onEdit: () => _editCategory(context, category),
                      onDelete: () => _deleteCategory(context, category.name),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () =>
                      context.read<CategoryCubit>().resetDefaults(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Restore defaults'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addCategory(BuildContext context) async {
    final category = await _categoryDialog(context, title: 'New category');
    if (category == null || !context.mounted) return;
    await context.read<CategoryCubit>().addCategory(
      name: category.name,
      iconKey: category.iconKey,
      colorValue: category.colorValue,
    );
  }

  Future<void> _editCategory(
    BuildContext context,
    TaskCategory category,
  ) async {
    final updated = await _categoryDialog(
      context,
      title: 'Edit category',
      initialCategory: category,
    );
    if (updated == null || !context.mounted) return;

    await context.read<CategoryCubit>().updateCategory(
      oldName: category.name,
      category: updated,
    );
    if (!context.mounted) return;
    final taskCubit = context.read<TaskCubit>();
    final tasks = context.read<TaskCubit>().state.tasks;
    for (final task in tasks.where((task) => task.category == category.name)) {
      await taskCubit.updateTask(task.copyWith(category: updated.name.trim()));
    }
  }

  Future<void> _deleteCategory(BuildContext context, String category) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete category?'),
            content: Text(
              'Tasks using "$category" will keep no category assigned.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !context.mounted) return;

    await context.read<CategoryCubit>().deleteCategory(category);
    if (!context.mounted) return;
    final taskCubit = context.read<TaskCubit>();
    final tasks = context.read<TaskCubit>().state.tasks;
    for (final task in tasks.where((task) => task.category == category)) {
      await taskCubit.updateTask(task.copyWith(clearCategory: true));
    }
  }

  Future<TaskCategory?> _categoryDialog(
    BuildContext context, {
    required String title,
    TaskCategory? initialCategory,
  }) {
    final controller = TextEditingController(text: initialCategory?.name ?? '');
    var iconKey = initialCategory?.iconKey ?? 'folder';
    var colorValue =
        initialCategory?.colorValue ?? AppColors.primaryGold.toARGB32();

    return showDialog<TaskCategory>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Category name',
                      hintText: 'Travel, Family, Home...',
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Icon',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: CategoryVisuals.icons.entries.map((entry) {
                      final selected = entry.key == iconKey;
                      return _VisualOption(
                        selected: selected,
                        color: Color(colorValue),
                        child: Icon(entry.value, size: 20),
                        onTap: () => setDialogState(() => iconKey = entry.key),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Color',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: CategoryVisuals.palette.map((color) {
                      final selected = color.toARGB32() == colorValue;
                      return _VisualOption(
                        selected: selected,
                        color: color,
                        child: const SizedBox(width: 20, height: 20),
                        onTap: () =>
                            setDialogState(() => colorValue = color.toARGB32()),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    TaskCategory(
                      name: controller.text.trim(),
                      iconKey: iconKey,
                      colorValue: colorValue,
                    ),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    ).whenComplete(controller.dispose);
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  final TaskCategory category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 260),
      padding: const EdgeInsets.only(left: 12, right: 4, top: 5, bottom: 5),
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: category.color.withValues(alpha: 0.38)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(category.icon, color: category.color, size: 17),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              category.name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Rename',
            visualDensity: VisualDensity.compact,
            iconSize: 16,
            onPressed: onEdit,
            icon: const Icon(Icons.edit_rounded),
          ),
          IconButton(
            tooltip: 'Delete',
            visualDensity: VisualDensity.compact,
            iconSize: 16,
            color: AppColors.danger,
            onPressed: onDelete,
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }
}

class _VisualOption extends StatelessWidget {
  const _VisualOption({
    required this.selected,
    required this.color,
    required this.child,
    required this.onTap,
  });

  final bool selected;
  final Color color;
  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: selected ? 0.24 : 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? color : AppColors.border,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: IconTheme(
          data: IconThemeData(color: color),
          child: child,
        ),
      ),
    );
  }
}
