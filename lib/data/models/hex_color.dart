/// Canonical format of stored tag colors: `#RRGGBB` uppercase.
library;

final _hexColor = RegExp(r'^#?([0-9a-fA-F]{6})$');

/// Normalizes `A1B2C3` or `#A1B2C3` in any casing to `#A1B2C3`, or returns
/// null when [value] is not a 6-digit hex color.
String? tryNormalizeHexColor(String value) {
  final match = _hexColor.firstMatch(value.trim());
  return match == null ? null : '#${match[1]!.toUpperCase()}';
}
