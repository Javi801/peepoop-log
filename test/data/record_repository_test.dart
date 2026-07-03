import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peepoop_log/data/db/app_database.dart';
import 'package:peepoop_log/data/models/event_type.dart';
import 'package:peepoop_log/data/models/record_models.dart';
import 'package:peepoop_log/data/repositories/record_repository.dart';
import 'package:peepoop_log/data/repositories/tag_repository.dart';

void main() {
  late AppDatabase db;
  late RecordRepository repository;
  late TagRepository tags;

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase(NativeDatabase.memory());
    repository = RecordRepository(db);
    tags = TagRepository(db);
  });

  tearDown(() => db.close());

  group('createRecord', () {
    test('persists the record with tags split by event type', () async {
      final yellow = await tags.ensureTag('yellow', EventType.urination);
      final smell = await tags.ensureTag('smell', EventType.defecation);

      final id = await repository.createRecord(
        RecordDraft(
          occurredAt: DateTime.utc(2026, 6, 19, 8, 30),
          details: {
            EventType.urination: EventDetail(
              description: 'pee note',
              tagIds: [yellow.id],
            ),
            EventType.defecation: EventDetail(
              description: 'poop note',
              tagIds: [smell.id],
            ),
          },
        ),
      );

      final saved = await repository.getRecord(id);
      expect(saved, isNotNull);
      expect(saved!.record.hasUrination, isTrue);
      expect(saved.record.hasDefecation, isTrue);
      expect(saved.record.urinationDescription, 'pee note');
      expect(saved.record.defecationDescription, 'poop note');
      expect(saved.tagsFor(EventType.urination).map((t) => t.id), [yellow.id]);
      expect(saved.tagsFor(EventType.defecation).map((t) => t.id), [smell.id]);
    });

    test('normalizes blank descriptions to null', () async {
      final id = await repository.createRecord(
        RecordDraft(
          occurredAt: DateTime.utc(2026, 6, 19),
          details: {EventType.urination: EventDetail(description: '   ')},
        ),
      );

      final saved = await repository.getRecord(id);
      expect(saved!.record.urinationDescription, isNull);
    });

    test('rejects a record with no event type', () async {
      await expectLater(
        repository.createRecord(
          RecordDraft(occurredAt: DateTime.utc(2026, 6, 19)),
        ),
        throwsArgumentError,
      );
    });

    test('rejects tags whose type does not match the detail', () async {
      final smell = await tags.ensureTag('smell', EventType.defecation);
      await expectLater(
        repository.createRecord(
          RecordDraft(
            occurredAt: DateTime.utc(2026, 6, 19),
            details: {
              EventType.urination: EventDetail(tagIds: [smell.id]),
            },
          ),
        ),
        throwsArgumentError,
      );
    });

    test('rejects unknown tag ids', () async {
      await expectLater(
        repository.createRecord(
          RecordDraft(
            occurredAt: DateTime.utc(2026, 6, 19),
            details: {
              EventType.urination: EventDetail(tagIds: [123]),
            },
          ),
        ),
        throwsArgumentError,
      );
    });
  });

  group('updateRecord', () {
    test('replaces fields and tag associations', () async {
      final yellow = await tags.ensureTag('yellow', EventType.urination);
      final urgent = await tags.ensureTag('urgent', EventType.urination);
      final id = await repository.createRecord(
        RecordDraft(
          occurredAt: DateTime.utc(2026, 6, 19, 8, 30),
          details: {
            EventType.urination: EventDetail(
              description: 'before',
              tagIds: [yellow.id],
            ),
          },
        ),
      );

      await repository.updateRecord(
        id,
        RecordDraft(
          occurredAt: DateTime.utc(2026, 6, 20, 9, 0),
          details: {
            EventType.urination: EventDetail(
              description: 'after',
              tagIds: [urgent.id],
            ),
          },
        ),
      );

      final saved = await repository.getRecord(id);
      expect(saved!.record.occurredAt.toUtc(), DateTime.utc(2026, 6, 20, 9, 0));
      expect(saved.record.urinationDescription, 'after');
      expect(saved.tagsFor(EventType.urination).map((t) => t.id), [urgent.id]);
    });

    test('clears details when an event type is deselected', () async {
      final yellow = await tags.ensureTag('yellow', EventType.urination);
      final id = await repository.createRecord(
        RecordDraft(
          occurredAt: DateTime.utc(2026, 6, 19),
          details: {
            EventType.urination: EventDetail(
              description: 'pee note',
              tagIds: [yellow.id],
            ),
            EventType.defecation: const EventDetail(),
          },
        ),
      );

      await repository.updateRecord(
        id,
        RecordDraft(
          occurredAt: DateTime.utc(2026, 6, 19),
          details: {EventType.defecation: const EventDetail()},
        ),
      );

      final saved = await repository.getRecord(id);
      expect(saved!.record.hasUrination, isFalse);
      expect(saved.record.urinationDescription, isNull);
      expect(saved.tagsFor(EventType.urination), isEmpty);
    });

    test('throws for a record that does not exist', () async {
      await expectLater(
        repository.updateRecord(
          999,
          RecordDraft(
            occurredAt: DateTime.utc(2026, 6, 19),
            details: {EventType.urination: const EventDetail()},
          ),
        ),
        throwsStateError,
      );
    });
  });

  group('filters', () {
    late int peeOnly;
    late int poopOnly;
    late int mixed;
    late Tag yellow;
    late Tag smell;

    setUp(() async {
      yellow = await tags.ensureTag('yellow', EventType.urination);
      smell = await tags.ensureTag('smell', EventType.defecation);

      peeOnly = await repository.createRecord(
        RecordDraft(
          occurredAt: DateTime.utc(2026, 6, 19, 8, 0),
          details: {
            EventType.urination: EventDetail(tagIds: [yellow.id]),
          },
        ),
      );
      poopOnly = await repository.createRecord(
        RecordDraft(
          occurredAt: DateTime.utc(2026, 6, 20, 12, 0),
          details: {
            EventType.defecation: EventDetail(tagIds: [smell.id]),
          },
        ),
      );
      mixed = await repository.createRecord(
        RecordDraft(
          occurredAt: DateTime.utc(2026, 6, 21, 18, 0),
          details: {
            EventType.urination: const EventDetail(),
            EventType.defecation: const EventDetail(),
          },
        ),
      );
    });

    Future<List<int>> idsFor(RecordFilter filter) async {
      final result = await repository.getRecords(filter: filter);
      return result.map((r) => r.record.id).toList();
    }

    test('returns everything ordered by occurred_at descending', () async {
      expect(await idsFor(const RecordFilter()), [mixed, poopOnly, peeOnly]);
    });

    test('hides records containing a disabled event type', () async {
      expect(await idsFor(const RecordFilter(includeDefecation: false)), [
        peeOnly,
      ]);
      expect(await idsFor(const RecordFilter(includeUrination: false)), [
        poopOnly,
      ]);
    });

    test('filters by date range inclusively', () async {
      expect(
        await idsFor(
          RecordFilter(
            from: DateTime.utc(2026, 6, 20),
            to: DateTime.utc(2026, 6, 20, 23, 59),
          ),
        ),
        [poopOnly],
      );
    });

    test('matches records having any of the selected tags', () async {
      expect(await idsFor(RecordFilter(tagIds: [yellow.id, smell.id])), [
        poopOnly,
        peeOnly,
      ]);
    });

    test('combines filters', () async {
      expect(
        await idsFor(
          RecordFilter(
            includeDefecation: false,
            from: DateTime.utc(2026, 6, 19),
            tagIds: [yellow.id],
          ),
        ),
        [peeOnly],
      );
    });

    test('watchRecords emits the current state on listen', () async {
      final emitted = await repository.watchRecords().first;
      expect(emitted.map((r) => r.record.id), [mixed, poopOnly, peeOnly]);
    });
  });

  group('deletes', () {
    test('deletes selected records and all records', () async {
      final a = await repository.createRecord(
        RecordDraft(
          occurredAt: DateTime.utc(2026, 6, 19),
          details: {EventType.urination: const EventDetail()},
        ),
      );
      final b = await repository.createRecord(
        RecordDraft(
          occurredAt: DateTime.utc(2026, 6, 20),
          details: {EventType.urination: const EventDetail()},
        ),
      );

      await repository.deleteRecord(a);
      expect((await repository.getRecords()).map((r) => r.record.id), [b]);

      await repository.deleteAllRecords();
      expect(await repository.getRecords(), isEmpty);
    });

    test('deleteAllData clears records and tags', () async {
      final yellow = await tags.ensureTag('yellow', EventType.urination);
      await repository.createRecord(
        RecordDraft(
          occurredAt: DateTime.utc(2026, 6, 19),
          details: {
            EventType.urination: EventDetail(tagIds: [yellow.id]),
          },
        ),
      );

      await repository.deleteAllData();

      expect(await repository.getRecords(), isEmpty);
      expect(await db.select(db.tags).get(), isEmpty);
    });
  });
}
