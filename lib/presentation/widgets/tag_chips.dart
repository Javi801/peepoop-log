import 'package:flutter/material.dart';

import '../../data/db/app_database.dart';
import '../theme/theme.dart';
import '../util/color_hex.dart';

/// Pill chip filled with the tag's stored color, with an optional "×"
/// remove button.
class TagChip extends StatelessWidget {
  const TagChip({super.key, required this.tag, this.onRemove});

  final Tag tag;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final labelStyle =
        AppTypography.chipLabel.copyWith(color: colors.textPrimary);

    return Container(
      padding: AppInsets.chip,
      decoration: BoxDecoration(
        color: colorFromHex(tag.colorHex, fallback: colors.tagFallback),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(tag.name, style: labelStyle),
          if (onRemove != null) ...[
            const SizedBox(width: AppSpacing.xs),
            GestureDetector(
              onTap: onRemove,
              child: Text(
                '×',
                style: labelStyle.copyWith(fontWeight: AppTypography.heavy),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Wrapping row of [TagChip]s.
class TagChips extends StatelessWidget {
  const TagChips({super.key, required this.tags, this.onRemove});

  final List<Tag> tags;
  final ValueChanged<Tag>? onRemove;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        for (final tag in tags)
          TagChip(
            tag: tag,
            onRemove: onRemove == null ? null : () => onRemove!(tag),
          ),
      ],
    );
  }
}
