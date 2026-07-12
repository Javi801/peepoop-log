import 'package:flutter_test/flutter_test.dart';
import 'package:peepoop_log/data/db/app_database.dart';
import 'package:peepoop_log/data/models/event_type.dart';
import 'package:peepoop_log/data/models/record_models.dart';

Tag _tag(int id, String name, {EventType type = EventType.urination}) => Tag(
  id: id,
  name: name,
  normalizedName: name.toLowerCase(),
  type: type,
  colorHex: '#FFE8A3',
);

RecordRow _record({
  bool urination = false,
  bool defecation = false,
  String? urinationDescription,
  String? defecationDescription,
}) => RecordRow(
  id: 1,
  occurredAt: DateTime(2026, 6, 1, 8, 30),
  hasUrination: urination,
  hasDefecation: defecation,
  urinationDescription: urinationDescription,
  defecationDescription: defecationDescription,
);

void main() {
  group('RecordRowEvents.has', () {
    test('maps each event type to its column', () {
      final row = _record(urination: true, defecation: false);
      expect(row.has(EventType.urination), isTrue);
      expect(row.has(EventType.defecation), isFalse);
    });
  });

  group('RecordRowEvents.descriptionFor', () {
    test('maps each event type to its description column', () {
      final row = _record(
        urinationDescription: 'pee note',
        defecationDescription: 'poop note',
      );
      expect(row.descriptionFor(EventType.urination), 'pee note');
      expect(row.descriptionFor(EventType.defecation), 'poop note');
    });

    test('returns null when a description is absent', () {
      final row = _record(urinationDescription: 'only pee');
      expect(row.descriptionFor(EventType.defecation), isNull);
    });
  });

  group('RecordWithTags.tagsFor', () {
    test('returns the tags stored for a type', () {
      final tag = _tag(1, 'urgent');
      final entry = RecordWithTags(
        record: _record(urination: true),
        tagsByType: {
          EventType.urination: [tag],
        },
      );
      expect(entry.tagsFor(EventType.urination), [tag]);
    });

    test('returns an empty list for a type with no entry', () {
      final entry = RecordWithTags(
        record: _record(urination: true),
        tagsByType: const {},
      );
      expect(entry.tagsFor(EventType.defecation), isEmpty);
    });
  });

  group('RecordFilter', () {
    test('defaults include both event types and newest-first sort', () {
      const filter = RecordFilter();
      expect(filter.includeUrination, isTrue);
      expect(filter.includeDefecation, isTrue);
      expect(filter.from, isNull);
      expect(filter.to, isNull);
      expect(filter.tagIds, isEmpty);
      expect(filter.sort, RecordSort.newestFirst);
    });
  });
}
