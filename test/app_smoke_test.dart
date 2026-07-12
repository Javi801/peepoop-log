import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peepoop_log/data/db/app_database.dart';
import 'package:peepoop_log/presentation/app.dart';

import 'support/widget_cleanup.dart';

void main() {
  testWidgets('boots from the splash into the home shell', (tester) async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(PeepoopLogApp(database: db));

    expect(find.text('Loading your data...'), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('Loading your data...'), findsNothing);
    expect(find.text('Add Record'), findsOneWidget);

    // The root screens the shell keeps alive each open a Drift query stream;
    // dispose the tree in-body so their pending timers are drained before the
    // framework's end-of-test timer check.
    await unmountWidgetTree(tester);
  });
}
