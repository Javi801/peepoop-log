import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peepoop_log/data/db/app_database.dart';
import 'package:peepoop_log/data/models/event_type.dart';
import 'package:peepoop_log/data/models/record_models.dart';
import 'package:peepoop_log/data/repositories/record_repository.dart';
import 'package:peepoop_log/data/repositories/tag_repository.dart';
import 'package:peepoop_log/presentation/scope/app_scope.dart';
import 'package:peepoop_log/presentation/screens/settings/settings_screen.dart';
import 'package:peepoop_log/presentation/theme/theme.dart';

void main() {
  late AppDatabase db;
  late RecordRepository records;
  late TagRepository tags;

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase(NativeDatabase.memory());
    records = RecordRepository(db);
    tags = TagRepository(db);
  });

  tearDown(() => db.close());

  Widget app() => AppScope(
    recordRepository: records,
    tagRepository: tags,
    child: MaterialApp(theme: AppTheme.light(), home: const SettingsScreen()),
  );

  testWidgets('shows the privacy and about cards', (tester) async {
    await tester.pumpWidget(app());

    expect(find.text('Privacy'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);
    expect(find.textContaining('Version 0.1.0'), findsOneWidget);
  });

  testWidgets('delete all app data wipes records and tags after confirmation', (
    tester,
  ) async {
    final tag = await tags.createTag(
      name: 'urgent',
      type: EventType.urination,
      colorHex: '#FFD3D3',
    );
    await records.createRecord(
      RecordDraft(
        occurredAt: DateTime(2026, 6, 22, 8, 30),
        hasUrination: true,
        urinationTagIds: [tag.id],
      ),
    );

    await tester.pumpWidget(app());

    await tester.tap(find.text('Delete all app data'));
    await tester.pumpAndSettle();

    expect(find.text('💩💕'), findsOneWidget);
    expect(find.text('Delete all app data?'), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('All app data deleted'), findsOneWidget);
    expect(await records.getRecords(), isEmpty);
    expect(await tags.watchTagsByType(EventType.urination).first, isEmpty);

    // Let the snackbar expire so no timers are pending at teardown.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('cancelling the confirmation keeps the data', (tester) async {
    await records.createRecord(
      RecordDraft(occurredAt: DateTime(2026, 6, 22, 8, 30), hasUrination: true),
    );

    await tester.pumpWidget(app());

    await tester.tap(find.text('Delete all app data'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(await records.getRecords(), hasLength(1));
  });
}
