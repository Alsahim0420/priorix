import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/priority_chip.dart';
import '../../domain/entities/task.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onToggle,
    this.compact = false,
  });

  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onToggle;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: task.isCompleted ? 0.62 : 1,
      child: GlassCard(
        onTap: onTap,
        padding: EdgeInsets.all(compact ? 12 : 16),
        borderColor: task.quadrant.color.withValues(alpha: 0.28),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: task.isCompleted
                      ? AppColors.success.withValues(alpha: 0.16)
                      : AppColors.surfaceSecondary,
                  border: Border.all(
                    color: task.isCompleted
                        ? AppColors.success
                        : AppColors.border,
                  ),
                ),
                child: task.isCompleted
                    ? const Icon(
                        Icons.check_rounded,
                        size: 17,
                        color: AppColors.success,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    maxLines: compact ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: compact ? 13 : 15,
                      fontWeight: FontWeight.w800,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  if (!compact && (task.description ?? '').isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      task.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      PriorityChip(quadrant: task.quadrant, compact: true),
                      if (task.dueDate != null)
                        _MetaPill(
                          icon: Icons.schedule_rounded,
                          label: task.dueDate!.mediumLabel,
                        ),
                      if (task.reminderAt != null)
                        _MetaPill(
                          icon: Icons.notifications_active_rounded,
                          label:
                              '${task.reminderAt!.mediumLabel} ${task.reminderAt!.hour.toString().padLeft(2, '0')}:${task.reminderAt!.minute.toString().padLeft(2, '0')}',
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
