import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/luxury_button.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.background,
              Color(0xFF0B1526),
              AppColors.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 760;
              final logoSize =
                  (isWide
                          ? constraints.maxHeight * 0.34
                          : constraints.maxWidth * 0.36)
                      .clamp(118.0, isWide ? 280.0 : 180.0);

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 40 : 24,
                  vertical: isWide ? 28 : 24,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - (isWide ? 56 : 48),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 980),
                      child: isWide
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _QuadrantLogo(size: logoSize),
                                const SizedBox(width: 52),
                                Flexible(
                                  child: _OnboardingContent(
                                    onStart: onStart,
                                    alignStart: true,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _QuadrantLogo(size: logoSize),
                                const SizedBox(height: 26),
                                _OnboardingContent(onStart: onStart),
                              ],
                            ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _OnboardingContent extends StatelessWidget {
  const _OnboardingContent({required this.onStart, this.alignStart = false});

  final VoidCallback onStart;
  final bool alignStart;

  @override
  Widget build(BuildContext context) {
    final textAlign = alignStart ? TextAlign.left : TextAlign.center;
    final crossAxisAlignment = alignStart
        ? CrossAxisAlignment.start
        : CrossAxisAlignment.center;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text('Priorix', style: AppTextStyles.display, textAlign: textAlign),
        const SizedBox(height: 8),
        Text(
          'Decide what matters first.',
          style: const TextStyle(
            color: AppColors.primaryGold,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
          textAlign: textAlign,
        ),
        const SizedBox(height: 22),
        GlassCard(
          child: Text(
            'A luxury productivity command center for separating signal from noise with the Eisenhower Matrix.',
            style: AppTextStyles.body,
            textAlign: textAlign,
          ),
        ),
        const SizedBox(height: 28),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LuxuryButton(
                label: 'Start prioritizing',
                icon: Icons.arrow_forward_rounded,
                onPressed: onStart,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: onStart,
                child: const Text('I already have an account'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuadrantLogo extends StatelessWidget {
  const _QuadrantLogo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    const colors = [
      AppColors.primaryGold,
      AppColors.emerald,
      AppColors.royalBlue,
      AppColors.goldDark,
    ];
    return GlassCard(
      padding: const EdgeInsets.all(14),
      borderColor: AppColors.primaryGold.withValues(alpha: 0.5),
      child: SizedBox(
        width: size,
        height: size,
        child: GridView.count(
          crossAxisCount: 2,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          children: List.generate(
            4,
            (index) => DecoratedBox(
              decoration: BoxDecoration(
                color: colors[index].withValues(alpha: 0.78),
                borderRadius: BorderRadius.circular(22),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
