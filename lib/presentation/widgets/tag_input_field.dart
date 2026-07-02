import 'package:flutter/material.dart';

import '../localization/app_strings.dart';
import 'labeled_field.dart';

/// Text field that submits tag names via the keyboard action or the "+"
/// button, clearing itself after each submission.
class TagInputField extends StatefulWidget {
  const TagInputField({
    super.key,
    required this.label,
    required this.onSubmitted,
  });

  final String label;

  /// Called with the trimmed, non-empty tag name.
  final ValueChanged<String> onSubmitted;

  @override
  State<TagInputField> createState() => _TagInputFieldState();
}

class _TagInputFieldState extends State<TagInputField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    widget.onSubmitted(name);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LabeledField(
      label: widget.label,
      child: TextField(
        controller: _controller,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          hintText: AppStrings.tagInputHint,
          suffixIcon: IconButton(
            onPressed: _submit,
            tooltip: AppStrings.tagInputAddTooltip,
            icon: Icon(Icons.add, color: colorScheme.onPrimaryContainer),
          ),
        ),
      ),
    );
  }
}
