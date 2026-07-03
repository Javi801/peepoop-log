import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_decorations.dart';

/// Shorthand accessors for the app's theme extensions.
extension ThemeContext on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;

  AppDecorations get appDecorations =>
      Theme.of(this).extension<AppDecorations>()!;
}
