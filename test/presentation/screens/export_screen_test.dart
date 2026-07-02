import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peepoop_log/data/db/app_database.dart';
import 'package:peepoop_log/data/models/event_type.dart';
import 'package:peepoop_log/data/models/record_models.dart';
import 'package:peepoop_log/data/repositories/record_repository.dart';
import 'package:peepoop_log/data/repositories/tag_repository.dart';
import 'package:peepoop_log/presentation/scope/app_scope.dart';
import 'package:peepoop_log/presentation/screens/export/export_screen.dart';
import 'package:peepoop_log/presentation/theme/theme.dart';

void main() {
  late AppDatabase db;
  late RecordRepository records;
  late TagRepository tags;

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase(NativeDatabase.memory());
    records = RecordRepository(db);
    tags = TagRepository(db);
  });

  tearDown(() => db.close());

  Widget app({required Future<void> Function(String) shareCsv}) => AppScope(
        recordRepository: records,
        tagRepository: tags,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: ExportScreen(shareCsv: shareCsv),
        ),
      );

  testWidgets('shares the CSV built from all records', (tester) async {
    final urgent = await tags.createTag(
      name: 'urgent',
      type: EventType.urination,
      colorHex: '#FFD3D3',
    );
    await records.createRecord(RecordDraft(
      occurredAt: DateTime(2026, 6, 22, 8, 30),
      hasUrination: true,
      hasDefecation: true,
      urinationDescription: 'Slight urgency.',
      urinationTagIds: [urgent.id],
    ));

    String? shared;
    await tester.pumpWidget(app(shareCsv: (csv) async => shared = csv));

    await tester.tap(find.text('Export CSV'));
    await tester.pumpAndSettle();

    expect(shared, '''
occurred_at,type,description,tags
2026-06-22T08:30:00,urination,"Slight urgency.","urgent"
2026-06-22T08:30:00,defecation,"",""''');
  });

  testWidgets('shares only the header when there is no data', (tester) async {
    String? shared;
    await tester.pumpWidget(app(shareCsv: (csv) async => shared = csv));

    await tester.tap(find.text('Export CSV'));
    await tester.pumpAndSettle();

    expect(shared, 'occurred_at,type,description,tags');
  });
}
