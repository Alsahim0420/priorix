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

class AppSettings extends Equatable {
  const AppSettings({
    this.themePreset = AppThemePreset.midnight,
    this.notificationsEnabled = false,
    this.defaultViewIndex = 0,
    this.defaultAlertThresholds = const [50, 20],
    this.defaultNotifyAtDeadline = true,
    this.userName = '',
    this.onboardingCompleted = false,
  });

  static const viewLabels = ['Inicio', 'Matriz', 'Agenda'];

  final AppThemePreset themePreset;
  final bool notificationsEnabled;
  final int defaultViewIndex;
  final List<int> defaultAlertThresholds;
  final bool defaultNotifyAtDeadline;
  final String userName;
  final bool onboardingCompleted;

  AppSettings copyWith({
    AppThemePreset? themePreset,
    bool? notificationsEnabled,
    int? defaultViewIndex,
    List<int>? defaultAlertThresholds,
    bool? defaultNotifyAtDeadline,
    String? userName,
    bool? onboardingCompleted,
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
  ];
}
