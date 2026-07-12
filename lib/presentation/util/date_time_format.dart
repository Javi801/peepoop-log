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

/// Whole calendar days between the [date] and [reference], ignoring the time
/// of day. `0` when they fall on the same day, `1` when [date] is the day
/// before [reference], and so on.
int calendarDaysAgo(DateTime date, DateTime reference) {
  final d = DateTime(date.year, date.month, date.day);
  final r = DateTime(reference.year, reference.month, reference.day);
  return r.difference(d).inDays;
}
