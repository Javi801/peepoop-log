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
  static const double colorPicker = 14;
  static const double modal = 28;
  static const double splashCard = 34;
}

/// Gaps and paddings.
abstract final class AppSpacing {
  /// Tightest gap between stacked lines (nav icon→label, time→date).
  static const double xxs = 2;

  /// Gap between chips.
  static const double xs = 6;

  /// Gap between a field label and its control.
  static const double labelGap = 7;

  /// Gap between segmented tab buttons.
  static const double tabGap = 8;

  /// Gap between elements in a row.
  static const double sm = 10;

  /// Gap between a fixed leading element (time column, color swatch) and
  /// the flexible content next to it.
  static const double rowGap = 12;

  /// Vertical gap between stacked cards.
  static const double md = 13;

  /// Gap below a form field.
  static const double fieldGap = 14;

  /// Screen edge padding.
  static const double lg = 16;

  /// Leading inset before the app bar title; larger than the screen edge
  /// so the title sits slightly further right.
  static const double appBarTitle = 24;

  /// Modal inner padding.
  static const double xl = 20;

  /// Splash: gap between the subtitle and the hero emoji.
  static const double splashEmojiGap = 42;

  /// Splash: gap between the hero emoji and the loading bar.
  static const double splashLoaderGap = 26;

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

  /// Segmented tab button (Pee/Poop).
  static const tab = EdgeInsets.symmetric(vertical: 10);

  /// Section heading between groups of cards.
  static const sectionTitle = EdgeInsets.only(top: 18, bottom: 10);

  /// Centered empty-list message.
  static const emptyState = EdgeInsets.symmetric(vertical: 40, horizontal: 16);

  /// Hero card on the export screen.
  static const exportHero = EdgeInsets.symmetric(vertical: 30, horizontal: 12);

  /// Outer margin detaching floating modals from the screen edges.
  static const modalMargin = EdgeInsets.all(14);

  /// Space under a modal title.
  static const modalTitle = EdgeInsets.only(bottom: 8);

  /// Space above the modal action button row.
  static const modalActions = EdgeInsets.only(top: 18);

  /// Space under the hero emoji in confirmation dialogs.
  static const dialogEmoji = EdgeInsets.only(bottom: 8);
}

/// Fixed component dimensions.
abstract final class AppSizes {
  /// Max content width; the layout is phone-shaped even on wide screens.
  static const double appMaxWidth = 430;

  static const double bottomNavHeight = 76;

  /// Top app bar height; taller than the Material default so the title
  /// has vertical breathing room.
  static const double appBarHeight = 72;

  /// Central "+" button on the bottom navigation.
  static const double fabSize = 58;

  /// How far the central "+" button overhangs above the nav bar.
  static const double fabOverhang = 28;

  /// Center slot in the nav bar reserved for the overhanging "+" button.
  static const double navPlusSlot = 76;

  /// Width of the time column in history cards.
  static const double historyTimeColumn = 58;

  /// Max height of the expanded tag dropdown in the history filter sheet;
  /// keeps about two tags visible and scrolls the rest.
  static const double filterTagPanelMaxHeight = 132;

  /// Tappable palette swatch in the tag color picker.
  static const double paletteSwatch = 36;

  static const double switchWidth = 48;
  static const double switchHeight = 28;
  static const double switchKnob = 22;

  static const double cuteIcon = 34;
  static const double tagDot = 28;
  static const double colorSwatch = 36;

  /// Height of the saturation/value plane in the color picker dialog; its
  /// width flexes to fill the dialog.
  static const double colorPickerAreaHeight = 176;

  /// Vertical rainbow hue bar next to the saturation/value plane.
  static const double hueSliderWidth = 26;

  /// Draggable circle handles inside the color picker.
  static const double colorPickerHandle = 20;

  static const double loaderWidth = 160;
  static const double loaderHeight = 9;
}

/// Misc visual effect values.
abstract final class AppEffects {
  /// Blur sigma behind the translucent bottom navigation bar.
  static const double navBlurSigma = 14;

  /// Opacity of the decorative background layer (bamboo, hearts).
  static const double bgDecorOpacity = 0.36;

  /// Opacity of disabled primary buttons.
  static const double disabledOpacity = 0.55;

  /// Static fill fraction of the splash loading bar.
  static const double splashLoaderValue = 0.68;

  /// Maximum modal height as a fraction of the screen height.
  static const double modalMaxHeightFraction = 0.84;

  static const Duration switchAnimation = Duration(milliseconds: 200);
}
