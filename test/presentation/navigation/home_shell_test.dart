import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peepoop_log/presentation/navigation/home_shell.dart';
import 'package:peepoop_log/presentation/theme/theme.dart';

void main() {
  Future<void> pumpShell(WidgetTester tester) {
    return tester.pumpWidget(
      MaterialApp(theme: AppTheme.light(), home: const HomeShell()),
    );
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
      await tester.tap(find.text(destination.title));
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
