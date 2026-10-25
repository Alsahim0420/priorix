import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/widgets/layout.dart';
import '../core/widgets/pressable.dart';
import '../features/settings/domain/app_settings.dart';
import '../features/settings/presentation/cubit/settings_cubit.dart';
import '../features/tasks/presentation/pages/agenda_page.dart';
import '../features/tasks/presentation/pages/home_page.dart';
import '../features/tasks/presentation/pages/matrix_page.dart';
import '../features/tasks/presentation/pages/settings_page.dart';
import '../features/tasks/presentation/task_actions.dart';
import 'theme/app_palette.dart';

class PriorixShell extends StatefulWidget {
  const PriorixShell({super.key});

  @override
  State<PriorixShell> createState() => _PriorixShellState();
}

class _PriorixShellState extends State<PriorixShell> {
  late int _index = context
      .read<SettingsCubit>()
      .state
      .settings
      .defaultViewIndex
      .clamp(0, AppSettings.viewLabels.length - 1);

  void _go(int index) {
    if (index == _index) return;
    HapticFeedback.selectionClick();
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final page = switch (_index) {
      0 => HomePage(onNavigate: _go),
      1 => const MatrixPage(),
      2 => const AgendaPage(),
      _ => const SettingsPage(),
    };
    return Scaffold(
      extendBody: true,
      body: PremiumBackground(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0, 0.012),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: KeyedSubtree(key: ValueKey(_index), child: page),
        ),
      ),
      bottomNavigationBar: _FloatingNav(
        index: _index,
        onSelect: _go,
        onAdd: () {
          HapticFeedback.lightImpact();
          openTaskEditor(context);
        },
      ),
    );
  }
}

class _FloatingNav extends StatelessWidget {
  const _FloatingNav({
    required this.index,
    required this.onSelect,
    required this.onAdd,
  });

  final int index;
  final ValueChanged<int> onSelect;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    Widget item(int i, IconData icon, IconData activeIcon, String label) {
      return Expanded(
        child: _NavItem(
          icon: icon,
          activeIcon: activeIcon,
          label: label,
          selected: index == i,
          onTap: () => onSelect(i),
        ),
      );
    }

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 12),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: p.surface.withValues(alpha: p.isLight ? 0.86 : 0.78),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: p.hairline),
                  ),
                  child: Row(
                    children: [
                      item(
                        0,
                        Icons.home_outlined,
                        Icons.home_rounded,
                        'Inicio',
                      ),
                      item(
                        1,
                        Icons.grid_view_outlined,
                        Icons.grid_view_rounded,
                        'Matriz',
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: _AddButton(onTap: onAdd),
                      ),
                      item(
                        2,
                        Icons.calendar_today_outlined,
                        Icons.calendar_today_rounded,
                        'Agenda',
                      ),
                      item(
                        3,
                        Icons.tune_outlined,
                        Icons.tune_rounded,
                        'Ajustes',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = selected ? p.textPrimary : p.textTertiary;
    return Semantics(
      selected: selected,
      button: true,
      label: label,
      child: Pressable(
        onTap: onTap,
        scale: 0.9,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                selected ? activeIcon : icon,
                key: ValueKey(selected),
                size: 22,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.fade,
              style: TextStyle(
                color: color,
                fontSize: 10.5,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: selected ? 14 : 0,
              height: 2,
              decoration: BoxDecoration(
                color: p.accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      button: true,
      label: 'Nueva tarea',
      child: Pressable(
        onTap: onTap,
        scale: 0.9,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(p.accent, Colors.white, 0.15)!,
                Color.lerp(p.accent, Colors.black, 0.12)!,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: p.accent.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(Icons.add_rounded, color: p.onAccent, size: 26),
        ),
      ),
    );
  }
}
