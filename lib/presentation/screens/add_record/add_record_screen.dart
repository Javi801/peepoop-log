import 'package:flutter/material.dart';

import '../../../data/db/app_database.dart';
import '../../../data/models/event_type.dart';
import '../../../data/models/record_models.dart';
import '../../localization/app_strings.dart';
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

class _AddRecordScreenState extends State<AddRecordScreen> {
  DateTime _occurredAt = DateTime.now();
  bool _hasUrination = true;
  bool _hasDefecation = false;
  final _urinationDescription = TextEditingController();
  final _defecationDescription = TextEditingController();
  final List<Tag> _urinationTags = [];
  final List<Tag> _defecationTags = [];
  bool _saving = false;

  @override
  void dispose() {
    _urinationDescription.dispose();
    _defecationDescription.dispose();
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
      final target = type == EventType.urination
          ? _urinationTags
          : _defecationTags;
      if (!target.any((t) => t.id == tag.id)) target.add(tag);
    });
  }

  Future<void> _save() async {
    final repository = AppScope.of(context).recordRepository;
    setState(() => _saving = true);
    try {
      await repository.createRecord(
        RecordDraft(
          occurredAt: _occurredAt,
          hasUrination: _hasUrination,
          hasDefecation: _hasDefecation,
          // Disabled sections keep their form state so re-enabling restores
          // it, but their details must not reach the repository, which
          // rejects details without their event type.
          urinationDescription: _hasUrination
              ? _urinationDescription.text
              : null,
          defecationDescription: _hasDefecation
              ? _defecationDescription.text
              : null,
          urinationTagIds: _hasUrination
              ? [for (final t in _urinationTags) t.id]
              : const [],
          defecationTagIds: _hasDefecation
              ? [for (final t in _defecationTags) t.id]
              : const [],
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
    _hasUrination = true;
    _hasDefecation = false;
    _urinationDescription.clear();
    _defecationDescription.clear();
    _urinationTags.clear();
    _defecationTags.clear();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final canSave = (_hasUrination || _hasDefecation) && !_saving;

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
            child: LabeledField(
              label: AppStrings.addRecordDateTime,
              text:
                  '${localizations.formatShortDate(_occurredAt)}'
                  '${AppStrings.addRecordDateTimeSeparator}'
                  '${formatHourMinute(_occurredAt)}',
              onTap: _pickDateTime,
            ),
          ),
          ToggleCard(
            label: AppStrings.urination,
            icon: AppSymbols.urination,
            value: _hasUrination,
            onChanged: (value) => setState(() => _hasUrination = value),
          ),
          if (_hasUrination)
            _DetailCard(
              descriptionLabel: AppStrings.urinationDescription,
              descriptionHint: AppStrings.urinationDescriptionHint,
              description: _urinationDescription,
              tagLabel: AppStrings.urinationTags,
              tags: _urinationTags,
              onAddTag: (name) => _addTag(name, EventType.urination),
              onRemoveTag: (tag) => setState(() => _urinationTags.remove(tag)),
            ),
          ToggleCard(
            label: AppStrings.defecation,
            icon: AppSymbols.defecation,
            value: _hasDefecation,
            onChanged: (value) => setState(() => _hasDefecation = value),
          ),
          if (_hasDefecation)
            _DetailCard(
              descriptionLabel: AppStrings.defecationDescription,
              descriptionHint: AppStrings.defecationDescriptionHint,
              description: _defecationDescription,
              tagLabel: AppStrings.defecationTags,
              tags: _defecationTags,
              onAddTag: (name) => _addTag(name, EventType.defecation),
              onRemoveTag: (tag) => setState(() => _defecationTags.remove(tag)),
            ),
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
