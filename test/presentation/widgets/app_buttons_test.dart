import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peepoop_log/presentation/theme/theme.dart';
import 'package:peepoop_log/presentation/widgets/widgets.dart';

Widget wrap(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  home: Scaffold(body: child),
);

void main() {
  testWidgets('PrimaryButton fires onPressed', (tester) async {
    var pressed = false;
    await tester.pumpWidget(
      wrap(
        PrimaryButton(
          onPressed: () => pressed = true,
          child: const Text('Save Record'),
        ),
      ),
    );

    await tester.tap(find.text('Save Record'));

    expect(pressed, isTrue);
  });

  testWidgets('disabled PrimaryButton is dimmed and inert', (tester) async {
    await tester.pumpWidget(
      wrap(const PrimaryButton(onPressed: null, child: Text('Save Record'))),
    );

    await tester.tap(find.text('Save Record'));

    final opacity = tester.widget<Opacity>(
      find.ancestor(
        of: find.text('Save Record'),
        matching: find.byType(Opacity),
      ),
    );
    expect(opacity.opacity, lessThan(1));
  });

  testWidgets('SecondaryButton and DangerButton fire onPressed', (
    tester,
  ) async {
    final pressed = <String>[];
    await tester.pumpWidget(
      wrap(
        Column(
          children: [
            SecondaryButton(
              onPressed: () => pressed.add('secondary'),
              child: const Text('Filters'),
            ),
            DangerButton(
              onPressed: () => pressed.add('danger'),
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.text('Filters'));
    await tester.tap(find.text('Delete'));

    expect(pressed, ['secondary', 'danger']);
  });
}
