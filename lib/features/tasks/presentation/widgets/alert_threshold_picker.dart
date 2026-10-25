import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/p_button.dart';
import '../../../../core/widgets/pressable.dart';
import '../../domain/services/deadline_alert_planner.dart';

/// Lets the user pick "notify me when X % of the time remains" thresholds,
/// either from presets or individually.
class AlertThresholdPicker extends StatelessWidget {
  const AlertThresholdPicker({
    super.key,
    required this.values,
    required this.onChanged,
  });

  final List<int> values;
  final ValueChanged<List<int>> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final normalized = DeadlineAlertPlanner.normalize(values);
    final options = DeadlineAlertPlanner.normalize([
      ...DeadlineAlertPlanner.suggested,
      ...normalized,
    ]);
    final full = normalized.length >= DeadlineAlertPlanner.maxThresholds;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              for (final preset in DeadlineAlertPlanner.presets)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _PresetChip(
                    preset: preset,
                    selected: listEquals(preset.thresholds, normalized),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onChanged(preset.thresholds);
                    },
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text('Avisarme cuando quede…', style: context.text.bodyMedium),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final value in options)
              _PercentChip(
                value: value,
                selected: normalized.contains(value),
                onTap: () {
                  HapticFeedback.selectionClick();
                  if (normalized.contains(value)) {
                    onChanged([...normalized]..remove(value));
                  } else if (!full) {
                    onChanged([...normalized, value]);
                  }
                },
              ),
            if (!full)
              Pressable(
                onTap: () async {
                  final value = await _pickCustom(context);
                  if (value != null) onChanged([...normalized, value]);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: p.hairline),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, size: 16, color: p.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        'Otro',
                        style: context.text.labelLarge?.copyWith(
                          color: p.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        if (normalized.isEmpty) ...[
          const SizedBox(height: 10),
          Text(
            'Sin avisos por porcentaje.',
            style: context.text.bodySmall?.copyWith(color: p.textTertiary),
          ),
        ],
      ],
    );
  }

  Future<int?> _pickCustom(BuildContext context) {
    return showModalBottomSheet<int>(
      context: context,
      builder: (_) => const _CustomPercentSheet(),
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.preset,
    required this.selected,
    required this.onTap,
  });

  final AlertPreset preset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.fromLTRB(14, 10, 16, 10),
        decoration: BoxDecoration(
          color: selected ? p.accent.withValues(alpha: 0.14) : p.surfaceHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? p.accent.withValues(alpha: 0.6) : p.hairline,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              preset.name,
              style: context.text.titleSmall?.copyWith(
                color: selected ? p.accent : p.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${preset.thresholds.join(' · ')} %',
              style: context.text.bodySmall?.copyWith(fontSize: 11.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _PercentChip extends StatelessWidget {
  const _PercentChip({
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final int value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? p.accent : p.surfaceHigh,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? p.accent : p.hairline),
        ),
        child: Text(
          '$value %',
          style: context.text.labelLarge?.copyWith(
            color: selected ? p.onAccent : p.textPrimary,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}

class _CustomPercentSheet extends StatefulWidget {
  const _CustomPercentSheet();

  @override
  State<_CustomPercentSheet> createState() => _CustomPercentSheetState();
}

class _CustomPercentSheetState extends State<_CustomPercentSheet> {
  double _value = 30;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Aviso personalizado', style: context.text.titleLarge),
            const SizedBox(height: 6),
            Text(
              'Te avisaremos cuando quede este porcentaje del tiempo hasta la fecha límite.',
              style: context.text.bodyMedium,
            ),
            const SizedBox(height: 28),
            Center(
              child: Text(
                '${_value.round()} %',
                style: context.text.displayLarge?.copyWith(color: p.accent),
              ),
            ),
            const SizedBox(height: 12),
            Slider(
              value: _value,
              min: 1,
              max: 99,
              divisions: 98,
              onChanged: (value) {
                if (value.round() != _value.round()) {
                  HapticFeedback.selectionClick();
                }
                setState(() => _value = value);
              },
            ),
            const SizedBox(height: 16),
            PButton(
              label: 'Añadir aviso',
              icon: Icons.notifications_active_outlined,
              onPressed: () => Navigator.pop(context, _value.round()),
            ),
          ],
        ),
      ),
    );
  }
}
