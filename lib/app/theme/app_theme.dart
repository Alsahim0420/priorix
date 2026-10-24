import 'package:flutter/material.dart';
import '../../features/settings/domain/app_settings.dart';
import 'app_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData dark({AppThemePreset preset = AppThemePreset.midnight}) {
    final isLight = preset.isLight;
    final primary = switch (preset) {
      AppThemePreset.midnight => AppColors.primaryGold,
      AppThemePreset.graphite => const Color(0xFFE5E7EB),
      AppThemePreset.emeraldNoir => AppColors.emerald,
      AppThemePreset.amethyst => const Color(0xFFA78BFA),
      AppThemePreset.champagneLight => AppColors.goldDark,
      AppThemePreset.porcelainLight => AppColors.royalBlue,
      AppThemePreset.mintLight => const Color(0xFF0F766E),
    };
    final scaffold = switch (preset) {
      AppThemePreset.champagneLight => const Color(0xFFFAF7EF),
      AppThemePreset.porcelainLight => const Color(0xFFF8FAFC),
      AppThemePreset.mintLight => const Color(0xFFF0FDFA),
      _ => AppColors.background,
    };
    final surface = isLight ? Colors.white : AppColors.surface;
    final textPrimary = isLight
        ? const Color(0xFF0F172A)
        : AppColors.textPrimary;
    final textSecondary = isLight
        ? const Color(0xFF475569)
        : AppColors.textSecondary;

    final inputFill = isLight
        ? Colors.white.withValues(alpha: 0.88)
        : AppColors.surface.withValues(alpha: 0.72);
    final borderColor = isLight ? const Color(0xFFE2E8F0) : AppColors.border;

    final navBg = isLight
        ? Colors.white.withValues(alpha: 0.96)
        : AppColors.surface.withValues(alpha: 0.94);

    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: isLight ? Brightness.light : Brightness.dark,
      primary: primary,
      secondary: AppColors.emerald,
      surface: surface,
      error: AppColors.danger,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: isLight ? Brightness.light : Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffold,
      fontFamily: 'SF Pro Display',
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: textPrimary,
      ),
      textTheme: ThemeData(
        brightness: isLight ? Brightness.light : Brightness.dark,
      ).textTheme.apply(bodyColor: textPrimary, displayColor: textPrimary),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        labelStyle: TextStyle(color: textSecondary),
        hintStyle: TextStyle(color: textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: primary, width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        foregroundColor: AppColors.background,
        elevation: 8,
      ).copyWith(backgroundColor: primary),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: navBg,
        indicatorColor: primary.withValues(alpha: 0.16),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: navBg,
        indicatorColor: primary.withValues(alpha: 0.16),
        selectedIconTheme: IconThemeData(color: primary),
        selectedLabelTextStyle: TextStyle(color: primary),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: navBg,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
      ),
    );

    return base.copyWith(
      extensions: [_PriorixThemeTokens(scaffold: scaffold, primary: primary)],
    );
  }
}

class _PriorixThemeTokens extends ThemeExtension<_PriorixThemeTokens> {
  const _PriorixThemeTokens({required this.scaffold, required this.primary});

  final Color scaffold;
  final Color primary;

  @override
  _PriorixThemeTokens copyWith({Color? scaffold, Color? primary}) {
    return _PriorixThemeTokens(
      scaffold: scaffold ?? this.scaffold,
      primary: primary ?? this.primary,
    );
  }

  @override
  _PriorixThemeTokens lerp(
    covariant ThemeExtension<_PriorixThemeTokens>? other,
    double t,
  ) {
    if (other is! _PriorixThemeTokens) return this;
    return _PriorixThemeTokens(
      scaffold: Color.lerp(scaffold, other.scaffold, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
    );
  }
}
