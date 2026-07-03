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
      final record = await _db
          .into(_db.records)
          .insertReturning(_draftCompanion(draft));
      await _insertAssociations(record.id, draft);
      return record.id;
    });
  }

  /// Replaces every editable field and the tag associations of the record.
  Future<void> updateRecord(int id, RecordDraft draft) {
    return _db.transaction(() async {
      _validateShape(draft);
      await _validateTagTypes(draft);
      final updated = await (_db.update(
        _db.records,
      )..where((r) => r.id.equals(id))).write(_draftCompanion(draft));
      if (updated == 0) {
        throw StateError('record $id does not exist');
      }
      await (_db.delete(
        _db.recordTags,
      )..where((rt) => rt.recordId.equals(id))).go();
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

  Stream<List<RecordWithTags>> watchRecords({
    RecordFilter filter = const RecordFilter(),
  }) {
    return _buildQuery(filter).watch().map(_groupRows);
  }

  Future<List<RecordWithTags>> getRecords({
    RecordFilter filter = const RecordFilter(),
  }) async {
    return _groupRows(await _buildQuery(filter).get());
  }

  Future<RecordWithTags?> getRecord(int id) async {
    final query = _buildQuery(const RecordFilter())
      ..where(_db.records.id.equals(id));
    final grouped = _groupRows(await query.get());
    return grouped.isEmpty ? null : grouped.single;
  }

  JoinedSelectStatement<HasResultSet, dynamic> _buildQuery(
    RecordFilter filter,
  ) {
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
        ..where(
          _db.recordTags.tagId.isIn(filter.tagIds) &
              _db.recordTags.recordId.equalsExp(_db.records.id),
        );
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
    final tagsByType = <int, Map<EventType, List<Tag>>>{};

    for (final row in rows) {
      final record = row.readTable(_db.records);
      if (!records.containsKey(record.id)) {
        records[record.id] = record;
        order.add(record.id);
        tagsByType[record.id] = {for (final type in EventType.values) type: []};
      }
      final tag = row.readTableOrNull(_db.tags);
      if (tag != null) {
        tagsByType[record.id]![tag.type]!.add(tag);
      }
    }

    return [
      for (final id in order)
        RecordWithTags(record: records[id]!, tagsByType: tagsByType[id]!),
    ];
  }

  void _validateShape(RecordDraft draft) {
    if (draft.details.isEmpty) {
      throw ArgumentError(
        'a record must include urination, defecation, or both',
      );
    }
  }

  Future<void> _validateTagTypes(RecordDraft draft) async {
    for (final entry in draft.details.entries) {
      await _checkTagsMatchType(entry.value.tagIds, entry.key);
    }
  }

  Future<void> _checkTagsMatchType(List<int> ids, EventType expected) async {
    if (ids.isEmpty) return;
    final unique = ids.toSet().toList();
    final tags = await (_db.select(
      _db.tags,
    )..where((t) => t.id.isIn(unique))).get();
    if (tags.length != unique.length) {
      throw ArgumentError('unknown tag id among $unique');
    }
    final mismatched = tags.where((t) => t.type != expected).toList();
    if (mismatched.isNotEmpty) {
      throw ArgumentError(
        'tags [${mismatched.map((t) => t.name).join(', ')}] are not ${expected.name} tags',
      );
    }
  }

  RecordsCompanion _draftCompanion(RecordDraft draft) {
    final urination = draft.details[EventType.urination];
    final defecation = draft.details[EventType.defecation];
    return RecordsCompanion(
      occurredAt: Value(draft.occurredAt),
      hasUrination: Value(urination != null),
      hasDefecation: Value(defecation != null),
      urinationDescription: Value(_cleanDescription(urination?.description)),
      defecationDescription: Value(_cleanDescription(defecation?.description)),
    );
  }

  Future<void> _insertAssociations(int recordId, RecordDraft draft) async {
    final tagIds = {for (final detail in draft.details.values) ...detail.tagIds};
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
