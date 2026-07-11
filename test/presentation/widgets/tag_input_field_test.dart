import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peepoop_log/data/db/app_database.dart';
import 'package:peepoop_log/data/models/event_type.dart';
import 'package:peepoop_log/data/repositories/record_repository.dart';
import 'package:peepoop_log/data/repositories/tag_repository.dart';
import 'package:peepoop_log/presentation/scope/app_scope.dart';
import 'package:peepoop_log/presentation/theme/theme.dart';
import 'package:peepoop_log/presentation/widgets/widgets.dart';

void main() {
  late AppDatabase db;
  late RecordRepository records;
  late TagRepository tags;
  late List<String> submitted;

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase(NativeDatabase.memory());
    records = RecordRepository(db);
    tags = TagRepository(db);
    submitted = [];
  });

  tearDown(() => db.close());

  Widget field() => AppScope(
    recordRepository: records,
    tagRepository: tags,
    child: MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: TagInputField(
          label: 'Urination tags',
          type: EventType.urination,
          onSubmitted: submitted.add,
        ),
      ),
    ),
  );

  String fieldText(WidgetTester tester) =>
      tester.widget<TextField>(find.byType(TextField)).controller!.text;

  testWidgets('keyboard action submits the trimmed name and clears the field', (
    tester,
  ) async {
    await tester.pumpWidget(field());

    await tester.enterText(find.byType(TextField), '  light yellow ');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(submitted, ['light yellow']);
    expect(fieldText(tester), isEmpty);
  });

  testWidgets('the + button submits too', (tester) async {
    await tester.pumpWidget(field());

    await tester.enterText(find.byType(TextField), 'urgent');
    await tester.tap(find.byTooltip('Add tag'));
    await tester.pump();

    expect(submitted, ['urgent']);
    expect(fieldText(tester), isEmpty);
  });

  testWidgets('blank input is ignored', (tester) async {
    await tester.pumpWidget(field());

    await tester.enterText(find.byType(TextField), '   ');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.tap(find.byTooltip('Add tag'));
    await tester.pump();

    expect(submitted, isEmpty);
  });

  testWidgets('typing shows matching existing tags in a dropdown', (
    tester,
  ) async {
    await tags.createTag(name: 'light yellow', type: EventType.urination, reuseExisting: true);
    await tags.createTag(name: 'dark yellow', type: EventType.urination, reuseExisting: true);
    await tags.createTag(name: 'urgent', type: EventType.urination, reuseExisting: true);

    await tester.pumpWidget(field());
    await tester.pump(); // let the tags stream deliver.

    await tester.enterText(find.byType(TextField), 'yellow');
    await tester.pump();

    expect(find.text('light yellow'), findsOneWidget);
    expect(find.text('dark yellow'), findsOneWidget);
    expect(find.text('urgent'), findsNothing);
  });

  testWidgets('selecting a suggestion submits it and clears the field', (
    tester,
  ) async {
    await tags.createTag(name: 'light yellow', type: EventType.urination, reuseExisting: true);

    await tester.pumpWidget(field());
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'light');
    await tester.pump();

    await tester.tap(find.text('light yellow'));
    await tester.pump();

    expect(submitted, ['light yellow']);
    expect(fieldText(tester), isEmpty);
  });
}
