import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> unmountWidgetTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
}

void unmountWidgetTreeAfterTest(WidgetTester tester) {
  addTearDown(() => unmountWidgetTree(tester));
}
