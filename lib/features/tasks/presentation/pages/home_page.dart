import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/task.dart';
import '../cubit/task_cubit.dart';
import '../cubit/task_state.dart';
import '../widgets/dashboard_summary_card.dart';
import '../widgets/priority_quadrant_card.dart';
import 'add_task_page.dart';
import 'task_detail_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.onOpenMatrix});

  final VoidCallback onOpenMatrix;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskCubit, TaskState>(
      builder: (context, state) {
        final tasks = state.tasks;
        return SafeArea(
          child: RefreshIndicator(
            onRefresh: () => context.read<TaskCubit>().loadTasks(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 96),
              children: [
                Text(
                  'Good morning, Pablo',
                  style: AppTextStyles.title.copyWith(fontSize: 25),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('EEEE, MMMM d').format(DateTime.now()),
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: 20),
                DashboardSummaryCard(tasks: tasks),
                const SizedBox(height: 26),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Priority Matrix',
                        style: AppTextStyles.section,
                      ),
                    ),
                    TextButton(
                      onPressed: onOpenMatrix,
                      child: const Text('Open matrix'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: MediaQuery.sizeOf(context).width < 390
                      ? 1
                      : 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: MediaQuery.sizeOf(context).width < 390
                      ? 1.55
                      : 0.9,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: TaskQuadrant.values.map((quadrant) {
                    final quadrantTasks = tasks
                        .where((task) => task.quadrant == quadrant)
                        .toList();
                    return PriorityQuadrantCard(
                      quadrant: quadrant,
                      tasks: quadrantTasks,
                      onTap: onOpenMatrix,
                    );
                  }).toList(),
                ),
                if (state.status == TaskStatus.loading)
                  const Padding(
                    padding: EdgeInsets.only(top: 24),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryGold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Future<void> openAddTask(BuildContext context) {
  return Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const AddTaskPage()));
}

Future<void> openTaskDetail(BuildContext context, Task task) {
  return Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => TaskDetailPage(taskId: task.id)));
}
