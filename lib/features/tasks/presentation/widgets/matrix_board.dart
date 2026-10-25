import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_palette.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/widgets/clock_scope.dart';
import '../../../../core/widgets/pressable.dart';
import '../../../../core/widgets/time_visuals.dart';
import '../../domain/entities/task.dart';
import '../cubit/task_cubit.dart';
import '../task_actions.dart';

/// Full Eisenhower board. Long-press a task to drag it into another quadrant.
class MatrixBoard extends StatelessWidget {
  const MatrixBoard({super.key, required this.tasks});

  /// Pending tasks only.
  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    final axis = context.text.labelSmall?.copyWith(fontSize: 10);
    Widget cell(TaskQuadrant quadrant) => Expanded(
      child: _QuadrantCell(
        quadrant: quadrant,
        tasks: tasks.where((task) => task.quadrant == quadrant).toList(),
      ),
    );

    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 24),
            Expanded(
              child: Center(child: Text('URGENTE', style: axis)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Center(child: Text('NO URGENTE', style: axis)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Row(
            children: [
              SizedBox(
                width: 24,
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Row(
                    children: [
                      Expanded(
                        child: Center(
                          child: Text('NO IMPORTANTE', style: axis),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Center(child: Text('IMPORTANTE', style: axis)),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          cell(TaskQuadrant.doNow),
                          const SizedBox(width: 10),
                          cell(TaskQuadrant.schedule),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Row(
                        children: [
                          cell(TaskQuadrant.delegate),
                          const SizedBox(width: 10),
                          cell(TaskQuadrant.eliminate),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuadrantCell extends StatelessWidget {
  const _QuadrantCell({required this.quadrant, required this.tasks});

  final TaskQuadrant quadrant;
  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = quadrant.color;
    final now = ClockScope.now(context);
    final sorted = [...tasks]..sort(_byDeadline);

    return DragTarget<Task>(
      onWillAcceptWithDetails: (details) => details.data.quadrant != quadrant,
      onAcceptWithDetails: (details) {
        HapticFeedback.mediumImpact();
        context.read<TaskCubit>().moveToQuadrant(details.data, quadrant);
      },
      builder: (context, candidates, _) {
        final hovering = candidates.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: Color.alphaBlend(
              color.withValues(
                alpha: hovering ? 0.22 : (p.isLight ? 0.06 : 0.08),
              ),
              p.surface,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: color.withValues(alpha: hovering ? 0.9 : 0.24),
              width: hovering ? 1.6 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Pressable(
                onTap: () => openQuadrant(context, quadrant),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 12, 10),
                  child: Row(
                    children: [
                      Icon(quadrant.icon, size: 16, color: color),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          quadrant.title,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.titleSmall?.copyWith(
                            color: color,
                          ),
                        ),
                      ),
                      Text(
                        '${tasks.length}',
                        style: context.text.titleSmall?.copyWith(
                          color: p.textSecondary,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: p.textTertiary,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: sorted.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            hovering ? 'Suelta aquí' : 'Despejado',
                            style: context.text.bodySmall?.copyWith(
                              color: hovering ? color : p.textTertiary,
                            ),
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
                        physics: const BouncingScrollPhysics(),
                        itemCount: sorted.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 6),
                        itemBuilder: (context, index) =>
                            _DraggableTask(task: sorted[index], now: now),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  static int _byDeadline(Task a, Task b) {
    final ad = a.dueDate;
    final bd = b.dueDate;
    if (ad == null && bd == null) return b.createdAt.compareTo(a.createdAt);
    if (ad == null) return 1;
    if (bd == null) return -1;
    return ad.compareTo(bd);
  }
}

class _DraggableTask extends StatelessWidget {
  const _DraggableTask({required this.task, required this.now});

  final Task task;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final card = _MiniTaskCard(task: task, now: now);
        return LongPressDraggable<Task>(
          data: task,
          hapticFeedbackOnStart: true,
          feedback: Material(
            color: Colors.transparent,
            child: SizedBox(
              width: constraints.maxWidth,
              child: Transform.rotate(
                angle: -0.03,
                child: _MiniTaskCard(task: task, now: now, lifted: true),
              ),
            ),
          ),
          childWhenDragging: Opacity(opacity: 0.25, child: card),
          child: Pressable(
            onTap: () => openTaskDetail(context, task),
            child: card,
          ),
        );
      },
    );
  }
}

class _MiniTaskCard extends StatelessWidget {
  const _MiniTaskCard({
    required this.task,
    required this.now,
    this.lifted = false,
  });

  final Task task;
  final DateTime now;
  final bool lifted;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final due = task.dueDate;
    final elapsed = task.elapsedFraction(now);
    final overdue = task.isOverdue(now);
    return Container(
      padding: const EdgeInsets.fromLTRB(11, 10, 11, 10),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: lifted
              ? task.quadrant.color.withValues(alpha: 0.7)
              : p.hairline,
        ),
        boxShadow: lifted
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.text.titleSmall?.copyWith(fontSize: 13),
          ),
          if (due != null) ...[
            const SizedBox(height: 4),
            Text(
              overdue ? 'Vencida' : due.relativeTo(now),
              style: context.text.bodySmall?.copyWith(
                fontSize: 11,
                color: overdue ? AppColors.danger : p.textTertiary,
              ),
            ),
            const SizedBox(height: 6),
            TimeProgressBar(
              elapsed: elapsed ?? 0,
              thickness: 2.5,
              color: urgencyColor(
                base: task.quadrant.color,
                elapsed: elapsed,
                overdue: overdue,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
