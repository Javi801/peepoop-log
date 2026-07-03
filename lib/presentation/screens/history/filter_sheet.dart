import 'package:flutter/material.dart';

import '../../../data/db/app_database.dart';
import '../../../data/models/event_type.dart';
import '../../../data/models/record_models.dart';
import '../../localization/app_strings.dart';
import '../../scope/app_scope.dart';
import '../../theme/theme.dart';
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
  late final Set<int> _tagIds = {...widget.initial.tagIds};

  // One-shot load: the sheet is short-lived, no need to watch.
  late final Future<List<Tag>> _tags = _loadTags();

  Future<List<Tag>> _loadTags() async {
    final repository = AppScope.of(context).tagRepository;
    return [
      ...await repository.watchTagsByType(EventType.urination).first,
      ...await repository.watchTagsByType(EventType.defecation).first,
    ];
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final date = await showAppDatePicker(
      context,
      initialDate: (isFrom ? _from : _to) ?? DateTime.now(),
    );
    if (date == null || !mounted) return;
    setState(() {
      if (isFrom) {
        _from = DateTime(date.year, date.month, date.day);
      } else {
        // Inclusive end of the selected day.
        _to = DateTime(date.year, date.month, date.day, 23, 59, 59);
      }
    });
  }

  void _clear() {
    setState(() {
      _urination = true;
      _defecation = true;
      _from = null;
      _to = null;
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
      ),
    );
  }

  String _dateLabel(BuildContext context, DateTime? value) => value == null
      ? AppStrings.filtersAny
      : MaterialLocalizations.of(context).formatShortDate(value);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ModalTitle(AppStrings.filtersTitle),
        PickerField(
          label: AppStrings.filtersFrom,
          text: _dateLabel(context, _from),
          onTap: () => _pickDate(isFrom: true),
        ),
        PickerField(
          label: AppStrings.filtersTo,
          text: _dateLabel(context, _to),
          onTap: () => _pickDate(isFrom: false),
        ),
        ToggleCard(
          label: AppStrings.urination,
          icon: AppSymbols.urination,
          value: _urination,
          onChanged: (value) => setState(() => _urination = value),
        ),
        ToggleCard(
          label: AppStrings.defecation,
          icon: AppSymbols.defecation,
          value: _defecation,
          onChanged: (value) => setState(() => _defecation = value),
        ),
        const SectionTitle(AppStrings.filtersTags),
        FutureBuilder<List<Tag>>(
          future: _tags,
          builder: (context, snapshot) {
            final tags = snapshot.data ?? const <Tag>[];
            return Column(
              children: [
                for (final tag in tags)
                  AppCard(
                    onTap: () => setState(() => _tagIds.toggle(tag.id)),
                    child: Row(
                      children: [
                        TagDot(colorHex: tag.colorHex),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(tag.name, style: AppTypography.bodyBold),
                        ),
                        if (_tagIds.contains(tag.id))
                          const Text(AppSymbols.selected),
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
