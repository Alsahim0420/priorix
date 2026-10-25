import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/pressable.dart';
import '../../domain/entities/task.dart';

/// Compact 2×2 Eisenhower picker.
class QuadrantSelector extends StatelessWidget {
  const QuadrantSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final TaskQuadrant value;
  final ValueChanged<TaskQuadrant> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget cell(TaskQuadrant quadrant) => Expanded(
      child: _Cell(
        quadrant: quadrant,
        selected: quadrant == value,
        onTap: () {
          HapticFeedback.selectionClick();
          onChanged(quadrant);
        },
      ),
    );
    final axis = context.text.labelSmall?.copyWith(fontSize: 10);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Center(child: Text('URGENTE', style: axis)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Center(child: Text('NO URGENTE', style: axis)),
            ),
          ],
        ),
        const SizedBox(height: 8),
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

class _Cell extends StatelessWidget {
  const _Cell({
    required this.quadrant,
    required this.selected,
    required this.onTap,
  });

  final TaskQuadrant quadrant;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = quadrant.color;
    return Semantics(
      selected: selected,
      button: true,
      label: '${quadrant.title}: ${quadrant.subtitle}',
      child: Pressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          height: 92,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected
                ? Color.alphaBlend(color.withValues(alpha: 0.16), p.surface)
                : p.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? color.withValues(alpha: 0.8) : p.hairline,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    quadrant.icon,
                    size: 18,
                    color: selected ? color : p.textTertiary,
                  ),
                  const Spacer(),
                  AnimatedOpacity(
                    opacity: selected ? 1 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: color,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                quadrant.title,
                style: context.text.titleSmall?.copyWith(
                  color: selected ? p.textPrimary : p.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                quadrant.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.bodySmall?.copyWith(
                  fontSize: 11,
                  color: p.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
