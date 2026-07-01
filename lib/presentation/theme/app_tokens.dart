/// Theme-independent design tokens: shapes, spacing and fixed sizes.
///
/// These stay the same across themes; only palette-based values change
/// per theme.
library;

import 'package:flutter/widgets.dart';

/// Corner radii.
abstract final class AppRadii {
  /// Fully rounded pill shape (buttons, chips, tabs, loader).
  static const double pill = 999;

  static const double card = 24;
  static const double input = 16;
  static const double toggleCard = 22;
  static const double cuteIcon = 14;
  static const double fab = 22;
  static const double tagDot = 11;
  static const double swatch = 18;
  static const double modal = 28;
  static const double splashCard = 34;
}

/// Gaps and paddings.
abstract final class AppSpacing {
  /// Gap between chips.
  static const double xs = 6;

  /// Gap between elements in a row.
  static const double sm = 10;

  /// Vertical gap between stacked cards.
  static const double md = 13;

  /// Gap below a form field.
  static const double fieldGap = 14;

  /// Screen edge padding.
  static const double lg = 16;

  /// Modal inner padding.
  static const double xl = 20;

  /// Extra bottom padding on scrollable screens so content clears the
  /// bottom navigation bar and the overhanging central button.
  static const double screenBottom = 94;
}

/// Common EdgeInsets presets.
abstract final class AppInsets {
  static const button = EdgeInsets.symmetric(vertical: 11, horizontal: 16);
  static const chip = EdgeInsets.symmetric(vertical: 7, horizontal: 10);
  static const input = EdgeInsets.symmetric(vertical: 12, horizontal: 13);
  static const card = EdgeInsets.all(15);
  static const modal = EdgeInsets.all(20);
  static const screen = EdgeInsets.fromLTRB(
    AppSpacing.lg,
    AppSpacing.lg,
    AppSpacing.lg,
    AppSpacing.screenBottom,
  );
}

/// Fixed component dimensions.
abstract final class AppSizes {
  /// Max content width; the layout is phone-shaped even on wide screens.
  static const double appMaxWidth = 430;

  static const double bottomNavHeight = 76;

  /// Central "+" button on the bottom navigation.
  static const double fabSize = 58;

  /// How far the central "+" button overhangs above the nav bar.
  static const double fabOverhang = 28;

  static const double switchWidth = 48;
  static const double switchHeight = 28;
  static const double switchKnob = 22;

  static const double cuteIcon = 34;
  static const double tagDot = 28;
  static const double colorSwatch = 52;

  static const double loaderWidth = 160;
  static const double loaderHeight = 9;
}

/// Misc visual effect values.
abstract final class AppEffects {
  /// Blur sigma behind the translucent bottom navigation bar.
  static const double navBlurSigma = 14;

  /// Opacity of the decorative background layer (bamboo, hearts).
  static const double bgDecorOpacity = 0.36;

  static const Duration switchAnimation = Duration(milliseconds: 200);
}
