import '../db/app_database.dart';
import 'event_type.dart';

/// Description and tag ids for a single event type within a record.
class EventDetail {
  const EventDetail({this.description, this.tagIds = const []});

  final String? description;
  final List<int> tagIds;
}

/// Input for creating or fully updating a record. A record contains an event
/// type if and only if [details] has an entry for it; that entry carries the
/// type's description and tag ids, so details for an unselected type are
/// unrepresentable.
class RecordDraft {
  const RecordDraft({required this.occurredAt, this.details = const {}});

  final DateTime occurredAt;
  final Map<EventType, EventDetail> details;
}

class RecordWithTags {
  const RecordWithTags({required this.record, required this.tagsByType});

  final RecordRow record;
  final Map<EventType, List<Tag>> tagsByType;

  List<Tag> tagsFor(EventType type) => tagsByType[type] ?? const [];
}

/// Per-event-type access to the columnar record row, so callers can iterate
/// [EventType.values] instead of branching on each generated column.
extension RecordRowEvents on RecordRow {
  bool has(EventType type) => switch (type) {
    EventType.urination => hasUrination,
    EventType.defecation => hasDefecation,
  };

  String? descriptionFor(EventType type) => switch (type) {
    EventType.urination => urinationDescription,
    EventType.defecation => defecationDescription,
  };
}

/// Combinable history filters.
///
/// Event type semantics: a record is visible only when every event type it
/// contains is enabled, so with [includeUrination] off, a mixed
/// urination+defecation record is hidden too. Tag semantics: a record matches
/// when it has at least one of [tagIds], in either event type.
class RecordFilter {
  const RecordFilter({
    this.includeUrination = true,
    this.includeDefecation = true,
    this.from,
    this.to,
    this.tagIds = const [],
  });

  final bool includeUrination;
  final bool includeDefecation;
  final DateTime? from;
  final DateTime? to;
  final List<int> tagIds;
}
