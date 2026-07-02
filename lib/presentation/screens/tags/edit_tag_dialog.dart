import 'package:flutter/material.dart';

import '../../../data/db/app_database.dart';
import '../../../data/models/event_type.dart';
import '../../../data/models/tag_models.dart';
import '../../../data/repositories/tag_repository.dart';
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
      setState(() => _error = 'Tag name is required.');
      return;
    }
    if (tryColorFromHex(_hex.text) == null) {
      setState(() => _error = 'Color must be a 6-digit hex value.');
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
      setState(() => _error = 'Tag already exists.');
      return;
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Dialog(
      child: Padding(
        padding: AppInsets.modal,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ModalTitle(widget.tag == null ? 'New Tag' : 'Edit Tag'),
              LabeledField(
                label: 'Name',
                child: TextField(controller: _name),
              ),
              LabeledField(
                label: 'Color',
                child: Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    for (final hex in TagRepository.defaultPalette)
                      _PaletteSwatch(
                        hex: hex,
                        selected: _hex.text.toUpperCase() == hex,
                        onTap: () => setState(() => _hex.text = hex),
                      ),
                  ],
                ),
              ),
              LabeledField(
                label: 'Hexadecimal color',
                child: Row(
                  children: [
                    Container(
                      width: AppSizes.colorSwatch,
                      height: AppSizes.colorSwatch,
                      decoration: BoxDecoration(
                        color: colorFromHex(
                          _hex.text,
                          fallback: colors.tagFallback,
                        ),
                        borderRadius: BorderRadius.circular(AppRadii.swatch),
                        border: Border.all(color: colors.swatchBorder),
                      ),
                    ),
                    const SizedBox(width: 12),
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
                    child: const Text('Cancel'),
                  ),
                  PrimaryButton(onPressed: _save, child: const Text('Save')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaletteSwatch extends StatelessWidget {
  const _PaletteSwatch({
    required this.hex,
    required this.selected,
    required this.onTap,
  });

  final String hex;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.tagDot),
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: colorFromHex(hex, fallback: colors.tagFallback),
          borderRadius: BorderRadius.circular(AppRadii.tagDot),
          border: Border.all(
            color: selected ? colors.primaryDark : colors.swatchBorder,
            width: selected ? 2 : 1,
          ),
        ),
      ),
    );
  }
}
