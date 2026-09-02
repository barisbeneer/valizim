import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/config/app_config.dart';
import '../../../core/database/database.dart';
import '../../trips/domain/trip_type.dart';
import '../domain/custom_template.dart';

/// Storage for user-saved templates.
class TemplateRepository {
  TemplateRepository(this._db, {Uuid? uuid, DateTime Function()? clock})
      : _uuid = uuid ?? const Uuid(),
        _now = clock ?? DateTime.now;

  final AppDatabase _db;
  final Uuid _uuid;
  final DateTime Function() _now;

  Stream<List<CustomTemplate>> watchTemplates() {
    final query = _db.select(_db.customTemplates)
      ..orderBy(<OrderClauseGenerator<$CustomTemplatesTable>>[
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
      ]);
    return query.watch().map(
          (List<CustomTemplateRow> rows) => rows.map(_toTemplate).toList(),
        );
  }

  Future<CustomTemplate?> getTemplate(String id) async {
    final row = await (_db.select(_db.customTemplates)
          ..where(($CustomTemplatesTable t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _toTemplate(row);
  }

  Future<String> saveTemplate({
    required String name,
    required List<TemplateItem> items,
    TripType? tripType,
  }) async {
    final id = _uuid.v4();
    final trimmed = name.trim();
    await _db.into(_db.customTemplates).insert(
          CustomTemplatesCompanion.insert(
            id: id,
            name: trimmed.length > AppConfig.maxTemplateNameLength
                ? trimmed.substring(0, AppConfig.maxTemplateNameLength)
                : trimmed,
            tripType: Value<String?>(tripType?.id),
            itemsJson: CustomTemplate.encodeItems(items),
            createdAt: Value<DateTime>(_now().toUtc()),
          ),
        );
    return id;
  }

  Future<void> deleteTemplate(String id) async {
    await (_db.delete(_db.customTemplates)
          ..where(($CustomTemplatesTable t) => t.id.equals(id)))
        .go();
  }

  Future<int> countTemplates() async {
    final count = _db.customTemplates.id.count();
    final query = _db.selectOnly(_db.customTemplates)
      ..addColumns(<Expression<Object>>[count]);
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  CustomTemplate _toTemplate(CustomTemplateRow row) => CustomTemplate(
        id: row.id,
        name: row.name,
        tripType: row.tripType == null ? null : TripType.fromId(row.tripType),
        items: CustomTemplate.decodeItems(row.itemsJson),
        createdAt: row.createdAt,
      );
}
