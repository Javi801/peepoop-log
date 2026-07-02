import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peepoop_log/data/db/app_database.dart';
import 'package:peepoop_log/data/models/event_type.dart';
import 'package:peepoop_log/presentation/theme/theme.dart';
import 'package:peepoop_log/presentation/widgets/widgets.dart';

Tag tag(int id, String name, String colorHex) => Tag(
  id: id,
  name: name,
  normalizedName: name.toLowerCase(),
  type: EventType.urination,
  colorHex: colorHex,
);

Widget wrap(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  home: Scaffold(body: child),
);

Color chipColor(WidgetTester tester, String name) {
  final container = tester.widget<Container>(
    find.ancestor(of: find.text(name), matching: find.byType(Container)).first,
  );
  return (container.decoration! as BoxDecoration).color!;
}

void main() {
  testWidgets('renders one chip per tag with its stored color', (tester) async {
    await tester.pumpWidget(
      wrap(
        TagChips(
          tags: [tag(1, 'urgent', '#FFD3D3'), tag(2, 'normal flow', '#CFEEFF')],
        ),
      ),
    );

    expect(find.byType(TagChip), findsNWidgets(2));
    expect(chipColor(tester, 'urgent'), const Color(0xFFFFD3D3));
    expect(chipColor(tester, 'normal flow'), const Color(0xFFCFEEFF));
    expect(find.text('×'), findsNothing);
  });

  testWidgets('invalid stored color falls back to the theme tag color', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(TagChips(tags: [tag(1, 'legacy', 'tag-yellow')])),
    );

    expect(chipColor(tester, 'legacy'), AppColors.pastel.tagFallback);
  });

  testWidgets('remove button reports the tapped tag', (tester) async {
    Tag? removed;
    final tags = [tag(1, 'urgent', '#FFD3D3'), tag(2, 'pain', '#EADBFF')];

    await tester.pumpWidget(
      wrap(TagChips(tags: tags, onRemove: (t) => removed = t)),
    );

    expect(find.text('×'), findsNWidgets(2));

    await tester.tap(
      find.descendant(
        of: find.widgetWithText(TagChip, 'pain'),
        matching: find.text('×'),
      ),
    );

    expect(removed, tags[1]);
  });
}
