import 'package:flutter/material.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/task.dart';
import 'task_card.dart';

class MatrixGrid extends StatelessWidget {
  const MatrixGrid({
    super.key,
    required this.tasks,
    required this.onTaskTap,
    required this.onToggle,
  });

  final List<Task> tasks;
  final ValueChanged<Task> onTaskTap;
  final ValueChanged<Task> onToggle;

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const EmptyState(
        title: 'No priorities here yet.',
        message: 'Add a task and Priorix will place it in the right quadrant.',
      );
    }
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.sizeOf(context).width < 390 ? 1 : 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: MediaQuery.sizeOf(context).width < 390 ? 1.25 : 0.82,
      children: TaskQuadrant.values.map((quadrant) {
        final quadrantTasks = tasks
            .where((task) => task.quadrant == quadrant)
            .toList();
        return _MatrixQuadrant(
          quadrant: quadrant,
          tasks: quadrantTasks,
          onTaskTap: onTaskTap,
          onToggle: onToggle,
        );
      }).toList(),
    );
  }
}

class _MatrixQuadrant extends StatelessWidget {
  const _MatrixQuadrant({
    required this.quadrant,
    required this.tasks,
    required this.onTaskTap,
    required this.onToggle,
  });

  final TaskQuadrant quadrant;
  final List<Task> tasks;
  final ValueChanged<Task> onTaskTap;
  final ValueChanged<Task> onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: quadrant.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: quadrant.color.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(quadrant.icon, color: quadrant.color, size: 19),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  quadrant.title,
                  style: TextStyle(
                    color: quadrant.color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text('${tasks.length}', style: TextStyle(color: quadrant.color)),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: tasks.isEmpty
                ? Center(
                    child: Text(
                      'No priorities here yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: quadrant.color.withValues(alpha: 0.72),
                        fontSize: 12,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: tasks.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return TaskCard(
                        task: task,
                        compact: true,
                        onTap: () => onTaskTap(task),
                        onToggle: () => onToggle(task),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
