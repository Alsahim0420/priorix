import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/notification_service.dart';
import '../../data/settings_local_datasource.dart';
import '../../domain/app_settings.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({
    required this.localDataSource,
    required this.notificationService,
  }) : super(const SettingsState());

  final SettingsLocalDataSource localDataSource;
  final NotificationService notificationService;

  Future<void> loadSettings() async {
    final settings = localDataSource.getSettings();
    emit(SettingsState(settings: settings));
  }

  Future<void> setTheme(AppThemePreset preset) {
    return _save(state.settings.copyWith(themePreset: preset));
  }

  Future<void> setDefaultView(int index) {
    return _save(state.settings.copyWith(defaultViewIndex: index));
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    if (enabled) {
      final granted = await notificationService.requestPermissions();
      if (!granted) {
        emit(
          state.copyWith(message: 'Notification permission was not granted.'),
        );
        return;
      }
    }
    await _save(state.settings.copyWith(notificationsEnabled: enabled));
  }

  Future<void> replaceSettings(AppSettings settings) async {
    await _save(settings);
  }

  Future<void> _save(AppSettings settings) async {
    await localDataSource.saveSettings(settings);
    emit(SettingsState(settings: settings));
  }
}
