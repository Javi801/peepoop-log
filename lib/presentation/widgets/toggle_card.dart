import 'package:flutter/material.dart';

import '../theme/theme.dart';
import 'app_switch.dart';

/// Card with an emoji icon, a label and a switch, used to enable the
/// urination/defecation sections of a record and the type filters.
///
/// The whole card toggles, not just the switch: a larger tap target than
/// the design reference.
class ToggleCard extends StatelessWidget {
  const ToggleCard({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  final String label;

  /// Emoji shown in the rounded icon square.
  final String icon;

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final decorations = Theme.of(context).extension<AppDecorations>()!;
    final radius = BorderRadius.circular(AppRadii.toggleCard);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border),
        borderRadius: radius,
        boxShadow: decorations.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: radius,
          onTap: () => onChanged(!value),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: AppSizes.cuteIcon,
                  height: AppSizes.cuteIcon,
                  decoration: BoxDecoration(
                    color: colors.cuteIconBackground,
                    borderRadius: BorderRadius.circular(AppRadii.cuteIcon),
                  ),
                  child: Center(
                    child: Text(icon, style: const TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.body
                        .copyWith(fontWeight: AppTypography.bold),
                  ),
                ),
                AppSwitch(value: value, onChanged: onChanged),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
