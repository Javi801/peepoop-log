import '../db/app_database.dart';

/// Input for creating or fully updating a record. Descriptions and tag ids
/// are only allowed for event types that are selected.
class RecordDraft {
  const RecordDraft({
    required this.occurredAt,
    this.hasUrination = false,
    this.hasDefecation = false,
    this.urinationDescription,
    this.defecationDescription,
    this.urinationTagIds = const [],
    this.defecationTagIds = const [],
  });

  final DateTime occurredAt;
  final bool hasUrination;
  final bool hasDefecation;
  final String? urinationDescription;
  final String? defecationDescription;
  final List<int> urinationTagIds;
  final List<int> defecationTagIds;
}

class RecordWithTags {
  const RecordWithTags({
    required this.record,
    required this.urinationTags,
    required this.defecationTags,
  });

  final RecordRow record;
  final List<Tag> urinationTags;
  final List<Tag> defecationTags;
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
