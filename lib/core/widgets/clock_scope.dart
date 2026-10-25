import 'dart:async';
import 'package:flutter/widgets.dart';

/// Shares a "now" that ticks every minute so countdowns and relative labels
/// stay fresh without each widget running its own timer.
class ClockScope extends StatefulWidget {
  const ClockScope({super.key, required this.child});

  final Widget child;

  static DateTime now(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ClockInherited>()?.now ??
      DateTime.now();

  @override
  State<ClockScope> createState() => _ClockScopeState();
}

class _ClockScopeState extends State<ClockScope> with WidgetsBindingObserver {
  DateTime _now = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _schedule();
  }

  void _schedule() {
    _timer?.cancel();
    final now = DateTime.now();
    final nextMinute = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute + 1,
    );
    _timer = Timer(nextMinute.difference(now), () {
      _tick();
      _schedule();
    });
  }

  void _tick() {
    if (mounted) setState(() => _now = DateTime.now());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _tick();
      _schedule();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _ClockInherited(now: _now, child: widget.child);
}

class _ClockInherited extends InheritedWidget {
  const _ClockInherited({required this.now, required super.child});

  final DateTime now;

  @override
  bool updateShouldNotify(_ClockInherited oldWidget) => oldWidget.now != now;
}
