import 'package:flutter/material.dart';

import '../../../data/db/app_database.dart';
import '../../../data/models/event_type.dart';
import '../../../data/models/tag_models.dart';
import '../../localization/app_strings.dart';
import '../../scope/app_scope.dart';
import '../../theme/theme.dart';
import '../../util/color_hex.dart';
import '../../widgets/widgets.dart';

/// Creates a tag of [type] when [tag] is null, edits it otherwise.
///
/// The color is set on a single row: a tappable swatch that opens the HSV
/// [showColorPickerDialog], next to a free hex field with live preview. An
/// invalid hex marks the field in red and disables saving.
class EditTagDialog extends StatefulWidget {
  const EditTagDialog({
    super.key,
    this.tag,
    required this.type,
    required this.initialColorHex,
  });

  final Tag? tag;
  final EventType type;
  final String initialColorHex;

  @override
  State<EditTagDialog> createState() => _EditTagDialogState();
}

class _EditTagDialogState extends State<EditTagDialog> {
  late final _name = TextEditingController(text: widget.tag?.name ?? '');
  late final _hex = TextEditingController(
    text: widget.tag?.colorHex ?? widget.initialColorHex,
  );
  String? _error;

  bool get _hexValid => tryColorFromHex(_hex.text) != null;

  @override
  void dispose() {
    _name.dispose();
    _hex.dispose();
    super.dispose();
  }

  Future<void> _pickColor() async {
    final current = colorFromHex(
      _hex.text,
      fallback: context.appColors.tagFallback,
    );
    final picked = await showColorPickerDialog(context, initialColor: current);
    if (picked != null && mounted) {
      setState(() => _hex.text = hexFromColor(picked));
    }
  }

  Future<void> _save() async {
    final repository = AppScope.of(context).tagRepository;
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = AppStrings.editTagNameRequired);
      return;
    }
    try {
      if (widget.tag == null) {
        await repository.createTag(
          name: name,
          type: widget.type,
          colorHex: _hex.text,
        );
      } else {
        await repository.updateTag(
          id: widget.tag!.id,
          name: name,
          colorHex: _hex.text,
        );
      }
    } on DuplicateTagException {
      setState(() => _error = AppStrings.editTagDuplicate);
      return;
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final repository = AppScope.of(context).tagRepository;
    final confirmed = await showConfirmDialog(
      context,
      title: AppStrings.editTagDeleteDialogTitle,
      message: AppStrings.editTagDeleteDialogMessage,
    );
    if (!confirmed || !mounted) return;
    await repository.deleteTags([widget.tag!.id]);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Dialog(
      child: Padding(
        padding: AppInsets.modal,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ModalTitle(
                widget.tag == null
                    ? AppStrings.editTagNewTitle
                    : AppStrings.editTagEditTitle,
              ),
              LabeledField(
                label: AppStrings.editTagName,
                child: TextField(controller: _name),
              ),
              LabeledField(
                label: AppStrings.editTagColor,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(AppRadii.swatch),
                      onTap: _pickColor,
                      child: TagDot(
                        colorHex: _hex.text,
                        size: AppSizes.colorSwatch,
                        radius: AppRadii.swatch,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.rowGap),
                    Expanded(
                      child: TextField(
                        controller: _hex,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          errorText: _hexValid
                              ? null
                              : AppStrings.editTagColorInvalid,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_error != null)
                Text(
                  _error!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall!.copyWith(color: colors.danger),
                ),
              ModalActions(
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(AppStrings.cancel),
                  ),
                  PrimaryButton(
                    onPressed: _hexValid ? _save : null,
                    child: const Text(AppStrings.editTagSave),
                  ),
                ],
              ),
              if (widget.tag != null)
                Align(
                  alignment: Alignment.center,
                  child: TextButton.icon(
                    onPressed: _delete,
                    style: TextButton.styleFrom(
                      foregroundColor: colors.danger,
                    ),
                    icon: const Icon(Icons.delete_outline, size: 22),
                    label: const Text(AppStrings.editTagDelete),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
