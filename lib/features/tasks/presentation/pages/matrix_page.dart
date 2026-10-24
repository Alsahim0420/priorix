import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../cubit/task_cubit.dart';
import '../cubit/task_state.dart';
import '../widgets/matrix_grid.dart';
import 'home_page.dart';

class MatrixPage extends StatelessWidget {
  const MatrixPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<TaskCubit, TaskState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 96),
            children: [
              const Text('Eisenhower Matrix', style: AppTextStyles.title),
              const SizedBox(height: 6),
              const Text(
                'Importance rises upward. Urgency moves to the right.',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 18),
              MatrixGrid(
                tasks: state.tasks,
                onTaskTap: (task) => openTaskDetail(context, task),
                onToggle: (task) =>
                    context.read<TaskCubit>().toggleCompleted(task.id),
              ),
            ],
          );
        },
      ),
    );
  }
}
