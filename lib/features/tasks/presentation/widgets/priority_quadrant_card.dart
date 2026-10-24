import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../domain/entities/task.dart';

class PriorityQuadrantCard extends StatelessWidget {
  const PriorityQuadrantCard({
    super.key,
    required this.quadrant,
    required this.tasks,
    this.onTap,
  });

  final TaskQuadrant quadrant;
  final List<Task> tasks;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final active = tasks.where((task) => !task.isCompleted).toList();
    return GlassCard(
      onTap: onTap,
      borderColor: quadrant.color.withValues(alpha: 0.42),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          quadrant.color.withValues(alpha: 0.16),
          AppColors.surface.withValues(alpha: 0.78),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: quadrant.color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(quadrant.icon, color: quadrant.color),
              ),
              const Spacer(),
              Text(
                '${active.length}',
                style: TextStyle(
                  color: quadrant.color,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            quadrant.title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            quadrant.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          if (active.isEmpty)
            const Text(
              'No priorities here yet.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            )
          else
            ...active
                .take(2)
                .map(
                  (task) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: quadrant.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            task.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
