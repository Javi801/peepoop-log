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
import 'package:peepoop_log/presentation/screens/tags/edit_tag_dialog.dart';
import 'package:peepoop_log/presentation/screens/tags/tags_screen.dart';
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
    await tags.createTag(
      name: 'light yellow',
      type: EventType.urination,
      colorHex: '#FFE8A3',
    );
    final urgent = await tags.createTag(
      name: 'urgent',
      type: EventType.urination,
      colorHex: '#FFD3D3',
    );
    await tags.createTag(
      name: 'normal',
      type: EventType.defecation,
      colorHex: '#D9F2C7',
    );
    await records.createRecord(
      RecordDraft(
        occurredAt: DateTime(2026, 6, 22, 8, 30),
        details: {
          EventType.urination: EventDetail(tagIds: [urgent.id]),
        },
      ),
    );
  }

  Widget app() => AppScope(
    recordRepository: records,
    tagRepository: tags,
    child: MaterialApp(theme: AppTheme.light(), home: const TagsScreen()),
  );

  Finder dialogField(int index) => find
      .descendant(
        of: find.byType(EditTagDialog),
        matching: find.byType(TextField),
      )
      .at(index);

  testWidgets('lists tags of the active tab with usage counts', (tester) async {
    unmountWidgetTreeAfterTest(tester);
    await seed();
    await tester.pumpWidget(app());
    await tester.pump();

    expect(find.text('light yellow'), findsOneWidget);
    expect(find.text('urgent'), findsOneWidget);
    expect(find.text('normal'), findsNothing);
    expect(find.text('1 uses'), findsOneWidget);
    expect(find.text('0 uses'), findsOneWidget);

    await tester.tap(find.text('Poop'));
    await tester.pump();

    expect(find.text('normal'), findsOneWidget);
    expect(find.text('urgent'), findsNothing);
  });

  testWidgets('creates a tag for the active tab from the editor', (
    tester,
  ) async {
    unmountWidgetTreeAfterTest(tester);
    await seed();
    await tester.pumpWidget(app());
    await tester.pump();

    await tester.tap(find.text('+ New Tag'));
    await tester.pumpAndSettle();

    expect(find.text('New Tag'), findsOneWidget);

    await tester.enterText(dialogField(0), 'clear');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.byType(EditTagDialog), findsNothing);
    expect(find.text('clear'), findsOneWidget);
  });

  testWidgets('rejects duplicate names within the same type', (tester) async {
    unmountWidgetTreeAfterTest(tester);
    await seed();
    await tester.pumpWidget(app());
    await tester.pump();

    await tester.tap(find.text('+ New Tag'));
    await tester.pumpAndSettle();
    await tester.enterText(dialogField(0), 'URGENT ');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Tag already exists.'), findsOneWidget);
    expect(find.byType(EditTagDialog), findsOneWidget);
  });

  testWidgets('edits a tag from its row', (tester) async {
    unmountWidgetTreeAfterTest(tester);
    await seed();
    await tester.pumpWidget(app());
    await tester.pump();

    await tester.tap(find.text('urgent'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Tag'), findsOneWidget);

    await tester.enterText(dialogField(0), 'very urgent');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('very urgent'), findsOneWidget);
    expect(find.text('urgent'), findsNothing);
  });

  testWidgets('delete mode removes the selected tags after confirmation', (
    tester,
  ) async {
    unmountWidgetTreeAfterTest(tester);
    await seed();
    await tester.pumpWidget(app());
    await tester.pump();

    await tester.tap(find.text('Delete'));
    await tester.pump();

    expect(find.text('○'), findsNWidgets(2));

    await tester.tap(find.text('urgent'));
    await tester.pump();

    expect(find.text('✓'), findsOneWidget);

    await tester.tap(find.text('Delete selected tags'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();

    expect(find.text('urgent'), findsNothing);
    expect(find.text('light yellow'), findsOneWidget);
    // Delete mode exits after deleting.
    expect(find.text('○'), findsNothing);
  });
}
