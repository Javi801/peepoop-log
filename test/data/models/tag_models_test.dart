import 'package:flutter_test/flutter_test.dart';
import 'package:peepoop_log/data/db/app_database.dart';
import 'package:peepoop_log/data/models/event_type.dart';
import 'package:peepoop_log/data/models/tag_models.dart';

void main() {
  group('TagWithUsage', () {
    test('carries a tag and its usage count', () {
      const tag = Tag(
        id: 1,
        name: 'urgent',
        normalizedName: 'urgent',
        type: EventType.urination,
        colorHex: '#FFE8A3',
      );
      const usage = TagWithUsage(tag: tag, usageCount: 3);
      expect(usage.tag, tag);
      expect(usage.usageCount, 3);
    });
  });

  group('DuplicateTagException', () {
    test('describes the colliding name and event type', () {
      final exception = DuplicateTagException('urgent', EventType.defecation);
      expect(
        exception.toString(),
        'DuplicateTagException: a defecation tag named "urgent" already exists',
      );
    });
  });
}
