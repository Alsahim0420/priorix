import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../features/settings/domain/app_settings.dart';
import 'app_colors.dart';
import 'app_palette.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData build(AppThemePreset preset) {
    final p = PriorixPalette.forPreset(preset);
    final brightness = p.isLight ? Brightness.light : Brightness.dark;
    final scheme =
        ColorScheme.fromSeed(
          seedColor: p.accent,
          brightness: brightness,
        ).copyWith(
          primary: p.accent,
          onPrimary: p.onAccent,
          secondary: p.accent,
          onSecondary: p.onAccent,
          surface: p.surface,
          onSurface: p.textPrimary,
          onSurfaceVariant: p.textSecondary,
          surfaceContainerLowest: p.background,
          surfaceContainerLow: p.surface,
          surfaceContainer: p.surface,
          surfaceContainerHigh: p.surfaceHigh,
          surfaceContainerHighest: p.surfaceHigh,
          outline: p.hairline,
          outlineVariant: p.hairline,
          error: AppColors.danger,
        );
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
    );
    final radius28 = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(28),
    );
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: p.hairline),
    );

    return base.copyWith(
      scaffoldBackgroundColor: p.background,
      canvasColor: p.background,
      textTheme: _textTheme(base.textTheme, p),
      splashFactory: InkRipple.splashFactory,
      splashColor: p.textPrimary.withValues(alpha: 0.04),
      highlightColor: Colors.transparent,
      dividerTheme: DividerThemeData(color: p.hairline, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: p.textPrimary,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        modalBackgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: p.textTertiary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: radius28,
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: radius28,
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: p.surface,
        shape: radius28,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: p.textPrimary,
        contentTextStyle: TextStyle(
          color: p.background,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surfaceHigh,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        hintStyle: TextStyle(color: p.textTertiary),
        labelStyle: TextStyle(color: p.textSecondary),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: p.accent, width: 1.2),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? p.onAccent
              : p.textSecondary,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? p.accent : p.surfaceHigh,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: p.accent,
        inactiveTrackColor: p.surfaceHigh,
        thumbColor: p.accent,
        overlayColor: p.accent.withValues(alpha: 0.12),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: p.accent,
        selectionColor: p.accent.withValues(alpha: 0.3),
        selectionHandleColor: p.accent,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.accent,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      extensions: [p],
    );
  }

  static TextTheme _textTheme(TextTheme base, PriorixPalette p) {
    // Builds on the platform styles so the system font (SF / Roboto) and its
    // fallbacks are kept.
    TextStyle style(
      TextStyle? from,
      double size,
      FontWeight weight, {
      double spacing = 0,
      double? height,
      Color? color,
    }) {
      return (from ?? const TextStyle()).copyWith(
        fontSize: size,
        fontWeight: weight,
        letterSpacing: spacing,
        height: height,
        color: color ?? p.textPrimary,
      );
    }

    return base.copyWith(
      displayLarge: style(
        base.displayLarge,
        56,
        FontWeight.w300,
        spacing: -2,
        height: 1,
      ),
      displayMedium: style(
        base.displayMedium,
        40,
        FontWeight.w600,
        spacing: -1.4,
        height: 1.05,
      ),
      displaySmall: style(
        base.displaySmall,
        32,
        FontWeight.w600,
        spacing: -1,
        height: 1.1,
      ),
      headlineMedium: style(
        base.headlineMedium,
        30,
        FontWeight.w600,
        spacing: -0.9,
        height: 1.12,
      ),
      headlineSmall: style(
        base.headlineSmall,
        26,
        FontWeight.w600,
        spacing: -0.6,
        height: 1.18,
      ),
      titleLarge: style(
        base.titleLarge,
        20,
        FontWeight.w600,
        spacing: -0.4,
        height: 1.25,
      ),
      titleMedium: style(
        base.titleMedium,
        16,
        FontWeight.w600,
        spacing: -0.2,
        height: 1.3,
      ),
      titleSmall: style(
        base.titleSmall,
        14,
        FontWeight.w600,
        spacing: -0.1,
        height: 1.3,
      ),
      bodyLarge: style(base.bodyLarge, 16, FontWeight.w400, height: 1.45),
      bodyMedium: style(
        base.bodyMedium,
        14,
        FontWeight.w400,
        height: 1.45,
        color: p.textSecondary,
      ),
      bodySmall: style(
        base.bodySmall,
        12.5,
        FontWeight.w400,
        height: 1.4,
        color: p.textSecondary,
      ),
      labelLarge: style(base.labelLarge, 14, FontWeight.w600, spacing: 0.1),
      labelMedium: style(
        base.labelMedium,
        12,
        FontWeight.w600,
        spacing: 0.2,
        color: p.textSecondary,
      ),
      labelSmall: style(
        base.labelSmall,
        11,
        FontWeight.w600,
        spacing: 1.4,
        color: p.textTertiary,
      ),
    );
  }
}
