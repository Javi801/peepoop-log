import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:peepoop_log/presentation/util/color_hex.dart';

void main() {
  group('tryColorFromHex', () {
    test('parses 6-digit hex with and without leading #', () {
      expect(tryColorFromHex('#FFE8A3'), const Color(0xFFFFE8A3));
      expect(tryColorFromHex('ffe8a3'), const Color(0xFFFFE8A3));
      expect(tryColorFromHex('  #CfEeFf '), const Color(0xFFCFEEFF));
    });

    test('returns null for invalid values', () {
      expect(tryColorFromHex(''), isNull);
      expect(tryColorFromHex('#FFF'), isNull);
      expect(tryColorFromHex('#GGGGGG'), isNull);
      expect(tryColorFromHex('#FFE8A3FF'), isNull);
    });
  });

  test('colorFromHex falls back on invalid input', () {
    const fallback = Color(0xFF123456);

    expect(colorFromHex('#D9F2C7', fallback: fallback),
        const Color(0xFFD9F2C7));
    expect(colorFromHex('not-a-color', fallback: fallback), fallback);
  });
}
