import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peepoop_log/presentation/theme/theme.dart';
import 'package:peepoop_log/presentation/widgets/widgets.dart';

Widget wrap(Widget child) =>
    MaterialApp(theme: AppTheme.light(), home: Scaffold(body: child));

void main() {
  testWidgets('renders icon and label', (tester) async {
    await tester.pumpWidget(wrap(
      ToggleCard(
        label: 'Urination',
        icon: '💧',
        value: false,
        onChanged: (_) {},
      ),
    ));

    expect(find.text('Urination'), findsOneWidget);
    expect(find.text('💧'), findsOneWidget);
  });

  testWidgets('tapping the card reports the toggled value', (tester) async {
    bool? reported;
    await tester.pumpWidget(wrap(
      ToggleCard(
        label: 'Urination',
        icon: '💧',
        value: false,
        onChanged: (value) => reported = value,
      ),
    ));

    await tester.tap(find.text('Urination'));

    expect(reported, isTrue);
  });

  testWidgets('tapping the switch also toggles', (tester) async {
    bool? reported;
    await tester.pumpWidget(wrap(
      ToggleCard(
        label: 'Defecation',
        icon: '💩',
        value: true,
        onChanged: (value) => reported = value,
      ),
    ));

    await tester.tap(find.byType(AppSwitch));

    expect(reported, isFalse);
  });
}
