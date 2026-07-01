import '../db/app_database.dart';
import 'event_type.dart';

class TagWithUsage {
  const TagWithUsage({required this.tag, required this.usageCount});

  final Tag tag;
  final int usageCount;
}

/// Thrown when creating or renaming a tag would collide with an existing tag
/// of the same event type and normalized name.
class DuplicateTagException implements Exception {
  DuplicateTagException(this.name, this.type);

  final String name;
  final EventType type;

  @override
  String toString() =>
      'DuplicateTagException: a ${type.name} tag named "$name" already exists';
}
