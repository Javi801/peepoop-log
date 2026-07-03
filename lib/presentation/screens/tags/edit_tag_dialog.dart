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
/// Replaces the native color input of the design reference with the default
/// palette as tappable swatches plus a free hex field with live preview.
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

  @override
  void dispose() {
    _name.dispose();
    _hex.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final repository = AppScope.of(context).tagRepository;
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = AppStrings.editTagNameRequired);
      return;
    }
    if (tryColorFromHex(_hex.text) == null) {
      setState(() => _error = AppStrings.editTagColorInvalid);
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
                child: Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    for (final hex in AppColors.tagPalette)
                      InkWell(
                        borderRadius: BorderRadius.circular(AppRadii.tagDot),
                        onTap: () => setState(() => _hex.text = hex),
                        child: TagDot(
                          colorHex: hex,
                          size: AppSizes.paletteSwatch,
                          selected: _hex.text.toUpperCase() == hex,
                        ),
                      ),
                  ],
                ),
              ),
              LabeledField(
                label: AppStrings.editTagHexColor,
                child: Row(
                  children: [
                    TagDot(
                      colorHex: _hex.text,
                      size: AppSizes.colorSwatch,
                      radius: AppRadii.swatch,
                    ),
                    const SizedBox(width: AppSpacing.rowGap),
                    Expanded(
                      child: TextField(
                        controller: _hex,
                        onChanged: (_) => setState(() {}),
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
                    onPressed: _save,
                    child: const Text(AppStrings.editTagSave),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
