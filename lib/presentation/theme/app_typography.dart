import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Text style tokens and the [TextTheme] derived from a palette.
///
/// The app uses the platform system font with unusually heavy weights,
/// so weights are named tokens instead of inline values.
abstract final class AppTypography {
  static const FontWeight bold = FontWeight.w800;
  static const FontWeight heavy = FontWeight.w900;

  /// Top bar screen title.
  static const TextStyle screenTitle = TextStyle(
    fontSize: 19,
    fontWeight: bold,
    letterSpacing: -0.38,
  );

  /// Modal / dialog title.
  static const TextStyle modalTitle = TextStyle(fontSize: 20, fontWeight: bold);

  /// Splash screen brand title.
  static const TextStyle splashTitle = TextStyle(
    fontSize: 32,
    fontWeight: bold,
    letterSpacing: -0.64,
    height: 1.15,
  );

  /// Small uppercase-feeling label above form fields.
  static const TextStyle fieldLabel = TextStyle(fontSize: 12, fontWeight: bold);

  static const TextStyle body = TextStyle(fontSize: 16);

  /// Emphasized [body] variant for card titles and row labels.
  static const TextStyle bodyBold = TextStyle(fontSize: 16, fontWeight: bold);

  /// Secondary/muted paragraph text.
  static const TextStyle secondary = TextStyle(fontSize: 13, height: 1.4);

  static const TextStyle buttonLabel = TextStyle(
    fontSize: 16,
    fontWeight: bold,
  );

  static const TextStyle chipLabel = TextStyle(fontSize: 12, fontWeight: bold);

  static const TextStyle navLabel = TextStyle(fontSize: 11);

  /// Emoji glyphs in nav items and the cute icon squares.
  static const TextStyle emojiIcon = TextStyle(fontSize: 18);

  /// "+" glyph on the central navigation button.
  static const TextStyle navPlus = TextStyle(
    fontSize: 34,
    fontWeight: heavy,
    height: 1,
  );

  /// Time column in history cards.
  static const TextStyle timeLabel = TextStyle(fontSize: 13, fontWeight: heavy);

  /// Short date under the time in history cards; merged over `bodySmall`.
  static const TextStyle dateLabel = TextStyle(fontSize: 11);

  /// Hero emoji illustrations, sized per screen like the design reference.
  static const TextStyle splashEmoji = TextStyle(fontSize: 94);
  static const TextStyle exportEmoji = TextStyle(fontSize: 90);
  static const TextStyle dialogEmoji = TextStyle(fontSize: 84);

  /// Section headers between groups of cards; rendered in `primaryDark`.
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 16,
    fontWeight: heavy,
  );

  /// Builds the Material [TextTheme] for the given palette.
  static TextTheme textTheme(AppColors colors) {
    return TextTheme(
      titleLarge: screenTitle.copyWith(color: colors.textPrimary),
      headlineSmall: modalTitle.copyWith(color: colors.textPrimary),
      labelMedium: fieldLabel.copyWith(color: colors.textMuted),
      labelSmall: navLabel.copyWith(color: colors.textMuted),
      labelLarge: buttonLabel.copyWith(color: colors.textPrimary),
      bodyLarge: body.copyWith(color: colors.textPrimary),
      bodyMedium: secondary.copyWith(color: colors.textPrimary),
      bodySmall: secondary.copyWith(color: colors.textMuted),
    );
  }
}
