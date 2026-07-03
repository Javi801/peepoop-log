import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../util/color_hex.dart';

/// Rounded square swatch showing a tag's stored color.
class TagDot extends StatelessWidget {
  const TagDot({
    super.key,
    required this.colorHex,
    this.size = AppSizes.tagDot,
    this.radius = AppRadii.tagDot,
    this.selected = false,
  });

  final String colorHex;
  final double size;
  final double radius;

  /// Draws the stronger selection border used by color pickers.
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colorFromHex(colorHex, fallback: colors.tagFallback),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: selected ? colors.primaryDark : colors.swatchBorder,
          width: selected ? 2 : 1,
        ),
      ),
    );
  }
}
