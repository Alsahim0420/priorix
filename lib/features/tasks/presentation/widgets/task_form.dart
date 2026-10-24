import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/luxury_button.dart';
import '../../../../core/widgets/priority_chip.dart';
import '../../../categories/domain/task_category.dart';
import '../../../categories/presentation/cubit/category_cubit.dart';
import '../../../categories/presentation/cubit/category_state.dart';
import '../../domain/entities/task.dart';

class TaskFormValue {
  const TaskFormValue({
    required this.title,
    this.description,
    this.dueDate,
    this.reminderAt,
    this.category,
    required this.isUrgent,
    required this.isImportant,
  });

  final String title;
  final String? description;
  final DateTime? dueDate;
  final DateTime? reminderAt;
  final String? category;
  final bool isUrgent;
  final bool isImportant;
}

class TaskForm extends StatefulWidget {
  const TaskForm({
    super.key,
    this.initialTask,
    required this.primaryLabel,
    required this.onSubmit,
    this.onCancel,
    this.onDelete,
  });

  final Task? initialTask;
  final String primaryLabel;
  final ValueChanged<TaskFormValue> onSubmit;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  String? _category;
  late bool _urgent;
  late bool _important;
  DateTime? _dueDate;
  DateTime? _reminderAt;

  @override
  void initState() {
    super.initState();
    final task = widget.initialTask;
    _title = TextEditingController(text: task?.title ?? '');
    _description = TextEditingController(text: task?.description ?? '');
    _category = task?.category;
    _urgent = task?.isUrgent ?? true;
    _important = task?.isImportant ?? true;
    _dueDate = task?.dueDate;
    _reminderAt = task?.reminderAt;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  TaskQuadrant get _quadrant {
    if (_urgent && _important) return TaskQuadrant.doNow;
    if (!_urgent && _important) return TaskQuadrant.schedule;
    if (_urgent && !_important) return TaskQuadrant.delegate;
    return TaskQuadrant.later;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _title,
            textInputAction: TextInputAction.next,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Title',
              hintText: 'Board review, proposal, workout...',
            ),
            validator: (value) {
              if ((value ?? '').trim().isEmpty) {
                return 'A priority needs a title';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _description,
            minLines: 3,
            maxLines: 5,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Context, decision, next step...',
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: BlocBuilder<CategoryCubit, CategoryState>(
                  builder: (context, state) {
                    return _CategoryPicker(
                      categories: state.categories,
                      value: _category,
                      onChanged: (value) => setState(() => _category = value),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Due date'),
                    child: Text(
                      _dueDate?.mediumLabel ?? 'Optional',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: _pickReminder,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Task notification',
                suffixIcon: _reminderAt == null
                    ? null
                    : IconButton(
                        tooltip: 'Clear reminder',
                        onPressed: () => setState(() => _reminderAt = null),
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications_active_rounded, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _reminderAt == null
                          ? 'No reminder'
                          : '${_reminderAt!.mediumLabel} at ${_reminderAt!.hour.toString().padLeft(2, '0')}:${_reminderAt!.minute.toString().padLeft(2, '0')}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _PremiumSwitch(
                  label: 'Important',
                  value: _important,
                  color: AppColors.emerald,
                  onChanged: (value) => setState(() => _important = value),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PremiumSwitch(
                  label: 'Urgent',
                  value: _urgent,
                  color: AppColors.primaryGold,
                  onChanged: (value) => setState(() => _urgent = value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GlassCard(
            padding: const EdgeInsets.all(16),
            borderColor: _quadrant.color.withValues(alpha: 0.42),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'This task belongs to:',
                    style: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.95),
                    ),
                  ),
                ),
                PriorityChip(quadrant: _quadrant),
              ],
            ),
          ),
          const SizedBox(height: 22),
          LuxuryButton(
            label: widget.primaryLabel,
            icon: Icons.check_rounded,
            onPressed: _submit,
          ),
          const SizedBox(height: 12),
          LuxuryButton(
            label: 'Cancel',
            secondary: true,
            onPressed: widget.onCancel ?? () => Navigator.pop(context),
          ),
          if (widget.onDelete != null) ...[
            const SizedBox(height: 12),
            LuxuryButton(
              label: 'Delete task',
              icon: Icons.delete_outline_rounded,
              danger: true,
              onPressed: widget.onDelete,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSubmit(
      TaskFormValue(
        title: _title.text,
        description: _description.text,
        dueDate: _dueDate,
        reminderAt: _reminderAt,
        category: _category,
        isUrgent: _urgent,
        isImportant: _important,
      ),
    );
  }

  Future<void> _pickReminder() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _reminderAt ?? _dueDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: _reminderAt == null
          ? TimeOfDay.now()
          : TimeOfDay(hour: _reminderAt!.hour, minute: _reminderAt!.minute),
    );
    if (time == null) return;
    setState(() {
      _reminderAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }
}

class _CategoryPicker extends StatelessWidget {
  const _CategoryPicker({
    required this.categories,
    required this.value,
    required this.onChanged,
  });

  final List<TaskCategory> categories;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final normalizedValue = (value ?? '').trim();
    final options = <TaskCategory>[
      ...categories,
      if (normalizedValue.isNotEmpty &&
          !categories.any(
            (category) =>
                category.name.toLowerCase() == normalizedValue.toLowerCase(),
          ))
        TaskCategory(
          name: normalizedValue,
          iconKey: 'folder',
          colorValue: AppColors.primaryGold.toARGB32(),
        ),
    ];

    return DropdownButtonFormField<String?>(
      initialValue: normalizedValue.isEmpty ? null : normalizedValue,
      isExpanded: true,
      dropdownColor: AppColors.surface,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: const InputDecoration(labelText: 'Category'),
      items: [
        const DropdownMenuItem<String?>(value: null, child: Text('None')),
        ...options.map(
          (category) => DropdownMenuItem<String?>(
            value: category.name,
            child: Row(
              children: [
                Icon(category.icon, color: category.color, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(category.name, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

class _PremiumSwitch extends StatelessWidget {
  const _PremiumSwitch({
    required this.label,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final Color color;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      borderColor: value ? color.withValues(alpha: 0.55) : AppColors.border,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: value ? color : AppColors.textSecondary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Switch(value: value, activeThumbColor: color, onChanged: onChanged),
        ],
      ),
    );
  }
}
