import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peepoop_log/data/db/app_database.dart';
import 'package:peepoop_log/data/models/event_type.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  Future<int> insertRecord({
    bool urination = true,
    bool defecation = false,
    String? urinationDescription,
    String? defecationDescription,
  }) async {
    final row = await db
        .into(db.records)
        .insertReturning(
          RecordsCompanion.insert(
            occurredAt: DateTime.utc(2026, 6, 19, 8, 30),
            hasUrination: Value(urination),
            hasDefecation: Value(defecation),
            urinationDescription: Value(urinationDescription),
            defecationDescription: Value(defecationDescription),
          ),
        );
    return row.id;
  }

  Future<int> insertTag(String name, EventType type) async {
    final row = await db
        .into(db.tags)
        .insertReturning(
          TagsCompanion.insert(
            name: name,
            normalizedName: name.trim().toLowerCase(),
            type: type,
            colorHex: '#FFE8A3',
          ),
        );
    return row.id;
  }

  group('records constraints', () {
    test('rejects a record with no event type', () async {
      await expectLater(
        insertRecord(urination: false, defecation: false),
        throwsA(isA<SqliteException>()),
      );
    });

    test('rejects a urination description without urination', () async {
      await expectLater(
        insertRecord(
          urination: false,
          defecation: true,
          urinationDescription: 'orphan',
        ),
        throwsA(isA<SqliteException>()),
      );
    });

    test('rejects a defecation description without defecation', () async {
      await expectLater(
        insertRecord(defecationDescription: 'orphan'),
        throwsA(isA<SqliteException>()),
      );
    });

    test('accepts a record with both events and both descriptions', () async {
      final id = await insertRecord(
        defecation: true,
        urinationDescription: 'pee note',
        defecationDescription: 'poop note',
      );
      expect(id, isPositive);
    });
  });

  group('tags constraints', () {
    test('rejects duplicated normalized name within the same type', () async {
      await insertTag('pain', EventType.urination);
      await expectLater(
        insertTag('pain', EventType.urination),
        throwsA(isA<SqliteException>()),
      );
    });

    test('allows the same normalized name in different types', () async {
      await insertTag('pain', EventType.urination);
      final id = await insertTag('pain', EventType.defecation);
      expect(id, isPositive);
    });

    test('rejects blank tag names', () async {
      await expectLater(
        insertTag('   ', EventType.urination),
        throwsA(isA<SqliteException>()),
      );
    });
  });

  group('record_tags constraints', () {
    test('rejects a duplicated record/tag association', () async {
      final recordId = await insertRecord();
      final tagId = await insertTag('urgent', EventType.urination);
      await db
          .into(db.recordTags)
          .insert(RecordTagsCompanion.insert(recordId: recordId, tagId: tagId));
      await expectLater(
        db
            .into(db.recordTags)
            .insert(
              RecordTagsCompanion.insert(recordId: recordId, tagId: tagId),
            ),
        throwsA(isA<SqliteException>()),
      );
    });

    test('rejects associations to unknown records or tags', () async {
      await expectLater(
        db
            .into(db.recordTags)
            .insert(RecordTagsCompanion.insert(recordId: 999, tagId: 999)),
        throwsA(isA<SqliteException>()),
      );
    });

    test('deleting a record cascades to its associations', () async {
      final recordId = await insertRecord();
      final tagId = await insertTag('urgent', EventType.urination);
      await db
          .into(db.recordTags)
          .insert(RecordTagsCompanion.insert(recordId: recordId, tagId: tagId));

      await (db.delete(db.records)..where((r) => r.id.equals(recordId))).go();

      expect(await db.select(db.recordTags).get(), isEmpty);
      expect(await db.select(db.tags).get(), hasLength(1));
    });

    test('deleting a tag cascades to associations but keeps records', () async {
      final recordId = await insertRecord();
      final tagId = await insertTag('urgent', EventType.urination);
      await db
          .into(db.recordTags)
          .insert(RecordTagsCompanion.insert(recordId: recordId, tagId: tagId));

      await (db.delete(db.tags)..where((t) => t.id.equals(tagId))).go();

      expect(await db.select(db.recordTags).get(), isEmpty);
      expect(await db.select(db.records).get(), hasLength(1));
    });
  });
}
