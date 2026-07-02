import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peepoop_log/data/db/app_database.dart';
import 'package:peepoop_log/data/repositories/record_repository.dart';
import 'package:peepoop_log/data/repositories/tag_repository.dart';
import 'package:peepoop_log/presentation/scope/app_scope.dart';
import 'package:peepoop_log/presentation/screens/add_record/add_record_screen.dart';
import 'package:peepoop_log/presentation/theme/theme.dart';
import 'package:peepoop_log/presentation/widgets/widgets.dart';

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
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const AddRecordScreen(),
        ),
      );

  testWidgets('saves a urination record with description and tag, then resets',
      (tester) async {
    await tester.pumpWidget(app());

    await tester.enterText(find.byType(TextField).first, 'No discomfort.');
    await tester.enterText(
      find.descendant(
        of: find.byType(TagInputField),
        matching: find.byType(TextField),
      ),
      'light yellow',
    );
    await tester.tap(find.byTooltip('Add tag'));
    await tester.pump();

    expect(find.byType(TagChip), findsOneWidget);

    await tester.ensureVisible(find.text('Save Record'));
    await tester.tap(find.text('Save Record'));
    await tester.pumpAndSettle();

    expect(find.text('Record saved'), findsOneWidget);

    final saved = await records.getRecords();
    expect(saved, hasLength(1));
    expect(saved.single.record.hasUrination, isTrue);
    expect(saved.single.record.hasDefecation, isFalse);
    expect(saved.single.record.urinationDescription, 'No discomfort.');
    expect(saved.single.urinationTags.map((t) => t.name), ['light yellow']);

    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      isEmpty,
    );
    expect(find.byType(TagChip), findsNothing);

    // Let the snackbar expire so no timers are pending at teardown.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('defecation section appears when toggled', (tester) async {
    await tester.pumpWidget(app());

    expect(find.text('Defecation description'), findsNothing);

    await tester.tap(find.text('Defecation'));
    await tester.pump();

    expect(find.text('Defecation description'), findsOneWidget);
  });

  testWidgets('save is disabled with both event types off', (tester) async {
    await tester.pumpWidget(app());

    await tester.tap(find.text('Urination'));
    await tester.pump();

    await tester.ensureVisible(find.text('Save Record'));
    await tester.tap(find.text('Save Record'));
    await tester.pumpAndSettle();

    expect(find.text('Record saved'), findsNothing);
    expect(await records.getRecords(), isEmpty);
  });
}
