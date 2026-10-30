import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_palette.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/widgets/clock_scope.dart';
import '../../../../core/widgets/quadrant_badge.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../../../core/widgets/time_visuals.dart';
import '../../../categories/domain/task_category.dart';
import '../../../categories/presentation/cubit/category_cubit.dart';
import '../../domain/entities/task.dart';
import '../task_actions.dart';
import 'task_links.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({super.key, required this.task, this.showQuadrant = true});

  final Task task;
  final bool showQuadrant;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final now = ClockScope.now(context);
    final category = context.select<CategoryCubit, TaskCategory?>(
      (cubit) => cubit.state.categories
          .where((item) => item.name == task.category)
          .firstOrNull,
    );
    final due = task.dueDate;
    final elapsed = task.elapsedFraction(now);
    final overdue = task.isOverdue(now);
    final barColor = urgencyColor(
      base: task.quadrant.color,
      elapsed: elapsed,
      overdue: overdue,
    );

    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(12, 14, 16, 14),
      radius: 20,
      onTap: () => openTaskDetail(context, task),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CompletionDot(
            completed: task.isCompleted,
            color: task.quadrant.color,
            onTap: () => toggleTaskCompleted(context, task),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                    task.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.titleMedium?.copyWith(
                      color: task.isCompleted ? p.textTertiary : null,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      decorationColor: p.textTertiary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (showQuadrant)
                      QuadrantBadge(quadrant: task.quadrant, dense: true),
                    if (category != null)
                      _Meta(
                        icon: category.icon,
                        label: category.name,
                        color: category.color,
                      )
                    else if (task.category != null)
                      _Meta(
                        icon: Icons.folder_rounded,
                        label: task.category!,
                        color: p.textSecondary,
                      ),
                    if (due != null)
                      _Meta(
                        icon: overdue
                            ? Icons.error_outline_rounded
                            : Icons.schedule_rounded,
                        label: overdue
                            ? 'Vencida ${due.relativeTo(now)}'
                            : '${due.smartLabel(now)} · ${due.relativeTo(now)}',
                        color: overdue ? AppColors.danger : p.textSecondary,
                      ),
                    if (task.alertThresholds.isNotEmpty && !task.isCompleted)
                      _Meta(
                        icon: Icons.notifications_none_rounded,
                        label: task.alertThresholds.map((v) => '$v').join('·'),
                        color: p.textTertiary,
                      ),
                    if (task.links.isNotEmpty)
                      TaskLinkButton(links: task.links),
                  ],
                ),
                if (elapsed != null && !task.isCompleted) ...[
                  const SizedBox(height: 12),
                  TimeProgressBar(
                    elapsed: elapsed,
                    color: barColor,
                    thickness: 3,
                    marks: [
                      for (final v in task.alertThresholds) (100 - v) / 100,
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class CompletionDot extends StatelessWidget {
  const CompletionDot({
    super.key,
    required this.completed,
    required this.color,
    required this.onTap,
    this.size = 24,
  });

  final bool completed;
  final Color color;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      checked: completed,
      label: completed ? 'Marcar como pendiente' : 'Marcar como completada',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutBack,
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: completed ? color : Colors.transparent,
              border: Border.all(
                color: completed ? color : color.withValues(alpha: 0.55),
                width: 1.6,
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: completed
                  ? Icon(
                      Icons.check_rounded,
                      key: const ValueKey(true),
                      size: size * 0.62,
                      color: Colors.white,
                    )
                  : const SizedBox.shrink(key: ValueKey(false)),
            ),
          ),
        ),
      ),
    );
  }
}
