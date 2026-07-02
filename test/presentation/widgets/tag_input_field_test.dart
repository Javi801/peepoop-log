import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peepoop_log/presentation/theme/theme.dart';
import 'package:peepoop_log/presentation/widgets/widgets.dart';

void main() {
  late List<String> submitted;

  Widget field() => MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(
      body: TagInputField(label: 'Urination tags', onSubmitted: submitted.add),
    ),
  );

  String fieldText(WidgetTester tester) =>
      tester.widget<TextField>(find.byType(TextField)).controller!.text;

  setUp(() => submitted = []);

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
}
