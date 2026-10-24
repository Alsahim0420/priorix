import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../cubit/task_cubit.dart';
import '../widgets/task_form.dart';

class AddTaskPage extends StatelessWidget {
  const AddTaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Priority')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            const Text('New Priority', style: AppTextStyles.title),
            const SizedBox(height: 8),
            const Text(
              'Define urgency and importance. Priorix will place it where it belongs.',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 22),
            TaskForm(
              primaryLabel: 'Create task',
              onSubmit: (value) async {
                await context.read<TaskCubit>().createTask(
                  title: value.title,
                  description: value.description,
                  dueDate: value.dueDate,
                  reminderAt: value.reminderAt,
                  category: value.category,
                  isUrgent: value.isUrgent,
                  isImportant: value.isImportant,
                );
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
