import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../util/color_hex.dart';

/// Swatch showing a tag's stored color, as a rounded square or a circle.
class TagDot extends StatelessWidget {
  const TagDot({
    super.key,
    required this.colorHex,
    this.size = AppSizes.tagDot,
    this.radius = AppRadii.tagDot,
    this.selected = false,
    this.circle = false,
  });

  final String colorHex;
  final double size;
  final double radius;

  /// Draws the stronger selection border used by color pickers.
  final bool selected;

  /// Renders as a circle instead of a rounded square; [radius] is ignored.
  final bool circle;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colorFromHex(colorHex, fallback: colors.tagFallback),
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(radius),
        border: Border.all(
          color: selected ? colors.primaryDark : colors.swatchBorder,
          width: selected ? 2 : 1,
        ),
      ),
    );
  }
}
