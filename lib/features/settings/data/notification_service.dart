import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../../../app/theme/app_colors.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../tasks/domain/entities/task.dart';
import '../../tasks/domain/services/deadline_alert_planner.dart';
import '../domain/app_settings.dart';

class NotificationService {
  NotificationService();

  /// iOS keeps at most 64 pending local notifications per app; stay below it
  /// and keep the soonest ones when rescheduling everything.
  static const _maxPending = 60;

  /// Monochrome status-bar icon in android/app/src/main/res/drawable-*/,
  /// rendered from the brand mark (see test/brand_assets_test.dart).
  static const _androidIcon = 'ic_stat_priorix';

  /// Outside the range produced by [_notificationId].
  static const _testNotificationId = 0x7FFFFFF0;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  /// Android fixes a channel's sound when it is first created, so each sound
  /// gets its own channel; the pre-sound `priorix_deadlines` one is dropped.
  static const _legacyChannelId = 'priorix_deadlines';
  static String _channelId(NotificationSound sound) =>
      '${_legacyChannelId}_${sound.name}';

  NotificationSound _sound = NotificationSound.destello;

  NotificationDetails get _details {
    final resource = _sound.resource;
    final darwin = DarwinNotificationDetails(
      presentAlert: true,
      presentBanner: true,
      presentList: true,
      presentSound: true,
      sound: resource == null ? null : '$resource.wav',
    );
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId(_sound),
        'Vencimientos · ${_sound.label}',
        channelDescription: 'Avisos según el tiempo restante de tus tareas.',
        importance: Importance.high,
        priority: Priority.high,
        icon: _androidIcon,
        color: AppColors.gold,
        playSound: true,
        sound: resource == null
            ? null
            : RawResourceAndroidNotificationSound(resource),
      ),
      iOS: darwin,
      macOS: darwin,
    );
  }

  /// Applies to alerts scheduled from now on; callers reschedule existing ones.
  Future<void> setSound(NotificationSound sound) async {
    _sound = sound;
    if (!_ready) return;
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return;
    for (final id in [
      _legacyChannelId,
      for (final other in NotificationSound.values)
        if (other != sound) _channelId(other),
    ]) {
      await android.deleteNotificationChannel(id);
    }
  }

  Future<void> initialize() async {
    if (kIsWeb || Platform.isLinux || Platform.isWindows) return;
    tz_data.initializeTimeZones();
    await _configureLocalTimeZone();
    const android = AndroidInitializationSettings(_androidIcon);
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(
        android: android,
        iOS: darwin,
        macOS: darwin,
      ),
    );
    _ready = true;
  }

  Future<bool> requestPermissions() async {
    if (!_ready) return false;
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final androidGranted = await android?.requestNotificationsPermission();

    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final iosGranted = await ios?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    final mac = _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();
    final macGranted = await mac?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    return androidGranted ?? iosGranted ?? macGranted ?? true;
  }

  /// Fires one alert right away with the current sound.
  Future<void> showTest() async {
    if (!_ready) return;
    await _plugin.show(
      _testNotificationId,
      'Priorix',
      'Así sonarán tus alertas · ${_sound.label}',
      _details,
    );
  }

  Future<void> scheduleTaskAlerts({
    required Task task,
    required bool enabled,
  }) async {
    if (!_ready) return;
    await cancelTaskAlerts(task.id);
    if (!enabled || task.isCompleted) return;
    final now = DateTime.now();
    for (final alert in DeadlineAlertPlanner.forTask(task)) {
      if (alert.at.isAfter(now)) await _schedule(task, alert);
    }
  }

  Future<void> cancelTaskAlerts(String taskId) async {
    if (!_ready) return;
    for (var slot = 0; slot < DeadlineAlertPlanner.slotCount; slot++) {
      await _plugin.cancel(_notificationId(taskId, slot));
    }
  }

  Future<void> rescheduleAll({
    required List<Task> tasks,
    required bool enabled,
  }) async {
    if (!_ready) return;
    await _plugin.cancelAll();
    if (!enabled) return;
    final now = DateTime.now();
    final upcoming = [
      for (final task in tasks.where((task) => !task.isCompleted))
        for (final alert in DeadlineAlertPlanner.forTask(task))
          if (alert.at.isAfter(now)) (task: task, alert: alert),
    ]..sort((a, b) => a.alert.at.compareTo(b.alert.at));
    for (final item in upcoming.take(_maxPending)) {
      await _schedule(item.task, item.alert);
    }
  }

  Future<void> _schedule(Task task, PlannedAlert alert) {
    return _plugin.zonedSchedule(
      _notificationId(task.id, alert.slot),
      task.title,
      _body(task, alert),
      tz.TZDateTime.from(alert.at, tz.local),
      _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: task.id,
    );
  }

  String _body(Task task, PlannedAlert alert) {
    final due = task.dueDate;
    return switch (alert.kind) {
      AlertKind.threshold =>
        'Queda el ${alert.percentRemaining} % del tiempo · vence ${due!.absoluteLabel}',
      AlertKind.deadline => 'Vence ahora · ${task.quadrant.title}',
      AlertKind.reminder =>
        due == null
            ? 'Recordatorio · ${task.quadrant.title}'
            : 'Recordatorio · vence ${due.absoluteLabel}',
    };
  }

  /// Deterministic across launches (unlike `String.hashCode`), so alerts can
  /// be cancelled after a restart.
  static int _notificationId(String taskId, int slot) {
    var hash = 0x811c9dc5;
    for (final unit in taskId.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return (hash % 20000000) * DeadlineAlertPlanner.slotCount + slot;
  }

  Future<void> _configureLocalTimeZone() async {
    final timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }
}
