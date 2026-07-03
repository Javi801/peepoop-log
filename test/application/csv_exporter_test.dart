import 'package:flutter_test/flutter_test.dart';
import 'package:peepoop_log/application/csv_exporter.dart';
import 'package:peepoop_log/data/db/app_database.dart';
import 'package:peepoop_log/data/models/event_type.dart';
import 'package:peepoop_log/data/models/record_models.dart';

Tag tag(int id, String name, {EventType type = EventType.urination}) => Tag(
  id: id,
  name: name,
  normalizedName: name.toLowerCase(),
  type: type,
  colorHex: '#FFE8A3',
);

RecordRow record({
  required DateTime occurredAt,
  bool urination = false,
  bool defecation = false,
  String? urinationDescription,
  String? defecationDescription,
}) => RecordRow(
  id: 1,
  occurredAt: occurredAt,
  hasUrination: urination,
  hasDefecation: defecation,
  urinationDescription: urinationDescription,
  defecationDescription: defecationDescription,
);

void main() {
  const exporter = CsvExporter();

  test('exports the header only when there are no records', () {
    expect(exporter.buildCsv([]), 'occurred_at,type,description,tags');
  });

  test('exports one row per event with semicolon-separated tags', () {
    final csv = exporter.buildCsv([
      RecordWithTags(
        record: record(
          occurredAt: DateTime(2026, 6, 19, 8, 30),
          urination: true,
          defecation: true,
          urinationDescription: 'Light description',
          defecationDescription: 'Another description',
        ),
        tagsByType: {
          EventType.urination: [tag(1, 'tag1'), tag(2, 'tag2')],
          EventType.defecation: [tag(3, 'tag3', type: EventType.defecation)],
        },
      ),
    ]);

    expect(csv, '''
occurred_at,type,description,tags
2026-06-19T08:30:00,urination,"Light description","tag1;tag2"
2026-06-19T08:30:00,defecation,"Another description","tag3"''');
  });

  test('omits rows for unselected event types', () {
    final csv = exporter.buildCsv([
      RecordWithTags(
        record: record(
          occurredAt: DateTime(2026, 6, 21, 22, 10),
          urination: true,
        ),
        tagsByType: const {},
      ),
    ]);

    expect(csv, '''
occurred_at,type,description,tags
2026-06-21T22:10:00,urination,"",""''');
  });

  test('escapes double quotes and preserves commas in descriptions', () {
    final csv = exporter.buildCsv([
      RecordWithTags(
        record: record(
          occurredAt: DateTime(2026, 1, 2, 3, 4, 5),
          urination: true,
          urinationDescription: 'He said "ouch", twice',
        ),
        tagsByType: {
          EventType.urination: [tag(1, 'a,b')],
        },
      ),
    ]);

    expect(
      csv.split('\n')[1],
      '2026-01-02T03:04:05,urination,"He said ""ouch"", twice","a,b"',
    );
  });
}
