import 'package:flutter_test/flutter_test.dart';
import 'package:peepoop_log/presentation/app.dart';

void main() {
  testWidgets('app builds and shows the placeholder screen', (tester) async {
    await tester.pumpWidget(const PeepoopLogApp());

    expect(find.text('PeePoop Log'), findsOneWidget);
  });
}
