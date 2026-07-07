import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Pill button with the accent→primary gradient and drop shadow.
///
/// Material buttons cannot render gradients, so this applies
/// `AppDecorations.primaryAction` manually; the themed [FilledButton]
/// remains the flat fallback.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.expand = false,
  });

  final VoidCallback? onPressed;
  final Widget child;

  /// Stretches the button to the available width.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final decorations = context.appDecorations;
    final radius = BorderRadius.circular(AppRadii.pill);
    final enabled = onPressed != null;

    final button = DecoratedBox(
      decoration: BoxDecoration(
        gradient: decorations.primaryAction,
        borderRadius: radius,
        boxShadow: enabled ? decorations.buttonShadow : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: radius,
          onTap: onPressed,
          child: Padding(
            padding: AppInsets.button,
            child: Center(
              widthFactor: 1,
              heightFactor: 1,
              child: DefaultTextStyle.merge(
                style: AppTypography.buttonLabel.copyWith(
                  color: colors.onPrimary,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );

    return Opacity(
      opacity: enabled ? 1 : AppEffects.disabledOpacity,
      child: expand ? SizedBox(width: double.infinity, child: button) : button,
    );
  }
}

/// Soft lilac pill button used for top bar actions.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}

/// Square, rounded icon button for the top bar (filter / add / delete).
class IconActionButton extends StatelessWidget {
  const IconActionButton({
    super.key,
    required this.onPressed,
    required this.tooltip,
    required this.icon,
  });

  final VoidCallback? onPressed;
  final String tooltip;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final radius = BorderRadius.circular(AppRadii.input);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: colors.primarySoft,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: colors.primaryDark, width: 1.5),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: radius,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Center(
              child: Icon(
                icon,
                size: 24,
                color: colors.primaryDark,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// AppBar `actions` with the shared layout: buttons centered vertically,
/// [AppSpacing.sm] between them and [AppSpacing.lg] before the screen edge.
List<Widget> appBarActions(List<Widget> buttons) {
  return [
    for (final (index, button) in buttons.indexed) ...[
      if (index > 0) const SizedBox(width: AppSpacing.sm),
      Center(child: button),
    ],
    const SizedBox(width: AppSpacing.lg),
  ];
}

/// Soft red pill button for destructive actions.
class DangerButton extends StatelessWidget {
  const DangerButton({super.key, required this.onPressed, required this.child});

  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: colors.dangerSoft,
        foregroundColor: colors.danger,
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}
