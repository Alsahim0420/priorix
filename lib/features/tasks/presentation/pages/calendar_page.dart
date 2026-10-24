import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/priority_chip.dart';
import '../../domain/entities/task.dart';
import '../cubit/task_state.dart';
import '../cubit/task_cubit.dart';
import 'home_page.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<TaskCubit, TaskState>(
        builder: (context, state) {
          final scheduled =
              state.tasks.where((task) => task.dueDate != null).toList()
                ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 96),
            children: [
              const Text('Schedule', style: AppTextStyles.title),
              const SizedBox(height: 6),
              const Text(
                'Your dated priorities, grouped for fast review.',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 20),
              if (scheduled.isEmpty)
                const EmptyState(
                  title: 'No scheduled priorities.',
                  message:
                      'Add a due date to see tasks grouped by time horizon.',
                  icon: Icons.calendar_today_rounded,
                )
              else
                ..._groups(scheduled).entries.map(
                  (entry) => _Group(title: entry.key, tasks: entry.value),
                ),
            ],
          );
        },
      ),
    );
  }

  Map<String, List<Task>> _groups(List<Task> tasks) {
    final now = DateTime.now();
    final weekEnd = now.add(Duration(days: 7 - now.weekday));
    final map = <String, List<Task>>{
      'Today': [],
      'Tomorrow': [],
      'This week': [],
      'Later': [],
    };
    for (final task in tasks) {
      final due = task.dueDate!;
      if (due.isToday) {
        map['Today']!.add(task);
      } else if (due.isTomorrow) {
        map['Tomorrow']!.add(task);
      } else if (due.isBefore(weekEnd.add(const Duration(days: 1)))) {
        map['This week']!.add(task);
      } else {
        map['Later']!.add(task);
      }
    }
    map.removeWhere((_, value) => value.isEmpty);
    return map;
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.tasks});

  final String title;
  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.section),
          const SizedBox(height: 10),
          ...tasks.map(
            (task) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                onTap: () => openTaskDetail(context, task),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                  side: BorderSide(
                    color: task.quadrant.color.withValues(alpha: 0.22),
                  ),
                ),
                tileColor: AppColors.surface.withValues(alpha: 0.72),
                title: Text(
                  task.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                subtitle: Text(task.dueDate!.mediumLabel),
                trailing: PriorityChip(quadrant: task.quadrant, compact: true),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
