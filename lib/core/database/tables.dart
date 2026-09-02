import 'package:drift/drift.dart';

import '../config/app_config.dart';

/// Constant SQL default for NOT NULL columns introduced by a migration.
/// Never surfaces to a user: every write supplies a real timestamp.
final Constant<DateTime> schemaEpoch = Constant<DateTime>(DateTime.utc(1970));

/// A saved trip.
///
/// Timestamps are always written in UTC (see `AppDatabase`), and [startDate]
/// holds a calendar date as UTC midnight rather than an instant, so a device
/// crossing a DST boundary or a time zone never shifts a trip to the wrong day.
@DataClassName('TripRow')
class Trips extends Table {
  TextColumn get id => text()();

  TextColumn get name => text().withLength(min: 1, max: AppConfig.maxTripNameLength)();

  /// `TripType.id`. Stored as text so an unknown future value degrades to
  /// `general` instead of throwing.
  TextColumn get tripType => text().withLength(max: 32)();

  /// Calendar date of departure, as UTC midnight. Null when the user has not
  /// set one, in which case no reminder can be scheduled.
  DateTimeColumn get startDate => dateTime().nullable()();

  IntColumn get durationDays => integer()();

  IntColumn get travelerCount => integer()();

  /// `TripSettings.encode()`.
  TextColumn get optionsJson => text()();

  DateTimeColumn get createdAt => dateTime()();

  /// Added in schema v2.
  ///
  /// The default is a *constant* sentinel, not `CURRENT_TIMESTAMP`: SQLite
  /// rejects a non-constant default in `ALTER TABLE ADD COLUMN`, and declaring
  /// it here rather than only in the migration keeps a freshly created database
  /// byte-identical to a migrated one. Every insert supplies a real value, and
  /// the migration backfills existing rows, so the sentinel is never read.
  DateTimeColumn get updatedAt => dateTime().withDefault(schemaEpoch)();

  /// Soft delete. Archived trips stay reusable and keep counting toward the
  /// free tier.
  BoolColumn get archived => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// One checklist row belonging to a trip.
@DataClassName('TripItemRow')
class TripItems extends Table {
  TextColumn get id => text()();

  TextColumn get tripId =>
      text().references(Trips, #id, onDelete: KeyAction.cascade)();

  /// Display text as generated or typed. For generated rows this is the English
  /// fallback; [ruleKey] takes priority when resolving the label.
  TextColumn get label =>
      text().withLength(min: 1, max: AppConfig.maxItemLabelLength)();

  /// `ItemCategory.id`.
  TextColumn get category => text().withLength(max: 32)();

  IntColumn get quantity => integer()();

  BoolColumn get checked => boolean().withDefault(const Constant(false))();

  BoolColumn get isEssential => boolean().withDefault(const Constant(false))();

  IntColumn get sortOrder => integer()();

  /// Added in schema v2. Non-null for generated rows, null for user-added ones.
  /// Lets the UI re-localize built-in labels when the device language changes
  /// without rewriting stored data.
  TextColumn get ruleKey => text().withLength(max: 64).nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// A user-saved template (Pro).
@DataClassName('CustomTemplateRow')
class CustomTemplates extends Table {
  TextColumn get id => text()();

  TextColumn get name =>
      text().withLength(min: 1, max: AppConfig.maxTemplateNameLength)();

  /// Optional `TripType.id` this template is associated with.
  TextColumn get tripType => text().withLength(max: 32).nullable()();

  /// JSON array of template items.
  TextColumn get itemsJson => text()();

  /// Added in schema v2. See the note on `Trips.updatedAt` for why this
  /// carries a constant SQL default.
  DateTimeColumn get createdAt => dateTime().withDefault(schemaEpoch)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
