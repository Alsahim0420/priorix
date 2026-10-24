import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_theme.dart';
import '../features/categories/presentation/cubit/category_cubit.dart';
import '../features/settings/presentation/cubit/settings_cubit.dart';
import '../features/settings/presentation/cubit/settings_state.dart';
import '../features/tasks/presentation/cubit/task_cubit.dart';
import '../features/tasks/presentation/pages/calendar_page.dart';
import '../features/tasks/presentation/pages/home_page.dart';
import '../features/tasks/presentation/pages/insights_page.dart';
import '../features/tasks/presentation/pages/matrix_page.dart';
import '../features/tasks/presentation/pages/onboarding_page.dart';
import '../features/tasks/presentation/pages/settings_page.dart';

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
        BlocProvider.value(value: taskCubit..loadTasks()),
        BlocProvider.value(value: categoryCubit..loadCategories()),
        BlocProvider.value(value: settingsCubit..loadSettings()),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'Priorix',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.dark(preset: state.settings.themePreset),
            home: const _EntryFlow(),
          );
        },
      ),
    );
  }
}

class _EntryFlow extends StatefulWidget {
  const _EntryFlow();

  @override
  State<_EntryFlow> createState() => _EntryFlowState();
}

class _EntryFlowState extends State<_EntryFlow> {
  bool _started = false;

  @override
  Widget build(BuildContext context) {
    if (!_started) {
      return OnboardingPage(onStart: () => setState(() => _started = true));
    }
    return const _PriorixShell();
  }
}

class _PriorixShell extends StatefulWidget {
  const _PriorixShell();

  @override
  State<_PriorixShell> createState() => _PriorixShellState();
}

class _PriorixShellState extends State<_PriorixShell> {
  int _index = 0;
  bool _didApplyDefaultView = false;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    final defaultViewIndex = context
        .watch<SettingsCubit>()
        .state
        .settings
        .defaultViewIndex;
    if (!_didApplyDefaultView) {
      _index = defaultViewIndex.clamp(0, 4);
      _didApplyDefaultView = true;
    }
    final isLightTheme = Theme.of(context).brightness == Brightness.light;
    final pages = [
      HomePage(onOpenMatrix: () => setState(() => _index = 1)),
      const MatrixPage(),
      const CalendarPage(),
      const InsightsPage(),
      const SettingsPage(),
    ];
    return Scaffold(
      body: Row(
        children: [
          if (isWide)
            NavigationRail(
              selectedIndex: _index,
              backgroundColor: AppColors.surface.withValues(alpha: 0.94),
              indicatorColor: AppColors.primaryGold.withValues(alpha: 0.16),
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: FloatingActionButton.small(
                  onPressed: () => openAddTask(context),
                  child: const Icon(Icons.add_rounded),
                ),
              ),
              onDestinationSelected: (value) => setState(() => _index = value),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home_rounded),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.grid_view_rounded),
                  label: Text('Matrix'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.calendar_month_rounded),
                  label: Text('Calendar'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.insights_rounded),
                  label: Text('Insights'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings_rounded),
                  label: Text('Settings'),
                ),
              ],
            ),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.2,
                  colors: isLightTheme
                      ? [
                          Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.14),
                          Theme.of(context).scaffoldBackgroundColor,
                        ]
                      : const [Color(0xFF10213D), AppColors.background],
                ),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: pages[_index],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: !isWide && _index <= 2
          ? FloatingActionButton(
              onPressed: () => openAddTask(context),
              child: const Icon(Icons.add_rounded),
            )
          : null,
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: _index,
              backgroundColor: AppColors.surface.withValues(alpha: 0.94),
              indicatorColor: AppColors.primaryGold.withValues(alpha: 0.16),
              onDestinationSelected: (value) => setState(() => _index = value),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.grid_view_rounded),
                  label: 'Matrix',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_month_rounded),
                  label: 'Calendar',
                ),
                NavigationDestination(
                  icon: Icon(Icons.insights_rounded),
                  label: 'Insights',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_rounded),
                  label: 'Settings',
                ),
              ],
            ),
    );
  }
}
