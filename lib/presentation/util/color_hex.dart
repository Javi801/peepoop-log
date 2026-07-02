import 'dart:ui';

/// Parses `A1B2C3` or `#A1B2C3` in any casing into an opaque [Color].
///
/// Returns null when the value is not a 6-digit hex color, mirroring the
/// leniency of `TagRepository.normalizeHexColor` without throwing: stored
/// tag colors may predate validation.
Color? tryColorFromHex(String value) {
  final match = RegExp(r'^#?([0-9a-fA-F]{6})$').firstMatch(value.trim());
  if (match == null) return null;
  return Color(0xFF000000 | int.parse(match[1]!, radix: 16));
}

Color colorFromHex(String value, {required Color fallback}) =>
    tryColorFromHex(value) ?? fallback;
