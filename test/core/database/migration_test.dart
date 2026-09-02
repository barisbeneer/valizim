import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:valizim/core/config/app_config.dart';
import 'package:valizim/core/database/database.dart';

/// Migration coverage from the schema described in spec section 4 (v1) to the
/// shipping schema (v2).
///
/// The v1 database is built here by hand rather than exported from a previous
/// build, because there is no previous build: this is the "synthetic prior
/// schema version" the QA plan calls for. The DDL below is exactly what
/// `Migrator.createAll()` would have produced for the v1 table definitions.
const List<String> _v1Schema = <String>[
  '''
  CREATE TABLE trips (
    id TEXT NOT NULL,
    name TEXT NOT NULL,
    trip_type TEXT NOT NULL,
    start_date TEXT NULL,
    duration_days INTEGER NOT NULL,
    traveler_count INTEGER NOT NULL,
    options_json TEXT NOT NULL,
    created_at TEXT NOT NULL,
    archived INTEGER NOT NULL DEFAULT 0 CHECK (archived IN (0, 1)),
    PRIMARY KEY (id)
  )''',
  '''
  CREATE TABLE trip_items (
    id TEXT NOT NULL,
    trip_id TEXT NOT NULL REFERENCES trips (id) ON DELETE CASCADE,
    label TEXT NOT NULL,
    category TEXT NOT NULL,
    quantity INTEGER NOT NULL,
    checked INTEGER NOT NULL DEFAULT 0 CHECK (checked IN (0, 1)),
    is_essential INTEGER NOT NULL DEFAULT 0 CHECK (is_essential IN (0, 1)),
    sort_order INTEGER NOT NULL,
    PRIMARY KEY (id)
  )''',
  '''
  CREATE TABLE custom_templates (
    id TEXT NOT NULL,
    name TEXT NOT NULL,
    trip_type TEXT NULL,
    items_json TEXT NOT NULL,
    PRIMARY KEY (id)
  )''',
];

/// A v1 database with one trip, two items and one template already in it.
Database _seedV1() {
  final db = sqlite3.openInMemory();
  for (final statement in _v1Schema) {
    db.execute(statement);
  }
  db.execute('PRAGMA user_version = 1');

  db.execute(
    'INSERT INTO trips (id, name, trip_type, start_date, duration_days, '
    'traveler_count, options_json, created_at, archived) '
    "VALUES ('trip-1', 'Lisbon', 'city', '2027-04-02T00:00:00.000Z', 4, 2, "
    "'{\"v\":1}', '2027-01-05T08:30:00.000Z', 0)",
  );
  db.execute(
    'INSERT INTO trip_items (id, trip_id, label, category, quantity, checked, '
    'is_essential, sort_order) '
    "VALUES ('item-1', 'trip-1', 'Passport', 'documents', 1, 1, 1, 10)",
  );
  db.execute(
    'INSERT INTO trip_items (id, trip_id, label, category, quantity, checked, '
    'is_essential, sort_order) '
    "VALUES ('item-2', 'trip-1', 'T-shirts', 'clothing', 4, 0, 0, 1030)",
  );
  db.execute(
    'INSERT INTO custom_templates (id, name, trip_type, items_json) '
    "VALUES ('tpl-1', 'Weekender', 'city', '[]')",
  );
  return db;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a fresh install creates the current schema', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await db.customSelect('SELECT 1').get();
    final version = await db
        .customSelect('PRAGMA user_version')
        .map((QueryRow row) => row.read<int>('user_version'))
        .getSingle();
    expect(version, AppConfig.databaseSchemaVersion);
  });

  group('v1 -> v2', () {
    late Database raw;
    late AppDatabase db;

    setUp(() {
      raw = _seedV1();
      db = AppDatabase(NativeDatabase.opened(raw));
    });

    tearDown(() async => db.close());

    test('the upgrade runs and lands on the current version', () async {
      // Any query forces the connection open, which runs the migration.
      await db.customSelect('SELECT 1').get();
      expect(raw.userVersion, AppConfig.databaseSchemaVersion);
    });

    test('existing rows survive with their values intact', () async {
      final trips = await db.select(db.trips).get();
      expect(trips, hasLength(1));

      final trip = trips.single;
      expect(trip.id, 'trip-1');
      expect(trip.name, 'Lisbon');
      expect(trip.tripType, 'city');
      expect(trip.durationDays, 4);
      expect(trip.travelerCount, 2);
      expect(trip.archived, isFalse);
      expect(trip.startDate, DateTime.utc(2027, 4, 2));

      final items = await db.select(db.tripItems).get();
      expect(items, hasLength(2));
      expect(
        items.map((TripItemRow i) => i.label),
        containsAll(<String>['Passport', 'T-shirts']),
      );
      expect(
        items.firstWhere((TripItemRow i) => i.id == 'item-1').checked,
        isTrue,
        reason: 'a ticked item must stay ticked across an upgrade',
      );

      final templates = await db.select(db.customTemplates).get();
      expect(templates, hasLength(1));
      expect(templates.single.name, 'Weekender');
    });

    test('updated_at is backfilled from created_at, not from now', () async {
      final trip = await db.select(db.trips).getSingle();
      expect(trip.updatedAt, trip.createdAt);
      expect(trip.updatedAt, DateTime.utc(2027, 1, 5, 8, 30));
    });

    test('rule_key is added and defaults to null for migrated rows', () async {
      final items = await db.select(db.tripItems).get();
      for (final item in items) {
        expect(item.ruleKey, isNull);
      }
    });

    test('created_at is added to templates with a usable value', () async {
      final template = await db.select(db.customTemplates).getSingle();
      expect(template.createdAt, isNotNull);
    });

    test('the migrated database still accepts writes', () async {
      await db.into(db.tripItems).insert(
            TripItemsCompanion.insert(
              id: 'item-3',
              tripId: 'trip-1',
              label: 'Charger',
              category: 'electronics',
              quantity: 1,
              sortOrder: 4010,
              ruleKey: const Value<String?>('phone_charger'),
            ),
          );
      final items = await db.select(db.tripItems).get();
      expect(items, hasLength(3));
      expect(
        items.firstWhere((TripItemRow i) => i.id == 'item-3').ruleKey,
        'phone_charger',
      );
    });

    test('the cascade still fires after the upgrade', () async {
      await (db.delete(db.trips)..where(($TripsTable t) => t.id.equals('trip-1')))
          .go();
      expect(await db.select(db.tripItems).get(), isEmpty);
    });
  });
}
