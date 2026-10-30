import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../settings/presentation/cubit/settings_cubit.dart';
import '../domain/entities/task.dart';
import 'cubit/task_cubit.dart';
import 'pages/quadrant_page.dart';
import 'pages/task_detail_page.dart';
import 'pages/task_editor_page.dart';

Future<void> openTaskEditor(
  BuildContext context, {
  Task? task,
  TaskQuadrant? initialQuadrant,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) =>
          TaskEditorPage(task: task, initialQuadrant: initialQuadrant),
    ),
  );
}

Future<void> openTaskDetail(BuildContext context, Task task) {
  return Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => TaskDetailPage(taskId: task.id)));
}

Future<void> openQuadrant(BuildContext context, TaskQuadrant quadrant) {
  return Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => QuadrantPage(quadrant: quadrant)));
}

Future<void> toggleTaskCompleted(BuildContext context, Task task) {
  if (task.isCompleted) {
    HapticFeedback.selectionClick();
  } else {
    HapticFeedback.mediumImpact();
  }
  return context.read<TaskCubit>().toggleCompleted(task.id);
}

/// Enables or disables alerts and reschedules every task accordingly.
Future<void> setNotifications(BuildContext context, bool enabled) async {
  final taskCubit = context.read<TaskCubit>();
  await context.read<SettingsCubit>().setNotificationsEnabled(enabled);
  await taskCubit.syncAllReminders();
}

/// Opens a task link in its own app (Notes, Freeform, browser…).
Future<void> openTaskLink(BuildContext context, String url) async {
  final messenger = ScaffoldMessenger.of(context);
  final uri = Uri.tryParse(url);
  var opened = false;
  if (uri != null) {
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on PlatformException {
      opened = false;
    }
  }
  if (!opened) {
    messenger.showSnackBar(
      const SnackBar(content: Text('No se pudo abrir el enlace.')),
    );
  }
}
