import 'package:flutter/material.dart';

import '../../../data/db/app_database.dart';
import '../../../data/models/event_type.dart';
import '../../../data/models/record_models.dart';
import '../../localization/app_strings.dart';
import '../../localization/event_type_strings.dart';
import '../../theme/theme.dart';
import '../../util/date_time_format.dart';
import '../../widgets/widgets.dart';

/// Action the user chose from the record details sheet, returned to the
/// caller so it can navigate to editing or run the delete flow.
enum RecordDetailAction { edit, delete }

/// Bottom sheet showing every detail of a record — its date and time, and
/// each event type's tags and description — with buttons to edit or delete
/// it. Selecting an action pops the sheet with the corresponding
/// [RecordDetailAction] so the caller can perform it.
class RecordDetailsSheet extends StatelessWidget {
  const RecordDetailsSheet({super.key, required this.entry});

  final RecordWithTags entry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;
    final record = entry.record;
    final title = AppStrings.recordTypeLabel(
      hasUrination: record.hasUrination,
      hasDefecation: record.hasDefecation,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final type in EventType.values)
              if (record.has(type)) ...[
                Text(type.icon, style: AppTypography.emojiIcon),
                const SizedBox(width: AppSpacing.xxs),
              ],
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xxs),
                child: Text(title, style: AppTypography.modalTitle),
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              tooltip: AppStrings.close,
              icon: Icon(Icons.close, color: colors.textMuted),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Icon(Icons.schedule, size: 18, color: colors.textMuted),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '${formatMonthDayYear(record.occurredAt)}'
              '${AppStrings.addRecordDateTimeSeparator}'
              '${formatHourMinute(record.occurredAt)}',
              style: textTheme.bodyMedium,
            ),
          ],
        ),
        for (final type in EventType.values)
          if (record.has(type))
            _EventSection(
              type: type,
              tags: entry.tagsFor(type),
              description: record.descriptionFor(type),
            ),
        const SizedBox(height: AppSpacing.lg),
        ModalActions(
          children: [
            SecondaryButton(
              onPressed: () =>
                  Navigator.pop(context, RecordDetailAction.edit),
              child: const Text(AppStrings.historyEdit),
            ),
            DangerButton(
              onPressed: () =>
                  Navigator.pop(context, RecordDetailAction.delete),
              child: const Text(AppStrings.editRecordDelete),
            ),
          ],
        ),
      ],
    );
  }
}

/// One event type's block within the details sheet: its labelled heading, the
/// tags applied to it, and its description when present.
class _EventSection extends StatelessWidget {
  const _EventSection({
    required this.type,
    required this.tags,
    required this.description,
  });

  final EventType type;
  final List<Tag> tags;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasDescription = description != null && description!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(type.label, style: AppTypography.bodyBold),
          if (tags.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            TagChips(tags: tags),
          ],
          if (hasDescription) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(description!, style: textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}
