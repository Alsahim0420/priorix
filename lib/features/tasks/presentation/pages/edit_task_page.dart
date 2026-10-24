import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/task.dart';
import '../cubit/task_cubit.dart';
import '../widgets/task_form.dart';

class EditTaskPage extends StatelessWidget {
  const EditTaskPage({super.key, required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Priority')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            const Text('Edit Priority', style: AppTextStyles.title),
            const SizedBox(height: 22),
            TaskForm(
              initialTask: task,
              primaryLabel: 'Save changes',
              onSubmit: (value) async {
                await context.read<TaskCubit>().updateTask(
                  task.copyWith(
                    title: value.title.trim(),
                    description: value.description?.trim(),
                    dueDate: value.dueDate,
                    reminderAt: value.reminderAt,
                    category: value.category?.trim(),
                    isUrgent: value.isUrgent,
                    isImportant: value.isImportant,
                    clearDescription: (value.description ?? '').trim().isEmpty,
                    clearCategory: (value.category ?? '').trim().isEmpty,
                    clearDueDate: value.dueDate == null,
                    clearReminder: value.reminderAt == null,
                  ),
                );
                if (context.mounted) Navigator.pop(context);
              },
              onDelete: () async {
                final confirmed = await _confirmDelete(context);
                if (!confirmed || !context.mounted) return;
                await context.read<TaskCubit>().deleteTask(task.id);
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete priority?'),
            content: const Text('This removes the task from Priorix.'),
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
  }
}
