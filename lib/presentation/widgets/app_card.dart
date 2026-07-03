import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Rounded surface card with the soft drop shadow from the design
/// reference, which Material elevation cannot reproduce.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    this.onTap,
    this.color,
    this.radius = AppRadii.card,
    this.padding = AppInsets.card,
    this.margin = const EdgeInsets.only(bottom: AppSpacing.md),
    required this.child,
  });

  final VoidCallback? onTap;

  /// Surface color; defaults to the translucent card surface.
  final Color? color;

  final double radius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final decorations = context.appDecorations;
    final borderRadius = BorderRadius.circular(radius);

    final content = Padding(padding: padding, child: child);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? colors.surfaceCard,
        border: Border.all(color: colors.border),
        borderRadius: borderRadius,
        boxShadow: decorations.cardShadow,
      ),
      child: onTap == null
          ? content
          : Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: borderRadius,
                onTap: onTap,
                child: content,
              ),
            ),
    );
  }
}
