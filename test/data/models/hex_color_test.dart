import 'package:flutter_test/flutter_test.dart';
import 'package:peepoop_log/data/models/hex_color.dart';

void main() {
  group('tryNormalizeHexColor', () {
    test('uppercases and prefixes a bare 6-digit value', () {
      expect(tryNormalizeHexColor('a1b2c3'), '#A1B2C3');
    });

    test('keeps an already prefixed value and uppercases it', () {
      expect(tryNormalizeHexColor('#a1b2c3'), '#A1B2C3');
    });

    test('trims surrounding whitespace', () {
      expect(tryNormalizeHexColor('  #CfEeFf '), '#CFEEFF');
    });

    test('returns null for values that are not 6-digit hex', () {
      expect(tryNormalizeHexColor(''), isNull);
      expect(tryNormalizeHexColor('#FFF'), isNull);
      expect(tryNormalizeHexColor('#GGGGGG'), isNull);
      expect(tryNormalizeHexColor('#A1B2C3FF'), isNull);
      expect(tryNormalizeHexColor('not-a-color'), isNull);
    });
  });
}
