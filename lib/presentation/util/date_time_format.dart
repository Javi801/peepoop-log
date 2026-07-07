/// Zero-padded 24h `HH:mm`, used where the design reference shows times.
String formatHourMinute(DateTime dateTime) {
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

const _monthAbbreviations = <String>[
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', //
];

/// Abbreviated `Mon D, YYYY` (e.g. `Jun 1, 2026`), used in the date-range
/// filter field.
String formatMonthDayYear(DateTime date) =>
    '${_monthAbbreviations[date.month - 1]} ${date.day}, ${date.year}';
