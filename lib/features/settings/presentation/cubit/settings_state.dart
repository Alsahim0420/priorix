import 'package:equatable/equatable.dart';
import '../../domain/app_settings.dart';

class SettingsState extends Equatable {
  const SettingsState({this.settings = const AppSettings(), this.message});

  final AppSettings settings;
  final String? message;

  SettingsState copyWith({AppSettings? settings, String? message}) {
    return SettingsState(settings: settings ?? this.settings, message: message);
  }

  @override
  List<Object?> get props => [settings, message];
}
