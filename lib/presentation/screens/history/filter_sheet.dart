import 'package:flutter/material.dart';

import '../../../data/db/app_database.dart';
import '../../../data/models/event_type.dart';
import '../../../data/models/record_models.dart';
import '../../localization/app_strings.dart';
import '../../scope/app_scope.dart';
import '../../theme/theme.dart';
import '../../util/date_time_format.dart';
import '../../util/set_toggle.dart';
import '../../widgets/widgets.dart';

/// Filter editor shown in a modal sheet; pops with the new [RecordFilter]
/// on Apply, or with null when dismissed.
class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key, required this.initial});

  final RecordFilter initial;

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late bool _urination = widget.initial.includeUrination;
  late bool _defecation = widget.initial.includeDefecation;
  late DateTime? _from = widget.initial.from;
  late DateTime? _to = widget.initial.to;
  late RecordSort _sort = widget.initial.sort;
  late final Set<int> _tagIds = {...widget.initial.tagIds};

  bool _sortOpen = false;
  bool _tagsOpen = false;

  // One-shot load: the sheet is short-lived, no need to watch.
  late final Future<List<Tag>> _tags = _loadTags();

  Future<List<Tag>> _loadTags() async {
    final repository = AppScope.of(context).tagRepository;
    return [
      ...await repository.watchTagsByType(EventType.urination).first,
      ...await repository.watchTagsByType(EventType.defecation).first,
    ];
  }

  Future<void> _pickDateRange() async {
    final range = await showAppDateRangePicker(
      context,
      initialRange: _from != null && _to != null
          ? DateTimeRange(start: _from!, end: _to!)
          : null,
    );
    if (range == null || !mounted) return;
    setState(() {
      _from = DateTime(range.start.year, range.start.month, range.start.day);
      // Inclusive end of the selected day.
      _to = DateTime(range.end.year, range.end.month, range.end.day, 23, 59, 59);
    });
  }

  void _clear() {
    setState(() {
      _urination = true;
      _defecation = true;
      _from = null;
      _to = null;
      _sort = RecordSort.newestFirst;
      _tagIds.clear();
    });
  }

  void _apply() {
    Navigator.pop(
      context,
      RecordFilter(
        includeUrination: _urination,
        includeDefecation: _defecation,
        from: _from,
        to: _to,
        tagIds: _tagIds.toList(),
        sort: _sort,
      ),
    );
  }

  String get _dateRangeLabel {
    if (_from == null && _to == null) return AppStrings.filtersAny;
    final start = _from == null
        ? AppStrings.filtersAny
        : formatMonthDayYear(_from!);
    final end = _to == null ? AppStrings.filtersAny : formatMonthDayYear(_to!);
    return '$start - $end';
  }

  String _sortLabel(RecordSort sort) => switch (sort) {
    RecordSort.newestFirst => AppStrings.filtersSortNewest,
    RecordSort.oldestFirst => AppStrings.filtersSortOldest,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FilterHeading(AppStrings.filtersTitle),
        const SectionTitle(AppStrings.filtersSortBy),
        _InlineDropdown(
          text: _sortLabel(_sort),
          open: _sortOpen,
          onTap: () => setState(() => _sortOpen = !_sortOpen),
          child: Column(
            children: [
              for (final sort in RecordSort.values)
                _SortOption(
                  label: _sortLabel(sort),
                  selected: sort == _sort,
                  onTap: () => setState(() {
                    _sort = sort;
                    _sortOpen = false;
                  }),
                ),
            ],
          ),
        ),
        const SectionTitle(AppStrings.filtersDateRange),
        _DateRangeField(text: _dateRangeLabel, onTap: _pickDateRange),
        const SectionTitle(AppStrings.filtersType),
        Row(
          children: [
            Expanded(
              child: _TypeToggle(
                icon: AppSymbols.urination,
                label: AppStrings.urination,
                included: _urination,
                onTap: () => setState(() => _urination = !_urination),
              ),
            ),
            const SizedBox(width: AppSpacing.tabGap),
            Expanded(
              child: _TypeToggle(
                icon: AppSymbols.defecation,
                label: AppStrings.defecation,
                included: _defecation,
                onTap: () => setState(() => _defecation = !_defecation),
              ),
            ),
          ],
        ),
        const SectionTitle(AppStrings.filtersTags),
        FutureBuilder<List<Tag>>(
          future: _tags,
          builder: (context, snapshot) {
            final tags = snapshot.data ?? const <Tag>[];
            final selected = [
              for (final tag in tags)
                if (_tagIds.contains(tag.id)) tag,
            ];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (selected.isNotEmpty) ...[
                  TagChips(
                    tags: selected,
                    onRemove: (tag) => setState(() => _tagIds.remove(tag.id)),
                  ),
                  const SizedBox(height: AppSpacing.labelGap),
                ],
                _InlineDropdown(
                  text: AppStrings.filtersTagsHint,
                  open: _tagsOpen,
                  onTap: () => setState(() => _tagsOpen = !_tagsOpen),
                  // Caps the panel so about two tags stay visible and the rest
                  // scroll within it, keeping the sheet compact.
                  maxChildHeight: AppSizes.filterTagPanelMaxHeight,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    children: [
                      for (final tag in tags)
                        _TagOption(
                          tag: tag,
                          selected: _tagIds.contains(tag.id),
                          onTap: () => setState(() => _tagIds.toggle(tag.id)),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        ModalActions(
          children: [
            OutlinedButton(
              onPressed: _clear,
              child: const Text(AppStrings.filtersClear),
            ),
            PrimaryButton(
              onPressed: _apply,
              child: const Text(AppStrings.filtersApply),
            ),
          ],
        ),
      ],
    );
  }
}

/// Left-aligned modal heading (H2): a step below the screen (H1) titles, so
/// the sheet reads as a section within History rather than its own screen.
class _FilterHeading extends StatelessWidget {
  const _FilterHeading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: AppInsets.modalTitle,
      child: Text(
        text,
        style: AppTypography.modalTitle.copyWith(
          color: colors.textPrimary,
          fontSize: 17,
        ),
      ),
    );
  }
}

/// Read-only field that expands an inline options panel below itself when
/// tapped. Because it lives inside the sheet's own scroll view it always
/// opens downward, unlike an overlay menu that flips upward when the sheet
/// sits near the bottom of the screen.
class _InlineDropdown extends StatelessWidget {
  const _InlineDropdown({
    required this.text,
    required this.open,
    required this.onTap,
    required this.child,
    this.maxChildHeight,
  });

  final String text;
  final bool open;
  final VoidCallback onTap;
  final Widget child;

  /// Caps the expanded panel height; the panel scrolls its own content past it.
  final double? maxChildHeight;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(AppRadii.input),
          onTap: onTap,
          child: InputDecorator(
            decoration: const InputDecoration(),
            child: Row(
              children: [
                Expanded(child: Text(text)),
                Icon(open ? Icons.arrow_drop_up : Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
        if (open) ...[
          const SizedBox(height: AppSpacing.labelGap),
          Container(
            constraints: maxChildHeight == null
                ? const BoxConstraints()
                : BoxConstraints(maxHeight: maxChildHeight!),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadii.input),
              border: Border.all(color: colors.border),
            ),
            child: child,
          ),
        ],
      ],
    );
  }
}

/// Single-select row inside the sort dropdown; the active choice is
/// highlighted and marked with a check.
class _SortOption extends StatelessWidget {
  const _SortOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: AppInsets.input,
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTypography.body.copyWith(
                  color: selected ? colors.primaryDark : colors.textPrimary,
                  fontWeight: selected ? AppTypography.bold : null,
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check, size: 18, color: colors.primaryDark),
          ],
        ),
      ),
    );
  }
}

/// Multi-select row inside the tag dropdown; toggling never closes the panel.
class _TagOption extends StatelessWidget {
  const _TagOption({
    required this.tag,
    required this.selected,
    required this.onTap,
  });

  final Tag tag;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: AppInsets.input,
        child: Row(
          children: [
            Icon(
              selected ? Icons.check_box : Icons.check_box_outline_blank,
              size: 20,
              color: selected ? colors.primary : colors.textMuted,
            ),
            const SizedBox(width: AppSpacing.rowGap),
            TagDot(colorHex: tag.colorHex),
            const SizedBox(width: AppSpacing.rowGap),
            Expanded(child: Text(tag.name)),
          ],
        ),
      ),
    );
  }
}

/// Single field showing the selected date range with a leading calendar icon;
/// tapping opens the range calendar picker.
class _DateRangeField extends StatelessWidget {
  const _DateRangeField({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.fieldGap),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.input),
        onTap: onTap,
        child: InputDecorator(
          decoration: const InputDecoration(),
          child: Row(
            children: [
              Icon(Icons.calendar_today, size: 18, color: colors.textMuted),
              const SizedBox(width: AppSpacing.rowGap),
              Expanded(child: Text(text)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Type filter button. Included types look active; tapping excludes the type,
/// greying it out and drawing a diagonal strike to signal it is filtered out.
class _TypeToggle extends StatelessWidget {
  const _TypeToggle({
    required this.icon,
    required this.label,
    required this.included,
    required this.onTap,
  });

  final String icon;
  final String label;
  final bool included;
  final VoidCallback onTap;

  // Luminance weights that collapse the emoji to greyscale when excluded.
  static const _greyscale = <double>[
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0, 0, 0, 1, 0, //
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    Widget iconGlyph = Text(icon, style: AppTypography.emojiIcon);
    if (!included) {
      iconGlyph = ColorFiltered(
        colorFilter: const ColorFilter.matrix(_greyscale),
        child: iconGlyph,
      );
    }

    return Material(
      color: included ? colors.surface : colors.surfaceSoft,
      shape: StadiumBorder(
        side: BorderSide(
          color: included ? colors.border : colors.switchTrackOff,
        ),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: AppInsets.tab,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconGlyph,
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    label,
                    style: AppTypography.buttonLabel.copyWith(
                      color: included ? colors.textPrimary : colors.textMuted,
                    ),
                  ),
                ],
              ),
              if (!included)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _StrikePainter(color: colors.textMuted),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Draws a single diagonal line across its bounds, marking an excluded type.
class _StrikePainter extends CustomPainter {
  const _StrikePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, size.height), Offset(size.width, 0), paint);
  }

  @override
  bool shouldRepaint(_StrikePainter oldDelegate) => oldDelegate.color != color;
}
