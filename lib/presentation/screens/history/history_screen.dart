import 'package:flutter/material.dart';

import '../../../data/models/event_type.dart';
import '../../../data/models/record_models.dart';
import '../../localization/app_strings.dart';
import '../../scope/app_scope.dart';
import '../../theme/theme.dart';
import '../../util/date_time_format.dart';
import '../../widgets/widgets.dart';
import '../add_record/add_record_screen.dart';
import 'filter_sheet.dart';

/// Chronological list of records with combinable filters.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  RecordFilter _filter = const RecordFilter();
  Stream<List<RecordWithTags>>? _records;

  Future<void> _openFilters() async {
    final result = await showAppModalSheet<RecordFilter>(
      context: context,
      builder: (context) => FilterSheet(initial: _filter),
    );
    if (result == null || !mounted) return;
    setState(() {
      _filter = result;
      _records = AppScope.of(
        context,
      ).recordRepository.watchRecords(filter: _filter);
    });
  }

  @override
  Widget build(BuildContext context) {
    _records ??= AppScope.of(
      context,
    ).recordRepository.watchRecords(filter: _filter);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.historyTitle),
        actions: appBarActions([
          SecondaryButton(
            onPressed: _openFilters,
            child: const Text(AppStrings.historyFilters),
          ),
        ]),
      ),
      body: StreamBuilder<List<RecordWithTags>>(
        stream: _records,
        builder: (context, snapshot) {
          final records = snapshot.data;
          if (records == null) return const SizedBox.shrink();
          if (records.isEmpty) {
            return const EmptyState(AppStrings.historyEmpty);
          }
          return ListView.builder(
            padding: AppInsets.screen,
            itemCount: records.length,
            itemBuilder: (context, index) => _RecordCard(entry: records[index]),
          );
        },
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.entry});

  final RecordWithTags entry;

  @override
  Widget build(BuildContext context) {
    final record = entry.record;
    final textTheme = Theme.of(context).textTheme;
    final title = AppStrings.recordTypeLabel(
      hasUrination: record.hasUrination,
      hasDefecation: record.hasDefecation,
    );

    return AppCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => AddRecordScreen(record: entry)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: AppSizes.historyTimeColumn,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatHourMinute(record.occurredAt),
                  style: AppTypography.timeLabel,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  MaterialLocalizations.of(
                    context,
                  ).formatShortMonthDay(record.occurredAt),
                  style: textTheme.bodySmall!.merge(AppTypography.dateLabel),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.rowGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bodyBold),
                for (final type in EventType.values)
                  if (entry.tagsFor(type).isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    TagChips(tags: entry.tagsFor(type)),
                  ],
                for (final type in EventType.values)
                  if (record.descriptionFor(type) != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(record.descriptionFor(type)!, style: textTheme.bodySmall),
                  ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
