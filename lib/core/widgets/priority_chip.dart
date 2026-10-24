import 'package:flutter/material.dart';
import '../../features/tasks/domain/entities/task.dart';

class PriorityChip extends StatelessWidget {
  const PriorityChip({super.key, required this.quadrant, this.compact = false});

  final TaskQuadrant quadrant;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 9 : 11,
        vertical: compact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: quadrant.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: quadrant.color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(quadrant.icon, color: quadrant.color, size: compact ? 13 : 15),
          const SizedBox(width: 6),
          Text(
            quadrant.title,
            style: TextStyle(
              color: quadrant.color,
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
