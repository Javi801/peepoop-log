import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Pill-shaped switch matching the design reference; Material's [Switch]
/// cannot be sized down to these proportions.
class AppSwitch extends StatelessWidget {
  const AppSwitch({super.key, required this.value, this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  static const _knobPadding = (AppSizes.switchHeight - AppSizes.switchKnob) / 2;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Semantics(
      toggled: value,
      child: GestureDetector(
        onTap: onChanged == null ? null : () => onChanged!(!value),
        child: AnimatedContainer(
          duration: AppEffects.switchAnimation,
          width: AppSizes.switchWidth,
          height: AppSizes.switchHeight,
          padding: const EdgeInsets.all(_knobPadding),
          decoration: BoxDecoration(
            color: value ? colors.primary : colors.switchTrackOff,
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          child: AnimatedAlign(
            duration: AppEffects.switchAnimation,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: AppSizes.switchKnob,
              height: AppSizes.switchKnob,
              decoration: BoxDecoration(
                color: colors.onPrimary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
