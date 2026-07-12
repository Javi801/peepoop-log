import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peepoop_log/data/db/app_database.dart';
import 'package:peepoop_log/data/models/event_type.dart';
import 'package:peepoop_log/data/models/record_models.dart';
import 'package:peepoop_log/presentation/screens/history/record_details_sheet.dart';
import 'package:peepoop_log/presentation/theme/theme.dart';
import 'package:peepoop_log/presentation/widgets/widgets.dart';

import '../../support/widget_cleanup.dart';

Tag _tag(int id, String name, {EventType type = EventType.urination}) => Tag(
  id: id,
  name: name,
  normalizedName: name.toLowerCase(),
  type: type,
  colorHex: '#FFE8A3',
);

RecordRow _record({
  required DateTime occurredAt,
  bool urination = false,
  bool defecation = false,
  String? urinationDescription,
  String? defecationDescription,
}) => RecordRow(
  id: 1,
  occurredAt: occurredAt,
  hasUrination: urination,
  hasDefecation: defecation,
  urinationDescription: urinationDescription,
  defecationDescription: defecationDescription,
);

/// Holds the value the sheet popped with, so tests can assert it after the
/// modal closes.
class _ActionSink {
  RecordDetailAction? value;
  bool popped = false;
}

void main() {
  // Presents the sheet through its real modal and records the popped action
  // into [sink].
  Future<void> pumpSheet(
    WidgetTester tester,
    RecordWithTags entry,
    _ActionSink sink,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () async {
                  sink.value = await showAppCenteredModal<RecordDetailAction>(
                    context: context,
                    builder: (_) => RecordDetailsSheet(entry: entry),
                  );
                  sink.popped = true;
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('renders the mixed type label, time, tags and descriptions', (
    tester,
  ) async {
    final entry = RecordWithTags(
      record: _record(
        occurredAt: DateTime(2026, 6, 22, 8, 30),
        urination: true,
        defecation: true,
        urinationDescription: 'Slight urgency.',
        defecationDescription: 'All normal.',
      ),
      tagsByType: {
        EventType.urination: [_tag(1, 'urgent')],
        EventType.defecation: [_tag(2, 'soft', type: EventType.defecation)],
      },
    );

    await pumpSheet(tester, entry, _ActionSink());

    expect(find.text('Urination + Defecation'), findsOneWidget);
    expect(find.text('Jun 22, 2026 · 08:30'), findsOneWidget);
    expect(find.text('urgent'), findsOneWidget);
    expect(find.text('soft'), findsOneWidget);
    expect(find.text('Slight urgency.'), findsOneWidget);
    expect(find.text('All normal.'), findsOneWidget);

    await unmountWidgetTree(tester);
  });

  testWidgets('omits sections for event types the record lacks', (
    tester,
  ) async {
    final entry = RecordWithTags(
      record: _record(
        occurredAt: DateTime(2026, 6, 22, 8, 30),
        urination: true,
        urinationDescription: 'Only pee.',
      ),
      tagsByType: const {},
    );

    await pumpSheet(tester, entry, _ActionSink());

    // "Urination" appears as both the record title and its section heading.
    expect(find.text('Urination'), findsWidgets);
    expect(find.text('Only pee.'), findsOneWidget);
    expect(find.text('Defecation'), findsNothing);

    await unmountWidgetTree(tester);
  });

  testWidgets('pops with the edit action', (tester) async {
    final sink = _ActionSink();
    final entry = RecordWithTags(
      record: _record(occurredAt: DateTime(2026, 6, 22, 8, 30), urination: true),
      tagsByType: const {},
    );

    await pumpSheet(tester, entry, sink);
    await tester.tap(find.text('Edit record'));
    await tester.pumpAndSettle();

    expect(find.byType(RecordDetailsSheet), findsNothing);
    expect(sink.value, RecordDetailAction.edit);

    await unmountWidgetTree(tester);
  });

  testWidgets('pops with the delete action', (tester) async {
    final sink = _ActionSink();
    final entry = RecordWithTags(
      record: _record(
        occurredAt: DateTime(2026, 6, 22, 8, 30),
        defecation: true,
      ),
      tagsByType: const {},
    );

    await pumpSheet(tester, entry, sink);
    await tester.tap(find.text('Delete record'));
    await tester.pumpAndSettle();

    expect(find.byType(RecordDetailsSheet), findsNothing);
    expect(sink.value, RecordDetailAction.delete);

    await unmountWidgetTree(tester);
  });

  testWidgets('pops with no action when closed', (tester) async {
    final sink = _ActionSink();
    final entry = RecordWithTags(
      record: _record(occurredAt: DateTime(2026, 6, 22, 8, 30), urination: true),
      tagsByType: const {},
    );

    await pumpSheet(tester, entry, sink);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();

    expect(sink.popped, isTrue);
    expect(sink.value, isNull);

    await unmountWidgetTree(tester);
  });
}
