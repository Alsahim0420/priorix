import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/luxury_button.dart';
import '../../../../core/widgets/priority_chip.dart';
import '../../domain/entities/task.dart';
import '../cubit/task_cubit.dart';
import '../cubit/task_state.dart';
import 'edit_task_page.dart';

class TaskDetailPage extends StatelessWidget {
  const TaskDetailPage({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskCubit, TaskState>(
      builder: (context, state) {
        final task = state.tasks.where((task) => task.id == taskId).firstOrNull;
        if (task == null) {
          return const Scaffold(body: Center(child: Text('Task not found')));
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Priority Detail')),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                PriorityChip(quadrant: task.quadrant),
                const SizedBox(height: 16),
                Text(task.title, style: AppTextStyles.title),
                if ((task.description ?? '').isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(task.description!, style: AppTextStyles.body),
                ],
                const SizedBox(height: 20),
                GlassCard(
                  child: Column(
                    children: [
                      _Row(
                        label: 'Due date',
                        value: task.dueDate?.fullLabel ?? 'Open',
                      ),
                      _Row(
                        label: 'Notification',
                        value: task.reminderAt == null
                            ? 'Off'
                            : '${task.reminderAt!.fullLabel} ${task.reminderAt!.hour.toString().padLeft(2, '0')}:${task.reminderAt!.minute.toString().padLeft(2, '0')}',
                      ),
                      _Row(label: 'Created', value: task.createdAt.fullLabel),
                      _Row(
                        label: 'Status',
                        value: task.isCompleted ? 'Completed' : 'Pending',
                      ),
                      _Row(
                        label: 'Urgency',
                        value: task.isUrgent ? 'Urgent' : 'Not urgent',
                      ),
                      _Row(
                        label: 'Importance',
                        value: task.isImportant
                            ? 'Important'
                            : 'Less important',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                GlassCard(
                  borderColor: task.quadrant.color.withValues(alpha: 0.36),
                  child: Row(
                    children: [
                      Icon(Icons.timeline_rounded, color: task.quadrant.color),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Priorix classified this as ${task.quadrant.title}. Keep the next action visible and review it before the day closes.',
                          style: AppTextStyles.body,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                LuxuryButton(
                  label: task.isCompleted
                      ? 'Mark as pending'
                      : 'Mark as completed',
                  icon: task.isCompleted
                      ? Icons.radio_button_unchecked_rounded
                      : Icons.check_circle_outline_rounded,
                  onPressed: () =>
                      context.read<TaskCubit>().toggleCompleted(task.id),
                ),
                const SizedBox(height: 12),
                LuxuryButton(
                  label: 'Edit task',
                  secondary: true,
                  icon: Icons.edit_rounded,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => EditTaskPage(task: task)),
                  ),
                ),
                const SizedBox(height: 12),
                LuxuryButton(
                  label: 'Delete task',
                  danger: true,
                  icon: Icons.delete_outline_rounded,
                  onPressed: () => _delete(context, task),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _delete(BuildContext context, Task task) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete priority?'),
            content: const Text('This action cannot be undone.'),
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
    await context.read<TaskCubit>().deleteTask(task.id);
    if (context.mounted) Navigator.pop(context);
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
