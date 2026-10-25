import 'package:flutter/material.dart';
import '../../features/settings/domain/app_settings.dart';

@immutable
class PriorixPalette extends ThemeExtension<PriorixPalette> {
  const PriorixPalette({
    required this.background,
    required this.surface,
    required this.surfaceHigh,
    required this.hairline,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.accent,
    required this.onAccent,
    required this.isLight,
  });

  final Color background;
  final Color surface;
  final Color surfaceHigh;
  final Color hairline;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color accent;
  final Color onAccent;
  final bool isLight;

  Color get glow => accent.withValues(alpha: isLight ? 0.10 : 0.12);

  factory PriorixPalette.forPreset(AppThemePreset preset) {
    return switch (preset) {
      AppThemePreset.midnight => _dark(
        background: const Color(0xFF08090E),
        surface: const Color(0xFF12141B),
        surfaceHigh: const Color(0xFF1A1D26),
        accent: const Color(0xFFD8B677),
        onAccent: const Color(0xFF1A1407),
      ),
      AppThemePreset.graphite => _dark(
        background: const Color(0xFF0B0B0C),
        surface: const Color(0xFF161618),
        surfaceHigh: const Color(0xFF202023),
        accent: const Color(0xFFDADAE0),
        onAccent: const Color(0xFF111113),
      ),
      AppThemePreset.emeraldNoir => _dark(
        background: const Color(0xFF070B0A),
        surface: const Color(0xFF111715),
        surfaceHigh: const Color(0xFF19211E),
        accent: const Color(0xFF6FD3A9),
        onAccent: const Color(0xFF04140D),
      ),
      AppThemePreset.amethyst => _dark(
        background: const Color(0xFF0A0910),
        surface: const Color(0xFF14121C),
        surfaceHigh: const Color(0xFF1D1A28),
        accent: const Color(0xFFB9A4F7),
        onAccent: const Color(0xFF140C2B),
      ),
      AppThemePreset.champagneLight => _light(
        background: const Color(0xFFF7F4EE),
        surfaceHigh: const Color(0xFFEFEAE1),
        accent: const Color(0xFF9C7631),
      ),
      AppThemePreset.porcelainLight => _light(
        background: const Color(0xFFF5F6F8),
        surfaceHigh: const Color(0xFFECEEF2),
        accent: const Color(0xFF3F51C9),
      ),
      AppThemePreset.mintLight => _light(
        background: const Color(0xFFF2F7F5),
        surfaceHigh: const Color(0xFFE5EFEB),
        accent: const Color(0xFF1F8A70),
      ),
    };
  }

  static PriorixPalette _dark({
    required Color background,
    required Color surface,
    required Color surfaceHigh,
    required Color accent,
    required Color onAccent,
  }) {
    return PriorixPalette(
      background: background,
      surface: surface,
      surfaceHigh: surfaceHigh,
      hairline: const Color(0x14FFFFFF),
      textPrimary: const Color(0xFFF4F1EA),
      textSecondary: const Color(0xFFA09DA8),
      textTertiary: const Color(0xFF67646F),
      accent: accent,
      onAccent: onAccent,
      isLight: false,
    );
  }

  static PriorixPalette _light({
    required Color background,
    required Color surfaceHigh,
    required Color accent,
  }) {
    return PriorixPalette(
      background: background,
      surface: Colors.white,
      surfaceHigh: surfaceHigh,
      hairline: const Color(0x14000000),
      textPrimary: const Color(0xFF17151A),
      textSecondary: const Color(0xFF67636D),
      textTertiary: const Color(0xFFA39FA8),
      accent: accent,
      onAccent: Colors.white,
      isLight: true,
    );
  }

  @override
  PriorixPalette copyWith({
    Color? background,
    Color? surface,
    Color? surfaceHigh,
    Color? hairline,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? accent,
    Color? onAccent,
    bool? isLight,
  }) {
    return PriorixPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceHigh: surfaceHigh ?? this.surfaceHigh,
      hairline: hairline ?? this.hairline,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      isLight: isLight ?? this.isLight,
    );
  }

  @override
  PriorixPalette lerp(
    covariant ThemeExtension<PriorixPalette>? other,
    double t,
  ) {
    if (other is! PriorixPalette) return this;
    return PriorixPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceHigh: Color.lerp(surfaceHigh, other.surfaceHigh, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      isLight: t < 0.5 ? isLight : other.isLight,
    );
  }
}

extension PaletteContext on BuildContext {
  PriorixPalette get palette => Theme.of(this).extension<PriorixPalette>()!;
  TextTheme get text => Theme.of(this).textTheme;
}
