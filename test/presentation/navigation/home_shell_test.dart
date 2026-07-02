import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peepoop_log/data/db/app_database.dart';
import 'package:peepoop_log/data/repositories/record_repository.dart';
import 'package:peepoop_log/data/repositories/tag_repository.dart';
import 'package:peepoop_log/presentation/navigation/home_shell.dart';
import 'package:peepoop_log/presentation/scope/app_scope.dart';
import 'package:peepoop_log/presentation/theme/theme.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  Future<void> pumpShell(WidgetTester tester) async {
    await tester.pumpWidget(
      AppScope(
        recordRepository: RecordRepository(db),
        tagRepository: TagRepository(db),
        child: MaterialApp(theme: AppTheme.light(), home: const HomeShell()),
      ),
    );
    await tester.pump();
  }

  Finder appBarTitle(String title) =>
      find.descendant(of: find.byType(AppBar), matching: find.text(title));

  testWidgets('starts on the Add Record screen', (tester) async {
    await pumpShell(tester);

    expect(appBarTitle('Add Record'), findsOneWidget);
  });

  testWidgets('bottom nav switches between the root screens', (tester) async {
    await pumpShell(tester);

    final destinations = [
      HomeDestination.history,
      HomeDestination.tags,
      HomeDestination.export,
      HomeDestination.settings,
    ];

    for (final destination in destinations) {
      await tester.tap(find.text(destination.title).last);
      await tester.pump();

      expect(appBarTitle(destination.title), findsOneWidget);
    }
  });

  testWidgets('central plus button returns to Add Record', (tester) async {
    await pumpShell(tester);

    await tester.tap(find.text(HomeDestination.history.title));
    await tester.pump();
    expect(appBarTitle('Add Record'), findsNothing);

    await tester.tap(find.text('+'));
    await tester.pump();

    expect(appBarTitle('Add Record'), findsOneWidget);
  });
}
