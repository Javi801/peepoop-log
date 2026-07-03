import 'package:flutter/material.dart';

/// Semantic color palette for one visual theme.
///
/// The values of [pastel] mirror the design reference in `docs/base-app.html`,
/// which remains the source of truth while the UI is ported to Flutter.
///
/// Registered as a [ThemeExtension] so widgets can read it with
/// `Theme.of(context).extension<AppColors>()`. Adding a new theme only
/// requires a new const instance (or `copyWith` on an existing one) passed
/// to `AppTheme.fromColors`; gradients, shadows and component themes are
/// derived from it automatically.
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.surfaceSoft,
    required this.surfaceCard,
    required this.surfaceNav,
    required this.surfaceSplash,
    required this.primary,
    required this.primaryDark,
    required this.primarySoft,
    required this.onPrimary,
    required this.accent,
    required this.accentSoft,
    required this.textPrimary,
    required this.textMuted,
    required this.border,
    required this.swatchBorder,
    required this.danger,
    required this.dangerSoft,
    required this.scrim,
    required this.switchTrackOff,
    required this.loaderTrack,
    required this.hazeLilac,
    required this.hazePink,
    required this.backdropTop,
    required this.backdropBottom,
    required this.splashBackdropBottom,
    required this.decorHearts,
    required this.shadowCard,
    required this.shadowButton,
    required this.shadowFab,
    required this.shadowModal,
    required this.tagFallback,
    required this.cuteIconBackground,
  });

  final Brightness brightness;

  /// Scaffold background.
  final Color background;

  /// Base surface for modals, inputs and opaque panels.
  final Color surface;

  /// Slightly tinted surface variant.
  final Color surfaceSoft;

  /// Translucent white for cards laid over the decorated background.
  final Color surfaceCard;

  /// Translucent white for the blurred bottom navigation bar.
  final Color surfaceNav;

  /// Translucent white for the splash screen card.
  final Color surfaceSplash;

  final Color primary;
  final Color primaryDark;
  final Color primarySoft;
  final Color onPrimary;

  /// Pink brand accent, paired with [primary] in gradients.
  final Color accent;
  final Color accentSoft;

  final Color textPrimary;
  final Color textMuted;

  /// Hairline borders on cards, inputs and the nav bar.
  final Color border;

  /// Faint border drawn around tag dots and color swatches so light tag
  /// colors stay visible on light surfaces.
  final Color swatchBorder;

  final Color danger;

  /// Background of destructive (soft) buttons.
  final Color dangerSoft;

  /// Modal barrier color.
  final Color scrim;

  final Color switchTrackOff;
  final Color loaderTrack;

  /// Lilac haze used in the top-left backdrop glow and the top bar gradient.
  final Color hazeLilac;

  /// Pink haze used in the top-right backdrop glow.
  final Color hazePink;

  /// Vertical app backdrop gradient endpoints.
  final Color backdropTop;
  final Color backdropBottom;

  /// Bottom stop of the splash screen gradient (top stop is [background]).
  final Color splashBackdropBottom;

  /// Decorative floating hearts.
  final Color decorHearts;

  final Color shadowCard;
  final Color shadowButton;
  final Color shadowFab;
  final Color shadowModal;

  /// Fallback when a tag has no valid color stored. The palette offered when
  /// creating tags is [tagPalette].
  final Color tagFallback;

  /// Background of the small rounded emoji icons next to toggles.
  final Color cuteIconBackground;

  /// Palette offered when creating tags, as hex strings because tag colors
  /// are persisted on the tag itself and do not follow the theme.
  static const tagPalette = [
    '#FFE8A3',
    '#CFEEFF',
    '#D9F2C7',
    '#FFD3D3',
    '#EADBFF',
    '#FFE4EC',
  ];

  /// Default pastel theme.
  static const pastel = AppColors(
    brightness: Brightness.light,
    background: Color(0xFFFFF7FB),
    surface: Color(0xFFFFFEFE),
    surfaceSoft: Color(0xFFFFF7FB),
    surfaceCard: Color(0xEBFFFFFF),
    surfaceNav: Color(0xE0FFFFFF),
    surfaceSplash: Color(0xADFFFFFF),
    primary: Color(0xFF9B7BE8),
    primaryDark: Color(0xFF7D5BD6),
    primarySoft: Color(0xFFEEE6FF),
    onPrimary: Colors.white,
    accent: Color(0xFFFF8FA3),
    accentSoft: Color(0xFFFFE4EC),
    textPrimary: Color(0xFF44333A),
    textMuted: Color(0xFF8B7B82),
    border: Color(0xFFF0DFE7),
    swatchBorder: Color(0x1F44333A),
    danger: Color(0xFFE75B64),
    dangerSoft: Color(0xFFFFE1E3),
    scrim: Color(0x7A40353D),
    switchTrackOff: Color(0xFFE5DBE8),
    loaderTrack: Color(0xFFEADFF5),
    hazeLilac: Color(0xFFF1E7FF),
    hazePink: Color(0xFFFFE5EF),
    backdropTop: Color(0xFFFFFAFD),
    backdropBottom: Color(0xFFFFF5FB),
    splashBackdropBottom: Color(0xFFF5EFFF),
    decorHearts: Color(0xFFFF9FB1),
    shadowCard: Color(0x298D6EA5),
    shadowButton: Color(0x339B7BE8),
    shadowFab: Color(0x599B7BE8),
    shadowModal: Color(0x3D000000),
    tagFallback: Color(0xFFFFE8A3),
    cuteIconBackground: Color(0xFFFFE8A3),
  );

  @override
  AppColors copyWith({
    Brightness? brightness,
    Color? background,
    Color? surface,
    Color? surfaceSoft,
    Color? surfaceCard,
    Color? surfaceNav,
    Color? surfaceSplash,
    Color? primary,
    Color? primaryDark,
    Color? primarySoft,
    Color? onPrimary,
    Color? accent,
    Color? accentSoft,
    Color? textPrimary,
    Color? textMuted,
    Color? border,
    Color? swatchBorder,
    Color? danger,
    Color? dangerSoft,
    Color? scrim,
    Color? switchTrackOff,
    Color? loaderTrack,
    Color? hazeLilac,
    Color? hazePink,
    Color? backdropTop,
    Color? backdropBottom,
    Color? splashBackdropBottom,
    Color? decorHearts,
    Color? shadowCard,
    Color? shadowButton,
    Color? shadowFab,
    Color? shadowModal,
    Color? tagFallback,
    Color? cuteIconBackground,
  }) {
    return AppColors(
      brightness: brightness ?? this.brightness,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceSoft: surfaceSoft ?? this.surfaceSoft,
      surfaceCard: surfaceCard ?? this.surfaceCard,
      surfaceNav: surfaceNav ?? this.surfaceNav,
      surfaceSplash: surfaceSplash ?? this.surfaceSplash,
      primary: primary ?? this.primary,
      primaryDark: primaryDark ?? this.primaryDark,
      primarySoft: primarySoft ?? this.primarySoft,
      onPrimary: onPrimary ?? this.onPrimary,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      textPrimary: textPrimary ?? this.textPrimary,
      textMuted: textMuted ?? this.textMuted,
      border: border ?? this.border,
      swatchBorder: swatchBorder ?? this.swatchBorder,
      danger: danger ?? this.danger,
      dangerSoft: dangerSoft ?? this.dangerSoft,
      scrim: scrim ?? this.scrim,
      switchTrackOff: switchTrackOff ?? this.switchTrackOff,
      loaderTrack: loaderTrack ?? this.loaderTrack,
      hazeLilac: hazeLilac ?? this.hazeLilac,
      hazePink: hazePink ?? this.hazePink,
      backdropTop: backdropTop ?? this.backdropTop,
      backdropBottom: backdropBottom ?? this.backdropBottom,
      splashBackdropBottom: splashBackdropBottom ?? this.splashBackdropBottom,
      decorHearts: decorHearts ?? this.decorHearts,
      shadowCard: shadowCard ?? this.shadowCard,
      shadowButton: shadowButton ?? this.shadowButton,
      shadowFab: shadowFab ?? this.shadowFab,
      shadowModal: shadowModal ?? this.shadowModal,
      tagFallback: tagFallback ?? this.tagFallback,
      cuteIconBackground: cuteIconBackground ?? this.cuteIconBackground,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      brightness: t < 0.5 ? brightness : other.brightness,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceSoft: Color.lerp(surfaceSoft, other.surfaceSoft, t)!,
      surfaceCard: Color.lerp(surfaceCard, other.surfaceCard, t)!,
      surfaceNav: Color.lerp(surfaceNav, other.surfaceNav, t)!,
      surfaceSplash: Color.lerp(surfaceSplash, other.surfaceSplash, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      swatchBorder: Color.lerp(swatchBorder, other.swatchBorder, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerSoft: Color.lerp(dangerSoft, other.dangerSoft, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      switchTrackOff: Color.lerp(switchTrackOff, other.switchTrackOff, t)!,
      loaderTrack: Color.lerp(loaderTrack, other.loaderTrack, t)!,
      hazeLilac: Color.lerp(hazeLilac, other.hazeLilac, t)!,
      hazePink: Color.lerp(hazePink, other.hazePink, t)!,
      backdropTop: Color.lerp(backdropTop, other.backdropTop, t)!,
      backdropBottom: Color.lerp(backdropBottom, other.backdropBottom, t)!,
      splashBackdropBottom: Color.lerp(
        splashBackdropBottom,
        other.splashBackdropBottom,
        t,
      )!,
      decorHearts: Color.lerp(decorHearts, other.decorHearts, t)!,
      shadowCard: Color.lerp(shadowCard, other.shadowCard, t)!,
      shadowButton: Color.lerp(shadowButton, other.shadowButton, t)!,
      shadowFab: Color.lerp(shadowFab, other.shadowFab, t)!,
      shadowModal: Color.lerp(shadowModal, other.shadowModal, t)!,
      tagFallback: Color.lerp(tagFallback, other.tagFallback, t)!,
      cuteIconBackground: Color.lerp(
        cuteIconBackground,
        other.cuteIconBackground,
        t,
      )!,
    );
  }
}
