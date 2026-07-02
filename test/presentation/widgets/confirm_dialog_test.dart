import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peepoop_log/presentation/theme/theme.dart';
import 'package:peepoop_log/presentation/widgets/widgets.dart';

void main() {
  Future<void> pumpLauncher(
    WidgetTester tester,
    void Function(bool) onResult, {
    String? emoji,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                onResult(
                  await showConfirmDialog(
                    context,
                    title: 'Delete all app data?',
                    message: 'This action cannot be undone.',
                    emoji: emoji,
                  ),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('confirming resolves to true', (tester) async {
    bool? result;
    await pumpLauncher(tester, (r) => result = r);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Delete all app data?'), findsOneWidget);
    expect(find.text('This action cannot be undone.'), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(result, isTrue);
    expect(find.text('Delete all app data?'), findsNothing);
  });

  testWidgets('cancelling resolves to false', (tester) async {
    bool? result;
    await pumpLauncher(tester, (r) => result = r);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(result, isFalse);
  });

  testWidgets('dismissing the barrier counts as cancel', (tester) async {
    bool? result;
    await pumpLauncher(tester, (r) => result = r);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(result, isFalse);
  });

  testWidgets('renders the optional emoji header', (tester) async {
    await pumpLauncher(tester, (_) {}, emoji: '💩💕');

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('💩💕'), findsOneWidget);
  });
}
