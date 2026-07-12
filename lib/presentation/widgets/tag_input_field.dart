import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/db/app_database.dart';
import '../../data/models/event_type.dart';
import '../../data/repositories/tag_repository.dart';
import '../localization/app_strings.dart';
import '../scope/app_scope.dart';
import '../theme/theme.dart';
import 'labeled_field.dart';
import 'tag_dot.dart';

/// Text field that submits tags via the keyboard action or the "+" button,
/// clearing itself after each submission. As the user types it suggests
/// existing tags of [type] in a dropdown; selecting one submits it.
///
/// Submitting resolves the entered name to a [Tag]: an existing tag of [type]
/// when the name matches one, otherwise a transient tag (id `0`) with a preview
/// color that is only persisted when the record is saved.
class TagInputField extends StatefulWidget {
  const TagInputField({
    super.key,
    required this.label,
    required this.type,
    required this.onAdd,
    this.selectedTags = const [],
  });

  final String label;

  /// Event type whose tags feed the suggestion dropdown.
  final EventType type;

  /// Tags already added to the record; excluded from the suggestions.
  final List<Tag> selectedTags;

  /// Called with the resolved tag; the tag has id `0` when it does not yet
  /// exist in the database.
  final ValueChanged<Tag> onAdd;

  @override
  State<TagInputField> createState() => _TagInputFieldState();
}

class _TagInputFieldState extends State<TagInputField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  StreamSubscription<List<Tag>>? _subscription;
  List<Tag> _tags = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _subscription?.cancel();
    _subscription = AppScope.of(context).tagRepository
        .watchTagsByType(widget.type)
        .listen((tags) => setState(() => _tags = tags));
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    widget.onAdd(_resolve(name));
    _controller.clear();
  }

  /// Matches [name] to an existing tag of this type, reusing its id and color.
  /// When nothing matches, returns a transient tag (id `0`) with a preview
  /// color, so it can be shown as a chip without touching the database; it is
  /// created only when the record is saved.
  Tag _resolve(String name) {
    final normalized = TagRepository.normalizeName(name);
    for (final tag in _tags) {
      if (tag.normalizedName == normalized) return tag;
    }
    return Tag(
      id: 0,
      name: name,
      normalizedName: normalized,
      type: widget.type,
      colorHex: AppScope.of(context).tagRepository.randomColor(),
    );
  }

  Iterable<Tag> _suggestions(String value) {
    final query = TagRepository.normalizeName(value);
    if (query.isEmpty) return const Iterable<Tag>.empty();
    final selectedIds = {for (final tag in widget.selectedTags) tag.id};
    return _tags.where(
      (tag) =>
          !selectedIds.contains(tag.id) && tag.normalizedName.contains(query),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return LabeledField(
      label: widget.label,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return RawAutocomplete<Tag>(
            textEditingController: _controller,
            focusNode: _focusNode,
            optionsBuilder: (value) => _suggestions(value.text),
            displayStringForOption: (tag) => tag.name,
            onSelected: (tag) {
              widget.onAdd(tag);
              _controller.clear();
            },
            fieldViewBuilder: (context, controller, focusNode, _) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  hintText: AppStrings.tagInputHint,
                  suffixIcon: IconButton(
                    onPressed: _submit,
                    tooltip: AppStrings.tagInputAddTooltip,
                    icon: Icon(
                      Icons.add,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  color: colors.surface,
                  elevation: 4,
                  borderRadius: BorderRadius.circular(AppRadii.input),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 220,
                      maxWidth: constraints.maxWidth,
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final tag = options.elementAt(index);
                        return InkWell(
                          onTap: () => onSelected(tag),
                          child: Padding(
                            padding: AppInsets.input,
                            child: Row(
                              children: [
                                TagDot(colorHex: tag.colorHex),
                                const SizedBox(width: AppSpacing.rowGap),
                                Expanded(
                                  child: Text(
                                    tag.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
