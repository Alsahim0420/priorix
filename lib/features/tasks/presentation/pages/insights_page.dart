import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../domain/entities/task.dart';
import '../cubit/task_cubit.dart';
import '../cubit/task_state.dart';
import '../widgets/insight_card.dart';

class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<TaskCubit, TaskState>(
        builder: (context, state) {
          final tasks = state.tasks;
          final completed = tasks.where((task) => task.isCompleted).length;
          final completionRate = tasks.isEmpty
              ? 0
              : ((completed / tasks.length) * 100).round();
          final focusScore = tasks.isEmpty
              ? 0
              : ((tasks.where((task) => task.isImportant).length /
                            tasks.length) *
                        100)
                    .round();
          final mostUsed = _mostUsed(tasks);
          final later = tasks
              .where((task) => task.quadrant == TaskQuadrant.later)
              .length;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 96),
            children: [
              const Text('Insights', style: AppTextStyles.title),
              const SizedBox(height: 6),
              const Text(
                'Clarity metrics for how your attention is allocated.',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 20),
              if (tasks.isEmpty)
                const EmptyState(
                  title: 'No insight data yet.',
                  message: 'Create priorities to unlock focus analytics.',
                  icon: Icons.insights_rounded,
                )
              else ...[
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.55,
                  children: [
                    InsightCard(
                      title: 'Focus score',
                      value: '$focusScore%',
                      icon: Icons.center_focus_strong_rounded,
                    ),
                    InsightCard(
                      title: 'Completion rate',
                      value: '$completionRate%',
                      icon: Icons.verified_rounded,
                      color: AppColors.emerald,
                    ),
                    InsightCard(
                      title: 'Most used quadrant',
                      value: mostUsed?.title ?? 'None',
                      icon: Icons.grid_view_rounded,
                      color: AppColors.royalBlue,
                    ),
                    InsightCard(
                      title: 'Later list',
                      value: '$later',
                      icon: Icons.bookmark_added_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quadrant distribution',
                        style: AppTextStyles.section,
                      ),
                      const SizedBox(height: 16),
                      ...TaskQuadrant.values.map((quadrant) {
                        final count = tasks
                            .where((task) => task.quadrant == quadrant)
                            .length;
                        final ratio = tasks.isEmpty
                            ? 0.0
                            : count / tasks.length;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      quadrant.title,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '$count',
                                    style: TextStyle(color: quadrant.color),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: ratio,
                                minHeight: 8,
                                color: quadrant.color,
                                backgroundColor: AppColors.surfaceSecondary,
                                borderRadius: BorderRadius.circular(99),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GlassCard(
                  borderColor: AppColors.primaryGold.withValues(alpha: 0.36),
                  child: Text(_insightText(tasks), style: AppTextStyles.body),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  TaskQuadrant? _mostUsed(List<Task> tasks) {
    if (tasks.isEmpty) return null;
    return TaskQuadrant.values.reduce((a, b) {
      final aCount = tasks.where((task) => task.quadrant == a).length;
      final bCount = tasks.where((task) => task.quadrant == b).length;
      return aCount >= bCount ? a : b;
    });
  }

  String _insightText(List<Task> tasks) {
    final urgent = tasks.where((task) => task.isUrgent).length;
    final important = tasks.where((task) => task.isImportant).length;
    if (urgent > important) {
      return 'You are spending most of your time on urgent tasks. Try scheduling important work earlier.';
    }
    return 'Your task mix is leaning toward important work. Protect calendar blocks for Schedule priorities.';
  }
}
