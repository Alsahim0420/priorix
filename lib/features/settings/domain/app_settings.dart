import 'package:equatable/equatable.dart';

enum AppThemePreset {
  midnight,
  graphite,
  emeraldNoir,
  amethyst,
  champagneLight,
  porcelainLight,
  mintLight,
}

extension AppThemePresetX on AppThemePreset {
  String get label => switch (this) {
    AppThemePreset.midnight => 'Obsidiana',
    AppThemePreset.graphite => 'Grafito',
    AppThemePreset.emeraldNoir => 'Jade',
    AppThemePreset.amethyst => 'Amatista',
    AppThemePreset.champagneLight => 'Champagne',
    AppThemePreset.porcelainLight => 'Porcelana',
    AppThemePreset.mintLight => 'Menta',
  };

  bool get isLight => switch (this) {
    AppThemePreset.champagneLight ||
    AppThemePreset.porcelainLight ||
    AppThemePreset.mintLight => true,
    _ => false,
  };
}

/// Alert sounds bundled per platform: `assets/sounds/` (in-app preview),
/// `android/app/src/main/res/raw/` and the iOS/macOS Runner bundles.
enum NotificationSound { system, destello, logro, pulso, cristal, eco, mensaje }

extension NotificationSoundX on NotificationSound {
  String get label => switch (this) {
    NotificationSound.system => 'Predeterminado del sistema',
    NotificationSound.destello => 'Destello',
    NotificationSound.logro => 'Logro',
    NotificationSound.pulso => 'Pulso',
    NotificationSound.cristal => 'Cristal',
    NotificationSound.eco => 'Eco',
    NotificationSound.mensaje => 'Mensaje',
  };

  /// Resource name without extension; null for the system sound.
  String? get resource =>
      this == NotificationSound.system ? null : 'priorix_$name';

  String? get assetPath => resource == null ? null : 'sounds/$resource.wav';
}

class AppSettings extends Equatable {
  const AppSettings({
    this.themePreset = AppThemePreset.midnight,
    this.notificationsEnabled = false,
    this.defaultViewIndex = 0,
    this.defaultAlertThresholds = const [50, 20],
    this.defaultNotifyAtDeadline = true,
    this.userName = '',
    this.onboardingCompleted = false,
    this.notificationSound = NotificationSound.destello,
  });

  static const viewLabels = ['Inicio', 'Matriz', 'Agenda'];

  final AppThemePreset themePreset;
  final bool notificationsEnabled;
  final int defaultViewIndex;
  final List<int> defaultAlertThresholds;
  final bool defaultNotifyAtDeadline;
  final String userName;
  final bool onboardingCompleted;
  final NotificationSound notificationSound;

  AppSettings copyWith({
    AppThemePreset? themePreset,
    bool? notificationsEnabled,
    int? defaultViewIndex,
    List<int>? defaultAlertThresholds,
    bool? defaultNotifyAtDeadline,
    String? userName,
    bool? onboardingCompleted,
    NotificationSound? notificationSound,
  }) {
    return AppSettings(
      themePreset: themePreset ?? this.themePreset,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      defaultViewIndex: defaultViewIndex ?? this.defaultViewIndex,
      defaultAlertThresholds:
          defaultAlertThresholds ?? this.defaultAlertThresholds,
      defaultNotifyAtDeadline:
          defaultNotifyAtDeadline ?? this.defaultNotifyAtDeadline,
      userName: userName ?? this.userName,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      notificationSound: notificationSound ?? this.notificationSound,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'themePreset': themePreset.name,
      'notificationsEnabled': notificationsEnabled,
      'defaultViewIndex': defaultViewIndex,
      'defaultAlertThresholds': defaultAlertThresholds,
      'defaultNotifyAtDeadline': defaultNotifyAtDeadline,
      'userName': userName,
      'onboardingCompleted': onboardingCompleted,
      'notificationSound': notificationSound.name,
    };
  }

  factory AppSettings.fromMap(Map<dynamic, dynamic> map) {
    final thresholds = map['defaultAlertThresholds'];
    return AppSettings(
      themePreset: AppThemePreset.values.firstWhere(
        (preset) => preset.name == map['themePreset'],
        orElse: () => AppThemePreset.midnight,
      ),
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? false,
      defaultViewIndex: ((map['defaultViewIndex'] as int?) ?? 0).clamp(
        0,
        viewLabels.length - 1,
      ),
      defaultAlertThresholds: thresholds is List
          ? thresholds.whereType<num>().map((v) => v.toInt()).toList()
          : const [50, 20],
      defaultNotifyAtDeadline: map['defaultNotifyAtDeadline'] as bool? ?? true,
      userName: map['userName'] as String? ?? '',
      onboardingCompleted: map['onboardingCompleted'] as bool? ?? false,
      notificationSound: NotificationSound.values.firstWhere(
        (sound) => sound.name == map['notificationSound'],
        orElse: () => NotificationSound.destello,
      ),
    );
  }

  @override
  List<Object> get props => [
    themePreset,
    notificationsEnabled,
    defaultViewIndex,
    defaultAlertThresholds,
    defaultNotifyAtDeadline,
    userName,
    onboardingCompleted,
    notificationSound,
  ];
}
