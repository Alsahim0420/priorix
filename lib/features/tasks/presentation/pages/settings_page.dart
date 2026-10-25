import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/layout.dart';
import '../../../../core/widgets/p_button.dart';
import '../../../../core/widgets/pressable.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../../categories/domain/task_category.dart';
import '../../../categories/presentation/cubit/category_cubit.dart';
import '../../../categories/presentation/cubit/category_state.dart';
import '../../../settings/data/backup_service.dart';
import '../../../settings/domain/app_settings.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../../../settings/presentation/cubit/settings_state.dart';
import '../../data/models/task_model.dart';
import '../cubit/task_cubit.dart';
import '../task_actions.dart';
import '../widgets/alert_threshold_picker.dart';
import 'notification_sound_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsCubit, SettingsState>(
      listenWhen: (previous, current) =>
          current.message != null && current.message != previous.message,
      listener: (context, state) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.message!)));
      },
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          final settings = state.settings;
          return PageFrame(
            children: [
              const PageHeader(overline: 'Priorix', title: 'Ajustes'),
              const SizedBox(height: 24),
              _ProfileCard(name: settings.userName),
              const SizedBox(height: 32),
              const SectionLabel('Notificaciones'),
              const SizedBox(height: 12),
              _Group(
                children: [
                  _Tile(
                    icon: Icons.notifications_active_outlined,
                    title: 'Alertas de vencimiento',
                    subtitle: settings.notificationsEnabled
                        ? 'Activas en este dispositivo'
                        : 'Desactivadas',
                    trailing: Switch(
                      value: settings.notificationsEnabled,
                      onChanged: (value) => setNotifications(context, value),
                    ),
                    onTap: () => setNotifications(
                      context,
                      !settings.notificationsEnabled,
                    ),
                  ),
                  _Tile(
                    icon: Icons.music_note_outlined,
                    title: 'Sonido',
                    subtitle: settings.notificationSound.label,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const NotificationSoundPage(),
                      ),
                    ),
                  ),
                  _Tile(
                    icon: Icons.tune_rounded,
                    title: 'Alertas por defecto',
                    subtitle: _describeDefaults(settings),
                    onTap: () => _editDefaultAlerts(context, settings),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 10, 6, 0),
                child: Text(
                  'Los porcentajes se calculan sobre el tiempo entre la creación de la tarea y su fecha límite. Todo se programa en local, sin servidores.',
                  style: context.text.bodySmall?.copyWith(
                    color: context.palette.textTertiary,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const SectionLabel('Apariencia'),
              const SizedBox(height: 12),
              _Group(
                children: [
                  _ThemeSelector(current: settings.themePreset),
                  _Tile(
                    icon: Icons.space_dashboard_outlined,
                    title: 'Vista inicial',
                    subtitle:
                        AppSettings.viewLabels[settings.defaultViewIndex.clamp(
                          0,
                          AppSettings.viewLabels.length - 1,
                        )],
                    onTap: () =>
                        _pickDefaultView(context, settings.defaultViewIndex),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SectionLabel(
                'Categorías',
                action: 'Nueva',
                onAction: () => _CategoryActions.add(context),
              ),
              const SizedBox(height: 12),
              const _CategoryManager(),
              const SizedBox(height: 32),
              const SectionLabel('Datos'),
              const SizedBox(height: 12),
              _Group(
                children: [
                  _Tile(
                    icon: Icons.ios_share_rounded,
                    title: 'Exportar copia',
                    subtitle: 'Tareas, categorías y ajustes en JSON',
                    onTap: () => _exportBackup(context),
                  ),
                  _Tile(
                    icon: Icons.download_rounded,
                    title: 'Importar copia',
                    subtitle: 'Reemplaza los datos actuales',
                    onTap: () => _importBackup(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _Group(
                children: [
                  _Tile(
                    icon: Icons.info_outline_rounded,
                    title: 'Acerca de Priorix',
                    subtitle: 'Decide qué importa primero.',
                    onTap: () => _openAbout(context),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Center(
                child: Text('PRIORIX 1.0', style: context.text.labelSmall),
              ),
            ],
          );
        },
      ),
    );
  }

  static String _describeDefaults(AppSettings settings) {
    final parts = [
      if (settings.defaultAlertThresholds.isNotEmpty)
        '${settings.defaultAlertThresholds.join(' · ')} %',
      if (settings.defaultNotifyAtDeadline) 'al vencer',
    ];
    return parts.isEmpty ? 'Sin alertas' : 'Cuando quede ${parts.join(' y ')}';
  }

  Future<void> _editDefaultAlerts(
    BuildContext context,
    AppSettings settings,
  ) async {
    final result = await showModalBottomSheet<(List<int>, bool)>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _DefaultAlertsSheet(
        thresholds: settings.defaultAlertThresholds,
        notifyAtDeadline: settings.defaultNotifyAtDeadline,
      ),
    );
    if (result == null || !context.mounted) return;
    await context.read<SettingsCubit>().setDefaultAlerts(
      thresholds: result.$1,
      notifyAtDeadline: result.$2,
    );
  }

  Future<void> _pickDefaultView(BuildContext context, int current) async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                child: Text('Vista inicial', style: context.text.titleLarge),
              ),
              for (var i = 0; i < AppSettings.viewLabels.length; i++)
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onTap: () => Navigator.pop(context, i),
                  title: Text(AppSettings.viewLabels[i]),
                  trailing: i == current
                      ? Icon(Icons.check_rounded, color: context.palette.accent)
                      : null,
                ),
            ],
          ),
        ),
      ),
    );
    if (selected != null && context.mounted) {
      await context.read<SettingsCubit>().setDefaultView(selected);
    }
  }

  Future<void> _exportBackup(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final tasks = context.read<TaskCubit>().state.tasks;
    final categories = context.read<CategoryCubit>().state.categories;
    final settings = context.read<SettingsCubit>().state.settings;
    try {
      final path = await BackupService().exportBackup(
        tasks: tasks.map(TaskModel.fromEntity).toList(),
        categories: categories,
        settings: settings,
      );
      messenger.showSnackBar(SnackBar(content: Text('Copia guardada: $path')));
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No se pudo guardar la copia.')),
      );
    }
  }

  Future<void> _importBackup(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final settingsCubit = context.read<SettingsCubit>();
    final categoryCubit = context.read<CategoryCubit>();
    final taskCubit = context.read<TaskCubit>();
    final PriorixBackup? backup;
    try {
      backup = await BackupService().importBackup();
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('El archivo no es una copia válida.')),
      );
      return;
    }
    if (backup == null) return;
    final current = settingsCubit.state.settings;
    await settingsCubit.replaceSettings(
      backup.settings.copyWith(
        onboardingCompleted: true,
        userName: backup.settings.userName.isEmpty
            ? current.userName
            : backup.settings.userName,
      ),
    );
    await categoryCubit.replaceCategories(backup.categories);
    await taskCubit.replaceTasks(backup.tasks);
    messenger.showSnackBar(const SnackBar(content: Text('Copia importada.')));
  }

  void _openAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Priorix',
      applicationVersion: '1.0.1',
      applicationLegalese: 'Decide qué importa primero.',
      children: const [
        SizedBox(height: 12),
        Text(
          'Clasifica tus tareas con la matriz de Eisenhower y recibe alertas locales según el tiempo que queda hasta cada fecha límite.',
        ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SurfaceCard(
      tint: p.accent,
      onTap: () => _editName(context),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(p.accent, Colors.white, 0.2)!,
                  Color.lerp(p.accent, Colors.black, 0.2)!,
                ],
              ),
            ),
            alignment: Alignment.center,
            child: name.isEmpty
                ? Icon(Icons.person_rounded, color: p.onAccent)
                : Text(
                    name.characters.first.toUpperCase(),
                    style: context.text.titleLarge?.copyWith(color: p.onAccent),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? 'Tu espacio' : name,
                  style: context.text.titleLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  'Todo se guarda en este dispositivo',
                  style: context.text.bodySmall,
                ),
              ],
            ),
          ),
          Icon(Icons.edit_outlined, size: 18, color: p.textTertiary),
        ],
      ),
    );
  }

  Future<void> _editName(BuildContext context) async {
    final controller = TextEditingController(text: name);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cómo te llamas?'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Tu nombre'),
          onSubmitted: (value) => Navigator.pop(context, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result != null && context.mounted) {
      await context.read<SettingsCubit>().setUserName(result);
    }
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              children[i],
              if (i != children.length - 1)
                const Divider(indent: 66, endIndent: 0),
            ],
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: p.surfaceHigh,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 18, color: p.accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.text.titleSmall),
                    const SizedBox(height: 2),
                    Text(subtitle, style: context.text.bodySmall),
                  ],
                ),
              ),
              trailing ??
                  Icon(Icons.chevron_right_rounded, color: p.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector({required this.current});

  final AppThemePreset current;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 0, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tema', style: context.text.titleSmall),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final preset in AppThemePreset.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _ThemeSwatch(
                      preset: preset,
                      selected: preset == current,
                      selectionColor: p.accent,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        context.read<SettingsCubit>().setTheme(preset);
                      },
                    ),
                  ),
                const SizedBox(width: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeSwatch extends StatelessWidget {
  const _ThemeSwatch({
    required this.preset,
    required this.selected,
    required this.selectionColor,
    required this.onTap,
  });

  final AppThemePreset preset;
  final bool selected;
  final Color selectionColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final swatch = PriorixPalette.forPreset(preset);
    return Pressable(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 64,
            height: 76,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? selectionColor : Colors.transparent,
                width: 2,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: swatch.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: swatch.hairline),
              ),
              padding: const EdgeInsets.all(9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    decoration: BoxDecoration(
                      color: swatch.surfaceHigh,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: swatch.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Container(
                          height: 5,
                          decoration: BoxDecoration(
                            color: swatch.textTertiary,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            preset.label,
            style: context.text.labelMedium?.copyWith(
              color: selected ? context.palette.textPrimary : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _DefaultAlertsSheet extends StatefulWidget {
  const _DefaultAlertsSheet({
    required this.thresholds,
    required this.notifyAtDeadline,
  });

  final List<int> thresholds;
  final bool notifyAtDeadline;

  @override
  State<_DefaultAlertsSheet> createState() => _DefaultAlertsSheetState();
}

class _DefaultAlertsSheetState extends State<_DefaultAlertsSheet> {
  late List<int> _thresholds = widget.thresholds;
  late bool _notifyAtDeadline = widget.notifyAtDeadline;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Alertas por defecto', style: context.text.titleLarge),
            const SizedBox(height: 6),
            Text(
              'Se aplican a cada tarea nueva. Puedes ajustarlas en cada una.',
              style: context.text.bodyMedium,
            ),
            const SizedBox(height: 22),
            AlertThresholdPicker(
              values: _thresholds,
              onChanged: (value) => setState(() => _thresholds = value),
            ),
            const SizedBox(height: 14),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _notifyAtDeadline,
              onChanged: (value) => setState(() => _notifyAtDeadline = value),
              title: Text('Avisar al vencer', style: context.text.titleSmall),
              subtitle: Text(
                'Una alerta en el momento exacto de la fecha límite.',
                style: context.text.bodySmall,
              ),
            ),
            const SizedBox(height: 16),
            PButton(
              label: 'Guardar',
              onPressed: () =>
                  Navigator.pop(context, (_thresholds, _notifyAtDeadline)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryManager extends StatelessWidget {
  const _CategoryManager();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return BlocBuilder<CategoryCubit, CategoryState>(
      builder: (context, state) {
        return SurfaceCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state.categories.isEmpty)
                Text('Aún no hay categorías.', style: context.text.bodyMedium)
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final category in state.categories)
                      Pressable(
                        onTap: () => _CategoryActions.edit(context, category),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: Color.alphaBlend(
                              category.color.withValues(alpha: 0.12),
                              p.surface,
                            ),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: category.color.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                category.icon,
                                size: 15,
                                color: category.color,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                category.name,
                                style: context.text.labelLarge,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => context.read<CategoryCubit>().resetDefaults(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      size: 15,
                      color: p.textTertiary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Restaurar predeterminadas',
                      style: context.text.labelMedium?.copyWith(
                        color: p.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryResult {
  const _CategoryResult(this.category, {this.delete = false});

  final TaskCategory category;
  final bool delete;
}

class _CategoryActions {
  const _CategoryActions._();

  static Future<void> add(BuildContext context) async {
    final result = await _open(context, null);
    if (result == null || !context.mounted) return;
    await context.read<CategoryCubit>().addCategory(
      name: result.category.name,
      iconKey: result.category.iconKey,
      colorValue: result.category.colorValue,
    );
  }

  static Future<void> edit(BuildContext context, TaskCategory category) async {
    final result = await _open(context, category);
    if (result == null || !context.mounted) return;
    final taskCubit = context.read<TaskCubit>();
    final affected = taskCubit.state.tasks
        .where((task) => task.category == category.name)
        .toList();
    if (result.delete) {
      await context.read<CategoryCubit>().deleteCategory(category.name);
      for (final task in affected) {
        await taskCubit.updateTask(task.copyWith(clearCategory: true));
      }
      return;
    }
    await context.read<CategoryCubit>().updateCategory(
      oldName: category.name,
      category: result.category,
    );
    final newName = result.category.name.trim();
    if (newName == category.name) return;
    for (final task in affected) {
      await taskCubit.updateTask(task.copyWith(category: newName));
    }
  }

  static Future<_CategoryResult?> _open(
    BuildContext context,
    TaskCategory? initial,
  ) {
    return showModalBottomSheet<_CategoryResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _CategorySheet(initial: initial),
    );
  }
}

class _CategorySheet extends StatefulWidget {
  const _CategorySheet({this.initial});

  final TaskCategory? initial;

  @override
  State<_CategorySheet> createState() => _CategorySheetState();
}

class _CategorySheetState extends State<_CategorySheet> {
  late final _name = TextEditingController(text: widget.initial?.name ?? '');
  late String _iconKey = widget.initial?.iconKey ?? 'folder';
  late int _colorValue =
      widget.initial?.colorValue ?? AppColors.gold.toARGB32();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = Color(_colorValue);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.initial == null ? 'Nueva categoría' : 'Editar categoría',
                style: context.text.titleLarge,
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _name,
                autofocus: widget.initial == null,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'Viajes, Familia, Casa…',
                  prefixIcon: Icon(
                    CategoryVisuals.iconFor(_iconKey),
                    color: color,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text('ICONO', style: context.text.labelSmall),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final entry in CategoryVisuals.icons.entries)
                    _Option(
                      selected: entry.key == _iconKey,
                      color: color,
                      onTap: () => setState(() => _iconKey = entry.key),
                      child: Icon(entry.value, size: 20),
                    ),
                ],
              ),
              const SizedBox(height: 22),
              Text('COLOR', style: context.text.labelSmall),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final option in CategoryVisuals.palette)
                    _Option(
                      selected: option.toARGB32() == _colorValue,
                      color: option,
                      onTap: () =>
                          setState(() => _colorValue = option.toARGB32()),
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: option,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 26),
              ValueListenableBuilder(
                valueListenable: _name,
                builder: (context, value, _) => PButton(
                  label: 'Guardar',
                  onPressed: value.text.trim().isEmpty
                      ? null
                      : () => Navigator.pop(
                          context,
                          _CategoryResult(
                            TaskCategory(
                              name: value.text.trim(),
                              iconKey: _iconKey,
                              colorValue: _colorValue,
                            ),
                          ),
                        ),
                ),
              ),
              if (widget.initial != null) ...[
                const SizedBox(height: 10),
                PButton(
                  label: 'Eliminar categoría',
                  variant: PButtonVariant.danger,
                  onPressed: () => Navigator.pop(
                    context,
                    _CategoryResult(widget.initial!, delete: true),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Las tareas que la usen quedarán sin categoría.',
                  style: context.text.bodySmall?.copyWith(
                    color: p.textTertiary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.selected,
    required this.color,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final Color color;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.18) : p.surfaceHigh,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color : Colors.transparent,
            width: 1.6,
          ),
        ),
        child: IconTheme(
          data: IconThemeData(color: selected ? color : p.textSecondary),
          child: child,
        ),
      ),
    );
  }
}
