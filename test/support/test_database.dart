import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:valizim/core/database/database.dart';

/// A fresh in-memory database at the current schema version.
AppDatabase openTestDatabase() => AppDatabase(NativeDatabase.memory());

/// Wraps an executor that has already been seeded with an older schema, so
/// migrations can be exercised.
AppDatabase openTestDatabaseOn(QueryExecutor executor) => AppDatabase(executor);
