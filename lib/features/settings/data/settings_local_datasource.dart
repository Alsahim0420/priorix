import 'package:hive/hive.dart';
import '../domain/app_settings.dart';

class SettingsLocalDataSource {
  SettingsLocalDataSource(this.box);

  static const settingsKey = 'app_settings';
  final Box<dynamic> box;

  AppSettings getSettings() {
    final stored = box.get(settingsKey);
    if (stored is Map) return AppSettings.fromMap(stored);
    return const AppSettings();
  }

  Future<void> saveSettings(AppSettings settings) {
    return box.put(settingsKey, settings.toMap());
  }
}
