import 'package:flutter/material.dart';

import '../theme/theme.dart';
import 'labeled_field.dart';

/// [showDatePicker] with the app-wide selectable date range.
Future<DateTime?> showAppDatePicker(
  BuildContext context, {
  required DateTime initialDate,
}) {
  return showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );
}

/// [showDateRangePicker] with the app-wide selectable date range; opens the
/// classic calendar that highlights every day between the two picked dates.
Future<DateTimeRange?> showAppDateRangePicker(
  BuildContext context, {
  DateTimeRange? initialRange,
}) {
  return showDateRangePicker(
    context: context,
    initialDateRange: initialRange,
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );
}

/// Read-only labeled input that opens a picker when tapped.
class PickerField extends StatelessWidget {
  const PickerField({
    super.key,
    required this.label,
    required this.text,
    required this.onTap,
  });

  final String label;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LabeledField(
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.input),
        onTap: onTap,
        child: InputDecorator(
          decoration: const InputDecoration(),
          child: Text(text),
        ),
      ),
    );
  }
}
