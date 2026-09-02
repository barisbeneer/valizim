import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../config/app_config.dart';
import 'tables.dart';

part 'database.g.dart';

/// The app's only database.
///
/// Schema history:
///  * **v1** - the shape described in spec section 4.
///  * **v2** - adds `trips.updated_at`, `trip_items.rule_key` and
///    `custom_templates.created_at`.
///
/// The v1 -> v2 upgrade is exercised by `test/core/database/migration_test.dart`
/// against a hand-built v1 database, which is the "synthetic prior schema
/// version" the QA plan requires. The strategy only ever adds columns: it never
/// drops or recreates a table, so no upgrade can silently discard user data.
@DriftDatabase(tables: [Trips, TripItems, CustomTemplates])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => AppConfig.databaseSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.addColumn(trips, trips.updatedAt);
            await m.addColumn(tripItems, tripItems.ruleKey);
            await m.addColumn(customTemplates, customTemplates.createdAt);

            // A migrated trip should report its own creation time as its last
            // update, not the moment the upgrade happened to run.
            await customStatement('UPDATE trips SET updated_at = created_at');

            // v1 recorded nothing about when a template was made. Migration
            // time is the only honest answer, and it keeps pre-existing
            // templates at the top of the newest-first list.
            await customStatement(
              'UPDATE custom_templates SET created_at = ?',
              <Object?>[DateTime.now().toUtc().toIso8601String()],
            );
          }
        },
        beforeOpen: (OpeningDetails details) async {
          // Cascade deletes only work when this is on, and SQLite resets it to
          // off for every new connection.
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  static QueryExecutor _openConnection() =>
      driftDatabase(name: AppConfig.databaseFileName);
}
