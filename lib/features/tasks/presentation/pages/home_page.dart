import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_palette.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/widgets/clock_scope.dart';
import '../../../../core/widgets/layout.dart';
import '../../../../core/widgets/p_button.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../../../core/widgets/time_visuals.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../../domain/entities/task.dart';
import '../cubit/task_cubit.dart';
import '../cubit/task_state.dart';
import '../task_actions.dart';
import '../widgets/task_tile.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.onNavigate});

  /// Switches the shell tab (1 = matrix, 2 = agenda).
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final now = ClockScope.now(context);
    final name = context.select(
      (SettingsCubit cubit) => cubit.state.settings.userName,
    );
    return BlocBuilder<TaskCubit, TaskState>(
      builder: (context, state) {
        final tasks = state.tasks;
        final pending = tasks.where((task) => !task.isCompleted).toList();
        final upcoming = pending.where((task) => task.dueDate != null).toList()
          ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

        return PageFrame(
          onRefresh: () => context.read<TaskCubit>().loadTasks(),
          children: [
            PageHeader(overline: now.longDate, title: _greeting(now, name)),
            const SizedBox(height: 24),
            _FocusHero(tasks: tasks, now: now),
            const SizedBox(height: 32),
            SectionLabel(
              'Próximos vencimientos',
              action: upcoming.isEmpty ? null : 'Agenda',
              onAction: () => onNavigate(2),
            ),
            const SizedBox(height: 12),
            if (upcoming.isEmpty)
              _QuietCard(
                hasTasks: tasks.isNotEmpty,
                onCreate: () => openTaskEditor(context),
              )
            else
              for (final task in upcoming.take(4))
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TaskTile(task: task),
                ),
            const SizedBox(height: 22),
            SectionLabel(
              'Tu matriz',
              action: 'Abrir',
              onAction: () => onNavigate(1),
            ),
            const SizedBox(height: 12),
            _MatrixOverview(tasks: pending, onTap: () => onNavigate(1)),
            if (tasks.isNotEmpty) ...[
              const SizedBox(height: 14),
              _InsightNote(tasks: pending),
            ],
          ],
        );
      },
    );
  }

  String _greeting(DateTime now, String name) {
    final hour = now.hour;
    final base = hour < 6
        ? 'Buenas noches'
        : hour < 12
        ? 'Buenos días'
        : hour < 20
        ? 'Buenas tardes'
        : 'Buenas noches';
    return name.isEmpty ? base : '$base, $name';
  }
}

class _FocusHero extends StatelessWidget {
  const _FocusHero({required this.tasks, required this.now});

  final List<Task> tasks;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final pending = tasks.where((task) => !task.isCompleted).toList();
    final completed = tasks.length - pending.length;
    final critical = pending
        .where((task) => task.quadrant == TaskQuadrant.doNow)
        .length;
    final dueToday = pending
        .where((task) => task.dueDate?.isSameDay(now) ?? false)
        .length;
    final overdue = pending.where((task) => task.isOverdue(now)).length;
    final progress = tasks.isEmpty ? 0.0 : completed / tasks.length;

    return SurfaceCard(
      tint: p.accent,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('HACER YA', style: context.text.labelSmall),
                    const SizedBox(height: 6),
                    Text(
                      '$critical',
                      style: context.text.displayLarge?.copyWith(
                        fontSize: 64,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      critical == 1
                          ? 'tarea crítica pendiente'
                          : 'tareas críticas pendientes',
                      style: context.text.bodyMedium,
                    ),
                  ],
                ),
              ),
              ProgressRing(
                value: progress,
                color: p.accent,
                size: 104,
                stroke: 8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(progress * 100).round()}%',
                      style: context.text.titleLarge,
                    ),
                    Text(
                      'hecho',
                      style: context.text.labelSmall?.copyWith(
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 14),
          Row(
            children: [
              _Stat(label: 'Pendientes', value: pending.length),
              _Stat(label: 'Vencen hoy', value: dueToday),
              _Stat(
                label: 'Vencidas',
                value: overdue,
                color: overdue > 0 ? AppColors.danger : null,
              ),
              _Stat(label: 'Hechas', value: completed),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.color});

  final String label;
  final int value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$value',
            style: context.text.titleLarge?.copyWith(
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.bodySmall?.copyWith(fontSize: 11.5),
          ),
        ],
      ),
    );
  }
}

class _MatrixOverview extends StatelessWidget {
  const _MatrixOverview({required this.tasks, required this.onTap});

  final List<Task> tasks;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Widget cell(TaskQuadrant quadrant) {
      final count = tasks.where((task) => task.quadrant == quadrant).length;
      final share = tasks.isEmpty ? 0.0 : count / tasks.length;
      return Expanded(
        child: SurfaceCard(
          onTap: () => openQuadrant(context, quadrant),
          radius: 20,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(quadrant.icon, size: 16, color: quadrant.color),
                  const Spacer(),
                  Text(
                    '$count',
                    style: context.text.titleLarge?.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(quadrant.title, style: context.text.titleSmall),
              const SizedBox(height: 8),
              TimeProgressBar(
                elapsed: share,
                color: quadrant.color,
                thickness: 3,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            cell(TaskQuadrant.doNow),
            const SizedBox(width: 10),
            cell(TaskQuadrant.schedule),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            cell(TaskQuadrant.delegate),
            const SizedBox(width: 10),
            cell(TaskQuadrant.eliminate),
          ],
        ),
      ],
    );
  }
}

class _InsightNote extends StatelessWidget {
  const _InsightNote({required this.tasks});

  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.hairline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome_rounded, size: 18, color: p.accent),
          const SizedBox(width: 12),
          Expanded(child: Text(_insight(), style: context.text.bodyMedium)),
        ],
      ),
    );
  }

  String _insight() {
    if (tasks.isEmpty) {
      return 'Todo en orden. Disfruta del espacio libre o planifica lo siguiente.';
    }
    int count(TaskQuadrant q) => tasks.where((t) => t.quadrant == q).length;
    final total = tasks.length;
    final urgent = tasks.where((t) => t.isUrgent).length;
    if (count(TaskQuadrant.eliminate) / total >= 0.3) {
      return 'Hay bastante en Eliminar. Soltar algunas tareas te dará foco.';
    }
    if (count(TaskQuadrant.schedule) / total >= 0.4) {
      return 'Buen equilibrio: la mayor parte de tu trabajo es importante y está planificado.';
    }
    if (urgent / total > 0.6) {
      return 'La urgencia está dirigiendo tu día. Reserva tiempo para lo importante antes de que se vuelva urgente.';
    }
    return 'Revisa tu matriz cada mañana: decide primero, ejecuta después.';
  }
}

class _QuietCard extends StatelessWidget {
  const _QuietCard({required this.hasTasks, required this.onCreate});

  final bool hasTasks;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SurfaceCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.hourglass_empty_rounded, color: p.accent),
          const SizedBox(height: 12),
          Text(
            hasTasks
                ? 'Sin vencimientos próximos'
                : 'Empieza por lo que importa',
            style: context.text.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Añade una fecha límite y Priorix te avisará cuando quede el 50 %, el 20 % o el tiempo que elijas.',
            style: context.text.bodyMedium,
          ),
          if (!hasTasks) ...[
            const SizedBox(height: 16),
            PButton(
              label: 'Crear primera tarea',
              icon: Icons.add_rounded,
              expanded: false,
              compact: true,
              onPressed: onCreate,
            ),
          ],
        ],
      ),
    );
  }
}
