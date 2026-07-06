import 'package:flutter/material.dart';

import '../localization/app_strings.dart';
import '../theme/theme.dart';
import '../util/color_hex.dart';
import 'app_buttons.dart';
import 'app_modal.dart';
import 'tag_dot.dart';

/// Opens the HSV color picker as a modal dialog, returning the chosen color
/// or null when dismissed.
Future<Color?> showColorPickerDialog(
  BuildContext context, {
  required Color initialColor,
}) {
  return showDialog<Color>(
    context: context,
    builder: (_) => _ColorPickerDialog(initialColor: initialColor),
  );
}

/// Saturation/value plane plus a rainbow hue bar with draggable handles.
class _ColorPickerDialog extends StatefulWidget {
  const _ColorPickerDialog({required this.initialColor});

  final Color initialColor;

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late HSVColor _hsv = HSVColor.fromColor(widget.initialColor).withAlpha(1);

  Color get _color => _hsv.toColor();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: AppInsets.modal,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ModalTitle(AppStrings.colorPickerTitle),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _SaturationValueArea(
                  hsv: _hsv,
                  onChanged: (saturation, value) => setState(
                    () => _hsv = _hsv.withSaturation(saturation).withValue(value),
                  ),
                ),
                const SizedBox(width: AppSpacing.rowGap),
                _HueSlider(
                  hue: _hsv.hue,
                  onChanged: (hue) => setState(() => _hsv = _hsv.withHue(hue)),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.fieldGap),
            Row(
              children: [
                TagDot(
                  colorHex: hexFromColor(_color),
                  size: AppSizes.tagDot,
                  radius: AppRadii.swatch,
                ),
                const SizedBox(width: AppSpacing.rowGap),
                Text(
                  hexFromColor(_color),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            ModalActions(
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(AppStrings.cancel),
                ),
                PrimaryButton(
                  onPressed: () => Navigator.pop(context, _color),
                  child: const Text(AppStrings.colorPickerSelect),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The white→hue horizontal / transparent→black vertical gradient square.
class _SaturationValueArea extends StatelessWidget {
  const _SaturationValueArea({required this.hsv, required this.onChanged});

  final HSVColor hsv;
  final void Function(double saturation, double value) onChanged;

  static const double _width = AppSizes.colorPickerArea;
  static const double _height = AppSizes.colorPickerAreaHeight;

  void _handle(Offset position) {
    final saturation = (position.dx / _width).clamp(0.0, 1.0);
    final value = 1 - (position.dy / _height).clamp(0.0, 1.0);
    onChanged(saturation, value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hueColor = HSVColor.fromAHSV(1, hsv.hue, 1, 1).toColor();
    final borderRadius = BorderRadius.circular(AppRadii.colorPicker);

    return GestureDetector(
      onTapDown: (details) => _handle(details.localPosition),
      onPanStart: (details) => _handle(details.localPosition),
      onPanUpdate: (details) => _handle(details.localPosition),
      child: SizedBox(
        width: _width,
        height: _height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                border: Border.all(color: colors.swatchBorder),
                gradient: LinearGradient(
                  colors: [Colors.white, hueColor],
                ),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black],
                  ),
                ),
                child: const SizedBox.expand(),
              ),
            ),
            Positioned(
              left: hsv.saturation * _width - AppSizes.colorPickerHandle / 2,
              top:
                  (1 - hsv.value) * _height - AppSizes.colorPickerHandle / 2,
              child: _PickerHandle(fill: hsv.toColor()),
            ),
          ],
        ),
      ),
    );
  }
}

/// The vertical rainbow bar controlling hue.
class _HueSlider extends StatelessWidget {
  const _HueSlider({required this.hue, required this.onChanged});

  final double hue;
  final void Function(double hue) onChanged;

  static const double _height = AppSizes.colorPickerAreaHeight;

  void _handle(Offset position) {
    onChanged((position.dy / _height).clamp(0.0, 1.0) * 360);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final borderRadius = BorderRadius.circular(AppRadii.colorPicker);

    return GestureDetector(
      onTapDown: (details) => _handle(details.localPosition),
      onPanStart: (details) => _handle(details.localPosition),
      onPanUpdate: (details) => _handle(details.localPosition),
      child: SizedBox(
        width: AppSizes.hueSliderWidth,
        height: _height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                border: Border.all(color: colors.swatchBorder),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    for (var h = 0; h <= 360; h += 60)
                      HSVColor.fromAHSV(1, h.toDouble() % 360, 1, 1).toColor(),
                  ],
                ),
              ),
              child: const SizedBox.expand(),
            ),
            Positioned(
              left: -AppSizes.colorPickerHandle / 2 +
                  AppSizes.hueSliderWidth / 2,
              top: hue / 360 * _height - AppSizes.colorPickerHandle / 2,
              child: _PickerHandle(
                fill: HSVColor.fromAHSV(1, hue, 1, 1).toColor(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Movable circle marking the current selection on a picker surface.
class _PickerHandle extends StatelessWidget {
  const _PickerHandle({required this.fill});

  final Color fill;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.colorPickerHandle,
      height: AppSizes.colorPickerHandle,
      decoration: BoxDecoration(
        color: fill,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: context.appDecorations.buttonShadow,
      ),
    );
  }
}
