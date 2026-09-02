import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/config/app_config.dart';
import '../../../core/database/database.dart';
import '../domain/item_category.dart';
import '../domain/packing_generator.dart';
import '../domain/trip.dart';
import '../domain/trip_options.dart';
import '../domain/trip_type.dart';

/// Everything that touches trip storage.
///
/// The UI never sees a drift row: mapping happens here so the database schema
/// can change without rippling into widgets, and so tests can drive the
/// repository against an in-memory database.
class TripRepository {
  TripRepository(this._db, {Uuid? uuid, DateTime Function()? clock})
      : _uuid = uuid ?? const Uuid(),
        _now = clock ?? DateTime.now;

  final AppDatabase _db;
  final Uuid _uuid;
  final DateTime Function() _now;

  DateTime get _timestamp => _now().toUtc();

  // ---------------------------------------------------------------------------
  // Reads
  // ---------------------------------------------------------------------------

  /// All trips, newest activity first. Watched so every screen updates the
  /// moment anything changes.
  Stream<List<Trip>> watchTrips() {
    final query = _db.select(_db.trips)
      ..orderBy(<OrderClauseGenerator<$TripsTable>>[
        (t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc),
      ]);
    return query.watch().map(
          (List<TripRow> rows) => rows.map(_toTrip).toList(),
        );
  }

  /// The trip and its items as one stream.
  ///
  /// This is a *join*, not two queries, for a reason that is easy to get wrong:
  /// drift re-emits a watched query only when a table it reads changes. Watching
  /// `trips` and loading the items inside the callback would leave the stream
  /// silent whenever only `trip_items` changed - which is every single tick of a
  /// checkbox, the app's primary interaction. The join reads both tables, so a
  /// write to either one pushes a new value.
  Stream<TripWithItems?> watchTripWithItems(String tripId) {
    final query = _db.select(_db.trips).join(<Join<HasResultSet, Object?>>[
      leftOuterJoin(
        _db.tripItems,
        _db.tripItems.tripId.equalsExp(_db.trips.id),
      ),
    ])
      ..where(_db.trips.id.equals(tripId))
      ..orderBy(<OrderingTerm>[
        OrderingTerm(expression: _db.tripItems.sortOrder),
        OrderingTerm(expression: _db.tripItems.label),
      ]);

    return query.watch().map((List<TypedResult> rows) {
      if (rows.isEmpty) return null;
      // A left outer join on a trip with no items still yields one row, with
      // every item column null.
      final items = <TripItem>[];
      for (final row in rows) {
        final item = row.readTableOrNull(_db.tripItems);
        if (item != null) items.add(_toItem(item));
      }
      return TripWithItems(
        trip: _toTrip(rows.first.readTable(_db.trips)),
        items: items,
      );
    });
  }

  /// Item counts per trip, for the home list. One grouped query instead of one
  /// query per row.
  Stream<Map<String, ({int packed, int total})>> watchProgressByTrip() {
    final total = _db.tripItems.id.count();
    final packed = _db.tripItems.id.count(
      filter: _db.tripItems.checked.equals(true),
    );
    final query = _db.selectOnly(_db.tripItems)
      ..addColumns(<Expression<Object>>[_db.tripItems.tripId, total, packed])
      ..groupBy(<Expression<Object>>[_db.tripItems.tripId]);

    return query.watch().map((List<TypedResult> rows) {
      return <String, ({int packed, int total})>{
        for (final row in rows)
          row.read(_db.tripItems.tripId)!: (
            packed: row.read(packed) ?? 0,
            total: row.read(total) ?? 0,
          ),
      };
    });
  }

  Future<int> countTrips() async {
    final count = _db.trips.id.count();
    final query = _db.selectOnly(_db.trips)..addColumns(<Expression<Object>>[count]);
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  Stream<int> watchTripCount() {
    final count = _db.trips.id.count();
    final query = _db.selectOnly(_db.trips)..addColumns(<Expression<Object>>[count]);
    return query.watchSingle().map((TypedResult row) => row.read(count) ?? 0);
  }

  Future<TripWithItems?> getTripWithItems(String tripId) async {
    final row = await (_db.select(_db.trips)
          ..where(($TripsTable t) => t.id.equals(tripId)))
        .getSingleOrNull();
    if (row == null) return null;
    final items = await (_db.select(_db.tripItems)
          ..where(($TripItemsTable i) => i.tripId.equals(tripId))
          ..orderBy(<OrderClauseGenerator<$TripItemsTable>>[
            (i) => OrderingTerm(expression: i.sortOrder),
            (i) => OrderingTerm(expression: i.label),
          ]))
        .get();
    return TripWithItems(
      trip: _toTrip(row),
      items: items.map(_toItem).toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // Writes
  // ---------------------------------------------------------------------------

  /// Creates a trip and its generated checklist in one transaction, so a
  /// failure halfway through cannot leave an empty trip behind.
  Future<String> createTrip({
    required String name,
    required TripType tripType,
    required int durationDays,
    required int travelerCount,
    required TripSettings settings,
    required List<GeneratedItem> items,
    DateTime? startDate,
  }) async {
    final id = _uuid.v4();
    final now = _timestamp;

    await _db.transaction(() async {
      await _db.into(_db.trips).insert(
            TripsCompanion.insert(
              id: id,
              name: _clamp(name, AppConfig.maxTripNameLength),
              tripType: tripType.id,
              startDate: Value<DateTime?>(startDate),
              durationDays: durationDays,
              travelerCount: travelerCount,
              optionsJson: settings.encode(),
              createdAt: now,
              updatedAt: Value<DateTime>(now),
            ),
          );
      await _insertGenerated(id, items);
    });

    return id;
  }

  /// Applies wizard edits. When [regeneratedItems] is supplied every existing
  /// item is replaced; otherwise the checklist is left exactly as the user
  /// left it, ticks included.
  Future<void> updateTrip(
    Trip trip, {
    List<GeneratedItem>? regeneratedItems,
  }) async {
    await _db.transaction(() async {
      await (_db.update(_db.trips)
            ..where(($TripsTable t) => t.id.equals(trip.id)))
          .write(
        TripsCompanion(
          name: Value<String>(_clamp(trip.name, AppConfig.maxTripNameLength)),
          tripType: Value<String>(trip.tripType.id),
          startDate: Value<DateTime?>(trip.startDate),
          durationDays: Value<int>(trip.durationDays),
          travelerCount: Value<int>(trip.travelerCount),
          optionsJson: Value<String>(trip.settings.encode()),
          updatedAt: Value<DateTime>(_timestamp),
          archived: Value<bool>(trip.archived),
        ),
      );

      if (regeneratedItems != null) {
        await (_db.delete(_db.tripItems)
              ..where(($TripItemsTable i) => i.tripId.equals(trip.id)))
            .go();
        await _insertGenerated(trip.id, regeneratedItems);
      }
    });
  }

  Future<void> setArchived(String tripId, bool archived) async {
    await (_db.update(_db.trips)..where(($TripsTable t) => t.id.equals(tripId)))
        .write(
      TripsCompanion(
        archived: Value<bool>(archived),
        updatedAt: Value<DateTime>(_timestamp),
      ),
    );
  }

  Future<void> deleteTrip(String tripId) async {
    // Items go with it through the cascade declared on TripItems.tripId.
    await (_db.delete(_db.trips)..where(($TripsTable t) => t.id.equals(tripId)))
        .go();
  }

  /// Copies a trip and every item, with ticks cleared, under a new id.
  ///
  /// The copy owns fresh item rows - nothing is shared with the original, which
  /// is the acceptance criterion in spec section 11.
  Future<String> duplicateTrip(String tripId, String newName) async {
    final source = await getTripWithItems(tripId);
    if (source == null) {
      throw StateError('Cannot duplicate missing trip $tripId');
    }

    final newId = _uuid.v4();
    final now = _timestamp;

    await _db.transaction(() async {
      await _db.into(_db.trips).insert(
            TripsCompanion.insert(
              id: newId,
              name: _clamp(newName, AppConfig.maxTripNameLength),
              tripType: source.trip.tripType.id,
              startDate: const Value<DateTime?>(null),
              durationDays: source.trip.durationDays,
              travelerCount: source.trip.travelerCount,
              // Reminders are intentionally dropped: the copy has no date yet,
              // so carrying them over would schedule nothing and mislead.
              optionsJson: TripSettings(packing: source.trip.options).encode(),
              createdAt: now,
              updatedAt: Value<DateTime>(now),
            ),
          );

      await _db.batch((Batch batch) {
        batch.insertAll(
          _db.tripItems,
          source.items.map(
            (TripItem item) => TripItemsCompanion.insert(
              id: _uuid.v4(),
              tripId: newId,
              label: item.label,
              category: item.category.id,
              quantity: item.quantity,
              checked: const Value<bool>(false),
              isEssential: Value<bool>(item.isEssential),
              sortOrder: item.sortOrder,
              ruleKey: Value<String?>(item.ruleKey),
            ),
          ),
        );
      });
    });

    return newId;
  }

  // ---------------------------------------------------------------------------
  // Items
  // ---------------------------------------------------------------------------

  Future<void> setChecked(String itemId, bool checked) async {
    await (_db.update(_db.tripItems)
          ..where(($TripItemsTable i) => i.id.equals(itemId)))
        .write(TripItemsCompanion(checked: Value<bool>(checked)));
  }

  Future<void> uncheckAll(String tripId) async {
    await (_db.update(_db.tripItems)
          ..where(($TripItemsTable i) => i.tripId.equals(tripId)))
        .write(const TripItemsCompanion(checked: Value<bool>(false)));
  }

  Future<String> addItem({
    required String tripId,
    required String label,
    required ItemCategory category,
    required int quantity,
    bool isEssential = false,
  }) async {
    final id = _uuid.v4();
    // Append to the end of its section, leaving generated ordering intact.
    final sortOrder = await _nextSortOrder(tripId, category);
    await _db.into(_db.tripItems).insert(
          TripItemsCompanion.insert(
            id: id,
            tripId: tripId,
            label: _clamp(label, AppConfig.maxItemLabelLength),
            category: category.id,
            quantity: quantity.clamp(1, AppConfig.maxItemQuantity),
            isEssential: Value<bool>(isEssential),
            sortOrder: sortOrder,
          ),
        );
    return id;
  }

  Future<void> updateItem(TripItem item) async {
    await (_db.update(_db.tripItems)
          ..where(($TripItemsTable i) => i.id.equals(item.id)))
        .write(
      TripItemsCompanion(
        label: Value<String>(_clamp(item.label, AppConfig.maxItemLabelLength)),
        category: Value<String>(item.category.id),
        quantity: Value<int>(item.quantity.clamp(1, AppConfig.maxItemQuantity)),
        isEssential: Value<bool>(item.isEssential),
      ),
    );
  }

  Future<void> deleteItem(String itemId) async {
    await (_db.delete(_db.tripItems)
          ..where(($TripItemsTable i) => i.id.equals(itemId)))
        .go();
  }

  /// Re-inserts a deleted row verbatim, which is what powers undo.
  Future<void> restoreItem(TripItem item) async {
    await _db.into(_db.tripItems).insert(
          TripItemsCompanion.insert(
            id: item.id,
            tripId: item.tripId,
            label: item.label,
            category: item.category.id,
            quantity: item.quantity,
            checked: Value<bool>(item.checked),
            isEssential: Value<bool>(item.isEssential),
            sortOrder: item.sortOrder,
            ruleKey: Value<String?>(item.ruleKey),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<int> countItems(String tripId) async {
    final count = _db.tripItems.id.count();
    final query = _db.selectOnly(_db.tripItems)
      ..addColumns(<Expression<Object>>[count])
      ..where(_db.tripItems.tripId.equals(tripId));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  /// Wipes every table. Used by "Delete all app data".
  Future<void> deleteEverything() async {
    await _db.transaction(() async {
      await _db.delete(_db.tripItems).go();
      await _db.delete(_db.trips).go();
      await _db.delete(_db.customTemplates).go();
    });
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  Future<void> _insertGenerated(String tripId, List<GeneratedItem> items) async {
    final capped = items.length > AppConfig.maxItemsPerTrip
        ? items.sublist(0, AppConfig.maxItemsPerTrip)
        : items;
    await _db.batch((Batch batch) {
      batch.insertAll(
        _db.tripItems,
        capped.map(
          (GeneratedItem item) => TripItemsCompanion.insert(
            id: _uuid.v4(),
            tripId: tripId,
            label: _clamp(item.label, AppConfig.maxItemLabelLength),
            category: item.category.id,
            quantity: item.quantity,
            isEssential: Value<bool>(item.isEssential),
            sortOrder: item.sortOrder,
            ruleKey: Value<String?>(item.ruleKey),
          ),
        ),
      );
    });
  }

  Future<int> _nextSortOrder(String tripId, ItemCategory category) async {
    final maxSort = _db.tripItems.sortOrder.max();
    final query = _db.selectOnly(_db.tripItems)
      ..addColumns(<Expression<Object>>[maxSort])
      ..where(
        _db.tripItems.tripId.equals(tripId) &
            _db.tripItems.category.equals(category.id),
      );
    final row = await query.getSingle();
    final current = row.read(maxSort);
    final sectionFloor = category.order * 1000;
    if (current == null) return sectionFloor + 900;
    return (current + 1).clamp(sectionFloor, sectionFloor + 999);
  }

  static String _clamp(String value, int max) {
    final trimmed = value.trim();
    return trimmed.length <= max ? trimmed : trimmed.substring(0, max);
  }

  Trip _toTrip(TripRow row) => Trip(
        id: row.id,
        name: row.name,
        tripType: TripType.fromId(row.tripType),
        startDate: row.startDate,
        durationDays: row.durationDays,
        travelerCount: row.travelerCount,
        settings: TripSettings.decode(row.optionsJson),
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        archived: row.archived,
      );

  TripItem _toItem(TripItemRow row) => TripItem(
        id: row.id,
        tripId: row.tripId,
        label: row.label,
        category: ItemCategory.fromId(row.category),
        quantity: row.quantity,
        checked: row.checked,
        isEssential: row.isEssential,
        sortOrder: row.sortOrder,
        ruleKey: row.ruleKey,
      );
}
