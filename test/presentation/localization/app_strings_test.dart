import 'package:flutter_test/flutter_test.dart';
import 'package:peepoop_log/presentation/localization/app_strings.dart';

void main() {
  group('AppStrings.recordTypeLabel', () {
    test('names both types when the record has both', () {
      expect(
        AppStrings.recordTypeLabel(hasUrination: true, hasDefecation: true),
        AppStrings.urinationAndDefecation,
      );
    });

    test('names urination when only urination is present', () {
      expect(
        AppStrings.recordTypeLabel(hasUrination: true, hasDefecation: false),
        AppStrings.urination,
      );
    });

    test('names defecation when urination is absent', () {
      expect(
        AppStrings.recordTypeLabel(hasUrination: false, hasDefecation: true),
        AppStrings.defecation,
      );
    });
  });

  group('AppStrings.tagUsageCount', () {
    test('formats the count with a uses suffix', () {
      expect(AppStrings.tagUsageCount(0), '0 uses');
      expect(AppStrings.tagUsageCount(5), '5 uses');
    });
  });
}
