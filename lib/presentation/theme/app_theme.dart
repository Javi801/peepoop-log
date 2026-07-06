import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_decorations.dart';
import 'app_tokens.dart';
import 'app_typography.dart';

/// Assembles a [ThemeData] from an [AppColors] palette.
///
/// Component styling that Material widgets support natively lives here;
/// what they cannot express (gradients, layered shadows) is exposed through
/// the [AppColors] and [AppDecorations] theme extensions.
abstract final class AppTheme {
  /// Default app theme.
  static ThemeData light() => fromColors(AppColors.pastel);

  static ThemeData fromColors(AppColors colors) {
    final textTheme = AppTypography.textTheme(colors);

    final colorScheme = ColorScheme(
      brightness: colors.brightness,
      primary: colors.primary,
      onPrimary: colors.onPrimary,
      primaryContainer: colors.primarySoft,
      onPrimaryContainer: colors.primaryDark,
      secondary: colors.accent,
      onSecondary: colors.onPrimary,
      secondaryContainer: colors.accentSoft,
      onSecondaryContainer: colors.textPrimary,
      error: colors.danger,
      onError: colors.onPrimary,
      errorContainer: colors.dangerSoft,
      onErrorContainer: colors.danger,
      surface: colors.surface,
      onSurface: colors.textPrimary,
      surfaceContainerHighest: colors.surfaceSoft,
      onSurfaceVariant: colors.textMuted,
      outline: colors.border,
      outlineVariant: colors.swatchBorder,
      shadow: colors.shadowCard,
      scrim: colors.scrim,
    );

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.background,
      textTheme: textTheme,
      extensions: [
        colors,
        AppDecorations(colors: colors),
      ],
      appBarTheme: AppBarThemeData(
        // Solid fallback; the full fade is AppDecorations.topBar.
        backgroundColor: colors.hazeLilac,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: AppSizes.appBarHeight,
        titleSpacing: AppSpacing.appBarTitle,
        titleTextStyle: textTheme.titleLarge,
        shape: Border(bottom: BorderSide(color: colors.border)),
      ),
      cardTheme: CardThemeData(
        // The soft drop shadow is AppDecorations.cardShadow; Material
        // elevation cannot reproduce it.
        color: colors.surfaceCard,
        elevation: 0,
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
          side: BorderSide(color: colors.border),
        ),
      ),
      chipTheme: ChipThemeData(
        // backgroundColor is a fallback: tag chips set their own stored color.
        backgroundColor: colors.tagFallback,
        shape: const StadiumBorder(),
        side: BorderSide.none,
        padding: AppInsets.chip,
        labelStyle: AppTypography.chipLabel.copyWith(color: colors.textPrimary),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: colors.surface,
        contentPadding: AppInsets.input,
        hintStyle: AppTypography.body.copyWith(color: colors.textMuted),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.input),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.input),
          borderSide: BorderSide(color: colors.primary),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.input),
          borderSide: BorderSide(color: colors.border),
        ),
      ),
      // Primary buttons: flat primary fill as fallback; the accent→primary
      // gradient version uses AppDecorations.primaryAction. Secondary pill
      // buttons use primaryContainer/onPrimaryContainer from the scheme.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          padding: AppInsets.button,
          shape: const StadiumBorder(),
          textStyle: AppTypography.buttonLabel,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: colors.surface,
          foregroundColor: colors.textPrimary,
          side: BorderSide(color: colors.border),
          padding: AppInsets.button,
          shape: const StadiumBorder(),
          textStyle: AppTypography.buttonLabel,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primaryDark,
          padding: AppInsets.button,
          shape: const StadiumBorder(),
          textStyle: AppTypography.buttonLabel,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStatePropertyAll(colors.surface),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.primary
              : colors.switchTrackOff,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: AppSizes.bottomNavHeight,
        backgroundColor: colors.surfaceNav,
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppTypography.navLabel.copyWith(
                  color: colors.primaryDark,
                  fontWeight: AppTypography.bold,
                )
              : AppTypography.navLabel.copyWith(color: colors.textMuted),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 18,
            color: states.contains(WidgetState.selected)
                ? colors.primaryDark
                : colors.textMuted,
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        barrierColor: colors.scrim,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.modal),
        ),
        titleTextStyle: textTheme.headlineSmall,
        contentTextStyle: textTheme.bodySmall,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        modalBarrierColor: colors.scrim,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadii.modal),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(color: colors.border, thickness: 1),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.primary,
        linearTrackColor: colors.loaderTrack,
        linearMinHeight: AppSizes.loaderHeight,
      ),
    );
  }
}
