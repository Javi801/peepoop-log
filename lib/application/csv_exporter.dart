import '../data/db/app_database.dart';
import '../data/models/event_type.dart';
import '../data/models/record_models.dart';

/// Builds the CSV export: one row per physiological event, so a record
/// containing both urination and defecation produces two rows.
class CsvExporter {
  const CsvExporter();

  static const fileName = 'peepoop-log-export.csv';

  String buildCsv(List<RecordWithTags> records) {
    final lines = ['occurred_at,type,description,tags'];
    for (final entry in records) {
      final record = entry.record;
      for (final type in EventType.values) {
        if (!record.has(type)) continue;
        lines.add(
          _row(
            record.occurredAt,
            type.name,
            record.descriptionFor(type),
            entry.tagsFor(type),
          ),
        );
      }
    }
    return lines.join('\n');
  }

  String _row(
    DateTime occurredAt,
    String type,
    String? description,
    List<Tag> tags,
  ) {
    final tagNames = tags.map((tag) => tag.name).join(';');
    return '${_timestamp(occurredAt)},$type,'
        '${_quote(description ?? '')},${_quote(tagNames)}';
  }

  String _quote(String value) => '"${value.replaceAll('"', '""')}"';

  /// ISO 8601 to the second, without milliseconds: `2026-06-19T08:30:00`.
  String _timestamp(DateTime dateTime) {
    String two(int n) => n.toString().padLeft(2, '0');
    final date =
        '${dateTime.year.toString().padLeft(4, '0')}'
        '-${two(dateTime.month)}-${two(dateTime.day)}';
    final time =
        '${two(dateTime.hour)}'
        ':${two(dateTime.minute)}:${two(dateTime.second)}';
    return '${date}T$time';
  }
}
