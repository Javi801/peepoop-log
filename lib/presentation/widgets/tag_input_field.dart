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

/// Text field that submits tag names via the keyboard action or the "+"
/// button, clearing itself after each submission. As the user types it
/// suggests existing tags of [type] in a dropdown; selecting one submits it.
class TagInputField extends StatefulWidget {
  const TagInputField({
    super.key,
    required this.label,
    required this.type,
    required this.onSubmitted,
    this.selectedTags = const [],
  });

  final String label;

  /// Event type whose tags feed the suggestion dropdown.
  final EventType type;

  /// Tags already added to the record; excluded from the suggestions.
  final List<Tag> selectedTags;

  /// Called with the trimmed, non-empty tag name.
  final ValueChanged<String> onSubmitted;

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
    widget.onSubmitted(name);
    _controller.clear();
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
              widget.onSubmitted(tag.name);
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
