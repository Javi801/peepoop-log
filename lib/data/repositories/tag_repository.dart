import 'dart:math';

import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../models/event_type.dart';
import '../models/tag_models.dart';

class TagRepository {
  TagRepository(this._db, {Random? random}) : _random = random ?? Random();

  final AppDatabase _db;
  final Random _random;

  static const defaultPalette = [
    '#FFE8A3',
    '#CFEEFF',
    '#D9F2C7',
    '#FFD3D3',
    '#EADBFF',
    '#FFE4EC',
  ];

  static String normalizeName(String name) => name.trim().toLowerCase();

  /// Accepts `A1B2C3` or `#A1B2C3` in any casing and returns `#A1B2C3`.
  static String normalizeHexColor(String value) {
    final match = RegExp(r'^#?([0-9a-fA-F]{6})$').firstMatch(value.trim());
    if (match == null) {
      throw ArgumentError.value(
          value, 'colorHex', 'must be a 6-digit hex color like #A1B2C3');
    }
    return '#${match[1]!.toUpperCase()}';
  }

  String randomColor() => defaultPalette[_random.nextInt(defaultPalette.length)];

  Stream<List<Tag>> watchTagsByType(EventType type) {
    final query = _db.select(_db.tags)
      ..where((t) => t.type.equalsValue(type))
      ..orderBy([(t) => OrderingTerm.asc(t.normalizedName)]);
    return query.watch();
  }

  /// Tags of [type] with their usage count across all records, ordered by
  /// usage descending. Backs the tag filter and the management screen.
  Stream<List<TagWithUsage>> watchTagsWithUsage(EventType type) {
    final usageCount = _db.recordTags.tagId.count();
    final query = _db.select(_db.tags).join([
      leftOuterJoin(
        _db.recordTags,
        _db.recordTags.tagId.equalsExp(_db.tags.id),
        useColumns: false,
      ),
    ])
      ..where(_db.tags.type.equalsValue(type))
      ..addColumns([usageCount])
      ..groupBy([_db.tags.id])
      ..orderBy([
        OrderingTerm.desc(usageCount),
        OrderingTerm.asc(_db.tags.normalizedName),
      ]);

    return query.watch().map((rows) => [
          for (final row in rows)
            TagWithUsage(
              tag: row.readTable(_db.tags),
              usageCount: row.read(usageCount) ?? 0,
            ),
        ]);
  }

  /// Reuses the existing tag matching the normalized name and [type], or
  /// creates it with a random color. Used when typing tags on a record.
  Future<Tag> ensureTag(String name, EventType type) async {
    final trimmed = _requireName(name);
    final existing = await _findByNormalizedName(normalizeName(trimmed), type);
    if (existing != null) return existing;
    return _insert(trimmed, type, randomColor());
  }

  Future<Tag> createTag({
    required String name,
    required EventType type,
    String? colorHex,
  }) async {
    final trimmed = _requireName(name);
    if (await _findByNormalizedName(normalizeName(trimmed), type) != null) {
      throw DuplicateTagException(trimmed, type);
    }
    final color =
        colorHex == null ? randomColor() : normalizeHexColor(colorHex);
    return _insert(trimmed, type, color);
  }

  /// Updates name and/or color. Changes propagate to every record using the
  /// tag because records only reference the tag id.
  Future<Tag> updateTag({required int id, String? name, String? colorHex}) async {
    final tag =
        await (_db.select(_db.tags)..where((t) => t.id.equals(id))).getSingle();

    var changes = const TagsCompanion();
    if (name != null) {
      final trimmed = _requireName(name);
      final normalized = normalizeName(trimmed);
      final existing = await _findByNormalizedName(normalized, tag.type);
      if (existing != null && existing.id != id) {
        throw DuplicateTagException(trimmed, tag.type);
      }
      changes = changes.copyWith(
        name: Value(trimmed),
        normalizedName: Value(normalized),
      );
    }
    if (colorHex != null) {
      changes = changes.copyWith(colorHex: Value(normalizeHexColor(colorHex)));
    }

    await (_db.update(_db.tags)..where((t) => t.id.equals(id))).write(changes);
    return (_db.select(_db.tags)..where((t) => t.id.equals(id))).getSingle();
  }

  /// Deletes the tags; their record associations are removed by the foreign
  /// key cascade while records themselves remain.
  Future<void> deleteTags(Iterable<int> ids) async {
    await (_db.delete(_db.tags)..where((t) => t.id.isIn(ids.toList()))).go();
  }

  String _requireName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(name, 'name', 'tag name must not be empty');
    }
    return trimmed;
  }

  Future<Tag?> _findByNormalizedName(String normalizedName, EventType type) {
    final query = _db.select(_db.tags)
      ..where(
          (t) => t.normalizedName.equals(normalizedName) & t.type.equalsValue(type));
    return query.getSingleOrNull();
  }

  Future<Tag> _insert(String name, EventType type, String colorHex) {
    return _db.into(_db.tags).insertReturning(TagsCompanion.insert(
          name: name,
          normalizedName: normalizeName(name),
          type: type,
          colorHex: colorHex,
        ));
  }
}
