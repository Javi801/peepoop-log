import 'package:flutter/material.dart';

import '../../../data/db/app_database.dart';
import '../../../data/models/event_type.dart';
import '../../../data/models/tag_models.dart';
import '../../localization/app_strings.dart';
import '../../scope/app_scope.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import 'edit_tag_dialog.dart';

/// Tag management: one tab per event type, with usage counts, an editor
/// dialog and a multi-select delete mode.
class TagsScreen extends StatefulWidget {
  const TagsScreen({super.key});

  @override
  State<TagsScreen> createState() => _TagsScreenState();
}

class _TagsScreenState extends State<TagsScreen> {
  EventType _type = EventType.urination;
  bool _deleteMode = false;
  final Set<int> _selected = {};
  Stream<List<TagWithUsage>>? _tags;

  void _setType(EventType type) {
    if (type == _type) return;
    setState(() {
      _type = type;
      _selected.clear();
      _tags = AppScope.of(context).tagRepository.watchTagsWithUsage(type);
    });
  }

  Future<void> _openEditor(Tag? tag) {
    final repository = AppScope.of(context).tagRepository;
    return showDialog<void>(
      context: context,
      builder: (_) => EditTagDialog(
        tag: tag,
        type: _type,
        initialColorHex: tag?.colorHex ?? repository.randomColor(),
      ),
    );
  }

  Future<void> _deleteSelected() async {
    final repository = AppScope.of(context).tagRepository;
    final confirmed = await showConfirmDialog(
      context,
      title: AppStrings.tagsDeleteSelectedDialogTitle,
      message: AppStrings.tagsDeleteSelectedDialogMessage,
    );
    if (!confirmed || !mounted) return;
    await repository.deleteTags(_selected.toList());
    if (!mounted) return;
    setState(() {
      _selected.clear();
      _deleteMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    _tags ??= AppScope.of(context).tagRepository.watchTagsWithUsage(_type);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.tagsTitle),
        actions: [
          Center(
            child: SecondaryButton(
              onPressed: () => setState(() {
                _deleteMode = !_deleteMode;
                _selected.clear();
              }),
              child: Text(
                _deleteMode ? AppStrings.cancel : AppStrings.tagsDelete,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Center(
            child: SecondaryButton(
              onPressed: () => _openEditor(null),
              child: const Text(AppStrings.tagsNew),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
        ],
      ),
      body: StreamBuilder<List<TagWithUsage>>(
        stream: _tags,
        builder: (context, snapshot) {
          final tags = snapshot.data;
          return ListView(
            padding: AppInsets.screen,
            children: [
              _TypeTabs(current: _type, onSelect: _setType),
              if (tags != null && tags.isEmpty)
                const EmptyState(AppStrings.tagsEmpty),
              for (final entry in tags ?? const <TagWithUsage>[])
                _TagRow(
                  entry: entry,
                  deleteMode: _deleteMode,
                  selected: _selected.contains(entry.tag.id),
                  onTap: () {
                    if (_deleteMode) {
                      setState(() {
                        _selected.contains(entry.tag.id)
                            ? _selected.remove(entry.tag.id)
                            : _selected.add(entry.tag.id);
                      });
                    } else {
                      _openEditor(entry.tag);
                    }
                  },
                ),
              if (_deleteMode)
                DangerButton(
                  onPressed: _selected.isEmpty ? null : _deleteSelected,
                  child: const Text(AppStrings.tagsDeleteSelected),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _TypeTabs extends StatelessWidget {
  const _TypeTabs({required this.current, required this.onSelect});

  final EventType current;
  final ValueChanged<EventType> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.fieldGap),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: AppStrings.tagsPee,
              selected: current == EventType.urination,
              onTap: () => onSelect(EventType.urination),
            ),
          ),
          const SizedBox(width: AppSpacing.tabGap),
          Expanded(
            child: _TabButton(
              label: AppStrings.tagsPoop,
              selected: current == EventType.defecation,
              onTap: () => onSelect(EventType.defecation),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Material(
      color: selected ? colors.primarySoft : colors.surface,
      shape: StadiumBorder(
        side: selected ? BorderSide.none : BorderSide(color: colors.border),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: AppInsets.tab,
          child: Center(
            child: Text(
              label,
              style: AppTypography.buttonLabel.copyWith(
                color: selected ? colors.primaryDark : colors.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TagRow extends StatelessWidget {
  const _TagRow({
    required this.entry,
    required this.deleteMode,
    required this.selected,
    required this.onTap,
  });

  final TagWithUsage entry;
  final bool deleteMode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final strong = AppTypography.body.copyWith(fontWeight: AppTypography.bold);

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          if (deleteMode) ...[
            Text(selected ? '✓' : '○', style: strong),
            const SizedBox(width: AppSpacing.sm),
          ],
          TagDot(colorHex: entry.tag.colorHex),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.tag.name, style: strong),
                Text(
                  AppStrings.tagUsageCount(entry.usageCount),
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (!deleteMode) Text('›', style: strong),
        ],
      ),
    );
  }
}
