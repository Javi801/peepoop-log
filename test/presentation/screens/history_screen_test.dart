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
import 'package:peepoop_log/presentation/screens/history/history_screen.dart';
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

  Future<void> seed() async {
    final urgent = await tags.createTag(
      name: 'urgent',
      type: EventType.urination,
      colorHex: '#FFD3D3',
    );
    await records.createRecord(
      RecordDraft(
        occurredAt: DateTime(2026, 6, 22, 8, 30),
        hasUrination: true,
        urinationDescription: 'Slight urgency.',
        urinationTagIds: [urgent.id],
      ),
    );
    await records.createRecord(
      RecordDraft(
        occurredAt: DateTime(2026, 6, 21, 22, 10),
        hasDefecation: true,
      ),
    );
  }

  Widget app() => AppScope(
    recordRepository: records,
    tagRepository: tags,
    child: MaterialApp(theme: AppTheme.light(), home: const HistoryScreen()),
  );

  testWidgets('shows records with time, type, tags and description', (
    tester,
  ) async {
    await seed();
    await tester.pumpWidget(app());
    await tester.pump();

    expect(find.text('08:30'), findsOneWidget);
    expect(find.text('Urination'), findsOneWidget);
    expect(find.text('urgent'), findsOneWidget);
    expect(find.text('Slight urgency.'), findsOneWidget);
    expect(find.text('22:10'), findsOneWidget);
    expect(find.text('Defecation'), findsOneWidget);
  });

  testWidgets('shows the empty state without records', (tester) async {
    await tester.pumpWidget(app());
    await tester.pump();

    expect(find.text('No records found.'), findsOneWidget);
  });

  testWidgets('event type filters hide matching records', (tester) async {
    await seed();
    await tester.pumpWidget(app());
    await tester.pump();

    await tester.tap(find.text('Filters'));
    await tester.pumpAndSettle();

    // The sheet overlays the list, so its toggles are the last matches.
    await tester.tap(find.text('Urination').last);
    await tester.pump();
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(find.text('urgent'), findsNothing);
    expect(find.text('Defecation'), findsOneWidget);

    await tester.tap(find.text('Filters'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Defecation').last);
    await tester.pump();
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(find.text('No records found.'), findsOneWidget);
  });

  testWidgets('clear resets the filters in the sheet', (tester) async {
    await seed();
    await tester.pumpWidget(app());
    await tester.pump();

    await tester.tap(find.text('Filters'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Urination').last);
    await tester.pump();
    await tester.tap(find.text('Clear'));
    await tester.pump();
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(find.text('Urination'), findsOneWidget);
    expect(find.text('Defecation'), findsOneWidget);
  });
}
