import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../domain/entities/task.dart';

class DashboardSummaryCard extends StatelessWidget {
  const DashboardSummaryCard({super.key, required this.tasks});

  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    final completed = tasks.where((task) => task.isCompleted).length;
    final today = DateTime.now();
    final dueToday = tasks.where((task) {
      final due = task.dueDate;
      return due != null &&
          due.year == today.year &&
          due.month == today.month &&
          due.day == today.day;
    }).length;
    final focusScore = tasks.isEmpty
        ? 0
        : (((tasks.where((task) => task.isImportant).length + completed) /
                      (tasks.length * 2)) *
                  100)
              .round();

    return GlassCard(
      borderColor: AppColors.primaryGold.withValues(alpha: 0.36),
      gradient: LinearGradient(
        colors: [
          AppColors.primaryGold.withValues(alpha: 0.16),
          AppColors.surface.withValues(alpha: 0.78),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Executive focus',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _Metric(label: 'Total tasks', value: '${tasks.length}'),
              _Metric(label: 'Completed', value: '$completed'),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _Metric(label: 'Focus score', value: '$focusScore%'),
              _Metric(label: 'Due today', value: '$dueToday'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.primaryGold,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
