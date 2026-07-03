import '../../data/models/event_type.dart';
import '../theme/app_symbols.dart';
import 'app_strings.dart';

/// Per-event-type copy and glyphs, so screens can iterate [EventType.values]
/// instead of branching per type.
extension EventTypeStrings on EventType {
  String get label => switch (this) {
    EventType.urination => AppStrings.urination,
    EventType.defecation => AppStrings.defecation,
  };

  String get icon => switch (this) {
    EventType.urination => AppSymbols.urination,
    EventType.defecation => AppSymbols.defecation,
  };

  String get descriptionLabel => switch (this) {
    EventType.urination => AppStrings.urinationDescription,
    EventType.defecation => AppStrings.defecationDescription,
  };

  String get descriptionHint => switch (this) {
    EventType.urination => AppStrings.urinationDescriptionHint,
    EventType.defecation => AppStrings.defecationDescriptionHint,
  };

  String get tagsLabel => switch (this) {
    EventType.urination => AppStrings.urinationTags,
    EventType.defecation => AppStrings.defecationTags,
  };
}
