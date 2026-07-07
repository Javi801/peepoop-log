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

/// Form to create a record, or edit [record] when one is provided, with
/// optional urination/defecation details.
class AddRecordScreen extends StatefulWidget {
  const AddRecordScreen({super.key, this.record});

  /// Existing record to edit; null creates a new one.
  final RecordWithTags? record;

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
  late DateTime _occurredAt;
  late final Map<EventType, _EventForm> _forms;
  bool _saving = false;

  bool get _isEditing => widget.record != null;

  @override
  void initState() {
    super.initState();
    final entry = widget.record;
    _occurredAt = entry?.record.occurredAt ?? DateTime.now();
    _forms = {
      for (final type in EventType.values) type: _buildForm(type, entry),
    };
  }

  /// Seeds a form for [type] from [entry] when editing, or an empty form for
  /// creation (only urination enabled by default).
  _EventForm _buildForm(EventType type, RecordWithTags? entry) {
    if (entry == null) {
      return _EventForm(enabled: type == EventType.urination);
    }
    final enabled = entry.record.has(type);
    final form = _EventForm(enabled: enabled);
    if (enabled) {
      form.description.text = entry.record.descriptionFor(type) ?? '';
      form.tags.addAll(entry.tagsFor(type));
    }
    return form;
  }

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
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    try {
      // Disabled sections keep their form state so re-enabling restores it,
      // but only enabled types contribute a detail to the draft.
      final draft = RecordDraft(
        occurredAt: _occurredAt,
        details: {
          for (final entry in _forms.entries)
            if (entry.value.enabled)
              entry.key: EventDetail(
                description: entry.value.description.text,
                tagIds: [for (final t in entry.value.tags) t.id],
              ),
        },
      );
      if (_isEditing) {
        await repository.updateRecord(widget.record!.record.id, draft);
      } else {
        await repository.createRecord(draft);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
    if (!mounted) return;
    // Editing runs on a pushed route: pop back to history after saving.
    if (_isEditing) {
      Navigator.pop(context);
      messenger.showSnackBar(
        const SnackBar(content: Text(AppStrings.recordUpdated)),
      );
      return;
    }
    setState(_reset);
    messenger.showSnackBar(
      const SnackBar(content: Text(AppStrings.recordSaved)),
    );
  }

  Future<void> _delete() async {
    final repository = AppScope.of(context).recordRepository;
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showConfirmDialog(
      context,
      title: AppStrings.editRecordDeleteDialogTitle,
      message: AppStrings.editRecordDeleteDialogMessage,
    );
    if (!confirmed || !mounted) return;
    await repository.deleteRecord(widget.record!.record.id);
    if (!mounted) return;
    Navigator.pop(context);
    messenger.showSnackBar(
      const SnackBar(content: Text(AppStrings.recordDeleted)),
    );
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
    final colors = context.appColors;
    final canSave = _forms.values.any((f) => f.enabled) && !_saving;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? AppStrings.editRecordTitle : AppStrings.addRecordTitle,
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: AppInsets.screen,
            children: [
              LabeledField(
                label: AppStrings.addRecordDateTime,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadii.input),
                  onTap: _pickDateTime,
                  child: InputDecorator(
                    decoration: const InputDecoration(),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 20,
                          color: colors.textMuted,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(localizations.formatShortDate(_occurredAt)),
                        const Spacer(),
                        Text(formatHourMinute(_occurredAt)),
                        const SizedBox(width: AppSpacing.sm),
                        Icon(
                          Icons.access_time,
                          size: 20,
                          color: colors.textMuted,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              for (final type in EventType.values) ...[
                Divider(
                  height: AppSpacing.md * 2,
                  thickness: 1,
                  color: colors.border,
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(
                    () => _forms[type]!.enabled = !_forms[type]!.enabled,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: AppSizes.cuteIcon,
                        height: AppSizes.cuteIcon,
                        decoration: BoxDecoration(
                          color: colors.cuteIconBackground,
                          borderRadius: BorderRadius.circular(
                            AppRadii.cuteIcon,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            type.icon,
                            style: AppTypography.emojiIcon,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(type.label, style: AppTypography.bodyBold),
                      ),
                      AppSwitch(
                        value: _forms[type]!.enabled,
                        onChanged: (value) =>
                            setState(() => _forms[type]!.enabled = value),
                      ),
                    ],
                  ),
                ),
                if (_forms[type]!.enabled) ...[
                  const SizedBox(height: AppSpacing.md),
                  _DetailFields(
                    type: type,
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
              ],
              if (_isEditing)
                Align(
                  alignment: Alignment.center,
                  child: TextButton.icon(
                    onPressed: _saving ? null : _delete,
                    style: TextButton.styleFrom(foregroundColor: colors.danger),
                    icon: const Icon(Icons.delete_outline, size: 22),
                    label: const Text(AppStrings.editRecordDelete),
                  ),
                ),
            ],
          ),
          // Save stays docked above the footer; the form scrolls beneath it.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: colors.background,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: PrimaryButton(
                expand: true,
                onPressed: canSave ? _save : null,
                child: Text(
                  _isEditing
                      ? AppStrings.editRecordSave
                      : AppStrings.addRecordSave,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Description and tags for one event type of the record being created.
class _DetailFields extends StatelessWidget {
  const _DetailFields({
    required this.type,
    required this.descriptionLabel,
    required this.descriptionHint,
    required this.description,
    required this.tagLabel,
    required this.tags,
    required this.onAddTag,
    required this.onRemoveTag,
  });

  final EventType type;
  final String descriptionLabel;
  final String descriptionHint;
  final TextEditingController description;
  final String tagLabel;
  final List<Tag> tags;
  final ValueChanged<String> onAddTag;
  final ValueChanged<Tag> onRemoveTag;

  @override
  Widget build(BuildContext context) {
    return Column(
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
        TagInputField(
          label: tagLabel,
          type: type,
          selectedTags: tags,
          onSubmitted: onAddTag,
        ),
        TagChips(tags: tags, onRemove: onRemoveTag),
      ],
    );
  }
}
