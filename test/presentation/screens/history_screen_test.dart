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

import '../../support/widget_cleanup.dart';

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
        details: {
          EventType.urination: EventDetail(
            description: 'Slight urgency.',
            tagIds: [urgent.id],
          ),
        },
      ),
    );
    await records.createRecord(
      RecordDraft(
        occurredAt: DateTime(2026, 6, 21, 22, 10),
        details: {EventType.defecation: const EventDetail()},
      ),
    );
  }

  Widget app() => AppScope(
    recordRepository: records,
    tagRepository: tags,
    child: MaterialApp(theme: AppTheme.light(), home: const HistoryScreen()),
  );

  Future<void> pumpApp(WidgetTester tester) => tester.pumpWidget(app());

  // The sheet body scrolls inside the modal, so its lower controls may sit
  // below the fold; scroll them into view before tapping.
  Future<void> tapSheetButton(WidgetTester tester, String label) async {
    await tester.ensureVisible(find.text(label));
    await tester.pump();
    await tester.tap(find.text(label));
  }

  Future<void> pumpModal(WidgetTester tester) async {
    await tester.pump();
    await tester.pumpAndSettle();
  }

  testWidgets('shows records with time, type and tags', (tester) async {
    await seed();
    await pumpApp(tester);
    await tester.pump();

    // Descriptions are not on the collapsed card; they live in the details
    // sheet (covered by record_details_sheet_test).
    expect(find.text('08:30'), findsOneWidget);
    expect(find.text('Urination'), findsOneWidget);
    expect(find.text('urgent'), findsOneWidget);
    expect(find.text('22:10'), findsOneWidget);
    expect(find.text('Defecation'), findsOneWidget);

    await unmountWidgetTree(tester);
  });

  testWidgets('shows the empty state without records', (tester) async {
    await pumpApp(tester);
    await tester.pump();

    expect(find.text('No records found.'), findsOneWidget);

    await unmountWidgetTree(tester);
  });

  testWidgets('event type filters hide matching records', (tester) async {
    await seed();
    await pumpApp(tester);
    await tester.pump();

    await tester.tap(find.byTooltip('Filters'));
    await pumpModal(tester);

    // The sheet overlays the list, so its toggles are the last matches.
    await tester.tap(find.text('Urination').last);
    await tester.pump();
    await tapSheetButton(tester, 'Apply');
    await pumpModal(tester);

    expect(find.text('urgent'), findsNothing);
    expect(find.text('Defecation'), findsOneWidget);

    await tester.tap(find.byTooltip('Filters'));
    await pumpModal(tester);
    await tester.tap(find.text('Defecation').last);
    await tester.pump();
    await tapSheetButton(tester, 'Apply');
    await pumpModal(tester);

    expect(find.text('No records found.'), findsOneWidget);

    await unmountWidgetTree(tester);
  });

  testWidgets('clear resets the filters in the sheet', (tester) async {
    await seed();
    await pumpApp(tester);
    await tester.pump();

    await tester.tap(find.byTooltip('Filters'));
    await pumpModal(tester);
    await tester.tap(find.text('Urination').last);
    await tester.pump();
    await tapSheetButton(tester, 'Clear');
    await tester.pump();
    await tapSheetButton(tester, 'Apply');
    await pumpModal(tester);

    expect(find.text('Urination'), findsOneWidget);
    expect(find.text('Defecation'), findsOneWidget);

    await unmountWidgetTree(tester);
  });
}
