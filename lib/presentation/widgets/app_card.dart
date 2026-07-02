import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Rounded surface card with the soft drop shadow from the design
/// reference, which Material elevation cannot reproduce.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    this.onTap,
    this.padding = AppInsets.card,
    this.margin = const EdgeInsets.only(bottom: AppSpacing.md),
    required this.child,
  });

  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final decorations = Theme.of(context).extension<AppDecorations>()!;
    final radius = BorderRadius.circular(AppRadii.card);

    final content = Padding(padding: padding, child: child);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        border: Border.all(color: colors.border),
        borderRadius: radius,
        boxShadow: decorations.cardShadow,
      ),
      child: onTap == null
          ? content
          : Material(
              color: Colors.transparent,
              child: InkWell(borderRadius: radius, onTap: onTap, child: content),
            ),
    );
  }
}
