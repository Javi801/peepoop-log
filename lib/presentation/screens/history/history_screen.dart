import 'package:flutter/material.dart';

import '../../../data/db/app_database.dart';
import '../../../data/models/event_type.dart';
import '../../../data/models/record_models.dart';
import '../../localization/app_strings.dart';
import '../../localization/event_type_strings.dart';
import '../../scope/app_scope.dart';
import '../../theme/theme.dart';
import '../../util/date_time_format.dart';
import '../../widgets/widgets.dart';
import '../add_record/add_record_screen.dart';
import 'filter_sheet.dart';
import 'record_details_sheet.dart';

/// Number of tags shown on a collapsed card before the "+N" indicator.
const _kCollapsedTagCount = 3;

/// Tighter horizontal edge padding than the default screen inset so the
/// timeline and its cards sit closer to the screen edges.
const _kHistoryListPadding = EdgeInsets.fromLTRB(
  AppSpacing.sm,
  AppSpacing.lg,
  AppSpacing.sm,
  AppSpacing.screenBottom,
);

/// Corner radius for history record cards — squarer than the default card
/// so the timeline reads as a denser list.
const _kHistoryCardRadius = 12.0;

/// Gap between the timeline dot/line and the record card; tight so the card
/// sits close against the timeline.
const _kHistoryCardGap = AppSpacing.xxs;

/// Chronological list of records with combinable filters, laid out as a
/// vertical timeline: the time sits at the left edge, records for the same
/// day are grouped under a rounded date pill, and each card can be expanded
/// to reveal every tag and the descriptions.
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
          IconActionButton(
            onPressed: _openFilters,
            tooltip: AppStrings.historyFilters,
            icon: Icons.filter_list,
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
          final items = _buildTimeline(records);
          return ListView.builder(
            padding: _kHistoryListPadding,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return switch (item) {
                _DayHeader() => _DateChip(label: item.label),
                _RecordRow() => _RecordTimelineRow(item: item),
              };
            },
          );
        },
      ),
    );
  }

  /// Flattens the records into a list of day headers and record rows, marking
  /// each row's position within its day so the connecting line can be drawn.
  List<_TimelineItem> _buildTimeline(List<RecordWithTags> records) {
    final now = DateTime.now();
    final items = <_TimelineItem>[];
    DateTime? currentDay;

    DateTime dayOf(RecordWithTags e) {
      final at = e.record.occurredAt;
      return DateTime(at.year, at.month, at.day);
    }

    for (var i = 0; i < records.length; i++) {
      final entry = records[i];
      final day = dayOf(entry);
      final isFirstInDay = currentDay == null || day != currentDay;
      if (isFirstInDay) {
        items.add(_DayHeader(_dayLabel(entry.record.occurredAt, now)));
        currentDay = day;
      }
      final isLastInDay =
          i == records.length - 1 || dayOf(records[i + 1]) != day;
      items.add(
        _RecordRow(
          entry: entry,
          isFirstInDay: isFirstInDay,
          isLastInDay: isLastInDay,
        ),
      );
    }
    return items;
  }

  String _dayLabel(DateTime date, DateTime now) {
    final daysAgo = calendarDaysAgo(date, now);
    if (daysAgo == 0) return AppStrings.historyToday;
    if (daysAgo == 1) return AppStrings.historyYesterday;
    return formatMonthDayYear(date);
  }
}

/// One entry in the flattened timeline: either a [_DayHeader] or a
/// [_RecordRow].
sealed class _TimelineItem {
  const _TimelineItem();
}

class _DayHeader extends _TimelineItem {
  const _DayHeader(this.label);

  final String label;
}

class _RecordRow extends _TimelineItem {
  const _RecordRow({
    required this.entry,
    required this.isFirstInDay,
    required this.isLastInDay,
  });

  final RecordWithTags entry;
  final bool isFirstInDay;
  final bool isLastInDay;
}

/// Rounded date pill heading a day's group of records ("Today", "Yesterday"
/// or e.g. "Jun 20, 2026"). The pill is centred on the timeline's vertical
/// line and a short segment below it links down to the day's first dot.
class _DateChip extends StatelessWidget {
  const _DateChip({required this.label});

  final String label;

  /// Horizontal centre of the timeline's vertical line, measured from the
  /// row's left edge: the time column plus half the gutter.
  static const double _lineCenter =
      AppSizes.historyTimeColumn + AppSizes.historyTimelineGutter / 2;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Centre the pill on the vertical line: lay it out at the line's
          // x and shift it left by half its own width.
          Padding(
            padding: const EdgeInsets.only(left: _lineCenter),
            child: FractionalTranslation(
              translation: const Offset(-0.5, 0),
              child: Container(
                width: AppSizes.historyDateChipWidth,
                padding: AppInsets.chip,
                decoration: BoxDecoration(
                  color: colors.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTypography.chipLabel.copyWith(
                    color: colors.primaryDark,
                  ),
                ),
              ),
            ),
          ),
          // Extend the line down from the pill to the day's first dot.
          Padding(
            padding: const EdgeInsets.only(left: _lineCenter - 1),
            child: Container(width: 2, height: 10, color: colors.border),
          ),
        ],
      ),
    );
  }
}

/// A single record on the timeline: the time at the left edge, the connecting
/// line and dot in the gutter, and the expandable card.
class _RecordTimelineRow extends StatelessWidget {
  const _RecordTimelineRow({required this.item});

  final _RecordRow item;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: AppSizes.historyTimeColumn,
            child: Padding(
              padding: const EdgeInsets.only(
                top: AppSizes.historyTimelineDotInset,
              ),
              child: Text(
                formatHourMinute(item.entry.record.occurredAt),
                style: AppTypography.timeLabel,
              ),
            ),
          ),
          _TimelineGutter(
            // Always draw the top segment: within a day it joins the record
            // above, and for the first record it links up to the date pill.
            showTop: true,
            showBottom: !item.isLastInDay,
          ),
          const SizedBox(width: _kHistoryCardGap),
          Expanded(child: _RecordCard(entry: item.entry)),
        ],
      ),
    );
  }
}

/// The vertical timeline line with a dot marking this record. The segment
/// above the dot is always drawn — it joins the record above or, for the
/// first record of a day, the date pill. The segment below is drawn only
/// while more records share the same day, so the line ends at the last dot.
class _TimelineGutter extends StatelessWidget {
  const _TimelineGutter({required this.showTop, required this.showBottom});

  final bool showTop;
  final bool showBottom;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final line = Container(width: 2, color: colors.border);

    return SizedBox(
      width: AppSizes.historyTimelineGutter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: AppSizes.historyTimelineDotInset,
            child: showTop ? Center(child: line) : null,
          ),
          Container(
            width: AppSizes.historyTimelineDot,
            height: AppSizes.historyTimelineDot,
            decoration: BoxDecoration(
              color: colors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: colors.surface, width: 2),
            ),
          ),
          Expanded(child: showBottom ? Center(child: line) : const SizedBox()),
        ],
      ),
    );
  }
}

/// Record card without its own date/time. Shows the event-type icons, the
/// title and up to [_kCollapsedTagCount] tags with a "+N" indicator. Tapping
/// the card — or its top-right menu button — opens the details sheet, from
/// which the record can be edited or deleted.
class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.entry});

  final RecordWithTags entry;

  Future<void> _openDetails(BuildContext context) async {
    final action = await showAppCenteredModal<RecordDetailAction>(
      context: context,
      builder: (_) => RecordDetailsSheet(entry: entry),
    );
    if (action == null || !context.mounted) return;
    switch (action) {
      case RecordDetailAction.edit:
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => AddRecordScreen(record: entry)),
        );
      case RecordDetailAction.delete:
        await _confirmDelete(context);
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final repository = AppScope.of(context).recordRepository;
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showConfirmDialog(
      context,
      title: AppStrings.editRecordDeleteDialogTitle,
      message: AppStrings.editRecordDeleteDialogMessage,
    );
    if (!confirmed) return;
    await repository.deleteRecord(entry.record.id);
    messenger.showSnackBar(
      const SnackBar(content: Text(AppStrings.recordDeleted)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final record = entry.record;
    final colors = context.appColors;
    final title = AppStrings.recordTypeLabel(
      hasUrination: record.hasUrination,
      hasDefecation: record.hasDefecation,
    );

    final tags = [
      for (final type in EventType.values) ...entry.tagsFor(type),
    ];
    final hiddenTags = tags.length - _kCollapsedTagCount;

    return AppCard(
      radius: _kHistoryCardRadius,
      onTap: () => _openDetails(context),
      child: Column(
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
              Expanded(child: Text(title, style: AppTypography.bodyBold)),
              InkWell(
                onTap: () => _openDetails(context),
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxs),
                  child: Icon(Icons.more_vert, color: colors.textMuted),
                ),
              ),
            ],
          ),
          if (tags.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            _CollapsedTags(tags: tags, hiddenCount: hiddenTags),
          ],
        ],
      ),
    );
  }
}

/// First few tags followed by a neutral "+N" pill when more are hidden.
class _CollapsedTags extends StatelessWidget {
  const _CollapsedTags({required this.tags, required this.hiddenCount});

  final List<Tag> tags;
  final int hiddenCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        for (final tag in tags.take(_kCollapsedTagCount)) TagChip(tag: tag),
        if (hiddenCount > 0)
          Container(
            padding: AppInsets.chip,
            decoration: BoxDecoration(
              color: colors.primarySoft,
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: Text(
              '+$hiddenCount',
              style: AppTypography.chipLabel.copyWith(
                color: colors.primaryDark,
              ),
            ),
          ),
      ],
    );
  }
}

