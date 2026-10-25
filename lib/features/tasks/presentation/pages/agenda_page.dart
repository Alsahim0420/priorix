import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_palette.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/widgets/clock_scope.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/layout.dart';
import '../../../../core/widgets/pressable.dart';
import '../../domain/entities/task.dart';
import '../cubit/task_cubit.dart';
import '../cubit/task_state.dart';
import '../widgets/task_tile.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final now = ClockScope.now(context);
    return BlocBuilder<TaskCubit, TaskState>(
      builder: (context, state) {
        final pending = state.tasks.where((task) => !task.isCompleted);
        final dated = pending.where((task) => task.dueDate != null).toList()
          ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
        final undated = pending.where((task) => task.dueDate == null).toList();
        final selected = _selectedDay;

        return PageFrame(
          onRefresh: () => context.read<TaskCubit>().loadTasks(),
          children: [
            PageHeader(
              overline: capitalize(DateFormat('MMMM y', 'es').format(now)),
              title: 'Agenda',
            ),
            const SizedBox(height: 20),
            _WeekStrip(
              now: now,
              tasks: dated,
              selected: selected,
              onSelect: (day) {
                HapticFeedback.selectionClick();
                setState(
                  () => _selectedDay =
                      selected != null && selected.isSameDay(day) ? null : day,
                );
              },
            ),
            const SizedBox(height: 28),
            if (selected != null)
              ..._dayView(context, selected, dated)
            else if (dated.isEmpty && undated.isEmpty)
              const EmptyState(
                icon: Icons.calendar_today_rounded,
                title: 'Agenda despejada',
                message:
                    'Las tareas con fecha límite aparecerán aquí, ordenadas por cercanía.',
              )
            else ...[
              for (final group in _groups(dated, now).entries) ...[
                SectionLabel('${group.key} · ${group.value.length}'),
                const SizedBox(height: 12),
                for (final task in group.value)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: TaskTile(task: task),
                  ),
                const SizedBox(height: 20),
              ],
              if (undated.isNotEmpty) ...[
                SectionLabel('Sin fecha · ${undated.length}'),
                const SizedBox(height: 12),
                for (final task in undated)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: TaskTile(task: task),
                  ),
              ],
            ],
          ],
        );
      },
    );
  }

  List<Widget> _dayView(BuildContext context, DateTime day, List<Task> dated) {
    final tasks = dated.where((task) => task.dueDate!.isSameDay(day)).toList();
    return [
      SectionLabel(
        capitalize(day.longDate),
        action: 'Ver todo',
        onAction: () => setState(() => _selectedDay = null),
      ),
      const SizedBox(height: 12),
      if (tasks.isEmpty)
        const EmptyState(
          icon: Icons.wb_sunny_outlined,
          title: 'Día libre',
          message: 'No hay vencimientos para este día.',
        )
      else
        for (final task in tasks)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: TaskTile(task: task),
          ),
    ];
  }

  Map<String, List<Task>> _groups(List<Task> tasks, DateTime now) {
    final today = now.dateOnly;
    final tomorrow = today.add(const Duration(days: 1));
    final weekEnd = today.add(Duration(days: 8 - today.weekday));
    final groups = <String, List<Task>>{
      'Vencidas': [],
      'Hoy': [],
      'Mañana': [],
      'Esta semana': [],
      'Más adelante': [],
    };
    for (final task in tasks) {
      final due = task.dueDate!;
      if (due.isBefore(now)) {
        groups['Vencidas']!.add(task);
      } else if (due.isSameDay(today)) {
        groups['Hoy']!.add(task);
      } else if (due.isSameDay(tomorrow)) {
        groups['Mañana']!.add(task);
      } else if (due.isBefore(weekEnd)) {
        groups['Esta semana']!.add(task);
      } else {
        groups['Más adelante']!.add(task);
      }
    }
    groups.removeWhere((_, value) => value.isEmpty);
    return groups;
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({
    required this.now,
    required this.tasks,
    required this.selected,
    required this.onSelect,
  });

  final DateTime now;
  final List<Task> tasks;
  final DateTime? selected;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final today = now.dateOnly;
    final days = List.generate(7, (i) => today.add(Duration(days: i)));
    return Row(
      children: [
        for (final day in days) ...[
          Expanded(
            child: _DayPill(
              day: day,
              isToday: day == today,
              selected: selected != null && selected!.isSameDay(day),
              count: tasks.where((t) => t.dueDate!.isSameDay(day)).length,
              hasCritical: tasks.any(
                (t) =>
                    t.dueDate!.isSameDay(day) &&
                    t.quadrant == TaskQuadrant.doNow,
              ),
              palette: p,
              onTap: () => onSelect(day),
            ),
          ),
          if (day != days.last) const SizedBox(width: 6),
        ],
      ],
    );
  }
}

class _DayPill extends StatelessWidget {
  const _DayPill({
    required this.day,
    required this.isToday,
    required this.selected,
    required this.count,
    required this.hasCritical,
    required this.palette,
    required this.onTap,
  });

  final DateTime day;
  final bool isToday;
  final bool selected;
  final int count;
  final bool hasCritical;
  final PriorixPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final fg = selected ? p.onAccent : p.textPrimary;
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? p.accent : p.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? p.accent
                : isToday
                ? p.accent.withValues(alpha: 0.4)
                : p.hairline,
          ),
        ),
        child: Column(
          children: [
            Text(
              DateFormat('EEEEE', 'es').format(day).toUpperCase(),
              style: context.text.labelSmall?.copyWith(
                letterSpacing: 0.6,
                color: selected ? p.onAccent.withValues(alpha: 0.7) : null,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${day.day}',
              style: context.text.titleMedium?.copyWith(
                color: fg,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 6,
              child: count == 0
                  ? null
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < count.clamp(1, 3); i++)
                          Container(
                            width: 4,
                            height: 4,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: selected
                                  ? p.onAccent
                                  : hasCritical
                                  ? AppColors.ember
                                  : p.textSecondary,
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
