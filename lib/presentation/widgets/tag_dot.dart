import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../util/color_hex.dart';

/// Rounded square swatch showing a tag's stored color.
class TagDot extends StatelessWidget {
  const TagDot({super.key, required this.colorHex});

  final String colorHex;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Container(
      width: AppSizes.tagDot,
      height: AppSizes.tagDot,
      decoration: BoxDecoration(
        color: colorFromHex(colorHex, fallback: colors.tagFallback),
        borderRadius: BorderRadius.circular(AppRadii.tagDot),
        border: Border.all(color: colors.swatchBorder),
      ),
    );
  }
}
