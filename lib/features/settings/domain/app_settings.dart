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
    AppThemePreset.midnight => 'Midnight Navy',
    AppThemePreset.graphite => 'Graphite Black',
    AppThemePreset.emeraldNoir => 'Emerald Noir',
    AppThemePreset.amethyst => 'Amethyst Night',
    AppThemePreset.champagneLight => 'Champagne Light',
    AppThemePreset.porcelainLight => 'Porcelain Light',
    AppThemePreset.mintLight => 'Mint Executive',
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
  });

  final AppThemePreset themePreset;
  final bool notificationsEnabled;
  final int defaultViewIndex;

  AppSettings copyWith({
    AppThemePreset? themePreset,
    bool? notificationsEnabled,
    int? defaultViewIndex,
  }) {
    return AppSettings(
      themePreset: themePreset ?? this.themePreset,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      defaultViewIndex: defaultViewIndex ?? this.defaultViewIndex,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'themePreset': themePreset.name,
      'notificationsEnabled': notificationsEnabled,
      'defaultViewIndex': defaultViewIndex,
    };
  }

  factory AppSettings.fromMap(Map<dynamic, dynamic> map) {
    return AppSettings(
      themePreset: AppThemePreset.values.firstWhere(
        (preset) => preset.name == map['themePreset'],
        orElse: () => AppThemePreset.midnight,
      ),
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? false,
      defaultViewIndex: map['defaultViewIndex'] as int? ?? 0,
    );
  }

  @override
  List<Object> get props => [
    themePreset,
    notificationsEnabled,
    defaultViewIndex,
  ];
}
