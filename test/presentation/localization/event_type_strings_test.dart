import 'package:flutter_test/flutter_test.dart';
import 'package:peepoop_log/data/models/event_type.dart';
import 'package:peepoop_log/presentation/localization/app_strings.dart';
import 'package:peepoop_log/presentation/localization/event_type_strings.dart';
import 'package:peepoop_log/presentation/theme/app_symbols.dart';

void main() {
  group('EventTypeStrings for urination', () {
    test('exposes the urination copy and glyph', () {
      expect(EventType.urination.label, AppStrings.urination);
      expect(EventType.urination.icon, AppSymbols.urination);
      expect(
        EventType.urination.descriptionLabel,
        AppStrings.urinationDescription,
      );
      expect(
        EventType.urination.descriptionHint,
        AppStrings.urinationDescriptionHint,
      );
      expect(EventType.urination.tagsLabel, AppStrings.urinationTags);
    });
  });

  group('EventTypeStrings for defecation', () {
    test('exposes the defecation copy and glyph', () {
      expect(EventType.defecation.label, AppStrings.defecation);
      expect(EventType.defecation.icon, AppSymbols.defecation);
      expect(
        EventType.defecation.descriptionLabel,
        AppStrings.defecationDescription,
      );
      expect(
        EventType.defecation.descriptionHint,
        AppStrings.defecationDescriptionHint,
      );
      expect(EventType.defecation.tagsLabel, AppStrings.defecationTags);
    });
  });
}
