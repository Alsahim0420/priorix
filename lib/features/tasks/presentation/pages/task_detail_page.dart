import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_palette.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/widgets/clock_scope.dart';
import '../../../../core/widgets/layout.dart';
import '../../../../core/widgets/p_button.dart';
import '../../../../core/widgets/pressable.dart';
import '../../../../core/widgets/quadrant_badge.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../../../core/widgets/time_visuals.dart';
import '../../../categories/presentation/cubit/category_cubit.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../../domain/entities/task.dart';
import '../../domain/services/deadline_alert_planner.dart';
import '../cubit/task_cubit.dart';
import '../cubit/task_state.dart';
import '../task_actions.dart';
import '../widgets/alert_timeline.dart';
import 'task_editor_page.dart';

class TaskDetailPage extends StatelessWidget {
  const TaskDetailPage({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskCubit, TaskState>(
      builder: (context, state) {
        final task = state.tasks.where((task) => task.id == taskId).firstOrNull;
        if (task == null) {
          return Scaffold(
            body: PremiumBackground(
              child: Center(
                child: Text(
                  'Esta tarea ya no existe.',
                  style: context.text.bodyMedium,
                ),
              ),
            ),
          );
        }
        return _DetailView(task: task);
      },
    );
  }
}

class _DetailView extends StatelessWidget {
  const _DetailView({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final now = ClockScope.now(context);
    final notificationsOn = context.select(
      (SettingsCubit cubit) => cubit.state.settings.notificationsEnabled,
    );
    final alerts = DeadlineAlertPlanner.forTask(task);

    return Scaffold(
      body: PremiumBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  Row(
                    children: [
                      CircleIconButton(
                        icon: Icons.arrow_back_rounded,
                        tooltip: 'Volver',
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      CircleIconButton(
                        icon: Icons.edit_outlined,
                        tooltip: 'Editar',
                        onPressed: () => openTaskEditor(context, task: task),
                      ),
                      const SizedBox(width: 10),
                      CircleIconButton(
                        icon: Icons.delete_outline_rounded,
                        tooltip: 'Eliminar',
                        color: AppColors.danger,
                        onPressed: () => _delete(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Row(children: [QuadrantBadge(quadrant: task.quadrant)]),
                  const SizedBox(height: 14),
                  Text(
                    task.title,
                    style: context.text.headlineMedium?.copyWith(
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      decorationColor: p.textTertiary,
                      color: task.isCompleted ? p.textSecondary : null,
                    ),
                  ),
                  if ((task.description ?? '').isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      task.description!,
                      style: context.text.bodyLarge?.copyWith(
                        color: p.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  _CountdownCard(task: task, now: now),
                  const SizedBox(height: 14),
                  if (alerts.isNotEmpty)
                    SurfaceCard(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Alertas',
                                  style: context.text.titleMedium,
                                ),
                              ),
                              if (!notificationsOn)
                                GestureDetector(
                                  onTap: () => setNotifications(context, true),
                                  child: Text(
                                    'Activar notificaciones',
                                    style: context.text.labelMedium?.copyWith(
                                      color: p.accent,
                                    ),
                                  ),
                                )
                              else if (task.isCompleted)
                                Text(
                                  'En pausa',
                                  style: context.text.labelMedium,
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          AlertTimeline(
                            alerts: alerts,
                            now: now,
                            muted: !notificationsOn || task.isCompleted,
                          ),
                        ],
                      ),
                    )
                  else if (task.dueDate != null)
                    SurfaceCard(
                      onTap: () => openTaskEditor(context, task: task),
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          Icon(
                            Icons.notifications_none_rounded,
                            color: p.textTertiary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Sin alertas. Añade avisos al 50 %, 20 %…',
                              style: context.text.bodyMedium,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: p.textTertiary,
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 14),
                  _InfoCard(task: task),
                  const SizedBox(height: 28),
                  const SectionLabel('Mover a'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      for (final quadrant in TaskQuadrant.values) ...[
                        Expanded(
                          child: _MoveChip(
                            quadrant: quadrant,
                            current: quadrant == task.quadrant,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              context.read<TaskCubit>().moveToQuadrant(
                                task,
                                quadrant,
                              );
                            },
                          ),
                        ),
                        if (quadrant != TaskQuadrant.values.last)
                          const SizedBox(width: 8),
                      ],
                    ],
                  ),
                  const SizedBox(height: 32),
                  PButton(
                    label: task.isCompleted
                        ? 'Reabrir tarea'
                        : 'Marcar como completada',
                    icon: task.isCompleted
                        ? Icons.replay_rounded
                        : Icons.check_rounded,
                    variant: task.isCompleted
                        ? PButtonVariant.secondary
                        : PButtonVariant.primary,
                    onPressed: () => toggleTaskCompleted(context, task),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _delete(BuildContext context) async {
    final confirmed = await confirmDeleteTask(context);
    if (!confirmed || !context.mounted) return;
    final navigator = Navigator.of(context);
    await context.read<TaskCubit>().deleteTask(task.id);
    navigator.pop();
  }
}

class _CountdownCard extends StatelessWidget {
  const _CountdownCard({required this.task, required this.now});

  final Task task;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final due = task.dueDate;
    if (due == null) {
      return SurfaceCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(Icons.event_busy_rounded, color: p.textTertiary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sin fecha límite', style: context.text.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    'Añade una para activar las alertas inteligentes.',
                    style: context.text.bodySmall,
                  ),
                ],
              ),
            ),
            PButton(
              label: 'Añadir',
              compact: true,
              expanded: false,
              variant: PButtonVariant.secondary,
              onPressed: () => openTaskEditor(context, task: task),
            ),
          ],
        ),
      );
    }

    final elapsed = task.elapsedFraction(now) ?? 0;
    final overdue = task.isOverdue(now);
    final color = task.isCompleted
        ? AppColors.success
        : urgencyColor(
            base: task.quadrant.color,
            elapsed: elapsed,
            overdue: overdue,
          );
    final remaining = due.difference(now);

    return SurfaceCard(
      tint: color,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          ProgressRing(
            value: task.isCompleted ? 1 : 1 - elapsed,
            color: color,
            size: 128,
            stroke: 9,
            marks: task.isCompleted
                ? const []
                : [for (final v in task.alertThresholds) v / 100],
            child: task.isCompleted
                ? const Icon(
                    Icons.check_rounded,
                    color: AppColors.success,
                    size: 36,
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        remaining.compact,
                        textAlign: TextAlign.center,
                        style: context.text.titleMedium?.copyWith(
                          color: overdue ? AppColors.danger : null,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        overdue ? 'de retraso' : 'restantes',
                        style: context.text.labelSmall?.copyWith(
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.isCompleted
                      ? 'COMPLETADA'
                      : overdue
                      ? 'VENCIÓ'
                      : 'VENCE',
                  style: context.text.labelSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  capitalize(due.weekdayDayMonth),
                  style: context.text.titleLarge,
                ),
                Text(
                  due.time,
                  style: context.text.displaySmall?.copyWith(
                    fontWeight: FontWeight.w300,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  task.isCompleted
                      ? 'Bien hecho.'
                      : '${(elapsed * 100).round()} % del tiempo consumido',
                  style: context.text.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final category = context.select(
      (CategoryCubit cubit) => cubit.state.categories
          .where((item) => item.name == task.category)
          .firstOrNull,
    );
    return SurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      child: Column(
        children: [
          _InfoRow(
            label: 'Categoría',
            value: task.category ?? 'Ninguna',
            leading: category == null
                ? null
                : Icon(category.icon, size: 15, color: category.color),
          ),
          const Divider(),
          _InfoRow(label: 'Cuadrante', value: task.quadrant.subtitle),
          const Divider(),
          _InfoRow(label: 'Creada', value: task.createdAt.absoluteLabel),
          const Divider(),
          _InfoRow(
            label: 'Estado',
            value: task.isCompleted ? 'Completada' : 'Pendiente',
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.leading});

  final String label;
  final String value;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: [
          Text(label, style: context.text.bodyMedium),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: 6)],
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.titleSmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MoveChip extends StatelessWidget {
  const _MoveChip({
    required this.quadrant,
    required this.current,
    required this.onTap,
  });

  final TaskQuadrant quadrant;
  final bool current;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = quadrant.color;
    return Pressable(
      onTap: current ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: current
              ? Color.alphaBlend(color.withValues(alpha: 0.16), p.surface)
              : p.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: current ? color.withValues(alpha: 0.7) : p.hairline,
          ),
        ),
        child: Column(
          children: [
            Icon(quadrant.icon, size: 18, color: color),
            const SizedBox(height: 6),
            Text(
              quadrant.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.labelMedium?.copyWith(
                color: current ? p.textPrimary : p.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
