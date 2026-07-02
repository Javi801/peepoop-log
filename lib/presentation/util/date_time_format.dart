/// Zero-padded 24h `HH:mm`, used where the design reference shows times.
String formatHourMinute(DateTime dateTime) {
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
