import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peepoop_log/presentation/theme/theme.dart';
import 'package:peepoop_log/presentation/widgets/widgets.dart';

void main() {
  testWidgets('showAppModalSheet shows content and returns the popped value',
      (tester) async {
    String? result;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await showAppModalSheet<String>(
                context: context,
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const ModalTitle('Filters'),
                    ModalActions(
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context, 'applied'),
                          child: const Text('Apply'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Filters'), findsOneWidget);

    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(result, 'applied');
    expect(find.text('Filters'), findsNothing);
  });
}
