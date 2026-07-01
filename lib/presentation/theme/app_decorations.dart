import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Gradients and shadows derived from an [AppColors] palette.
///
/// Everything here is computed from the palette, so a new theme gets its
/// decorations for free. Registered as a [ThemeExtension]; read it with
/// `Theme.of(context).extension<AppDecorations>()`.
class AppDecorations extends ThemeExtension<AppDecorations> {
  const AppDecorations({required this.colors});

  final AppColors colors;

  /// Diagonal accent→primary gradient for primary buttons and the central
  /// "+" navigation button. Material buttons cannot render gradients, so
  /// widgets needing this apply it via an [Ink]/[DecoratedBox].
  LinearGradient get primaryAction => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [colors.accent, colors.primary],
      );

  /// Horizontal variant used by the splash loading bar fill.
  LinearGradient get loaderFill => LinearGradient(
        colors: [colors.accent, colors.primary],
      );

  /// Vertical fade behind the top bar.
  LinearGradient get topBar => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [colors.hazeLilac, colors.background],
      );

  /// Soft vertical tint behind every screen.
  LinearGradient get screenBackdrop => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [colors.backdropTop, colors.backdropBottom],
      );

  /// Splash screen backdrop.
  LinearGradient get splashBackdrop => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [colors.background, colors.splashBackdropBottom],
      );

  /// Lilac glow fading out from the top-left corner, layered over
  /// [screenBackdrop].
  RadialGradient get hazeTopLeft => RadialGradient(
        center: Alignment.topLeft,
        radius: 1,
        colors: [colors.hazeLilac, colors.hazeLilac.withAlpha(0)],
        stops: const [0, 0.34],
      );

  /// Pink glow fading out from the top-right corner.
  RadialGradient get hazeTopRight => RadialGradient(
        center: Alignment.topRight,
        radius: 1,
        colors: [colors.hazePink, colors.hazePink.withAlpha(0)],
        stops: const [0, 0.30],
      );

  /// Large soft drop shadow under cards and toggles.
  List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: colors.shadowCard,
          offset: const Offset(0, 16),
          blurRadius: 40,
        ),
      ];

  /// Shadow under primary gradient buttons.
  List<BoxShadow> get buttonShadow => [
        BoxShadow(
          color: colors.shadowButton,
          offset: const Offset(0, 8),
          blurRadius: 18,
        ),
      ];

  /// Stronger shadow under the central "+" navigation button.
  List<BoxShadow> get fabShadow => [
        BoxShadow(
          color: colors.shadowFab,
          offset: const Offset(0, 14),
          blurRadius: 28,
        ),
      ];

  /// Shadow behind modals.
  List<BoxShadow> get modalShadow => [
        BoxShadow(
          color: colors.shadowModal,
          offset: const Offset(0, 22),
          blurRadius: 54,
        ),
      ];

  @override
  AppDecorations copyWith({AppColors? colors}) {
    return AppDecorations(colors: colors ?? this.colors);
  }

  @override
  AppDecorations lerp(ThemeExtension<AppDecorations>? other, double t) {
    if (other is! AppDecorations) return this;
    return AppDecorations(colors: colors.lerp(other.colors, t));
  }
}
