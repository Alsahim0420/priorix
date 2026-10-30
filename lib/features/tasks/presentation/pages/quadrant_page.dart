import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/layout.dart';
import '../../../../core/widgets/p_button.dart';
import '../../../../core/widgets/quadrant_badge.dart';
import '../../domain/entities/task.dart';
import '../cubit/task_cubit.dart';
import '../cubit/task_state.dart';
import '../task_actions.dart';
import '../widgets/task_tile.dart';

class QuadrantPage extends StatelessWidget {
  const QuadrantPage({super.key, required this.quadrant});

  final TaskQuadrant quadrant;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PremiumBackground(
        child: SafeArea(
          child: BlocBuilder<TaskCubit, TaskState>(
            builder: (context, state) {
              final tasks = state.tasks
                  .where((task) => task.quadrant == quadrant)
                  .toList();
              final pending = tasks.where((task) => !task.isCompleted).toList()
                ..sort((a, b) {
                  final ad = a.dueDate;
                  final bd = b.dueDate;
                  if (ad == null) return bd == null ? 0 : 1;
                  if (bd == null) return -1;
                  return ad.compareTo(bd);
                });
              final completed = tasks.where((task) => task.isCompleted);

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  Row(
                    children: [
                      CircleIconButton(
                        icon: Icons.arrow_back_rounded,
                        tooltip: 'Volver',
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Row(children: [QuadrantBadge(quadrant: quadrant)]),
                  const SizedBox(height: 14),
                  Text(quadrant.subtitle, style: context.text.headlineMedium),
                  const SizedBox(height: 8),
                  Text(quadrant.guidance, style: context.text.bodyMedium),
                  const SizedBox(height: 20),
                  PButton(
                    label: 'Añadir a ${quadrant.title}',
                    icon: Icons.add_rounded,
                    variant: PButtonVariant.secondary,
                    onPressed: () =>
                        openTaskEditor(context, initialQuadrant: quadrant),
                  ),
                  const SizedBox(height: 32),
                  SectionLabel('Pendientes · ${pending.length}'),
                  const SizedBox(height: 12),
                  if (pending.isEmpty)
                    EmptyState(
                      icon: quadrant.icon,
                      title: 'Nada pendiente aquí',
                      message: 'Este cuadrante está despejado.',
                    )
                  else
                    for (final task in pending)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: TaskTile(task: task, showQuadrant: false),
                      ),
                  if (completed.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    SectionLabel('Completadas · ${completed.length}'),
                    const SizedBox(height: 12),
                    for (final task in completed)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: TaskTile(task: task, showQuadrant: false),
                      ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
