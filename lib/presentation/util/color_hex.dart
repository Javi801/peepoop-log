import 'dart:ui';

import '../../data/models/hex_color.dart';

/// Parses `A1B2C3` or `#A1B2C3` in any casing into an opaque [Color].
///
/// Shares the canonical parser with `TagRepository.normalizeHexColor` but
/// returns null instead of throwing: stored tag colors may predate
/// validation.
Color? tryColorFromHex(String value) {
  final normalized = tryNormalizeHexColor(value);
  if (normalized == null) return null;
  return Color(0xFF000000 | int.parse(normalized.substring(1), radix: 16));
}

Color colorFromHex(String value, {required Color fallback}) =>
    tryColorFromHex(value) ?? fallback;
