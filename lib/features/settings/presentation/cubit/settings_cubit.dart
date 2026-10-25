import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../tasks/domain/services/deadline_alert_planner.dart';
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

  void loadSettings() {
    emit(SettingsState(settings: localDataSource.getSettings()));
  }

  Future<void> setTheme(AppThemePreset preset) {
    return _save(state.settings.copyWith(themePreset: preset));
  }

  Future<void> setDefaultView(int index) {
    return _save(state.settings.copyWith(defaultViewIndex: index));
  }

  Future<void> setUserName(String name) {
    return _save(state.settings.copyWith(userName: name.trim()));
  }

  Future<void> completeOnboarding({String name = ''}) {
    return _save(
      state.settings.copyWith(userName: name.trim(), onboardingCompleted: true),
    );
  }

  Future<void> setDefaultAlerts({
    required List<int> thresholds,
    required bool notifyAtDeadline,
  }) {
    return _save(
      state.settings.copyWith(
        defaultAlertThresholds: DeadlineAlertPlanner.normalize(thresholds),
        defaultNotifyAtDeadline: notifyAtDeadline,
      ),
    );
  }

  /// Returns whether notifications ended up enabled.
  Future<bool> setNotificationsEnabled(bool enabled) async {
    if (enabled) {
      final granted = await notificationService.requestPermissions();
      if (!granted) {
        emit(
          state.copyWith(
            message:
                'Permiso denegado. Actívalo en los ajustes del sistema para recibir alertas.',
          ),
        );
        // Clear it so the same message can be shown again next time.
        emit(state.copyWith());
        return false;
      }
    }
    await _save(state.settings.copyWith(notificationsEnabled: enabled));
    return enabled;
  }

  Future<void> replaceSettings(AppSettings settings) async {
    await _save(settings);
  }

  Future<void> _save(AppSettings settings) async {
    await localDataSource.saveSettings(settings);
    emit(SettingsState(settings: settings));
  }
}
