import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../models/event_type.dart';
import '../models/record_models.dart';

class RecordRepository {
  RecordRepository(this._db);

  final AppDatabase _db;

  Future<int> createRecord(RecordDraft draft) {
    return _db.transaction(() async {
      _validateShape(draft);
      await _validateTagTypes(draft);
      final record =
          await _db.into(_db.records).insertReturning(RecordsCompanion.insert(
                occurredAt: draft.occurredAt,
                hasUrination: Value(draft.hasUrination),
                hasDefecation: Value(draft.hasDefecation),
                urinationDescription:
                    Value(_cleanDescription(draft.urinationDescription)),
                defecationDescription:
                    Value(_cleanDescription(draft.defecationDescription)),
              ));
      await _insertAssociations(record.id, draft);
      return record.id;
    });
  }

  /// Replaces every editable field and the tag associations of the record.
  Future<void> updateRecord(int id, RecordDraft draft) {
    return _db.transaction(() async {
      _validateShape(draft);
      await _validateTagTypes(draft);
      final updated =
          await (_db.update(_db.records)..where((r) => r.id.equals(id)))
              .write(RecordsCompanion(
        occurredAt: Value(draft.occurredAt),
        hasUrination: Value(draft.hasUrination),
        hasDefecation: Value(draft.hasDefecation),
        urinationDescription:
            Value(_cleanDescription(draft.urinationDescription)),
        defecationDescription:
            Value(_cleanDescription(draft.defecationDescription)),
      ));
      if (updated == 0) {
        throw StateError('record $id does not exist');
      }
      await (_db.delete(_db.recordTags)..where((rt) => rt.recordId.equals(id)))
          .go();
      await _insertAssociations(id, draft);
    });
  }

  Future<void> deleteRecord(int id) => deleteRecords([id]);

  Future<void> deleteRecords(Iterable<int> ids) async {
    await (_db.delete(_db.records)..where((r) => r.id.isIn(ids.toList()))).go();
  }

  Future<void> deleteAllRecords() async {
    await _db.delete(_db.records).go();
  }

  /// Settings "delete all app data": removes records and tags.
  Future<void> deleteAllData() {
    return _db.transaction(() async {
      await _db.delete(_db.records).go();
      await _db.delete(_db.tags).go();
    });
  }

  Stream<List<RecordWithTags>> watchRecords(
      {RecordFilter filter = const RecordFilter()}) {
    return _buildQuery(filter).watch().map(_groupRows);
  }

  Future<List<RecordWithTags>> getRecords(
      {RecordFilter filter = const RecordFilter()}) async {
    return _groupRows(await _buildQuery(filter).get());
  }

  Future<RecordWithTags?> getRecord(int id) async {
    final query = _buildQuery(const RecordFilter())
      ..where(_db.records.id.equals(id));
    final grouped = _groupRows(await query.get());
    return grouped.isEmpty ? null : grouped.single;
  }

  JoinedSelectStatement<HasResultSet, dynamic> _buildQuery(
      RecordFilter filter) {
    final query = _db.select(_db.records).join([
      leftOuterJoin(
        _db.recordTags,
        _db.recordTags.recordId.equalsExp(_db.records.id),
      ),
      leftOuterJoin(_db.tags, _db.tags.id.equalsExp(_db.recordTags.tagId)),
    ]);

    if (!filter.includeUrination) {
      query.where(_db.records.hasUrination.equals(false));
    }
    if (!filter.includeDefecation) {
      query.where(_db.records.hasDefecation.equals(false));
    }
    if (filter.from != null) {
      query.where(_db.records.occurredAt.isBiggerOrEqualValue(filter.from!));
    }
    if (filter.to != null) {
      query.where(_db.records.occurredAt.isSmallerOrEqualValue(filter.to!));
    }
    if (filter.tagIds.isNotEmpty) {
      final matching = _db.selectOnly(_db.recordTags)
        ..addColumns([_db.recordTags.recordId])
        ..where(_db.recordTags.tagId.isIn(filter.tagIds) &
            _db.recordTags.recordId.equalsExp(_db.records.id));
      query.where(existsQuery(matching));
    }

    query.orderBy([
      OrderingTerm.desc(_db.records.occurredAt),
      OrderingTerm.desc(_db.records.id),
      OrderingTerm.asc(_db.tags.normalizedName),
    ]);
    return query;
  }

  List<RecordWithTags> _groupRows(List<TypedResult> rows) {
    final order = <int>[];
    final records = <int, RecordRow>{};
    final urinationTags = <int, List<Tag>>{};
    final defecationTags = <int, List<Tag>>{};

    for (final row in rows) {
      final record = row.readTable(_db.records);
      if (!records.containsKey(record.id)) {
        records[record.id] = record;
        order.add(record.id);
        urinationTags[record.id] = [];
        defecationTags[record.id] = [];
      }
      final tag = row.readTableOrNull(_db.tags);
      if (tag != null) {
        final target =
            tag.type == EventType.urination ? urinationTags : defecationTags;
        target[record.id]!.add(tag);
      }
    }

    return [
      for (final id in order)
        RecordWithTags(
          record: records[id]!,
          urinationTags: urinationTags[id]!,
          defecationTags: defecationTags[id]!,
        ),
    ];
  }

  void _validateShape(RecordDraft draft) {
    if (!draft.hasUrination && !draft.hasDefecation) {
      throw ArgumentError('a record must include urination, defecation, or both');
    }
    if (!draft.hasUrination &&
        (_cleanDescription(draft.urinationDescription) != null ||
            draft.urinationTagIds.isNotEmpty)) {
      throw ArgumentError('urination details require hasUrination');
    }
    if (!draft.hasDefecation &&
        (_cleanDescription(draft.defecationDescription) != null ||
            draft.defecationTagIds.isNotEmpty)) {
      throw ArgumentError('defecation details require hasDefecation');
    }
  }

  Future<void> _validateTagTypes(RecordDraft draft) async {
    await _checkTagsMatchType(draft.urinationTagIds, EventType.urination);
    await _checkTagsMatchType(draft.defecationTagIds, EventType.defecation);
  }

  Future<void> _checkTagsMatchType(List<int> ids, EventType expected) async {
    if (ids.isEmpty) return;
    final unique = ids.toSet().toList();
    final tags =
        await (_db.select(_db.tags)..where((t) => t.id.isIn(unique))).get();
    if (tags.length != unique.length) {
      throw ArgumentError('unknown tag id among $unique');
    }
    final mismatched = tags.where((t) => t.type != expected).toList();
    if (mismatched.isNotEmpty) {
      throw ArgumentError(
          'tags [${mismatched.map((t) => t.name).join(', ')}] are not ${expected.name} tags');
    }
  }

  Future<void> _insertAssociations(int recordId, RecordDraft draft) async {
    final tagIds = {...draft.urinationTagIds, ...draft.defecationTagIds};
    if (tagIds.isEmpty) return;
    await _db.batch((batch) {
      batch.insertAll(_db.recordTags, [
        for (final tagId in tagIds)
          RecordTagsCompanion.insert(recordId: recordId, tagId: tagId),
      ]);
    });
  }

  String? _cleanDescription(String? description) {
    final trimmed = description?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }
}
