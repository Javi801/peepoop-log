import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../models/event_type.dart';

part 'app_database.g.dart';

@DataClassName('RecordRow')
@TableIndex(name: 'idx_records_occurred_at', columns: {#occurredAt})
class Records extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get occurredAt => dateTime()();
  BoolColumn get hasUrination => boolean().withDefault(const Constant(false))();
  BoolColumn get hasDefecation =>
      boolean().withDefault(const Constant(false))();
  TextColumn get urinationDescription => text().nullable()();
  TextColumn get defecationDescription => text().nullable()();

  @override
  List<String> get customConstraints => [
        'CHECK (has_urination = 1 OR has_defecation = 1)',
        'CHECK (has_urination = 1 OR urination_description IS NULL)',
        'CHECK (has_defecation = 1 OR defecation_description IS NULL)',
      ];
}

class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get normalizedName => text()();
  TextColumn get type => textEnum<EventType>()();
  TextColumn get colorHex => text()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {normalizedName, type},
      ];

  @override
  List<String> get customConstraints => [
        'CHECK (length(trim(name)) > 0)',
        "CHECK (type IN ('urination', 'defecation'))",
      ];
}

@TableIndex(name: 'idx_record_tags_tag', columns: {#tagId})
class RecordTags extends Table {
  IntColumn get recordId =>
      integer().references(Records, #id, onDelete: KeyAction.cascade)();
  IntColumn get tagId =>
      integer().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {recordId, tagId};
}

@DriftDatabase(tables: [Records, Tags, RecordTags])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  AppDatabase.open() : super(driftDatabase(name: 'peepoop_log'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        beforeOpen: (details) async {
          // SQLite ships with foreign keys disabled; without this the ON
          // DELETE CASCADE clauses are ignored.
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
