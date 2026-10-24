import 'package:flutter/material.dart';
import '../../features/tasks/domain/entities/task.dart';

class QuadrantBadge extends StatelessWidget {
  const QuadrantBadge({super.key, required this.quadrant, this.dense = false});

  final TaskQuadrant quadrant;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final color = quadrant.color;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 11,
        vertical: dense ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(quadrant.icon, color: color, size: dense ? 12 : 14),
          SizedBox(width: dense ? 4 : 6),
          Text(
            quadrant.title,
            style: TextStyle(
              color: color,
              fontSize: dense ? 11 : 12.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
