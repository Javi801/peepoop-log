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

/// Form to create a record with optional urination/defecation details.
class AddRecordScreen extends StatefulWidget {
  const AddRecordScreen({super.key});

  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

/// Editable form state for one event type. Kept even while the type is
/// disabled so re-enabling restores what the user typed.
class _EventForm {
  _EventForm({this.enabled = false});

  final TextEditingController description = TextEditingController();
  final List<Tag> tags = [];
  bool enabled;

  void dispose() => description.dispose();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  DateTime _occurredAt = DateTime.now();
  final Map<EventType, _EventForm> _forms = {
    EventType.urination: _EventForm(enabled: true),
    EventType.defecation: _EventForm(enabled: false),
  };
  bool _saving = false;

  @override
  void dispose() {
    for (final form in _forms.values) {
      form.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showAppDatePicker(context, initialDate: _occurredAt);
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_occurredAt),
    );
    if (time == null) return;
    setState(() {
      _occurredAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _addTag(String name, EventType type) async {
    final tag = await AppScope.of(context).tagRepository.ensureTag(name, type);
    if (!mounted) return;
    setState(() {
      final tags = _forms[type]!.tags;
      if (!tags.any((t) => t.id == tag.id)) tags.add(tag);
    });
  }

  Future<void> _save() async {
    final repository = AppScope.of(context).recordRepository;
    setState(() => _saving = true);
    try {
      // Disabled sections keep their form state so re-enabling restores it,
      // but only enabled types contribute a detail to the draft.
      await repository.createRecord(
        RecordDraft(
          occurredAt: _occurredAt,
          details: {
            for (final entry in _forms.entries)
              if (entry.value.enabled)
                entry.key: EventDetail(
                  description: entry.value.description.text,
                  tagIds: [for (final t in entry.value.tags) t.id],
                ),
          },
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
    if (!mounted) return;
    setState(_reset);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text(AppStrings.recordSaved)));
  }

  void _reset() {
    _occurredAt = DateTime.now();
    _forms.forEach((type, form) {
      form.enabled = type == EventType.urination;
      form.description.clear();
      form.tags.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final canSave = _forms.values.any((f) => f.enabled) && !_saving;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.addRecordTitle),
        actions: appBarActions([
          SecondaryButton(
            onPressed: () => setState(() => _occurredAt = DateTime.now()),
            child: const Text(AppStrings.addRecordNow),
          ),
        ]),
      ),
      body: ListView(
        padding: AppInsets.screen,
        children: [
          AppCard(
            child: PickerField(
              label: AppStrings.addRecordDateTime,
              text:
                  '${localizations.formatShortDate(_occurredAt)}'
                  '${AppStrings.addRecordDateTimeSeparator}'
                  '${formatHourMinute(_occurredAt)}',
              onTap: _pickDateTime,
            ),
          ),
          for (final type in EventType.values) ...[
            ToggleCard(
              label: type.label,
              icon: type.icon,
              value: _forms[type]!.enabled,
              onChanged: (value) =>
                  setState(() => _forms[type]!.enabled = value),
            ),
            if (_forms[type]!.enabled)
              _DetailCard(
                descriptionLabel: type.descriptionLabel,
                descriptionHint: type.descriptionHint,
                description: _forms[type]!.description,
                tagLabel: type.tagsLabel,
                tags: _forms[type]!.tags,
                onAddTag: (name) => _addTag(name, type),
                onRemoveTag: (tag) =>
                    setState(() => _forms[type]!.tags.remove(tag)),
              ),
          ],
          PrimaryButton(
            expand: true,
            onPressed: canSave ? _save : null,
            child: const Text(AppStrings.addRecordSave),
          ),
        ],
      ),
    );
  }
}

/// Description and tags for one event type of the record being created.
class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.descriptionLabel,
    required this.descriptionHint,
    required this.description,
    required this.tagLabel,
    required this.tags,
    required this.onAddTag,
    required this.onRemoveTag,
  });

  final String descriptionLabel;
  final String descriptionHint;
  final TextEditingController description;
  final String tagLabel;
  final List<Tag> tags;
  final ValueChanged<String> onAddTag;
  final ValueChanged<Tag> onRemoveTag;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LabeledField(
            label: descriptionLabel,
            child: TextField(
              controller: description,
              maxLines: 3,
              decoration: InputDecoration(hintText: descriptionHint),
            ),
          ),
          TagInputField(label: tagLabel, onSubmitted: onAddTag),
          TagChips(tags: tags, onRemove: onRemoveTag),
        ],
      ),
    );
  }
}
