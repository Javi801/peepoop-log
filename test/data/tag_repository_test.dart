import 'dart:math';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peepoop_log/data/db/app_database.dart';
import 'package:peepoop_log/data/models/event_type.dart';
import 'package:peepoop_log/data/models/record_models.dart';
import 'package:peepoop_log/data/models/tag_models.dart';
import 'package:peepoop_log/data/repositories/record_repository.dart';
import 'package:peepoop_log/data/repositories/tag_repository.dart';

void main() {
  late AppDatabase db;
  late TagRepository repository;

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase(NativeDatabase.memory());
    repository = TagRepository(db, random: Random(1));
  });

  tearDown(() => db.close());

  group('normalizeHexColor', () {
    test('normalizes casing and missing #', () {
      expect(TagRepository.normalizeHexColor('a1b2c3'), '#A1B2C3');
      expect(TagRepository.normalizeHexColor(' #ffe8a3 '), '#FFE8A3');
    });

    test('rejects invalid values', () {
      expect(() => TagRepository.normalizeHexColor('red'), throwsArgumentError);
      expect(
        () => TagRepository.normalizeHexColor('#FFF'),
        throwsArgumentError,
      );
    });
  });

  group('createTag with reuseExisting', () {
    test(
      'creates a new tag with a random color and normalized name',
      () async {
        final tag = await repository.createTag(
          name: ' Light Yellow ',
          type: EventType.urination,
          reuseExisting: true,
        );

        expect(tag.name, 'Light Yellow');
        expect(tag.normalizedName, 'light yellow');
        expect(tag.type, EventType.urination);
        expect(tag.colorHex, matches(r'^#[0-9A-F]{6}$'));
      },
    );

    test('reuses an existing tag ignoring case and whitespace', () async {
      final original = await repository.createTag(name: 'pain', type: EventType.urination, reuseExisting: true);
      final reused = await repository.createTag(name: '  PAIN ', type: EventType.urination, reuseExisting: true);

      expect(reused.id, original.id);
      expect(await db.select(db.tags).get(), hasLength(1));
    });

    test('creates independent tags per event type', () async {
      final pee = await repository.createTag(name: 'pain', type: EventType.urination, reuseExisting: true);
      final poop = await repository.createTag(name: 'pain', type: EventType.defecation, reuseExisting: true);

      expect(pee.id, isNot(poop.id));
    });

    test('rejects empty names', () async {
      await expectLater(
        repository.createTag(name: '  ', type: EventType.urination, reuseExisting: true),
        throwsArgumentError,
      );
    });
  });

  group('createTag', () {
    test(
      'throws DuplicateTagException on same normalized name and type',
      () async {
        await repository.createTag(name: 'pain', type: EventType.urination);
        await expectLater(
          repository.createTag(name: ' Pain ', type: EventType.urination),
          throwsA(isA<DuplicateTagException>()),
        );
      },
    );

    test('stores a normalized explicit color', () async {
      final tag = await repository.createTag(
        name: 'yellow',
        type: EventType.urination,
        colorHex: 'ffe8a3',
      );
      expect(tag.colorHex, '#FFE8A3');
    });
  });

  group('updateTag', () {
    test('renames and updates the normalized name', () async {
      final tag = await repository.createTag(
        name: 'pain',
        type: EventType.urination,
      );
      final renamed = await repository.updateTag(
        id: tag.id,
        name: ' Strong Pain ',
      );

      expect(renamed.name, 'Strong Pain');
      expect(renamed.normalizedName, 'strong pain');
    });

    test('rejects renaming into an existing tag of the same type', () async {
      await repository.createTag(name: 'pain', type: EventType.urination);
      final other = await repository.createTag(
        name: 'urgent',
        type: EventType.urination,
      );

      await expectLater(
        repository.updateTag(id: other.id, name: 'PAIN'),
        throwsA(isA<DuplicateTagException>()),
      );
    });

    test('allows re-saving the same tag with its own name', () async {
      final tag = await repository.createTag(
        name: 'pain',
        type: EventType.urination,
      );
      final updated = await repository.updateTag(
        id: tag.id,
        name: 'Pain',
        colorHex: '#CFEEFF',
      );

      expect(updated.id, tag.id);
      expect(updated.name, 'Pain');
      expect(updated.colorHex, '#CFEEFF');
    });
  });

  group('watchTagsWithUsage', () {
    test('orders by usage count and includes unused tags', () async {
      final records = RecordRepository(db);
      final pain = await repository.createTag(name: 'pain', type: EventType.urination, reuseExisting: true);
      final urgent = await repository.createTag(name: 'urgent', type: EventType.urination, reuseExisting: true);
      await repository.createTag(name: 'unused', type: EventType.urination, reuseExisting: true);
      await repository.createTag(name: 'poop tag', type: EventType.defecation, reuseExisting: true);

      for (var i = 0; i < 2; i++) {
        await records.createRecord(
          RecordDraft(
            occurredAt: DateTime.utc(2026, 6, 19 + i),
            details: {
              EventType.urination: EventDetail(
                tagIds: [pain.id, if (i == 0) urgent.id],
              ),
            },
          ),
        );
      }

      final usage = await repository
          .watchTagsWithUsage(EventType.urination)
          .first;

      expect(usage.map((u) => u.tag.name).toList(), [
        'pain',
        'urgent',
        'unused',
      ]);
      expect(usage.map((u) => u.usageCount).toList(), [2, 1, 0]);
    });
  });

  group('deleteTags', () {
    test('removes associations but keeps records', () async {
      final records = RecordRepository(db);
      final pain = await repository.createTag(name: 'pain', type: EventType.urination, reuseExisting: true);
      final recordId = await records.createRecord(
        RecordDraft(
          occurredAt: DateTime.utc(2026, 6, 19),
          details: {
            EventType.urination: EventDetail(tagIds: [pain.id]),
          },
        ),
      );

      await repository.deleteTags([pain.id]);

      final record = await records.getRecord(recordId);
      expect(record, isNotNull);
      expect(record!.tagsFor(EventType.urination), isEmpty);
      expect(await db.select(db.tags).get(), isEmpty);
    });
  });
}
