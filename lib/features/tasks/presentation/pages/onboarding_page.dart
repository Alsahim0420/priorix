import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/layout.dart';
import '../../../../core/widgets/p_button.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../../domain/entities/task.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..forward();
  final _name = TextEditingController();

  @override
  void dispose() {
    _intro.dispose();
    _name.dispose();
    super.dispose();
  }

  Widget _reveal(double start, Widget child) {
    final curve = CurvedAnimation(
      parent: _intro,
      curve: Interval(
        start,
        (start + 0.4).clamp(0, 1),
        curve: Curves.easeOutCubic,
      ),
    );
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(curve),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      body: PremiumBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _MatrixLogo(animation: _intro),
                        const SizedBox(height: 40),
                        _reveal(
                          0.25,
                          Text('Priorix', style: context.text.displayMedium),
                        ),
                        const SizedBox(height: 8),
                        _reveal(
                          0.3,
                          Text(
                            'Decide qué importa primero.',
                            style: context.text.titleMedium?.copyWith(
                              color: p.accent,
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),
                        _reveal(
                          0.4,
                          const _Feature(
                            icon: Icons.grid_view_rounded,
                            title: 'Matriz de Eisenhower',
                            text:
                                'Clasifica cada tarea por urgencia e importancia.',
                          ),
                        ),
                        _reveal(
                          0.48,
                          const _Feature(
                            icon: Icons.hourglass_bottom_rounded,
                            title: 'Alertas según el tiempo restante',
                            text:
                                'Te avisa cuando quede el 50 %, el 20 % o lo que tú elijas.',
                          ),
                        ),
                        _reveal(
                          0.56,
                          const _Feature(
                            icon: Icons.lock_outline_rounded,
                            title: 'Privado y local',
                            text: 'Tus datos nunca salen de este dispositivo.',
                          ),
                        ),
                        const SizedBox(height: 32),
                        _reveal(
                          0.62,
                          TextField(
                            controller: _name,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _start(),
                            decoration: const InputDecoration(
                              hintText: '¿Cómo te llamas? (opcional)',
                              prefixIcon: Icon(Icons.person_outline_rounded),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _reveal(
                          0.66,
                          PButton(
                            label: 'Comenzar',
                            icon: Icons.arrow_forward_rounded,
                            onPressed: _start,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _start() {
    context.read<SettingsCubit>().completeOnboarding(name: _name.text);
  }
}

class _Feature extends StatelessWidget {
  const _Feature({required this.icon, required this.title, required this.text});

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: p.hairline),
            ),
            child: Icon(icon, size: 19, color: p.accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.text.titleSmall),
                const SizedBox(height: 2),
                Text(text, style: context.text.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MatrixLogo extends StatelessWidget {
  const _MatrixLogo({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    const size = 84.0;
    const gap = 6.0;
    const cell = (size - gap) / 2;
    return SizedBox.square(
      dimension: size,
      child: Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final quadrant in TaskQuadrant.values)
            ScaleTransition(
              scale: CurvedAnimation(
                parent: animation,
                curve: Interval(
                  quadrant.index * 0.07,
                  0.35 + quadrant.index * 0.07,
                  curve: Curves.easeOutBack,
                ),
              ),
              child: Container(
                width: cell,
                height: cell,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      quadrant.color,
                      quadrant.color.withValues(alpha: 0.6),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
