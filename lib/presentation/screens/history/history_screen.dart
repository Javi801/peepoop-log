import 'package:flutter/material.dart';

import '../../../data/models/record_models.dart';
import '../../scope/app_scope.dart';
import '../../theme/theme.dart';
import '../../util/date_time_format.dart';
import '../../widgets/widgets.dart';
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
        title: const Text('History'),
        actions: [
          Center(
            child: SecondaryButton(
              onPressed: _openFilters,
              child: const Text('Filters'),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
        ],
      ),
      body: StreamBuilder<List<RecordWithTags>>(
        stream: _records,
        builder: (context, snapshot) {
          final records = snapshot.data;
          if (records == null) return const SizedBox.shrink();
          if (records.isEmpty) return const EmptyState('No records found.');
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
    final title = record.hasUrination && record.hasDefecation
        ? 'Urination + Defecation'
        : record.hasUrination
        ? 'Urination'
        : 'Defecation';

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 58,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatHourMinute(record.occurredAt),
                  style: AppTypography.timeLabel,
                ),
                const SizedBox(height: 2),
                Text(
                  MaterialLocalizations.of(
                    context,
                  ).formatShortMonthDay(record.occurredAt),
                  style: textTheme.bodySmall!.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.body.copyWith(
                    fontWeight: AppTypography.bold,
                  ),
                ),
                if (entry.urinationTags.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  TagChips(tags: entry.urinationTags),
                ],
                if (entry.defecationTags.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  TagChips(tags: entry.defecationTags),
                ],
                if (record.urinationDescription != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    record.urinationDescription!,
                    style: textTheme.bodySmall,
                  ),
                ],
                if (record.defecationDescription != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    record.defecationDescription!,
                    style: textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
