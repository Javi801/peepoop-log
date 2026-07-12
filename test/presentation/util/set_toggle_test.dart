import 'package:flutter_test/flutter_test.dart';
import 'package:peepoop_log/presentation/util/set_toggle.dart';

void main() {
  group('SetToggle.toggle', () {
    test('adds the value when it is absent', () {
      final set = <int>{1, 2};
      set.toggle(3);
      expect(set, {1, 2, 3});
    });

    test('removes the value when it is present', () {
      final set = <int>{1, 2, 3};
      set.toggle(2);
      expect(set, {1, 3});
    });

    test('round-trips back to the original set', () {
      final set = <String>{'a'};
      set.toggle('b');
      set.toggle('b');
      expect(set, {'a'});
    });

    test('toggling into an empty set adds then removes', () {
      final set = <int>{};
      set.toggle(7);
      expect(set, {7});
      set.toggle(7);
      expect(set, isEmpty);
    });
  });
}
