import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_palette.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/widgets/clock_scope.dart';
import '../../../../core/widgets/layout.dart';
import '../../../../core/widgets/p_button.dart';
import '../../../../core/widgets/pressable.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../../../core/widgets/time_visuals.dart';
import '../../../categories/domain/task_category.dart';
import '../../../categories/presentation/cubit/category_cubit.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../../domain/entities/task.dart';
import '../../domain/services/deadline_alert_planner.dart';
import '../cubit/task_cubit.dart';
import '../task_actions.dart';
import '../widgets/alert_threshold_picker.dart';
import '../widgets/alert_timeline.dart';
import '../widgets/quadrant_selector.dart';
import '../widgets/task_links.dart';

class TaskEditorPage extends StatefulWidget {
  const TaskEditorPage({super.key, this.task, this.initialQuadrant});

  final Task? task;
  final TaskQuadrant? initialQuadrant;

  @override
  State<TaskEditorPage> createState() => _TaskEditorPageState();
}

class _TaskEditorPageState extends State<TaskEditorPage> {
  late final TextEditingController _title;
  late final TextEditingController _description;
  late TaskQuadrant _quadrant;
  String? _category;
  DateTime? _deadline;
  DateTime? _reminderAt;
  late List<int> _thresholds;
  late bool _notifyAtDeadline;
  late List<String> _links;
  late final DateTime _start;
  bool _saving = false;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    final settings = context.read<SettingsCubit>().state.settings;
    _title = TextEditingController(text: task?.title ?? '');
    _description = TextEditingController(text: task?.description ?? '');
    _quadrant = task?.quadrant ?? widget.initialQuadrant ?? TaskQuadrant.doNow;
    _category = task?.category;
    _deadline = task?.dueDate;
    _reminderAt = task?.reminderAt;
    _thresholds = task?.alertThresholds ?? settings.defaultAlertThresholds;
    _notifyAtDeadline =
        task?.notifyAtDeadline ?? settings.defaultNotifyAtDeadline;
    _links = [...?task?.links];
    _start = task?.createdAt ?? DateTime.now();
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final now = ClockScope.now(context);
    final notificationsOn = context.select(
      (SettingsCubit cubit) => cubit.state.settings.notificationsEnabled,
    );

    return Scaffold(
      body: PremiumBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    CircleIconButton(
                      icon: Icons.close_rounded,
                      tooltip: 'Cerrar',
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        _isEditing ? 'Editar tarea' : 'Nueva tarea',
                        textAlign: TextAlign.center,
                        style: context.text.titleMedium,
                      ),
                    ),
                    ValueListenableBuilder(
                      valueListenable: _title,
                      builder: (context, value, _) => PButton(
                        label: 'Guardar',
                        compact: true,
                        expanded: false,
                        onPressed: value.text.trim().isEmpty || _saving
                            ? null
                            : _save,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  children: [
                    TextField(
                      controller: _title,
                      autofocus: !_isEditing,
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      style: context.text.headlineSmall,
                      decoration: _bare('¿Qué hay que hacer?'),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _description,
                      minLines: 1,
                      maxLines: 6,
                      textCapitalization: TextCapitalization.sentences,
                      style: context.text.bodyLarge?.copyWith(
                        color: p.textSecondary,
                      ),
                      decoration: _bare('Añade contexto o el siguiente paso…'),
                    ),
                    const SizedBox(height: 32),
                    const SectionLabel('Cuadrante'),
                    const SizedBox(height: 12),
                    QuadrantSelector(
                      value: _quadrant,
                      onChanged: (value) => setState(() => _quadrant = value),
                    ),
                    const SizedBox(height: 32),
                    const SectionLabel('Categoría'),
                    const SizedBox(height: 12),
                    _CategoryChips(
                      value: _category,
                      onChanged: (value) => setState(() => _category = value),
                    ),
                    const SizedBox(height: 32),
                    const SectionLabel('Fecha límite'),
                    const SizedBox(height: 12),
                    _DeadlineField(
                      value: _deadline,
                      now: now,
                      onPick: _pickDeadline,
                      onQuickPick: (value) {
                        HapticFeedback.selectionClick();
                        setState(() => _deadline = value);
                      },
                      onClear: () => setState(() => _deadline = null),
                    ),
                    const SizedBox(height: 32),
                    const SectionLabel('Alertas inteligentes'),
                    const SizedBox(height: 12),
                    if (_deadline == null)
                      _Hint(
                        icon: Icons.hourglass_empty_rounded,
                        text:
                            'Define una fecha límite y Priorix te avisará cuando quede el porcentaje de tiempo que elijas.',
                      )
                    else ...[
                      if (!notificationsOn) ...[
                        _NotificationsOffBanner(
                          onEnable: () => setNotifications(context, true),
                        ),
                        const SizedBox(height: 16),
                      ],
                      AlertThresholdPicker(
                        values: _thresholds,
                        onChanged: (value) =>
                            setState(() => _thresholds = value),
                      ),
                      const SizedBox(height: 16),
                      _SwitchRow(
                        icon: Icons.flag_rounded,
                        title: 'Avisar al vencer',
                        subtitle: 'Una alerta en el momento exacto.',
                        value: _notifyAtDeadline,
                        onChanged: (value) =>
                            setState(() => _notifyAtDeadline = value),
                      ),
                      const SizedBox(height: 16),
                      _AlertPreview(
                        start: _start,
                        deadline: _deadline!,
                        thresholds: _thresholds,
                        notifyAtDeadline: _notifyAtDeadline,
                        reminderAt: _reminderAt,
                        now: now,
                        muted: !notificationsOn,
                      ),
                    ],
                    const SizedBox(height: 32),
                    const SectionLabel('Recordatorio puntual'),
                    const SizedBox(height: 12),
                    _ReminderField(
                      value: _reminderAt,
                      now: now,
                      onPick: _pickReminder,
                      onClear: () => setState(() => _reminderAt = null),
                    ),
                    const SizedBox(height: 32),
                    const SectionLabel('Notas y tableros'),
                    const SizedBox(height: 12),
                    if (_links.isNotEmpty) ...[
                      TaskLinkList(
                        links: _links,
                        onRemove: (url) => setState(() => _links.remove(url)),
                      ),
                      const SizedBox(height: 10),
                    ],
                    TaskLinkComposer(
                      existing: _links,
                      onAdd: (url) => setState(() => _links.add(url)),
                    ),
                    if (_isEditing) ...[
                      const SizedBox(height: 40),
                      PButton(
                        label: 'Eliminar tarea',
                        icon: Icons.delete_outline_rounded,
                        variant: PButtonVariant.danger,
                        onPressed: _delete,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _bare(String hint) => InputDecoration(
    hintText: hint,
    filled: false,
    isDense: true,
    contentPadding: EdgeInsets.zero,
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
  );

  Future<DateTime?> _pickDateTime({
    required DateTime? initial,
    required TimeOfDay defaultTime,
  }) async {
    final now = DateTime.now();
    final firstDate = [
      now.dateOnly,
      if (initial != null) initial.dateOnly,
    ].reduce((a, b) => a.isBefore(b) ? a : b);
    final date = await showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: firstDate,
      lastDate: DateTime(now.year + 5),
    );
    if (date == null || !mounted) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: initial == null
          ? defaultTime
          : TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _pickDeadline() async {
    final value = await _pickDateTime(
      initial: _deadline,
      defaultTime: const TimeOfDay(hour: 18, minute: 0),
    );
    if (value != null) setState(() => _deadline = value);
  }

  Future<void> _pickReminder() async {
    final value = await _pickDateTime(
      initial: _reminderAt ?? _deadline,
      defaultTime: TimeOfDay.now(),
    );
    if (value != null) setState(() => _reminderAt = value);
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty) return;
    setState(() => _saving = true);
    HapticFeedback.lightImpact();
    final cubit = context.read<TaskCubit>();
    final description = _description.text.trim();
    final task = widget.task;
    if (task == null) {
      await cubit.createTask(
        title: _title.text,
        description: description,
        dueDate: _deadline,
        reminderAt: _reminderAt,
        category: _category,
        isUrgent: _quadrant.isUrgent,
        isImportant: _quadrant.isImportant,
        alertThresholds: _thresholds,
        notifyAtDeadline: _notifyAtDeadline,
        links: _links,
        createdAt: _start,
      );
    } else {
      await cubit.updateTask(
        task.copyWith(
          title: _title.text.trim(),
          description: description,
          dueDate: _deadline,
          reminderAt: _reminderAt,
          category: _category,
          isUrgent: _quadrant.isUrgent,
          isImportant: _quadrant.isImportant,
          alertThresholds: _thresholds,
          notifyAtDeadline: _notifyAtDeadline,
          links: _links,
          clearDescription: description.isEmpty,
          clearCategory: _category == null,
          clearDueDate: _deadline == null,
          clearReminder: _reminderAt == null,
        ),
      );
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final task = widget.task;
    if (task == null) return;
    final confirmed = await confirmDeleteTask(context);
    if (!confirmed || !mounted) return;
    final navigator = Navigator.of(context);
    await context.read<TaskCubit>().deleteTask(task.id);
    navigator.popUntil((route) => route.isFirst);
  }
}

Future<bool> confirmDeleteTask(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('¿Eliminar tarea?'),
          content: const Text(
            'Se eliminará junto con todas sus alertas. No se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppColors.danger),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar'),
            ),
          ],
        ),
      ) ??
      false;
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.value, required this.onChanged});

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final categories = context.select(
      (CategoryCubit cubit) => cubit.state.categories,
    );
    final known = categories.any((c) => c.name == value);
    final options = <TaskCategory>[
      ...categories,
      if (value != null && !known)
        TaskCategory(
          name: value!,
          iconKey: 'folder',
          colorValue: p.textSecondary.toARGB32(),
        ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          _Chip(
            label: 'Ninguna',
            icon: Icons.block_rounded,
            color: p.textSecondary,
            selected: value == null,
            onTap: () => onChanged(null),
          ),
          for (final category in options)
            _Chip(
              label: category.name,
              icon: category.icon,
              color: category.color,
              selected: category.name == value,
              onTap: () => onChanged(category.name),
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Pressable(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? Color.alphaBlend(color.withValues(alpha: 0.16), p.surface)
                : p.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? color.withValues(alpha: 0.7) : p.hairline,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: selected ? color : p.textTertiary),
              const SizedBox(width: 7),
              Text(
                label,
                style: context.text.labelLarge?.copyWith(
                  color: selected ? p.textPrimary : p.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeadlineField extends StatelessWidget {
  const _DeadlineField({
    required this.value,
    required this.now,
    required this.onPick,
    required this.onQuickPick,
    required this.onClear,
  });

  final DateTime? value;
  final DateTime now;
  final VoidCallback onPick;
  final ValueChanged<DateTime> onQuickPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final value = this.value;
    final today = now.dateOnly;
    final daysToMonday = (DateTime.monday - now.weekday + 7) % 7;
    final quick = <(String, DateTime)>[
      if (now.hour < 17) ('Hoy 18:00', today.add(const Duration(hours: 18))),
      ('Mañana 09:00', today.add(const Duration(days: 1, hours: 9))),
      ('En 3 días', today.add(const Duration(days: 3, hours: 18))),
      (
        'Próx. lunes',
        today.add(
          Duration(days: daysToMonday == 0 ? 7 : daysToMonday, hours: 9),
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SurfaceCard(
          radius: 20,
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          onTap: onPick,
          child: Row(
            children: [
              _IconBox(icon: Icons.event_rounded, active: value != null),
              const SizedBox(width: 14),
              Expanded(
                child: value == null
                    ? Text(
                        'Sin fecha límite',
                        style: context.text.titleSmall?.copyWith(
                          color: p.textSecondary,
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            capitalize(value.smartLabel(now)),
                            style: context.text.titleMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            value.isAfter(now)
                                ? 'Vence ${value.relativeTo(now)}'
                                : 'Ya venció',
                            style: context.text.bodySmall?.copyWith(
                              color: value.isAfter(now)
                                  ? p.textSecondary
                                  : AppColors.danger,
                            ),
                          ),
                        ],
                      ),
              ),
              if (value != null)
                IconButton(
                  tooltip: 'Quitar fecha',
                  onPressed: onClear,
                  icon: Icon(Icons.close_rounded, color: p.textTertiary),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: p.textTertiary,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (label, date) in quick)
              Pressable(
                onTap: () => onQuickPick(date),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: value == date
                        ? p.accent.withValues(alpha: 0.14)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: value == date
                          ? p.accent.withValues(alpha: 0.5)
                          : p.hairline,
                    ),
                  ),
                  child: Text(
                    label,
                    style: context.text.labelMedium?.copyWith(
                      color: value == date ? p.accent : p.textSecondary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ReminderField extends StatelessWidget {
  const _ReminderField({
    required this.value,
    required this.now,
    required this.onPick,
    required this.onClear,
  });

  final DateTime? value;
  final DateTime now;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final value = this.value;
    return SurfaceCard(
      radius: 20,
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
      onTap: onPick,
      child: Row(
        children: [
          _IconBox(icon: Icons.alarm_rounded, active: value != null),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value == null
                      ? 'Sin recordatorio'
                      : capitalize(value.smartLabel(now)),
                  style: context.text.titleSmall?.copyWith(
                    color: value == null ? p.textSecondary : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Un aviso extra a la hora exacta que elijas.',
                  style: context.text.bodySmall,
                ),
              ],
            ),
          ),
          if (value != null)
            IconButton(
              tooltip: 'Quitar recordatorio',
              onPressed: onClear,
              icon: Icon(Icons.close_rounded, color: p.textTertiary),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(Icons.chevron_right_rounded, color: p.textTertiary),
            ),
        ],
      ),
    );
  }
}

class _AlertPreview extends StatelessWidget {
  const _AlertPreview({
    required this.start,
    required this.deadline,
    required this.thresholds,
    required this.notifyAtDeadline,
    required this.reminderAt,
    required this.now,
    required this.muted,
  });

  final DateTime start;
  final DateTime deadline;
  final List<int> thresholds;
  final bool notifyAtDeadline;
  final DateTime? reminderAt;
  final DateTime now;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final alerts = DeadlineAlertPlanner.plan(
      start: start,
      deadline: deadline,
      thresholds: thresholds,
      notifyAtDeadline: notifyAtDeadline,
      reminderAt: reminderAt,
    );
    final sameDay = start.isSameDay(deadline);
    final total = deadline.difference(start).inSeconds;
    final elapsed = total <= 0
        ? 1.0
        : (now.difference(start).inSeconds / total).clamp(0.0, 1.0);

    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Vista previa', style: context.text.titleSmall),
              ),
              Text(
                '${alerts.length} ${alerts.length == 1 ? 'aviso' : 'avisos'}',
                style: context.text.labelMedium,
              ),
            ],
          ),
          const SizedBox(height: 14),
          TimeProgressBar(
            elapsed: elapsed,
            color: p.accent,
            marks: [
              for (final v in DeadlineAlertPlanner.normalize(thresholds))
                (100 - v) / 100,
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(_edge(start, sameDay), style: context.text.labelSmall),
              const Spacer(),
              Text(_edge(deadline, sameDay), style: context.text.labelSmall),
            ],
          ),
          if (alerts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                'No hay avisos programados para esta tarea.',
                style: context.text.bodySmall,
              ),
            )
          else ...[
            const SizedBox(height: 4),
            AlertTimeline(alerts: alerts, now: now, muted: muted),
          ],
        ],
      ),
    );
  }

  String _edge(DateTime value, bool sameDay) =>
      sameDay ? value.time : value.dayMonth;
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      radius: 20,
      padding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          _IconBox(icon: icon, active: value),
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
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon, required this.active});

  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: active ? p.accent.withValues(alpha: 0.14) : p.surfaceHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 19, color: active ? p.accent : p.textTertiary),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.hairline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: p.textTertiary),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: context.text.bodyMedium)),
        ],
      ),
    );
  }
}

class _NotificationsOffBanner extends StatelessWidget {
  const _NotificationsOffBanner({required this.onEnable});

  final VoidCallback onEnable;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SurfaceCard(
      tint: p.accent,
      radius: 20,
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      child: Row(
        children: [
          Icon(Icons.notifications_off_outlined, color: p.accent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Las notificaciones están desactivadas en Priorix.',
              style: context.text.bodyMedium?.copyWith(color: p.textPrimary),
            ),
          ),
          TextButton(onPressed: onEnable, child: const Text('Activar')),
        ],
      ),
    );
  }
}
