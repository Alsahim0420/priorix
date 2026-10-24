import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../core/widgets/clock_scope.dart';
import '../features/categories/presentation/cubit/category_cubit.dart';
import '../features/settings/domain/app_settings.dart';
import '../features/settings/presentation/cubit/settings_cubit.dart';
import '../features/settings/presentation/cubit/settings_state.dart';
import '../features/tasks/presentation/cubit/task_cubit.dart';
import '../features/tasks/presentation/pages/onboarding_page.dart';
import 'shell.dart';
import 'splash.dart';
import 'theme/app_theme.dart';

class PriorixApp extends StatelessWidget {
  const PriorixApp({
    super.key,
    required this.taskCubit,
    required this.categoryCubit,
    required this.settingsCubit,
  });

  final TaskCubit taskCubit;
  final CategoryCubit categoryCubit;
  final SettingsCubit settingsCubit;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: taskCubit),
        BlocProvider.value(value: categoryCubit),
        BlocProvider.value(value: settingsCubit),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        buildWhen: (previous, current) =>
            previous.settings.themePreset != current.settings.themePreset,
        builder: (context, state) {
          final preset = state.settings.themePreset;
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: preset.isLight
                ? SystemUiOverlayStyle.dark
                : SystemUiOverlayStyle.light,
            child: MaterialApp(
              title: 'Priorix',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.build(preset),
              locale: const Locale('es'),
              supportedLocales: const [Locale('es'), Locale('en')],
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
              builder: (context, child) => ClockScope(child: child!),
              home: const _Root(),
            ),
          );
        },
      ),
    );
  }
}

class _Root extends StatefulWidget {
  const _Root();

  @override
  State<_Root> createState() => _RootState();
}

class _RootState extends State<_Root> {
  bool _splashDone = false;

  @override
  Widget build(BuildContext context) {
    final onboarded = context.select(
      (SettingsCubit cubit) => cubit.state.settings.onboardingCompleted,
    );
    final Widget child;
    if (!_splashDone) {
      child = AnnotatedRegion<SystemUiOverlayStyle>(
        key: const ValueKey('splash'),
        value: SystemUiOverlayStyle.light,
        child: PriorixSplash(
          onFinished: () => setState(() => _splashDone = true),
        ),
      );
    } else if (onboarded) {
      child = const PriorixShell(key: ValueKey('shell'));
    } else {
      child = const OnboardingPage(key: ValueKey('onboarding'));
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: child,
    );
  }
}
